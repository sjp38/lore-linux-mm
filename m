Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
References: <Pine.LNX.4.21.0006131700490.5590-100000@inspiron.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Tue, 13 Jun 2000 17:08:19 +0200 (CEST)"
Date: 13 Jun 2000 19:08:59 +0200
Message-ID: <yttsnuh8q50.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

andrea> You have more kswapd load for sure due the strict zone approch. It maybe
andrea> not noticeable but it's real. You boot, you allocate all the normal zone
andrea> in cache doing some fs load, then you start netscape and you allocate the
andrea> lower 16mbyte of RAM into it, then doing some other thing you trigger
andrea> kswapd to run because also the lower 16mbyte are been allocated now. Then
andrea> netscape exists and release all the lower 16m but kswapd keeps shrinking
andrea> the normal zone (this shouldn't happen and it wouldn't happen with
andrea> classzone design).

Linus argument is that you should never get _all_ the normal zone
allocated and nothing of the DMA zone.  You need to balance the
allocations module the .free_pages, .low_pages etc of each zone....

The problem with the actual algorithm is when we have allocated all
the pages in one zone and all the pages in the LRU list are from a
different zone.  We need to do some swaping and not write to disk
_all_ the pages of the rest of the zones (that happend to be in the
LRU list).  See the comments from riel and Roger Larson in this list.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
