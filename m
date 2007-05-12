Date: Sat, 12 May 2007 20:24:08 +0100
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2, mode:0x84020
Message-ID: <20070512192408.GA5769@skynet.ie>
References: <20070511090823.GA29273@skynet.ie> <1178884283.27195.1.camel@rousalka.dyndns.org> <20070511173811.GA8529@skynet.ie> <1178905541.2473.2.camel@rousalka.dyndns.org> <1178908210.4360.21.camel@rousalka.dyndns.org> <20070511203610.GA12136@skynet.ie> <1178957491.4095.2.camel@rousalka.dyndns.org> <20070512164237.GA2691@skynet.ie> <1178993343.6397.1.camel@rousalka.dyndns.org> <1178996310.6397.3.camel@rousalka.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1178996310.6397.3.camel@rousalka.dyndns.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nicolas Mailhot <nicolas.mailhot@laposte.net>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On (12/05/07 20:58), Nicolas Mailhot didst pronounce:
> Le samedi 12 mai 2007 a 20:09 +0200, Nicolas Mailhot a ecrit :
> > Le samedi 12 mai 2007 a 17:42 +0100, Mel Gorman a ecrit :
> > 
> > > order-2 (at least 19 pages but more are there) and higher pages were free
> > > and this was a NORMAL allocation. It should also be above watermarks so
> > > something screwy is happening
> > > 
> > > *peers suspiciously*
> > > 
> > > Can you try the following patch on top of the kswapd patch please? It is
> > > also available from http://www.csn.ul.ie/~mel/watermarks.patch
> > 
> > Ok, testing now
> 
> And this one failed testing too 

And same thing, you have suitable free memory. The last patch was
wrong because I forgot the !in_interrupt() part which was careless
and dumb.  Please try the following, again on top of the kswapd patch -
http://www.csn.ul.ie/~mel/watermarks-v2.patch

Thanks for all the testing, it's appreciated.

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-revertmd/mm/page_alloc.c linux-2.6.21-mm2-watermarks/mm/page_alloc.c
--- linux-2.6.21-mm2-revertmd/mm/page_alloc.c	2007-05-11 21:16:57.000000000 +0100
+++ linux-2.6.21-mm2-watermarks/mm/page_alloc.c	2007-05-12 20:20:19.000000000 +0100
@@ -1645,8 +1645,16 @@ nofail_alloc:
 	}
 
 	/* Atomic allocations - we can't balance anything */
-	if (!wait)
+	if (!wait) {
+
+		/* Attempt to allocate ignoring watermarks */
+		page = get_page_from_freelist(gfp_mask, order,
+					zonelist, ALLOC_NO_WATERMARKS);	
+		if (page)
+			goto got_pg;
+
 		goto nopage;
+	}
 
 	cond_resched();
 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
