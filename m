Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 315056B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 17:10:51 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x2-v6so9764074qto.10
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:10:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m14-v6si5296911qti.317.2018.04.26.14.09.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 14:10:12 -0700 (PDT)
Date: Thu, 26 Apr 2018 17:09:54 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1804261354230.6674@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1804261508430.26980@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
 <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com> <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com>
 <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake> <alpine.LRH.2.02.1804171454020.26973@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804180952580.1334@nuc-kabylake>
 <alpine.LRH.2.02.1804251702250.9428@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804251917460.2429@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804261354230.6674@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org



On Thu, 26 Apr 2018, Christopher Lameter wrote:

> On Wed, 25 Apr 2018, Mikulas Patocka wrote:
> 
> > Do you want this? It deletes slab_order and replaces it with the
> > "minimize_waste" logic directly.
> 
> Well yes that looks better. Now we need to make it easy to read and less
> complicated. Maybe try to keep as much as possible of the old code
> and also the names of variables to make it easier to review?
> 
> > It simplifies the code and it is very similar to the old algorithms, most
> > slab caches have the same order, so it shouldn't cause any regressions.
> >
> > This patch changes order of these slabs:
> > TCPv6: 3 -> 4
> > sighand_cache: 3 -> 4
> > task_struct: 3 -> 4
> 
> Hmmm... order 4 for these caches may cause some concern. These should stay
> under costly order I think. Otherwise allocations are no longer
> guaranteed.

You said that slub has fallback to smaller order allocations.

The whole purpose of this "minimize waste" approach is to use higher-order 
allocations to use memory more efficiently, so it is just doing its job. 
(for these 3 caches, order-4 really wastes less memory than order-3 - on 
my system TCPv6 and sighand_cache have size 2112, task_struct 2752).

We could improve the fallback code, so that if order-4 allocation fails, 
it tries order-3 allocation, and then falls back to order-0. But I think 
that these failures are rare enough that it is not a problem.

> > @@ -3269,35 +3245,35 @@ static inline int calculate_order(unsign
> >  	max_objects = order_objects(slub_max_order, size, reserved);
> >  	min_objects = min(min_objects, max_objects);
> >
> > -	while (min_objects > 1) {
> > -		unsigned int fraction;
> > +	/* Get the minimum acceptable order for one object */
> > +	order = get_order(size + reserved);
> > +
> > +	for (test_order = order + 1; test_order < MAX_ORDER; test_order++) {
> > +		unsigned order_obj = order_objects(order, size, reserved);
> > +		unsigned test_order_obj = order_objects(test_order, size, reserved);
> > +
> > +		/* If there are too many objects, stop searching */
> > +		if (test_order_obj > MAX_OBJS_PER_PAGE)
> > +			break;
> >
> > -		fraction = 16;
> > -		while (fraction >= 4) {
> > -			order = slab_order(size, min_objects,
> > -					slub_max_order, fraction, reserved);
> > -			if (order <= slub_max_order)
> > -				return order;
> > -			fraction /= 2;
> > -		}
> > -		min_objects--;
> > +		/* Always increase up to slub_min_order */
> > +		if (test_order <= slub_min_order)
> > +			order = test_order;
> 
> Well that is a significant change. In our current scheme the order
> boundart wins.

I think it's not a change. The existing function slab_order() starts with 
min_order (unless it overshoots MAX_OBJS_PER_PAGE) and then goes upwards. 
My code does the same - my code tests for MAX_OBJS_PER_PAGE (and bails out 
if we would overshoot it) and increases the order until it reaches 
slub_min_order (and then increases it even more if it satisfies the other 
conditions).

If you believe that it behaves differently, please describe the situation 
in detail.

> > +
> > +		/* If we are below min_objects and slub_max_order, increase order */
> > +		if (order_obj < min_objects && test_order <= slub_max_order)
> > +			order = test_order;
> > +
> > +		/* Increase order even more, but only if it reduces waste */
> > +		if (test_order_obj <= 32 &&
> 
> Where does the 32 come from?

It is to avoid extremely high order for extremely small slabs.

For example, see kmalloc-96.
10922 96-byte objects would fit into 1MiB
21845 96-byte objects would fit into 2MiB

The algorithm would recognize this one more object that fits into 2MiB 
slab as "waste reduction" and increase the order to 2MiB - and we don't 
want this.

So, the general reasoning is - if we have 32 objects in a slab, then it is 
already considered that wasted space is reasonably low and we don't want 
to increase the order more.

Currently, kmalloc-96 uses order-0 - that is reasonable (we already have 
42 objects in 4k page, so we don't need to use higher order, even if it 
wastes one-less object).

> > +		    test_order_obj > order_obj << (test_order - order))
> 
> Add more () to make the condition better readable.
> 
> > +			order = test_order;
> 
> Can we just call test_order order and avoid using the long variable names
> here? Variable names in functions are typically short.

You need two variables - "order" and "test_order".

"order" is the best order found so far and "test_order" is the order that 
we are now testing. If "test_order" wastes less space than "order", we 
assign order = test_order.

Mikulas
