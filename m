Date: Thu, 19 Oct 2000 13:16:37 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: oopses in test10-pre4 (was Re: [RFC] atomic pte updates and pae
 changes, take 3)
In-Reply-To: <Pine.LNX.4.21.0010132002440.25522-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.10.10010191301270.1350-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Ben,
 you added these two BUG() conditions in your atomic pte patch:

> diff -ur v2.4.0-test10-pre2/mm/vmscan.c work-10-2/mm/vmscan.c
> --- v2.4.0-test10-pre2/mm/vmscan.c	Fri Oct 13 17:18:37 2000
> +++ work-10-2/mm/vmscan.c	Fri Oct 13 17:19:47 2000
> @@ -99,6 +98,10 @@
>  	if (PageSwapCache(page)) {
>  		entry.val = page->index;
>  		swap_duplicate(entry);
> +		if (pte_dirty(pte))
> +			BUG();
> +		if (pte_write(pte))
> +			BUG();
>  		set_pte(page_table, swp_entry_to_pte(entry));
>  drop_pte:
>  		UnlockPage(page);
> @@ -109,6 +112,13 @@

and people are getting them left and right when they start swapping.

As far as I can tell, the thing you test for is not actually a bug at all.
The pte may be dirty, but that's ok - the swap cache page is obviously
up-to-date, as it's actually physically the very same page.

I think you overlooked the fact that SHM mappings use the page cache, and
it's ok if such pages are dirty and writable - they will get written out
by the shm_swap() logic once there are no mappings active any more.

I like the test per se, because I think it's correct for the "normal"
case of a private page, but I really think those two BUG()'s are not bugs
at all in general, and we should just remove the two tests.

Comments? Anything I've overlooked?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
