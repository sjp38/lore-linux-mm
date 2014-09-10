Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 495596B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 19:36:31 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so7499312pad.14
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:36:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xx3si29733033pab.116.2014.09.10.16.36.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 16:36:30 -0700 (PDT)
Date: Wed, 10 Sep 2014 16:36:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: softdirty: unmapped addresses between VMAs are
 clean
Message-Id: <20140910163628.66302ac77f7835ba5df2f49c@linux-foundation.org>
In-Reply-To: <1410391486-9106-1-git-send-email-pfeiner@google.com>
References: <1410391486-9106-1-git-send-email-pfeiner@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Feiner <pfeiner@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, 10 Sep 2014 16:24:46 -0700 Peter Feiner <pfeiner@google.com> wrote:

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
> ...
>
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
>
> ...
>
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
> +		unsigned long vm_start = end;

Did you really mean to do that?  If so, perhaps a little comment to
explain how it works?

> +		unsigned long vm_end = end;
> +		unsigned long vm_flags = 0;
> +
> +		if (vma) {
> +			/*
> +			 * We can't possibly be in a hugetlb VMA. In general,
> +			 * for a mm_walk with a pmd_entry and a hugetlb_entry,
> +			 * the pmd_entry can only be called on addresses in a
> +			 * hugetlb if the walk starts in a non-hugetlb VMA and
> +			 * spans a hugepage VMA. Since pagemap_read walks are
> +			 * PMD-sized and PMD-aligned, this will never be true.
> +			 */
> +			BUG_ON(is_vm_hugetlb_page(vma));
> +			vm_start = vma->vm_start;
> +			vm_end = min(end, vma->vm_end);
> +			vm_flags = vma->vm_flags;
> +		}
> +
> +		/* Addresses before the VMA. */
> +		for (; addr < vm_start; addr += PAGE_SIZE) {
> +			pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
> +
> +			err = add_to_pagemap(addr, &pme, pm);
> +			if (err)
> +				return err;
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
