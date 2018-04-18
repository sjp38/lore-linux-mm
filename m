Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 918E96B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 10:55:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id s138so1263327qke.10
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:55:34 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id q36-v6si1520759qtf.211.2018.04.18.07.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 07:55:33 -0700 (PDT)
Date: Wed, 18 Apr 2018 09:55:31 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1804171454020.26973@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1804180952580.1334@nuc-kabylake>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
 <alpine.LRH.2.02.1804171454020.26973@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, 17 Apr 2018, Mikulas Patocka wrote:

> I can make a slub-only patch with no extra flag (on a freshly booted
> system it increases only the order of caches "TCPv6" and "sighand_cache"
> by one - so it should not have unexpected effects):
>
> Doing a generic solution for slab would be more comlpicated because slab
> assumes that all slabs have the same order, so it can't fall-back to
> lower-order allocations.

Well again SLAB uses compound pages and thus would be able to detect the
size of the page. It may be some work but it could be done.

>
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2018-04-17 19:59:49.000000000 +0200
> +++ linux-2.6/mm/slub.c	2018-04-17 20:58:23.000000000 +0200
> @@ -3252,6 +3252,7 @@ static inline unsigned int slab_order(un
>  static inline int calculate_order(unsigned int size, unsigned int reserved)
>  {
>  	unsigned int order;
> +	unsigned int test_order;
>  	unsigned int min_objects;
>  	unsigned int max_objects;
>
> @@ -3277,7 +3278,7 @@ static inline int calculate_order(unsign
>  			order = slab_order(size, min_objects,
>  					slub_max_order, fraction, reserved);
>  			if (order <= slub_max_order)
> -				return order;
> +				goto ret_order;
>  			fraction /= 2;
>  		}
>  		min_objects--;
> @@ -3289,15 +3290,25 @@ static inline int calculate_order(unsign
>  	 */
>  	order = slab_order(size, 1, slub_max_order, 1, reserved);

The slab order is determined in slab_order()

>  	if (order <= slub_max_order)
> -		return order;
> +		goto ret_order;
>
>  	/*
>  	 * Doh this slab cannot be placed using slub_max_order.
>  	 */
>  	order = slab_order(size, 1, MAX_ORDER, 1, reserved);
> -	if (order < MAX_ORDER)
> -		return order;
> -	return -ENOSYS;
> +	if (order >= MAX_ORDER)
> +		return -ENOSYS;
> +
> +ret_order:
> +	for (test_order = order + 1; test_order < MAX_ORDER; test_order++) {
> +		unsigned long order_objects = ((PAGE_SIZE << order) - reserved) / size;
> +		unsigned long test_order_objects = ((PAGE_SIZE << test_order) - reserved) / size;
> +		if (test_order_objects > min(32, MAX_OBJS_PER_PAGE))
> +			break;
> +		if (test_order_objects > order_objects << (test_order - order))
> +			order = test_order;
> +	}
> +	return order;

Could yo move that logic into slab_order()? It does something awfully
similar.
