Date: Wed, 16 May 2007 10:45:43 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <464ACA68.2040707@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
 <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org>
 <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au>
 <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, Nick Piggin wrote:

> Mel Gorman wrote:
>> On Wed, 16 May 2007, Nick Piggin wrote:
>
>>> Hmm, so we require higher order pages be kept free even if nothing is
>>> using them? That's not very nice :(
>>> 
>> 
>> Not quite. We are already required to keep a minimum number of pages free 
>> even though nothing is using them. The difference is that if it is known 
>> high-order allocations are frequently required, the freed pages will be 
>> contiguous. If no one calls raise_kswapd_order(), kswapd will continue 
>> reclaiming at order-0.
>
> And after they are stopped being used, it falls back to order-0?

No, raise_kswapd_order() is used when it is known there are many 
high-order allocations of a particular value. It becomes the minimum value 
kswapd reclaims at. SLUB does not *require* high order allocations but can 
be configured to use them so it makes sense to keep min_free_kbytes at 
that order to reduce stalls due to direct reclaim.

> Why
> can't this use the infrastructure that is already in place for that?
>

The infrastructure there currently deals nicely with the situation where 
there are rarely allocations of a high order. This change is for when it 
is known there are frequent high-order (e.g. orders 1-4) allocations. 
While the callers often can direct reclaim, kswapd should help them avoid 
stalls because reducing stalls is one of it's functions. With this patch, 
kswapd still reclaims the same number of pages, just tries to reclaim 
contiguous ones.

>> Arguably, e1000 should also be calling raise_kswapd_order() when it is 
>> using jumbo frames.
>
> It should be able to handle higher order page allocation failures
> gracefully.

Has something changed recently that it can handle failures? It might have 
because it has been hinted that it's possible, just not very fast.

> kswapd will be notified of the attempts and go on and try
> to free up some higher order pages for it for next time. What is wrong
> with this process?

It's reactive, it only occurs when a process has already entered direct 
reclaim.

> Are the higher order watermarks insufficient?
>

The high-order watermarks are still used to make a process that can sleep 
enter direct reclaim when the higher order watermarks are not being met.

> (I would also add that non-arguably, e1000 should also be able to do
> scatter gather with jumbo frames too.)
>

That's another football that has done the laps.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
