Subject: Re: [PATCH -v7 2/2] Update ctime and mtime for memory-mapped files
References: <12009619562023-git-send-email-salikhmetov@gmail.com>
	<12009619584168-git-send-email-salikhmetov@gmail.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 22 Jan 2008 05:39:43 +0100
In-Reply-To: <12009619584168-git-send-email-salikhmetov@gmail.com>
Message-ID: <p737ii2o4mo.fsf@crumb.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Anton Salikhmetov <salikhmetov@gmail.com> writes:

You should probably put your design document somewhere in Documentation
with a patch.

> + * Scan the PTEs for pages belonging to the VMA and mark them read-only.
> + * It will force a pagefault on the next write access.
> + */
> +static void vma_wrprotect(struct vm_area_struct *vma)
> +{
> +	unsigned long addr;
> +
> +	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
> +		spinlock_t *ptl;
> +		pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
> +		pud_t *pud = pud_offset(pgd, addr);
> +		pmd_t *pmd = pmd_offset(pud, addr);
> +		pte_t *pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);

This means on i386 with highmem ptes you will map/flush tlb/unmap each
PTE individually. You will do 512 times as much work as really needed
per PTE leaf page.

The performance critical address space walkers use a different design
pattern that avoids this.

> +		if (pte_dirty(*pte) && pte_write(*pte)) {
> +			pte_t entry = ptep_clear_flush(vma, addr, pte);

Flushing TLBs unbatched can also be very expensive because if the MM is
shared by several CPUs you'll have a inter-processor interrupt for 
each iteration. They are quite costly even on smaller systems.

It would be better if you did a single flush_tlb_range() at the end.
This means on x86 this will currently always do a full flush, but that's
still better than really slowing down in the heavily multithreaded case.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
