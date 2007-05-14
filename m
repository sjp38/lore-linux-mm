Date: Mon, 14 May 2007 11:13:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: apw@shadowen.org, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think the slub fragment may have to be this way? This calls 
raise_kswapd_order on each kmem_cache_create with the order of the cache 
that was created thus insuring that the min_order is correctly.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    1 +
 1 file changed, 1 insertion(+)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-14 11:10:37.000000000 -0700
+++ slub/mm/slub.c	2007-05-14 11:10:55.000000000 -0700
@@ -1996,6 +1996,7 @@ static int kmem_cache_open(struct kmem_c
 #ifdef CONFIG_NUMA
 	s->defrag_ratio = 100;
 #endif
+	raise_kswapd_order(s->order);
 
 	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
