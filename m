Date: Fri, 26 Jan 2007 17:53:24 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/8] Allow huge page allocations to use GFP_HIGH_MOVABLE
In-Reply-To: <Pine.LNX.4.64.0701260944270.7457@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701261747290.23091@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070125234558.28809.21103.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260832260.6141@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261649040.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260903110.6966@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261720120.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260921310.7301@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261727400.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260944270.7457@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Christoph Lameter wrote:

> On Fri, 26 Jan 2007, Mel Gorman wrote:
>
>> It's come up a few times and the converation is always fairly similar although
>> the thread http://lkml.org/lkml/2006/9/22/44 has interesting information on
>> the topic. There has been no serious discussion on whether anti-fragmentation
>> would help it or not. I think it would if atomic allocations were clustered
>> together because then jumbo frame allocations would cluster together in the
>> same MAX_ORDER blocks and tend to keep other allocations away.
>
> They are clustered in both schemes together with other non movable allocs
> right?

For the jumbo frame problem, only the antifragmentation approach of 
clustering types of pages together in MAX_ORDER blocks has any chance of 
helping.

> The problem is to defrag while atomic?

Worse, the problem is to have high order contiguous blocks free at the 
time of allocation without reclaim or migration. If the allocations were 
not atomic, anti-fragmentation as it is today would be enough.

By clustering atomic allocations together though, I would expect the jumbo 
frames to be allocated and freed within the same area without interference 
from other allocation types as long as min_free_kbytes was also set higher 
than default. I lack the hardware to prove/disprove the idea though.

> How is the zone based
> concept different in that area from the max order block based one?

The zone-based approach does nothing to help jumbo frame allocations. It 
only helps hugepage allocations at runtime and potentially memory 
hot-remove.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
