Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA09873
	for <linux-mm@kvack.org>; Sun, 30 May 1999 19:30:27 -0400
Date: Mon, 31 May 1999 01:12:43 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <14159.18916.728327.550606@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.05.9905310111460.7712-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 29 May 1999, Stephen C. Tweedie wrote:

>It should be cheap, yes, but it will require a fundamental change in the
>VM: currently, all swap cache is readonly.  No exceptions.  To keep the
>allocation persistent, even over write()s to otherwise unshared pages
>(and we need to do to sustain good performance), we need to allow dirty
>pages in the swap cache.  The current PG_Dirty work impacts on this.

I am just rewriting swapped-in pages to their previous location on swap to
avoid swap fragmentation. No need to have dirty pages into the swap cache
to handle that. We just have the information cached in the
page-map->offset field. We only need to know when it make sense to know if
we should use it or not. To handle that I simply added a PG_swap_entry
bitflag set at swapin time and cleared after swapout to the old entry or
at free_page_and_swap_cache() time. The thing runs like a charm (the
swapin performances definitely improves a lot).

        ftp://e-mind.com/pub/andrea/kernel/2.3.3_andrea9.bz2

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
