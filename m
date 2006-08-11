Date: Thu, 10 Aug 2006 20:16:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <20060810124137.6da0fdef.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0608102010150.12657@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <20060810124137.6da0fdef.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Aug 2006, Andrew Morton wrote:

> This adds a little bit of overhead to non-numa kernels.  I think that
> overhead could be eliminated if we were to do

The overhead is really minimal. The parameter we are testing is passed on 
later and the test is unlikely.

I would rather avoid fiddling around with making __GFP_xxx conditional.
We have seen  to what problems this could lead. The #ifdef is less harmful
if placed in get_page_from_freelist.

How about this one:

Index: linux-2.6.18-rc3-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/page_alloc.c	2006-08-09 18:37:06.434599531 -0700
+++ linux-2.6.18-rc3-mm2/mm/page_alloc.c	2006-08-10 20:13:53.674465629 -0700
@@ -918,12 +918,14 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	 */
 	do {
 		zone = *z;
+#ifdef CONFIG_NUMA
 		if (unlikely((gfp_mask & __GFP_THISNODE) &&
 			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
 				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
 				!cpuset_zone_allowed(zone, gfp_mask))
 			continue;
+#endif
 
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
