Date: Sat, 12 May 2007 17:42:37 +0100
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2, mode:0x84020
Message-ID: <20070512164237.GA2691@skynet.ie>
References: <20070510230044.GB15332@skynet.ie> <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com> <1178863002.24635.4.camel@rousalka.dyndns.org> <20070511090823.GA29273@skynet.ie> <1178884283.27195.1.camel@rousalka.dyndns.org> <20070511173811.GA8529@skynet.ie> <1178905541.2473.2.camel@rousalka.dyndns.org> <1178908210.4360.21.camel@rousalka.dyndns.org> <20070511203610.GA12136@skynet.ie> <1178957491.4095.2.camel@rousalka.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1178957491.4095.2.camel@rousalka.dyndns.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nicolas Mailhot <nicolas.mailhot@laposte.net>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On (12/05/07 10:11), Nicolas Mailhot didst pronounce:
> Le vendredi 11 mai 2007 a 21:36 +0100, Mel Gorman a ecrit :
> 
> > I'm pretty sure I have. I recreated the tree and reverted the same patch as
> > you and regenerated the diff below. I sent it to myself and it appeared ok
> > and another automated system was able to use it.
> > 
> > In case it's a mailer problem, the patch can be downloaded from
> > http://www.csn.ul.ie/~mel/kswapd-minorder.patch . 
> 
> This one applies, but the kernel still has allocation failures (I just
> found rpm -Va was a good trigger). So so far we have two proposed fixes
> none of which work
> 

Sorry about this. What is most preplexing is that the memory was free.
In your log we see;

> May 12 10:00:47 rousalka kernel: DMA: 6*4kB 4*8kB 9*16kB 3*32kB 6*64kB 7*128kB 5*256kB 0*512kB 1*1024kB 0*2048kB 1*4096kB = 7976kB
> May 12 10:00:47 rousalka kernel: DMA32: 2619*4kB 27*8kB 6*16kB 0*32kB 0*64kB 2*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 11556kB

and

> May 12 10:00:47 rousalka kernel: DMA: 6*4kB 4*8kB 9*16kB 3*32kB 6*64kB 7*128kB 5*256kB 0*512kB 1*1024kB 0*2048kB 1*4096kB = 7976kB
> May 12 10:00:47 rousalka kernel: DMA32: 1651*4kB 29*8kB 10*16kB 0*32kB 0*64kB 2*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 7764kB

order-2 (at least 19 pages but more are there) and higher pages were free
and this was a NORMAL allocation. It should also be above watermarks so
something screwy is happening

*peers suspiciously*

Can you try the following patch on top of the kswapd patch please? It is
also available from http://www.csn.ul.ie/~mel/watermarks.patch

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-revertmd/mm/page_alloc.c linux-2.6.21-mm2-watermarks/mm/page_alloc.c
--- linux-2.6.21-mm2-revertmd/mm/page_alloc.c	2007-05-11 21:16:57.000000000 +0100
+++ linux-2.6.21-mm2-watermarks/mm/page_alloc.c	2007-05-12 17:34:10.000000000 +0100
@@ -1627,7 +1627,7 @@ restart:
 	/* This allocation should allow future memory freeing. */
 
 rebalance:
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
+	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE) || !wait))
 			&& !in_interrupt()) {
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 nofail_alloc:
@@ -1636,7 +1636,7 @@ nofail_alloc:
 				zonelist, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
-			if (gfp_mask & __GFP_NOFAIL) {
+			if (gfp_mask & __GFP_NOFAIL && wait) {
 				congestion_wait(WRITE, HZ/50);
 				goto nofail_alloc;
 			}
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
