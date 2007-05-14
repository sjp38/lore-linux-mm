Date: Mon, 14 May 2007 19:19:21 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705141905400.7302@skynet.skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Christoph Lameter wrote:

> On Mon, 14 May 2007, Mel Gorman wrote:
>
>> +++ linux-2.6.21-mm2-001_kswapd_minorder/mm/slub.c	2007-05-14 17:09:39.000000000 +0100
>> @@ -2131,6 +2131,7 @@ static struct kmem_cache *kmalloc_caches
>>  static int __init setup_slub_min_order(char *str)
>>  {
>>  	get_option (&str, &slub_min_order);
>> +	raise_kswapd_order(slub_min_order);
>>  	user_override = 1;
>>  	return 1;
>>  }
>
> You need to do this for slub_max_order not for slub_min_order.

The intention is to have kswapd keep high-order pages free of an order 
that is known to be of interest. Hence I used slub_min_order because it's 
known to be used regularly. By default, the value is 0 but it's higher if 
slub_min_order, then it gets raised.

> Also the slub_max_order may not necessarily be used. It is just the 
> maximum allowed order. I could maintain a slub_max_used_order variable. 
> When that is increased I could call raise_kswapd_order?
>

A slub_max_user_order variable may have been useful but your suggestion 
in relation to kmem_cache_open() makes more sense.

> The same call needs to be put into kmem_cache_init? Or is this only for
> orders > 3?
>

With kmem_cache_open(), altering kmem_cache_init seems unnecessary. 
Similarly, calling raise_kswapd_order() when parsing slub_min_order= is 
unnecessary.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
