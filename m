From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only pte and _count=2?
Date: Thu, 19 Jun 2008 03:29:30 +1000
References: <20080618164158.GC10062@sgi.com>
In-Reply-To: <20080618164158.GC10062@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806190329.30622.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 19 June 2008 02:41, Robin Holt wrote:
> I am running into a problem where I think a call to get_user_pages(...,
> write=1, force=1,...) is returning a readable pte and a page ref count
> of 2.  I have not yet trapped the event, but I think I see one place
> where this _may_ be happening.
>
> In the sles10 kernel source:
> int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> 		unsigned long start, int len, int write, int force,
> 		struct page **pages, struct vm_area_struct **vmas)
> {
> ...
> retry:
> 			cond_resched();
> 			while (!(page = follow_page(vma, start, foll_flags))) {
> 				int ret;
> 				ret = __handle_mm_fault(mm, vma, start,
> 						foll_flags & FOLL_WRITE);
> ...
> 				/*
> 				 * The VM_FAULT_WRITE bit tells us that do_wp_page has
> 				 * broken COW when necessary, even if maybe_mkwrite
> 				 * decided not to set pte_write. We can thus safely do
> 				 * subsequent page lookups as if they were reads.
> 				 */
> 				if (ret & VM_FAULT_WRITE)
> 					foll_flags &= ~FOLL_WRITE;
>
> 				cond_resched();
> 			}
>
> The case I am seeing is under heavy memory pressure.
>
> I think the first pass at follow_page has failed and we called
> __handle_mm_fault().  At the time in __handle_mm_fault where the page table
> is unlocked, there is a writable pte in the processes page table, and a
> struct page with a reference count of 1.  ret will have VM_FAULT_WRITE
> set so the get_user_pages code will clear FOLL_WRITE from foll_flags.
>
> Between the time above and the second attempt at follow_page, the
> page gets swapped out.  The second attempt at follow_page, now without
> FOLL_WRITE (and FOLL_GET is set) will result in a read-only pte with a
> reference count of 2.

There would not be a writeable pte in the page table, otherwise
VM_FAULT_WRITE should not get returned. But it can be returned via
other paths...

However, assuming it was returned, then mmap_sem is still held, so
the vma should not get changed from a writeable to a readonly one,
so I can't see the problem you're describin with that sequence.

Swap pages, for one, could return with VM_FAULT_WRITE, then
subsequently have its page swapped out, then set up a readonly pte
due to the __handle_mm_fault with write access cleared. *I think*.
But although that feels a bit unclean, I don't think it would cause
a problem because the previous VM_FAULT_WRITE (while under mmap_sem)
ensures our swap page should still be valid to write into via get
user pages (and a subsequent write access should cause do_wp_page to
go through the proper reuse logic and now COW).


> Any subsequent write fault by the process will 
> result in a COW break and the process pointing at a different page than
> the get_user_pages() returned page.
>
> Is this sequence plausible or am I missing something key?
>
> If this sequence is plausible, I need to know how to either work around
> this problem or if it should really be fixed in the kernel.

I'd be interested to know the situation that leads to this problem.
If possible a test case would be ideal.

But, with force=1, it is possible to create private "COW" copies of pages
that have readonly ptes in the process page table, and that the process
never has permission to write into (these are "Linus pages").

This situation should not cause the process to be able to write into the
address and cause a further COW, but in the case of shared vmas, it will
cause the page to become disconnected from the file...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
