Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E708B6B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 15:19:36 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k23-v6so2179586qtj.16
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 12:19:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p54-v6si51554qtj.296.2018.04.27.12.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 12:19:35 -0700 (PDT)
Date: Fri, 27 Apr 2018 15:19:31 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1804271136390.11686@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1804271513320.16558@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
 <alpine.LRH.2.02.1804171454020.26973@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804180952580.1334@nuc-kabylake> <alpine.LRH.2.02.1804251702250.9428@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804251917460.2429@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1804261354230.6674@nuc-kabylake> <alpine.LRH.2.02.1804261508430.26980@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804271136390.11686@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org



On Fri, 27 Apr 2018, Christopher Lameter wrote:

> On Thu, 26 Apr 2018, Mikulas Patocka wrote:
> 
> > > Hmmm... order 4 for these caches may cause some concern. These should stay
> > > under costly order I think. Otherwise allocations are no longer
> > > guaranteed.
> >
> > You said that slub has fallback to smaller order allocations.
> 
> Yes it does...
> 
> > The whole purpose of this "minimize waste" approach is to use higher-order
> > allocations to use memory more efficiently, so it is just doing its job.
> > (for these 3 caches, order-4 really wastes less memory than order-3 - on
> > my system TCPv6 and sighand_cache have size 2112, task_struct 2752).
> 
> Hmmm... Ok if the others are fine with this as well. I got some pushback
> there in the past.
> 
> > We could improve the fallback code, so that if order-4 allocation fails,
> > it tries order-3 allocation, and then falls back to order-0. But I think
> > that these failures are rare enough that it is not a problem.
> 
> I also think that would be too many fallbacks.

You are right - it's better to fallback to the minimum possible size, so 
that the allocation is faster.

> The old code uses the concept of a "fraction" to calculate overhead. The
> code here uses absolute counts of bytes. Fraction looks better to me.

OK - I reworked the patch using the same "fraction" calculation as before.  
The existing logic targets 1/16 wasted space, so I used this target in 
this patch too.

This patch increases only the order of task_struct (from 3 to 4), all the 
other caches have the same order as before.

Mikulas



From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] slub: use higher order to reduce wasted space

If we create a slub cache with large object size (larger than
slub_max_order), the slub subsystem currently rounds up the object size to
the next power of two.

This is inefficient, because it wastes too much space. We use the slab
cache as a buffer cache in dm-bufio, in order to use the memory
efficiently, we need to reduce wasted space.

This patch reworks the slub order calculation algorithm, so that it uses
higher order allocations if it would reduce wasted space. The slub
subsystem has fallback if the higher-order allocations fails, so using
order higher than PAGE_ALLOC_COSTLY_ORDER is ok.

The new algorithm first calculates the minimum order that can be used for
a give object size and then increases the order according to these
conditions:
* if we would overshoot MAX_OBJS_PER_PAGE, don't increase
* if we are below slub_min_order, increase
* if we are below slub_max_order and below min_objects, increase
* we increase above slub_max_order only if it reduces wasted space and if
  we alrady waste at least 1/16 of the compound page

The new algorithm gives very similar results to the old one, all the
caches on my system have the same order as before, only the order of
task_struct (size 2752) is increased from 3 to 4.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 mm/slub.c |   82 +++++++++++++++++++++++---------------------------------------
 1 file changed, 31 insertions(+), 51 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2018-04-27 19:30:34.000000000 +0200
+++ linux-2.6/mm/slub.c	2018-04-27 21:05:53.000000000 +0200
@@ -3224,34 +3224,10 @@ static unsigned int slub_min_objects;
  * requested a higher mininum order then we start with that one instead of
  * the smallest order which will fit the object.
  */
-static inline unsigned int slab_order(unsigned int size,
-		unsigned int min_objects, unsigned int max_order,
-		unsigned int fract_leftover, unsigned int reserved)
+static int calculate_order(unsigned int size, unsigned int reserved)
 {
-	unsigned int min_order = slub_min_order;
-	unsigned int order;
-
-	if (order_objects(min_order, size, reserved) > MAX_OBJS_PER_PAGE)
-		return get_order(size * MAX_OBJS_PER_PAGE) - 1;
-
-	for (order = max(min_order, (unsigned int)get_order(min_objects * size + reserved));
-			order <= max_order; order++) {
-
-		unsigned int slab_size = (unsigned int)PAGE_SIZE << order;
-		unsigned int rem;
-
-		rem = (slab_size - reserved) % size;
-
-		if (rem <= slab_size / fract_leftover)
-			break;
-	}
-
-	return order;
-}
-
-static inline int calculate_order(unsigned int size, unsigned int reserved)
-{
-	unsigned int order;
+	unsigned int best_order;
+	unsigned int test_order;
 	unsigned int min_objects;
 	unsigned int max_objects;
 
@@ -3269,34 +3245,38 @@ static inline int calculate_order(unsign
 	max_objects = order_objects(slub_max_order, size, reserved);
 	min_objects = min(min_objects, max_objects);
 
-	while (min_objects > 1) {
-		unsigned int fraction;
+	/* Get the minimum acceptable order for one object */
+	best_order = get_order(size + reserved);
+
+	for (test_order = best_order + 1; test_order < MAX_ORDER; test_order++) {
+		unsigned best_order_obj = order_objects(best_order, size, reserved);
+		unsigned test_order_obj = order_objects(test_order, size, reserved);
+
+		unsigned best_order_slab_size = (unsigned int)PAGE_SIZE << best_order;
+		unsigned best_order_rem = (best_order_slab_size - reserved) % size;
+
+		/* If there would be too many objects, stop searching */
+		if (test_order_obj > MAX_OBJS_PER_PAGE)
+			break;
 
-		fraction = 16;
-		while (fraction >= 4) {
-			order = slab_order(size, min_objects,
-					slub_max_order, fraction, reserved);
-			if (order <= slub_max_order)
-				return order;
-			fraction /= 2;
-		}
-		min_objects--;
+		/* Always increase up to slub_min_order */
+		if (test_order <= slub_min_order)
+			best_order = test_order;
+
+		/* If we are below min_objects and slub_max_order, increase the order */
+		if (best_order_obj < min_objects && test_order <= slub_max_order)
+			best_order = test_order;
+
+		/* Increase the order even more, but only if it reduces waste */
+		/* If we already waste less than 1/16, don't increase it */
+		if (best_order_rem >= (best_order_slab_size / 16) &&
+		    test_order_obj > (best_order_obj << (test_order - best_order)))
+			best_order = test_order;
 	}
 
-	/*
-	 * We were unable to place multiple objects in a slab. Now
-	 * lets see if we can place a single object there.
-	 */
-	order = slab_order(size, 1, slub_max_order, 1, reserved);
-	if (order <= slub_max_order)
-		return order;
+	if (best_order < MAX_ORDER)
+		return best_order;
 
-	/*
-	 * Doh this slab cannot be placed using slub_max_order.
-	 */
-	order = slab_order(size, 1, MAX_ORDER, 1, reserved);
-	if (order < MAX_ORDER)
-		return order;
 	return -ENOSYS;
 }
 
