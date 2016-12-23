Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D63E280274
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 04:17:31 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id l2so13870173wml.5
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 01:17:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j133si4074146wma.62.2016.12.23.01.17.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 01:17:29 -0800 (PST)
Date: Fri, 23 Dec 2016 10:17:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: pmd dirty emulation in page fault handler
Message-ID: <20161223091725.GA23117@dhcp22.suse.cz>
References: <1482364101-16204-1-git-send-email-minchan@kernel.org>
 <20161222081713.GA32480@node.shutemov.name>
 <20161222145203.GA18970@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161222145203.GA18970@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jason Evans <je@fb.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "[4.5+]" <stable@vger.kernel.org>, Andreas Schwab <schwab@suse.de>

On Thu 22-12-16 23:52:03, Minchan Kim wrote:
[...]
> >From b3ec95c0df91ad113525968a4a6b53030fd0b48d Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Thu, 22 Dec 2016 23:43:49 +0900
> Subject: [PATCH v2] mm: pmd dirty emulation in page fault handler
> 
> Andreas reported [1] made a test in jemalloc hang in THP mode in arm64.
> http://lkml.kernel.org/r/mvmmvfy37g1.fsf@hawking.suse.de
> 
> The problem is page fault handler supports only accessed flag emulation
> for THP page of SW-dirty/accessed architecture.
> 
> This patch enables dirty-bit emulation for those architectures.
> Without it, MADV_FREE makes application hang by repeated fault forever.

The changelog is rather terse and considering the issue is rather subtle
and it aims the stable tree I think it could see more information. How
do we end up looping in the page fault and why the dirty pmd stops it.
Could you update the changelog to be more verbose, please? I am still
digesting this patch but I believe it is correct fwiw...

Thanks!

> [1] b8d3c4c3009d, mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called
> 
> Cc: Jason Evans <je@fb.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: linux-arch@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: <stable@vger.kernel.org> [4.5+]
> Fixes: b8d3c4c3009d ("mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called")
> Reported-by: Andreas Schwab <schwab@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> * from v1
>   * Remove __handle_mm_fault part - Kirill
> 
>  mm/huge_memory.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 10eedbf..29ec8a4 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -883,15 +883,17 @@ void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
>  {
>  	pmd_t entry;
>  	unsigned long haddr;
> +	bool write = vmf->flags & FAULT_FLAG_WRITE;
>  
>  	vmf->ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
>  		goto unlock;
>  
>  	entry = pmd_mkyoung(orig_pmd);
> +	if (write)
> +		entry = pmd_mkdirty(entry);
>  	haddr = vmf->address & HPAGE_PMD_MASK;
> -	if (pmdp_set_access_flags(vmf->vma, haddr, vmf->pmd, entry,
> -				vmf->flags & FAULT_FLAG_WRITE))
> +	if (pmdp_set_access_flags(vmf->vma, haddr, vmf->pmd, entry, write))
>  		update_mmu_cache_pmd(vmf->vma, vmf->address, vmf->pmd);
>  
>  unlock:
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
