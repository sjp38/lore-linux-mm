Date: Thu, 10 Oct 2002 04:55:18 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Meaning of the dirty bit
Message-ID: <20021010115518.GX12432@holomorphy.com>
References: <3DA5306C.7B63584@scs.ch> <Pine.LNX.4.44.0210101209140.1510-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210101209140.1510-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Martin Maletinsky <maletinsky@scs.ch>, Stephen Tweedie <sct@redhat.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 10, 2002 at 12:40:08PM +0100, Hugh Dickins wrote:
> Originally (pre-2.4.4), as you've noticed, there was no write argument
> to follow_page, and map_user_kiobuf made one call to handle_mm_fault
> per page.  Experience with races under memory pressure will have shown
> that to be inadequate, it needed to loop until it could hold down the
> page, with the writable bit in the pte guaranteeing it good to write to.

Could you explain what race occurred?


On Thu, Oct 10, 2002 at 12:40:08PM +0100, Hugh Dickins wrote:
> But why dirty too, you ask?  I think, because writing to page via kiobuf
> happens directly, not via pte, so the pte dirty bit would not be set
> that way; but if it's not set, then the modification to the page may
> be lost later.  Hence map_user_kiobuf used handle_mm_fault to set
> that dirty bit too, and used follow_page to check that it is set.

Some of the mechanics of how the PTE dirty bit relate to the software
notion of a page being dirty are escaping me here. How does follow_page()
enter the equation? The PTE's of other processes cannot be resolved this
way so it does not seem clear to me at all that follow_page() taking an
extra argument can actually get something useful done here.


On Thu, Oct 10, 2002 at 12:40:08PM +0100, Hugh Dickins wrote:
> Except that's racy too, and so mark_dirty_kiobuf() was added to
> SetPageDirty on the pages after kio done, before unmapping the kiobuf.
> mark_dirty_kiobuf appeared in the main kernel tree at the same time
> as the pte_dirty test in follow_page, but I'm guessing the pte_dirty
> test was an earlier failed attempt to solve the problems fixed by
> mark_dirty_kiobuf, which got left in place (and also helped a bit
> if kiobuf users weren't updated to call mark_dirty_kiobuf).
> Apologies in advance if my guesses are wild.

Hrm, I'm going to have to dig up a tree with kiobuf stuff in it, I've
largely ignored that path for various reasons.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
