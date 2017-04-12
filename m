Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6AAA6B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 09:33:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 6so2961637wra.23
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 06:33:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c185si8081625wmf.168.2017.04.12.06.33.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 06:33:36 -0700 (PDT)
Subject: Re: [PATCH 2/4] thp: fix MADV_DONTNEED vs. numa balancing race
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-3-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f105f6a5-bb5e-9480-6b2e-d2d15f631af9@suse.cz>
Date: Wed, 12 Apr 2017 15:33:35 +0200
MIME-Version: 1.0
In-Reply-To: <20170302151034.27829-3-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/02/2017 04:10 PM, Kirill A. Shutemov wrote:
> In case prot_numa, we are under down_read(mmap_sem). It's critical
> to not clear pmd intermittently to avoid race with MADV_DONTNEED
> which is also under down_read(mmap_sem):
> 
> 	CPU0:				CPU1:
> 				change_huge_pmd(prot_numa=1)
> 				 pmdp_huge_get_and_clear_notify()
> madvise_dontneed()
>  zap_pmd_range()
>   pmd_trans_huge(*pmd) == 0 (without ptl)
>   // skip the pmd
> 				 set_pmd_at();
> 				 // pmd is re-established
> 
> The race makes MADV_DONTNEED miss the huge pmd and don't clear it
> which may break userspace.
> 
> Found by code analysis, never saw triggered.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c | 34 +++++++++++++++++++++++++++++++++-
>  1 file changed, 33 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e7ce73b2b208..bb2b3646bd78 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1744,7 +1744,39 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	if (prot_numa && pmd_protnone(*pmd))
>  		goto unlock;
>  
> -	entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
> +	/*
> +	 * In case prot_numa, we are under down_read(mmap_sem). It's critical
> +	 * to not clear pmd intermittently to avoid race with MADV_DONTNEED
> +	 * which is also under down_read(mmap_sem):
> +	 *
> +	 *	CPU0:				CPU1:
> +	 *				change_huge_pmd(prot_numa=1)
> +	 *				 pmdp_huge_get_and_clear_notify()
> +	 * madvise_dontneed()
> +	 *  zap_pmd_range()
> +	 *   pmd_trans_huge(*pmd) == 0 (without ptl)
> +	 *   // skip the pmd
> +	 *				 set_pmd_at();
> +	 *				 // pmd is re-established
> +	 *
> +	 * The race makes MADV_DONTNEED miss the huge pmd and don't clear it
> +	 * which may break userspace.
> +	 *
> +	 * pmdp_invalidate() is required to make sure we don't miss
> +	 * dirty/young flags set by hardware.
> +	 */
> +	entry = *pmd;
> +	pmdp_invalidate(vma, addr, pmd);
> +
> +	/*
> +	 * Recover dirty/young flags.  It relies on pmdp_invalidate to not
> +	 * corrupt them.
> +	 */

pmdp_invalidate() does:

        pmd_t entry = *pmdp;
        set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));

so it's not atomic and if CPU sets dirty or accessed in the middle of
this, they will be lost?

But I don't see how the other invalidate caller
__split_huge_pmd_locked() deals with this either. Andrea, any idea?

Vlastimil

> +	if (pmd_dirty(*pmd))
> +		entry = pmd_mkdirty(entry);
> +	if (pmd_young(*pmd))
> +		entry = pmd_mkyoung(entry);
> +
>  	entry = pmd_modify(entry, newprot);
>  	if (preserve_write)
>  		entry = pmd_mk_savedwrite(entry);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
