Message-ID: <454A2CE5.6080003@shadowen.org>
Date: Thu, 02 Nov 2006 17:37:41 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: Page allocator: Single Zone optimizations
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com> <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com> <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com> <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com> <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com> <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie> <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Wed, 1 Nov 2006, Andrew Morton wrote:
> 
>> On Wed, 1 Nov 2006 18:26:05 +0000
>> mel@skynet.ie (Mel Gorman) wrote:
>>
>>> I never really got this objection. With list-based anti-frag, the
>>> zone-balancing logic remains the same. There are patches from Andy
>>> Whitcroft that reclaims pages in contiguous blocks, but still with
>>> the same
>>> zone-ordering. It doesn't affect load balancing between zones as such.
>>
>> I do believe that lumpy-reclaim (initiated by Andy, redone and prototyped
>> by Peter, cruelly abandoned) is a perferable approach to solving the
>> fragmentation approach.
>>

Heh, I've talked to Peter and apologised for its apparent abandonment.
In fact the problem is that a huge amount of time has been consumed
papering over the cracks in the last few releases; I for one feel this
has been the most unstable "merge window" we've ever had.

> On it's own lumpy-reclaim or linear-reclaim were not enough to get
> MAX_ORDER_NR_PAGES blocks of contiguous pages and these were of interest
> for huge pages although not necessarily of much use to memory
> hot-unplug. Tests with linear reclaim and lumpy reclaim showed them to
> be marginally (very marginal) better than just using the standard
> allocator and standard reclaim. The clustering by reclaim type (or
> having a separate zone) was still needed.

As Mel indicates a reclaim algorithm change is not enough.  Without
thoughtful placement of the non-reclaimable kernel allocations we end up
with no reclaimable blocks regardless of algorithm.  Unless we are going
to allow all pages to be reclaimed (which is a massive job of
unthinkable proportions IMO) then we need some kind of placement scheme
to aid reclaim.

To illustrate this I have pulled together some figures from some testing
we have managed to get through.  All figures represent the percentage of
overall memory which could be allocated at MAX_ORDER-1 at rest after a
period of high fragmentation activity:

					ppc64		x86_64
baseline				 9 %		21 %
linear-reclaim-v1			 9 %		21 %
linear-reclaim-v1 listbased-v26		59 %		72 %
lumpy-reclaim-v2			11 %		16 %
lumpy-reclaim-v2 listbased-v26		24 %		57 %

Also as a graph at the following URL:
    http://www.shadowen.org/~apw/public/reclaim/reclaim-rates.png

The comparison between the baseline and baseline + reclaim algorithm
shows that we gain near nothing with just that change.  Bring in the
placement and we see real gains.

I am currently working on a variant of lumpy reclaim to try and bridge
the gap between it and linear without losing its graceful simplicity.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
