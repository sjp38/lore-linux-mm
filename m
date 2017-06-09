Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC4A66B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 17:23:52 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 3so19723185otz.1
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 14:23:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w184sor722311oif.14.2017.06.09.14.23.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Jun 2017 14:23:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170607204859.13104-1-ross.zwisler@linux.intel.com>
References: <20170607204859.13104-1-ross.zwisler@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 9 Jun 2017 14:23:51 -0700
Message-ID: <CAA9_cmcPsyZCB7-pd9djL0+bLamfL49SJVgkyoJ22G6tgOxyww@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: add vm_insert_mixed_mkwrite()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, ext4 hackers <linux-ext4@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Wed, Jun 7, 2017 at 1:48 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> To be able to use the common 4k zero page in DAX we need to have our PTE
> fault path look more like our PMD fault path where a PTE entry can be
> marked as dirty and writeable as it is first inserted, rather than waiting
> for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
>
> Right now we can rely on having a dax_pfn_mkwrite() call because we can
> distinguish between these two cases in do_wp_page():
>
>         case 1: 4k zero page => writable DAX storage
>         case 2: read-only DAX storage => writeable DAX storage
>
> This distinction is made by via vm_normal_page().  vm_normal_page() returns
> false for the common 4k zero page, though, just as it does for DAX ptes.
> Instead of special casing the DAX + 4k zero page case, we will simplify our
> DAX PTE page fault sequence so that it matches our DAX PMD sequence, and
> get rid of dax_pfn_mkwrite() completely.
>
> This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
> and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
> will do the work that was previously done by wp_page_reuse() as part of the
> dax_pfn_mkwrite() call path.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/mm.h |  9 +++++++--
>  mm/memory.c        | 21 ++++++++++++++-------
>  2 files changed, 21 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b892e95..11e323a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2294,10 +2294,15 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>                         unsigned long pfn);
>  int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
>                         unsigned long pfn, pgprot_t pgprot);
> -int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
> -                       pfn_t pfn);
> +int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
> +                       pfn_t pfn, bool mkwrite);

Are there any other planned public users of vm_insert_mixed_mkwrite()
that would pass false? I think not.

>  int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
>
> +static inline int vm_insert_mixed(struct vm_area_struct *vma,
> +               unsigned long addr, pfn_t pfn)
> +{
> +       return vm_insert_mixed_mkwrite(vma, addr, pfn, false);
> +}

...in other words instead of making the distinction of
vm_insert_mixed_mkwrite() and vm_insert_mixed() with extra flag
argument just move the distinction into mm/memory.c directly.

So, the prototype remains the same as vm_insert_mixed()

int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long
addr, pfn_t pfn);

...and only static insert_pfn(...) needs to change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
