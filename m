Date: Thu, 10 Oct 2002 14:40:32 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Meaning of the dirty bit
In-Reply-To: <20021010115518.GX12432@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0210101403120.1756-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Martin Maletinsky <maletinsky@scs.ch>, Stephen Tweedie <sct@redhat.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Oct 2002, William Lee Irwin III wrote:
> On Thu, Oct 10, 2002 at 12:40:08PM +0100, Hugh Dickins wrote:
> > Originally (pre-2.4.4), as you've noticed, there was no write argument
> > to follow_page, and map_user_kiobuf made one call to handle_mm_fault
> > per page.  Experience with races under memory pressure will have shown
> > that to be inadequate, it needed to loop until it could hold down the
> > page, with the writable bit in the pte guaranteeing it good to write to.
> 
> Could you explain what race occurred?

In the 2.4.3 version, handle_mm_fault would fault the page in, writable
and dirty, if not already; but try_to_swap_out might intervene, just
before map_user_kiobuf immediately after takes the page_table_lock
and does follow_page, clearing the page table entry just verified.

And there might even be a read fault coming in too (from another thread),
bringing back the page table entry but without its dirty bit.  Er, no,
scrub that: we have down_write on mmap_sem, keeping out such a fault.

(But I wasn't involved, just noticed when the looping was added and
was unsurprised since it had looked unsafe to me before.  Perhaps the
race which actually occurred was something else I've not thought of.)

> On Thu, Oct 10, 2002 at 12:40:08PM +0100, Hugh Dickins wrote:
> > But why dirty too, you ask?  I think, because writing to page via kiobuf
> > happens directly, not via pte, so the pte dirty bit would not be set
> > that way; but if it's not set, then the modification to the page may
> > be lost later.  Hence map_user_kiobuf used handle_mm_fault to set
> > that dirty bit too, and used follow_page to check that it is set.
> 
> Some of the mechanics of how the PTE dirty bit relate to the software
> notion of a page being dirty are escaping me here. How does follow_page()
> enter the equation? The PTE's of other processes cannot be resolved this
> way so it does not seem clear to me at all that follow_page() taking an
> extra argument can actually get something useful done here.

I don't entirely understand you here.  follow_page verifies the pte,
while holding page_table_lock, prior to bumping page reference count:
page_table_lock necessary to keep try_to_swap_out away, and of course
it cannot be held over call to handle_mm_fault.

The extra arg to follow_page does get something useful done, in the
2.4.4 tree where it's introduced along with the loop, since in that
loop the follow_page is done before the handle_mm_fault - so if the
writable dirty(?) pte already exists, no need to call handle_mm_fault
at all.  get_user_pages still works this way.

> On Thu, Oct 10, 2002 at 12:40:08PM +0100, Hugh Dickins wrote:
> > Except that's racy too, and so mark_dirty_kiobuf() was added to
> > SetPageDirty on the pages after kio done, before unmapping the kiobuf.
> > mark_dirty_kiobuf appeared in the main kernel tree at the same time
> > as the pte_dirty test in follow_page, but I'm guessing the pte_dirty
> > test was an earlier failed attempt to solve the problems fixed by
> > mark_dirty_kiobuf, which got left in place (and also helped a bit
> > if kiobuf users weren't updated to call mark_dirty_kiobuf).
> > Apologies in advance if my guesses are wild.
> 
> Hrm, I'm going to have to dig up a tree with kiobuf stuff in it, I've
> largely ignored that path for various reasons.

I believe akpm hopes to do away with kiobufs shortly; but I assume
the get_user_pages inheritor of this code will remain, and it is a
different kind of path which can easily catch us out.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
