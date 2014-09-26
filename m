Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 730656B005C
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 17:24:19 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id x13so7501083qcv.9
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 14:24:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g9si7233498qgf.49.2014.09.26.14.24.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 14:24:18 -0700 (PDT)
Date: Fri, 26 Sep 2014 16:33:26 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2] mm: softdirty: unmapped addresses between VMAs are
 clean
Message-ID: <20140926203326.GA12422@nhori.bos.redhat.com>
References: <1410391486-9106-1-git-send-email-pfeiner@google.com>
 <1410806438-7496-1-git-send-email-pfeiner@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410806438-7496-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Feiner <pfeiner@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Sep 15, 2014 at 11:40:38AM -0700, Peter Feiner wrote:
> If a /proc/pid/pagemap read spans a [VMA, an unmapped region, then a
> VM_SOFTDIRTY VMA], the virtual pages in the unmapped region are reported
> as softdirty. Here's a program to demonstrate the bug:
> 
> int main() {
> 	const uint64_t PAGEMAP_SOFTDIRTY = 1ul << 55;
> 	uint64_t pme[3];
> 	int fd = open("/proc/self/pagemap", O_RDONLY);;
> 	char *m = mmap(NULL, 3 * getpagesize(), PROT_READ,
> 	               MAP_ANONYMOUS | MAP_SHARED, -1, 0);
> 	munmap(m + getpagesize(), getpagesize());
> 	pread(fd, pme, 24, (unsigned long) m / getpagesize() * 8);
> 	assert(pme[0] & PAGEMAP_SOFTDIRTY);    /* passes */
> 	assert(!(pme[1] & PAGEMAP_SOFTDIRTY)); /* fails */
> 	assert(pme[2] & PAGEMAP_SOFTDIRTY);    /* passes */
> 	return 0;
> }
> 
> (Note that all pages in new VMAs are softdirty until cleared).
> 
> Tested:
> 	Used the program given above. I'm going to include this code in
> 	a selftest in the future.
> 
> Signed-off-by: Peter Feiner <pfeiner@google.com>

I triggered the BUG_ON(is_vm_hugetlb_page(vma)) introduced by this patch,
when I simply read /proc/pid/pagemap of the process using hugetlb.
This BUG_ON looks right itself, but find_vma() can find vmas beyond
the pmd boundary, so checking the overrun is necessary.

Could you test and merge the following change?

---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 26 Sep 2014 15:57:39 -0400
Subject: [PATCH] pagemap: prevent pagemap_pte_range() from overrunning

When the vm_end address of the last vma just before vma(VM_HUGETLB)
is not aligned to PMD boundary, the while loop in pagemap_pte_range()
gets vma(VM_HUGETLB) and triggers BUG_ON(is_vm_hugetlb_page(vma)).
This patch fixes it by checking the overrun.

Fixes: 62c98294410d ("mm: softdirty: unmapped addresses between VMAs are clean")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 5674675adeae..f2b15da32a7f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1083,7 +1083,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 				return err;
 		}
 
-		if (!vma)
+		if (!vma || vma->vm_start >= end)
 			break;
 		/*
 		 * We can't possibly be in a hugetlb VMA. In general,
-- 
1.9.3

Thanks,
Naoya Horiguchi


> ---
> 
> v1 -> v2:
> 	Restructured patch to make logic more clear.
> ---
>  fs/proc/task_mmu.c | 61 +++++++++++++++++++++++++++++++++++-------------------
>  1 file changed, 40 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index dfc791c..2abf37b 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1020,7 +1020,6 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	spinlock_t *ptl;
>  	pte_t *pte;
>  	int err = 0;
> -	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
>  
>  	/* find the first VMA at or above 'addr' */
>  	vma = find_vma(walk->mm, addr);
> @@ -1034,6 +1033,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  
>  		for (; addr != end; addr += PAGE_SIZE) {
>  			unsigned long offset;
> +			pagemap_entry_t pme;
>  
>  			offset = (addr & ~PAGEMAP_WALK_MASK) >>
>  					PAGE_SHIFT;
> @@ -1048,32 +1048,51 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  
>  	if (pmd_trans_unstable(pmd))
>  		return 0;
> -	for (; addr != end; addr += PAGE_SIZE) {
> -		int flags2;
> -
> -		/* check to see if we've left 'vma' behind
> -		 * and need a new, higher one */
> -		if (vma && (addr >= vma->vm_end)) {
> -			vma = find_vma(walk->mm, addr);
> -			if (vma && (vma->vm_flags & VM_SOFTDIRTY))
> -				flags2 = __PM_SOFT_DIRTY;
> -			else
> -				flags2 = 0;
> -			pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, flags2));
> +
> +	while (1) {
> +		/* End of address space hole, which we mark as non-present. */
> +		unsigned long hole_end;
> +
> +		if (vma)
> +			hole_end = min(end, vma->vm_start);
> +		else
> +			hole_end = end;
> +
> +		for (; addr < hole_end; addr += PAGE_SIZE) {
> +			pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
> +
> +			err = add_to_pagemap(addr, &pme, pm);
> +			if (err)
> +				return err;
>  		}
>  
> -		/* check that 'vma' actually covers this address,
> -		 * and that it isn't a huge page vma */
> -		if (vma && (vma->vm_start <= addr) &&
> -		    !is_vm_hugetlb_page(vma)) {
> +		if (!vma)
> +			break;
> +		/*
> +		 * We can't possibly be in a hugetlb VMA. In general,
> +		 * for a mm_walk with a pmd_entry and a hugetlb_entry,
> +		 * the pmd_entry can only be called on addresses in a
> +		 * hugetlb if the walk starts in a non-hugetlb VMA and
> +		 * spans a hugepage VMA. Since pagemap_read walks are
> +		 * PMD-sized and PMD-aligned, this will never be true.
> +		 */
> +		BUG_ON(is_vm_hugetlb_page(vma));
> +
> +		/* Addresses in the VMA. */
> +		for (; addr < min(end, vma->vm_end); addr += PAGE_SIZE) {
> +			pagemap_entry_t pme;
>  			pte = pte_offset_map(pmd, addr);
>  			pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
> -			/* unmap before userspace copy */
>  			pte_unmap(pte);
> +			err = add_to_pagemap(addr, &pme, pm);
> +			if (err)
> +				return err;
>  		}
> -		err = add_to_pagemap(addr, &pme, pm);
> -		if (err)
> -			return err;
> +
> +		if (addr == end)
> +			break;
> +
> +		vma = find_vma(walk->mm, addr);
>  	}
>  
>  	cond_resched();
> -- 
> 2.1.0.rc2.206.gedb03e5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
