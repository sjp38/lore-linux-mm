Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3C516B025E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 19:24:26 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p190so12251673qkc.17
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 16:24:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z40-v6si1051041qtj.365.2018.04.25.16.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 16:24:24 -0700 (PDT)
Date: Wed, 25 Apr 2018 19:24:22 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1804251702250.9428@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1804251917460.2429@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
 <alpine.LRH.2.02.1804171454020.26973@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804180952580.1334@nuc-kabylake> <alpine.LRH.2.02.1804251702250.9428@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org



On Wed, 25 Apr 2018, Mikulas Patocka wrote:

> 
> 
> On Wed, 18 Apr 2018, Christopher Lameter wrote:
> 
> > On Tue, 17 Apr 2018, Mikulas Patocka wrote:
> > 
> > > I can make a slub-only patch with no extra flag (on a freshly booted
> > > system it increases only the order of caches "TCPv6" and "sighand_cache"
> > > by one - so it should not have unexpected effects):
> > >
> > > Doing a generic solution for slab would be more comlpicated because slab
> > > assumes that all slabs have the same order, so it can't fall-back to
> > > lower-order allocations.
> > 
> > Well again SLAB uses compound pages and thus would be able to detect the
> > size of the page. It may be some work but it could be done.
> > 
> > >
> > > Index: linux-2.6/mm/slub.c
> > > ===================================================================
> > > --- linux-2.6.orig/mm/slub.c	2018-04-17 19:59:49.000000000 +0200
> > > +++ linux-2.6/mm/slub.c	2018-04-17 20:58:23.000000000 +0200
> > > @@ -3252,6 +3252,7 @@ static inline unsigned int slab_order(un
> > >  static inline int calculate_order(unsigned int size, unsigned int reserved)
> > >  {
> > >  	unsigned int order;
> > > +	unsigned int test_order;
> > >  	unsigned int min_objects;
> > >  	unsigned int max_objects;
> > >
> > > @@ -3277,7 +3278,7 @@ static inline int calculate_order(unsign
> > >  			order = slab_order(size, min_objects,
> > >  					slub_max_order, fraction, reserved);
> > >  			if (order <= slub_max_order)
> > > -				return order;
> > > +				goto ret_order;
> > >  			fraction /= 2;
> > >  		}
> > >  		min_objects--;
> > > @@ -3289,15 +3290,25 @@ static inline int calculate_order(unsign
> > >  	 */
> > >  	order = slab_order(size, 1, slub_max_order, 1, reserved);
> > 
> > The slab order is determined in slab_order()
> > 
> > >  	if (order <= slub_max_order)
> > > -		return order;
> > > +		goto ret_order;
> > >
> > >  	/*
> > >  	 * Doh this slab cannot be placed using slub_max_order.
> > >  	 */
> > >  	order = slab_order(size, 1, MAX_ORDER, 1, reserved);
> > > -	if (order < MAX_ORDER)
> > > -		return order;
> > > -	return -ENOSYS;
> > > +	if (order >= MAX_ORDER)
> > > +		return -ENOSYS;
> > > +
> > > +ret_order:
> > > +	for (test_order = order + 1; test_order < MAX_ORDER; test_order++) {
> > > +		unsigned long order_objects = ((PAGE_SIZE << order) - reserved) / size;
> > > +		unsigned long test_order_objects = ((PAGE_SIZE << test_order) - reserved) / size;
> > > +		if (test_order_objects > min(32, MAX_OBJS_PER_PAGE))
> > > +			break;
> > > +		if (test_order_objects > order_objects << (test_order - order))
> > > +			order = test_order;
> > > +	}
> > > +	return order;
> > 
> > Could yo move that logic into slab_order()? It does something awfully
> > similar.
> 
> But slab_order (and its caller) limits the order to "max_order" and we 
> want more.
> 
> Perhaps slab_order should be dropped and calculate_order totally 
> rewritten?
> 
> Mikulas

Do you want this? It deletes slab_order and replaces it with the 
"minimize_waste" logic directly.

The patch starts with a minimal order for a given size and increases the 
order if one of these conditions is met:
* we is below slub_min_order
* we are below min_objects and slub_max_order
* we go above slub_max_order only if it minimizes waste and if we don't 
  increase the object count above 32

It simplifies the code and it is very similar to the old algorithms, most 
slab caches have the same order, so it shouldn't cause any regressions.

This patch changes order of these slabs:
TCPv6: 3 -> 4
sighand_cache: 3 -> 4
task_struct: 3 -> 4

---
 mm/slub.c |   76 +++++++++++++++++++++-----------------------------------------
 1 file changed, 26 insertions(+), 50 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2018-04-26 00:07:30.000000000 +0200
+++ linux-2.6/mm/slub.c	2018-04-26 00:21:37.000000000 +0200
@@ -3224,34 +3224,10 @@ static unsigned int slub_min_objects;
  * requested a higher mininum order then we start with that one instead of
  * the smallest order which will fit the object.
  */
-static inline unsigned int slab_order(unsigned int size,
-		unsigned int min_objects, unsigned int max_order,
-		unsigned int fract_leftover, unsigned int reserved)
-{
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
 static inline int calculate_order(unsigned int size, unsigned int reserved)
 {
 	unsigned int order;
+	unsigned int test_order;
 	unsigned int min_objects;
 	unsigned int max_objects;
 
@@ -3269,35 +3245,35 @@ static inline int calculate_order(unsign
 	max_objects = order_objects(slub_max_order, size, reserved);
 	min_objects = min(min_objects, max_objects);
 
-	while (min_objects > 1) {
-		unsigned int fraction;
+	/* Get the minimum acceptable order for one object */
+	order = get_order(size + reserved);
+
+	for (test_order = order + 1; test_order < MAX_ORDER; test_order++) {
+		unsigned order_obj = order_objects(order, size, reserved);
+		unsigned test_order_obj = order_objects(test_order, size, reserved);
+
+		/* If there are too many objects, stop searching */
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
+			order = test_order;
+
+		/* If we are below min_objects and slub_max_order, increase order */
+		if (order_obj < min_objects && test_order <= slub_max_order)
+			order = test_order;
+
+		/* Increase order even more, but only if it reduces waste */
+		if (test_order_obj <= 32 &&
+		    test_order_obj > order_obj << (test_order - order))
+			order = test_order;
 	}
 
-	/*
-	 * We were unable to place multiple objects in a slab. Now
-	 * lets see if we can place a single object there.
-	 */
-	order = slab_order(size, 1, slub_max_order, 1, reserved);
-	if (order <= slub_max_order)
-		return order;
+	if (order >= MAX_ORDER)
+		return -ENOSYS;
 
-	/*
-	 * Doh this slab cannot be placed using slub_max_order.
-	 */
-	order = slab_order(size, 1, MAX_ORDER, 1, reserved);
-	if (order < MAX_ORDER)
-		return order;
-	return -ENOSYS;
+	return order;
 }
 
 static void
