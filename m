Date: Wed, 3 May 2000 02:38:47 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <Pine.LNX.4.21.0005030008150.1677-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0005030228300.3498-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 May 2000, Andrea Arcangeli wrote:

>Making swap cache dirty will take a swap entry locked indefinitely (well,

I thought some more at it and I think the best thing to do is to reduce
the ability of the swap entry bit. The swap entry bit should keep to be
effective only as far as the page is an anonymous page not shared and it
should never be set on a swap cache page.

Once the swap-entry-page is mapped by more than one process we don't know
anymore which was the original task that was swapped out in such previous
location (if the parent or the child) so during cow we don't know if the
new page or the old page should get the entry bit. I'm not going to
discover that ;).

So what I propose is to set the entry bit in the swapin path only if we
take over the swap cache, and to clear it in do_wp_page during COW and in
free_page_and_swap_cache unconditionally (we know if it's set the page was
not shared). We should also set it while taking over the swap cache in the
cow after removing the page from the swap cache (in the case the page
isn't shared).

This way the swap-entry logic will take care only of the simple case where
a big task gets swapped out then a little part gets swapped in and we'll
try to swapout it again in the same place. That looks sane feature to me.

Note that dirty swap cache during COW have the same problem to choose if
the swap entry should be inherit by the old page or by the new page (so
it's not going to be a solution for that). My conclusion is that dropping
the persistence on the swap during cow looks rasonable action.

Comments?

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
