Date: Wed, 18 Jun 2008 20:01:48 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <200806190329.30622.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0806181944080.4968@blonde.site>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008, Nick Piggin wrote:
> On Thursday 19 June 2008 02:41, Robin Holt wrote:
> > I am running into a problem where I think a call to get_user_pages(...,
> > write=1, force=1,...) is returning a readable pte and a page ref count

I'm hoping Robin doesn't really need force=1 - can't you do what you
need with force=0, Robin? force=1 is weird and really only for ptrace
I think.  And assuming that Robin meant to say "readonly pte" above.

> > of 2.  I have not yet trapped the event, but I think I see one place
> > where this _may_ be happening.
> >
> > The case I am seeing is under heavy memory pressure.
> >
> > I think the first pass at follow_page has failed and we called
> > __handle_mm_fault().  At the time in __handle_mm_fault where the page table
> > is unlocked, there is a writable pte in the processes page table, and a
> > struct page with a reference count of 1.  ret will have VM_FAULT_WRITE
> > set so the get_user_pages code will clear FOLL_WRITE from foll_flags.
> >
> > Between the time above and the second attempt at follow_page, the
> > page gets swapped out.  The second attempt at follow_page, now without
> > FOLL_WRITE (and FOLL_GET is set) will result in a read-only pte with a
> > reference count of 2.
> 
> There would not be a writeable pte in the page table, otherwise
> VM_FAULT_WRITE should not get returned. But it can be returned via
> other paths...

In his scenario, there wasn't a writeable pte originally, the
first call to handle_pte_fault instantiates the writeable pte
and returns with VM_FAULT_WRITE set.

> 
> However, assuming it was returned, then mmap_sem is still held, so
> the vma should not get changed from a writeable to a readonly one,
> so I can't see the problem you're describin with that sequence.

The vma doesn't get changed, but the pte just instantiated writably
above, gets swapped out before the next follow_page, then brought
back in by the second call to handle_pte_fault.  But this is with
FOLL_WRITE cleared, so it behaves as a read fault, and puts just
a readonly pte.

> 
> Swap pages, for one, could return with VM_FAULT_WRITE, then
> subsequently have its page swapped out, then set up a readonly pte
> due to the __handle_mm_fault with write access cleared. *I think*.

Yes.

> But although that feels a bit unclean, I don't think it would cause
> a problem because the previous VM_FAULT_WRITE (while under mmap_sem)
> ensures our swap page should still be valid to write into via get
> user pages (and a subsequent write access should cause do_wp_page to
> go through the proper reuse logic and now COW).

I think perhaps Robin is wanting to write into the page both from the
kernel (hence the get_user_pages) and from userspace: but finding that
the attempt to write from userspace breaks COW again (because gup
raised the page count and it's a readonly pte), so they end up
writing into different pages.  We know that COW didn't need to
be broken a second time, but do_wp_page doesn't know that.

> > Any subsequent write fault by the process will 
> > result in a COW break and the process pointing at a different page than
> > the get_user_pages() returned page.
> >
> > Is this sequence plausible or am I missing something key?
> >
> > If this sequence is plausible, I need to know how to either work around
> > this problem or if it should really be fixed in the kernel.
> 
> I'd be interested to know the situation that leads to this problem.
> If possible a test case would be ideal.

Might it help if do_wp_page returned VM_FAULT_WRITE (perhaps renamed)
only in the case where maybe_mkwrite decided not to mkwrite i.e. the
weird write=1,force=1 on readonly vma case?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
