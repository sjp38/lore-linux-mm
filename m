Date: Thu, 23 Aug 2007 06:11:37 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru
Message-ID: <20070823041137.GH18788@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Martin Bligh <mbligh@mbligh.org>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

About this patch... I hope it doesn't get merged without good reason...

Our current reclaim scheme may not always make great choices, but one
thing I really like about it is that it can generally always reclaim file
backed pages at O(1) WRT the size of RAM. Once you start giving things
multiple trips around lists, you can reach the situation where you need
to scan all or a huge number of pages before reclaiming any. If you have
long periods of not touching reclaim, it could be very likely that most
memory is on the active list with referenced set.

One thing you could potentially do is have mark_page_accessed always
put active pages back to the head of the LRU, but that is probably going
to take way too much locking... I'm not completely happy with our random
page reclaim policy either, but I console myself in this case by thinking
of PG_referenced as giving the page a slightly better chance before
leaving the inactive list.

FWIW, this is one of the big reasons not to go with the scheme where
you rip out mark_page_accessed completely and do all aging simply based
on referenced or second chance bits. It's conceptually a lot simpler
and more consistent, and it behaves really well for use-once type pages
too, but in practice it can cause big pauses when you initially start
reclaim (and I expect this patch could be subject to the same, even if
there were fewer cases that triggered such behaviour).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
