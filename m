Date: Thu, 10 Oct 2002 12:40:08 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Meaning of the dirty bit
In-Reply-To: <3DA5306C.7B63584@scs.ch>
Message-ID: <Pine.LNX.4.44.0210101209140.1510-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: Stephen Tweedie <sct@redhat.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Oct 2002, Martin Maletinsky wrote:
> 
> While studying the follow_page() function (the version of the function
> that is in place since 2.4.4, i.e. with the write argument), I noticed,
> that for an address that > should be written to (i.e. write != 0), the
> function checks not only the writeable flag (with pte_write()), but also
> the dirty flag (with pte_dirty()) of the page > containing this address.
> From what I thought to understand from general paging theory, the dirty
> flag of a page is set, when its content in physical memory differs from
> its backing on the permanent storage system (file or swap space). Based
> on this understanding I do not understand why it is necessary to check
> the dirty flag, in order to ensure that a page is writable
> - what am I missing here?

Good question (and I don't see the answer in Dharmender's replies).
I expect Stephen can give the definitive answer, but here's my guess.

follow_page() was introduced for kiobufs, so despite its general name,
it's doing what map_user_kiobuf() needed (or thought it needed).

Originally (pre-2.4.4), as you've noticed, there was no write argument
to follow_page, and map_user_kiobuf made one call to handle_mm_fault
per page.  Experience with races under memory pressure will have shown
that to be inadequate, it needed to loop until it could hold down the
page, with the writable bit in the pte guaranteeing it good to write to.

But why dirty too, you ask?  I think, because writing to page via kiobuf
happens directly, not via pte, so the pte dirty bit would not be set
that way; but if it's not set, then the modification to the page may
be lost later.  Hence map_user_kiobuf used handle_mm_fault to set
that dirty bit too, and used follow_page to check that it is set.

Except that's racy too, and so mark_dirty_kiobuf() was added to
SetPageDirty on the pages after kio done, before unmapping the kiobuf.
mark_dirty_kiobuf appeared in the main kernel tree at the same time
as the pte_dirty test in follow_page, but I'm guessing the pte_dirty
test was an earlier failed attempt to solve the problems fixed by
mark_dirty_kiobuf, which got left in place (and also helped a bit
if kiobuf users weren't updated to call mark_dirty_kiobuf).

Apologies in advance if my guesses are wild.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
