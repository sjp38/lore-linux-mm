Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E03736B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 15:01:08 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x2-v6so9463189qto.10
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 12:01:08 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id x13si4107024qvb.73.2018.04.26.12.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 12:01:07 -0700 (PDT)
Date: Thu, 26 Apr 2018 14:01:06 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1804251917460.2429@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1804261354230.6674@nuc-kabylake>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
 <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com> <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com>
 <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake> <alpine.LRH.2.02.1804171454020.26973@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804180952580.1334@nuc-kabylake>
 <alpine.LRH.2.02.1804251702250.9428@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804251917460.2429@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, 25 Apr 2018, Mikulas Patocka wrote:

> Do you want this? It deletes slab_order and replaces it with the
> "minimize_waste" logic directly.

Well yes that looks better. Now we need to make it easy to read and less
complicated. Maybe try to keep as much as possible of the old code
and also the names of variables to make it easier to review?

> It simplifies the code and it is very similar to the old algorithms, most
> slab caches have the same order, so it shouldn't cause any regressions.
>
> This patch changes order of these slabs:
> TCPv6: 3 -> 4
> sighand_cache: 3 -> 4
> task_struct: 3 -> 4

Hmmm... order 4 for these caches may cause some concern. These should stay
under costly order I think. Otherwise allocations are no longer
guaranteed.

> @@ -3269,35 +3245,35 @@ static inline int calculate_order(unsign
>  	max_objects = order_objects(slub_max_order, size, reserved);
>  	min_objects = min(min_objects, max_objects);
>
> -	while (min_objects > 1) {
> -		unsigned int fraction;
> +	/* Get the minimum acceptable order for one object */
> +	order = get_order(size + reserved);
> +
> +	for (test_order = order + 1; test_order < MAX_ORDER; test_order++) {
> +		unsigned order_obj = order_objects(order, size, reserved);
> +		unsigned test_order_obj = order_objects(test_order, size, reserved);
> +
> +		/* If there are too many objects, stop searching */
> +		if (test_order_obj > MAX_OBJS_PER_PAGE)
> +			break;
>
> -		fraction = 16;
> -		while (fraction >= 4) {
> -			order = slab_order(size, min_objects,
> -					slub_max_order, fraction, reserved);
> -			if (order <= slub_max_order)
> -				return order;
> -			fraction /= 2;
> -		}
> -		min_objects--;
> +		/* Always increase up to slub_min_order */
> +		if (test_order <= slub_min_order)
> +			order = test_order;

Well that is a significant change. In our current scheme the order
boundart wins.


> +
> +		/* If we are below min_objects and slub_max_order, increase order */
> +		if (order_obj < min_objects && test_order <= slub_max_order)
> +			order = test_order;
> +
> +		/* Increase order even more, but only if it reduces waste */
> +		if (test_order_obj <= 32 &&

Where does the 32 come from?

> +		    test_order_obj > order_obj << (test_order - order))

Add more () to make the condition better readable.

> +			order = test_order;

Can we just call test_order order and avoid using the long variable names
here? Variable names in functions are typically short.
