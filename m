Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBBA6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 16:29:39 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id d15so81741834qke.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 13:29:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c41si3941673qtc.80.2017.02.07.13.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 13:29:38 -0800 (PST)
Date: Tue, 7 Feb 2017 22:29:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mprotect: drop overprotective lock_pte_protection()
Message-ID: <20170207212935.GL25530@redhat.com>
References: <20170207143347.123871-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207143347.123871-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 07, 2017 at 05:33:47PM +0300, Kirill A. Shutemov wrote:
> lock_pte_protection() uses pmd_lock() to make sure that we have stable
> PTE page table before walking pte range.
> 
> That's not necessary. We only need to make sure that PTE page table is
> established. It cannot vanish under us as long as we hold mmap_sem at
> least for read.
> 
> And we already have helper for that -- pmd_trans_unstable().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/mprotect.c | 43 ++++++++++++-------------------------------
>  1 file changed, 12 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index f9c07f54dd62..e919e4613eab 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -33,34 +33,6 @@
>  
>  #include "internal.h"
>  
> -/*
> - * For a prot_numa update we only hold mmap_sem for read so there is a
> - * potential race with faulting where a pmd was temporarily none. This
> - * function checks for a transhuge pmd under the appropriate lock. It
> - * returns a pte if it was successfully locked or NULL if it raced with
> - * a transhuge insertion.
> - */
> -static pte_t *lock_pte_protection(struct vm_area_struct *vma, pmd_t *pmd,
> -			unsigned long addr, int prot_numa, spinlock_t **ptl)
> -{
> -	pte_t *pte;
> -	spinlock_t *pmdl;
> -
> -	/* !prot_numa is protected by mmap_sem held for write */
> -	if (!prot_numa)
> -		return pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
> -
> -	pmdl = pmd_lock(vma->vm_mm, pmd);
> -	if (unlikely(pmd_trans_huge(*pmd) || pmd_none(*pmd))) {
> -		spin_unlock(pmdl);
> -		return NULL;
> -	}
> -
> -	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
> -	spin_unlock(pmdl);
> -	return pte;
> -}
> -
>  static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  		unsigned long addr, unsigned long end, pgprot_t newprot,
>  		int dirty_accountable, int prot_numa)
> @@ -71,7 +43,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	unsigned long pages = 0;
>  	int target_node = NUMA_NO_NODE;
>  
> -	pte = lock_pte_protection(vma, pmd, addr, prot_numa, &ptl);
> +	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	if (!pte)

I cleaned it up too but I moved the pmd_trans_unstable in the caller
above instead of the callee, otherwise it's the same.

>  
> @@ -177,8 +149,6 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
>  			if (next - addr != HPAGE_PMD_SIZE) {
>  				__split_huge_pmd(vma, pmd, addr, false, NULL);
> -				if (pmd_trans_unstable(pmd))
> -					continue;

Agree it can be removed too, but I only removed lock_pte_protection in
my version.

If you prefer this version to be merged so we don't have to cleanup
the above superfluous check in a incremental patch that's fine of
course, otherwise at runtime they're equivalent as far as I can
tell. The version in -mm is here.

https://git.kernel.org/cgit/linux/kernel/git/mhocko/mm.git/commit/?h=auto-latest&id=d84ff4e4985f397ca4ecfe7ec029c45c6f2b9906

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
