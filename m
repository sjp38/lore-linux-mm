Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A394F6B0361
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 18:06:12 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w63so357635918oiw.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 15:06:12 -0800 (PST)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id s5si11989548oif.104.2016.12.20.15.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 15:06:10 -0800 (PST)
Received: by mail-oi0-x236.google.com with SMTP id w63so193683163oiw.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 15:06:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1482272586-21177-3-git-send-email-ross.zwisler@linux.intel.com>
References: <1482272586-21177-1-git-send-email-ross.zwisler@linux.intel.com> <1482272586-21177-3-git-send-email-ross.zwisler@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 20 Dec 2016 15:06:09 -0800
Message-ID: <CAPcyv4iiqDkqS1xT1Vor3Cb6vO2Ms_q9cbW5r-=Nw+a9hYDRKw@mail.gmail.com>
Subject: Re: [PATCH 2/2] dax: wrprotect pmd_t in dax_mapping_entry_mkclean
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Tue, Dec 20, 2016 at 2:23 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> Currently dax_mapping_entry_mkclean() fails to clean and write protect the
> pmd_t of a DAX PMD entry during an *sync operation.  This can result in
> data loss in the following sequence:
>
> 1) mmap write to DAX PMD, dirtying PMD radix tree entry and making the
>    pmd_t dirty and writeable
> 2) fsync, flushing out PMD data and cleaning the radix tree entry. We
>    currently fail to mark the pmd_t as clean and write protected.
> 3) more mmap writes to the PMD.  These don't cause any page faults since
>    the pmd_t is dirty and writeable.  The radix tree entry remains clean.
> 4) fsync, which fails to flush the dirty PMD data because the radix tree
>    entry was clean.
> 5) crash - dirty data that should have been fsync'd as part of 4) could
>    still have been in the processor cache, and is lost.
>
> Fix this by marking the pmd_t clean and write protected in
> dax_mapping_entry_mkclean(), which is called as part of the fsync
> operation 2).  This will cause the writes in step 3) above to generate page
> faults where we'll re-dirty the PMD radix tree entry, resulting in flushes
> in the fsync that happens in step 4).
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Fixes: 4b4bb46d00b3 ("dax: clear dirty entry tags on cache flush")
> ---
>  fs/dax.c           | 51 ++++++++++++++++++++++++++++++++++++---------------
>  include/linux/mm.h |  2 --
>  mm/memory.c        |  4 ++--
>  3 files changed, 38 insertions(+), 19 deletions(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index 5c74f60..ddcddfe 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -691,8 +691,8 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
>                                       pgoff_t index, unsigned long pfn)
>  {
>         struct vm_area_struct *vma;
> -       pte_t *ptep;
> -       pte_t pte;
> +       pte_t pte, *ptep = NULL;
> +       pmd_t *pmdp = NULL;
>         spinlock_t *ptl;
>         bool changed;
>
> @@ -707,21 +707,42 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
>
>                 address = pgoff_address(index, vma);
>                 changed = false;
> -               if (follow_pte(vma->vm_mm, address, &ptep, &ptl))
> +               if (follow_pte_pmd(vma->vm_mm, address, &ptep, &pmdp, &ptl))
>                         continue;
> -               if (pfn != pte_pfn(*ptep))
> -                       goto unlock;
> -               if (!pte_dirty(*ptep) && !pte_write(*ptep))
> -                       goto unlock;
>
> -               flush_cache_page(vma, address, pfn);
> -               pte = ptep_clear_flush(vma, address, ptep);
> -               pte = pte_wrprotect(pte);
> -               pte = pte_mkclean(pte);
> -               set_pte_at(vma->vm_mm, address, ptep, pte);
> -               changed = true;
> -unlock:
> -               pte_unmap_unlock(ptep, ptl);
> +               if (pmdp) {
> +#ifdef CONFIG_FS_DAX_PMD
> +                       pmd_t pmd;
> +
> +                       if (pfn != pmd_pfn(*pmdp))
> +                               goto unlock_pmd;
> +                       if (!pmd_dirty(*pmdp) && !pmd_write(*pmdp))
> +                               goto unlock_pmd;
> +
> +                       flush_cache_page(vma, address, pfn);
> +                       pmd = pmdp_huge_clear_flush(vma, address, pmdp);
> +                       pmd = pmd_wrprotect(pmd);
> +                       pmd = pmd_mkclean(pmd);
> +                       set_pmd_at(vma->vm_mm, address, pmdp, pmd);
> +                       changed = true;
> +unlock_pmd:
> +                       spin_unlock(ptl);
> +#endif

Can we please kill this ifdef?

I know we've had problems with ARCH=um builds in the past with
undefined pmd helpers, but to me that simply means we now need to
extend the FS_DAX blacklist to include UML

diff --git a/fs/Kconfig b/fs/Kconfig
index c2a377cdda2b..661931fb0ce0 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -37,7 +37,7 @@ source "fs/f2fs/Kconfig"
 config FS_DAX
        bool "Direct Access (DAX) support"
        depends on MMU
-       depends on !(ARM || MIPS || SPARC)
+       depends on !(ARM || MIPS || SPARC || UML)
        help
          Direct Access (DAX) can be used on memory-backed block devices.
          If the block device supports DAX and the filesystem supports DAX,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
