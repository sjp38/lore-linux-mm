Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA31722
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 11:26:09 -0500
Date: Mon, 25 Jan 1999 16:25:41 GMT
Message-Id: <199901251625.QAA04452@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990123161758.12138B-100000@penguin.transmeta.com>
References: <m104CMO-0007U1C@the-village.bc.nu>
	<Pine.LNX.3.95.990123161758.12138B-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 23 Jan 1999 16:19:13 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> Complexity is not a goal to be reached. Complexity is something to be
> avoided at all cost. If you don't believe me, look at NT.

Nevertheless, the 2.2.0-pre9 VM sucks.  I've been getting seriously
frustrated at pre-9's interactive feel over the past few days.

Linus, there really are fundamental problems remaining in the VM in
2.2.0-pre right now.  The two biggest are the lack of responsiveness
of kswapd and a general misbalance in the cache management.

The kswapd in pre9 is improved, but still only checks status at 1HZ.
Once we detect an out-of-memory condition, then yes, we increase that
frequency, but it means we can take a long time to start responding to
(say) a burst of network traffic, and the free list can be completely
exhausted long before kswapd notices.

The second, balancing issue is evident in a general all-round
performance degradation when under VM load.  I notice this on 64M and on
8M.  Interactive response is simply poor all over, and build times are
excessive especially in low memory configurations.

Regarding the former, is there any chance you'd consider adding a kswapd
wakeup when low_memory gets set in get_free_pages()?  Being able to
respond to a burst in network traffic without locking up is not exactly
a minor issue.

As for the balancing, the tiny patch below seems to completely restore
the responsiveness and throughput of the VM we had in the 132-ac*
kernels.  8MB builds are very much faster.  Responsiveness on memory
sizes up to 64MB is improved both when we have several competing tasks
running and when simply switching between applications.  vmstat shows
swapouts clustered well: I see between 3 and 6 times the swap throughput
that pre9 alone has, and swap bursts end in about a quarter of the time
as under plain pre9.

The changes are very similar to the self-tuning clock counter we had in
those ac* vms.  The modified shrink_mmap() just avoids decrementing the
count for locked, non-DMA (if GFP_DMA) or multiply-mapped pages.  The
effect is to avoid counting memory mapped pages when we trim cache.  In
low memory, this allows us to keep trimming back the "excess" unmapped
pure cache pages even if a large fraction of physical memory is occupied
by mapped pages.  

Right now, on my 64MB box this kernel is so much more responsive than
pre9 that it is scary.  Ditto 8MB.  Kernel builds also now proceed
without excessive cache trimming: even pre9 used to show large amounts
of disk read activity as the include file working set got tossed from
cache, but halving the "count" limit as below is enough to eliminate
that entirely.  The new limit also has the side effect of allowing
swapout to stream much more effectively, without any signs of the cache
growing to excess.  Sustained IO activity grows the cache to about the
same size as in previous kernels.

Up to you, take it or leave it, but right now one of the major benefits
we are touting for 2.2 over 2.0 is performance, and people will expect
2.2.0's performance to be representative of the 2.2.* series.  Right now
we are way behind the 131+ kernels on that front.

--Stephen

----------------------------------------------------------------
--- mm/filemap.c.~1~	Thu Jan 21 10:26:41 1999
+++ mm/filemap.c	Mon Jan 25 12:59:38 1999
@@ -125,7 +125,7 @@
 	struct page * page;
 	int count;
 
-	count = (limit << 1) >> priority;
+	count = limit >> priority;
 
 	page = mem_map + clock;
 	do {
@@ -147,7 +147,6 @@
 			clock = page - mem_map;
 		}
 		
-		count--;
 		referenced = test_and_clear_bit(PG_referenced, &page->flags);
 
 		if (PageLocked(page))
@@ -159,6 +158,8 @@
 		/* We can't free pages unless there's just one user */
 		if (atomic_read(&page->count) != 1)
 			continue;
+
+		count--;
 
 		/*
 		 * Is it a page swap page? If so, we want to
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
