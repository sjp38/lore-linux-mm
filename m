Date: Tue, 19 Aug 2008 02:11:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: dirty page tracking race fix
Message-Id: <20080819021155.3d92b193.akpm@linux-foundation.org>
In-Reply-To: <20080818053821.GA3011@wotan.suse.de>
References: <20080818053821.GA3011@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Aug 2008 07:38:21 +0200 Nick Piggin <npiggin@suse.de> wrote:

> There is a race with dirty page accounting where a page may not properly
> be accounted for.
> 
> clear_page_dirty_for_io() calls page_mkclean; then TestClearPageDirty.
> 
> page_mkclean walks the rmaps for that page, and for each one it cleans and
> write protects the pte if it was dirty. It uses page_check_address to find the
> pte. That function has a shortcut to avoid the ptl if the pte is not
> present. Unfortunately, the pte can be switched to not-present then back to
> present by other code while holding the page table lock -- this should not
> be a signal for page_mkclean to ignore that pte, because it may be dirty.
> 
> For example, powerpc64's set_pte_at will clear a previously present pte before
> setting it to the desired value. There may also be other code in core mm or
> in arch which do similar things.
> 
> The consequence of the bug is loss of data integrity due to msync, and loss
> of dirty page accounting accuracy. XIP's __xip_unmap could easily also be
> unreliable (depending on the exact XIP locking scheme), which can lead to data
> corruption.
> 
> Fix this by having an option to always take ptl to check the pte in
> page_check_address.
> 
> It's possible to retain this optimization for page_referenced and
> try_to_unmap.

Is it also possible to retain it for

/**
 * page_mapped_in_vma - check whether a page is really mapped in a VMA
 * @page: the page to test
 * @vma: the VMA to test
 *
 * Returns 1 if the page is mapped into the page tables of the VMA, 0
 * if the page is not mapped into the page tables of this VMA.  Only
 * valid for normal file or anonymous VMAs.
 */
static int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
{
	unsigned long address;
	pte_t *pte;
	spinlock_t *ptl;

	address = vma_address(page, vma);
	if (address == -EFAULT)		/* out of vma range */
		return 0;
	pte = page_check_address(page, vma->vm_mm, address, &ptl);
	if (!pte)			/* the page is not in this mm */
		return 0;
	pte_unmap_unlock(pte, ptl);

	return 1;
}

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
