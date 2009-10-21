Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 573716B004F
	for <linux-mm@kvack.org>; Wed, 21 Oct 2009 16:04:49 -0400 (EDT)
Received: by gv-out-0910.google.com with SMTP id l14so864574gvf.19
        for <linux-mm@kvack.org>; Wed, 21 Oct 2009 13:04:46 -0700 (PDT)
Date: Wed, 21 Oct 2009 22:04:42 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: [PATCH] SLUB: Don't drop __GFP_NOFAIL completely from
	allocate_slab() (was: Re: [Bug #14265] ifconfig: page allocation
	failure. order:5,ode:0x8020 w/ e100)
Message-ID: <20091021200442.GA2987@bizet.domek.prywatny>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.rP.2MTxKB@chimera>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <COE24pZSBH.A.rP.2MTxKB@chimera>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com, Tobias Oetiker <tobi@oetiker.ch>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 01, 2009 at 09:56:04PM +0200, Rafael J. Wysocki wrote:
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14265
> Subject		: ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100
> Submitter	: Karol Lewandowski <karol.k.lewandowski@gmail.com>
> Date		: 2009-09-15 12:05 (17 days old)
> References	: http://marc.info/?l=linux-kernel&m=125301636509517&w=4

Guys, could anyone check if patch below helps?  I think I've finally
found culprit of all allocation failures (but I might be wrong
too... ;-)

Thanks.


commit d6849591e042bceb66f1b4513a1df6740d2ad762
Author: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Date:   Wed Oct 21 21:01:20 2009 +0200

    SLUB: Don't drop __GFP_NOFAIL completely from allocate_slab()
    
    Commit ba52270d18fb17ce2cf176b35419dab1e43fe4a3 unconditionally
    cleared __GFP_NOFAIL flag on all allocations.
    
    Preserve this flag on second attempt to allocate page (with possibly
    decreased order).
    
    This should help with bugs #14265, #14141 and similar.
    
    Signed-off-by: Karol Lewandowski <karol.k.lewandowski@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index b627675..ac5db65 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1084,7 +1084,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
 	struct kmem_cache_order_objects oo = s->oo;
-	gfp_t alloc_gfp;
+	gfp_t alloc_gfp, nofail;
 
 	flags |= s->allocflags;
 
@@ -1092,6 +1092,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 * Let the initial higher-order allocation fail under memory pressure
 	 * so we fall-back to the minimum order allocation.
 	 */
+	nofail = flags & __GFP_NOFAIL;
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
 
 	page = alloc_slab_page(alloc_gfp, node, oo);
@@ -1100,8 +1101,10 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 		/*
 		 * Allocation may have failed due to fragmentation.
 		 * Try a lower order alloc if possible
+		 *
+		 * Preserve __GFP_NOFAIL flag if previous allocation failed.
 		 */
-		page = alloc_slab_page(flags, node, oo);
+		page = alloc_slab_page(flags | nofail, node, oo);
 		if (!page)
 			return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
