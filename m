Date: Wed, 18 Jun 2008 11:41:58 -0500
From: Robin Holt <holt@sgi.com>
Subject: Can get_user_pages( ,write=1, force=1, ) result in a read-only pte
	and _count=2?
Message-ID: <20080618164158.GC10062@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am running into a problem where I think a call to get_user_pages(...,
write=1, force=1,...) is returning a readable pte and a page ref count
of 2.  I have not yet trapped the event, but I think I see one place
where this _may_ be happening.

In the sles10 kernel source:
int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
		unsigned long start, int len, int write, int force,
		struct page **pages, struct vm_area_struct **vmas)
{
...
retry:
			cond_resched();
			while (!(page = follow_page(vma, start, foll_flags))) {
				int ret;
				ret = __handle_mm_fault(mm, vma, start,
						foll_flags & FOLL_WRITE);
...
				/*
				 * The VM_FAULT_WRITE bit tells us that do_wp_page has
				 * broken COW when necessary, even if maybe_mkwrite
				 * decided not to set pte_write. We can thus safely do
				 * subsequent page lookups as if they were reads.
				 */
				if (ret & VM_FAULT_WRITE)
					foll_flags &= ~FOLL_WRITE;

				cond_resched();
			}

The case I am seeing is under heavy memory pressure.

I think the first pass at follow_page has failed and we called
__handle_mm_fault().  At the time in __handle_mm_fault where the page table
is unlocked, there is a writable pte in the processes page table, and a
struct page with a reference count of 1.  ret will have VM_FAULT_WRITE
set so the get_user_pages code will clear FOLL_WRITE from foll_flags.

Between the time above and the second attempt at follow_page, the
page gets swapped out.  The second attempt at follow_page, now without
FOLL_WRITE (and FOLL_GET is set) will result in a read-only pte with a
reference count of 2.  Any subsequent write fault by the process will
result in a COW break and the process pointing at a different page than
the get_user_pages() returned page.

Is this sequence plausible or am I missing something key?

If this sequence is plausible, I need to know how to either work around
this problem or if it should really be fixed in the kernel.

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
