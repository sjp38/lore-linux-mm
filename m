Date: Mon, 14 May 2007 21:39:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705142129290.28065@schroedinger.engr.sgi.com>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: apw@shadowen.org, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On third thought: The trouble with this solution is that we will now set 
the order to that used by the largest kmalloc cache. Bad... this could be 
6 on i386 to 13 if CONFIG_LARGE_ALLOCs is set. The large kmalloc caches 
are rarely used and we are used to OOMing if those are utilized to 
frequently.

I guess we should only set this for non kmalloc caches then. 
So move the call into kmem_cache_create? Would make the min order 3 on
most of my mm machines.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-14 21:33:48.000000000 -0700
+++ slub/mm/slub.c	2007-05-14 21:35:40.000000000 -0700
@@ -1996,8 +1996,6 @@ static int kmem_cache_open(struct kmem_c
 #ifdef CONFIG_NUMA
 	s->defrag_ratio = 100;
 #endif
-	raise_kswapd_order(s->order);
-
 	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		return 1;
 error:
@@ -2560,6 +2558,7 @@ struct kmem_cache *kmem_cache_create(con
 				goto err;
 			}
 			list_add(&s->list, &slab_caches);
+			raise_kswapd_order(s->order);
 		} else
 			kfree(s);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
