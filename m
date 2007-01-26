Date: Fri, 26 Jan 2007 17:20:07 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
In-Reply-To: <Pine.LNX.4.64.0701260855560.6966@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701261703200.23091@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260812150.6141@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261629050.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260855560.6966@schroedinger.engr.sgi.com>
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
>>> For arches that do not have HIGHMEM other zones would be okay too it
>>> seems.
>> It would, but it'd obscure the code to take advantage of that.
>
> No MOVABLE memory for 64 bit platforms that do not have HIGHMEM right now?
>

err, no, I misinterpreted what you meant by "other zones would be ok..". I 
though you were suggesting the reuse of zone names for some reason.

The zone used to for ZONE_MOVABLE is the highest populated zone on the 
architecture. On some architectures, that will be ZONE_HIGHMEM. On others, 
it will be ZONE_DMA. See the function find_usable_zone_for_movable()

ZONE_MOVABLE never spans zones. For example, it will not use some 
ZONE_HIGHMEM and some ZONE_NORMAL memory.

>> The anti-fragmentation code could potentially be used to have subzone groups
>> that kept movable and unmovable allocations as far apart as possible and at
>> opposite ends of a zone. That approach has been kicked a few times because of
>> complexity.
>
> Hmm... But his patch also introduces additional complexity plus its
> difficult to handle for the end user.
>

It's harder for the user to setup all right. But it works within limits 
that are known well in advance and doesn't add additional code to the main 
allocator path. Once it's setup, it acts like any other zone and zone 
behavior is better understood than anti-fragmentations behavior.

>>> There are some NUMA architectures that are not that
>>> symmetric.
>> I know, it's why find_zone_movable_pfns_for_nodes() is as complex as it is.
>> The mechanism spreads the unmovable memory evenly throughout all nodes. In the
>> event some nodes are too small to hold their share, the remaining unmovable
>> memory is divided between the nodes that are larger.
>
> I would have expected a percentage of a node. If equal amounts of
> unmovable memory are assigned to all nodes at first then there will be
> large disparities in the amount of movable memories f.e. between a node
> with 8G memory compared to a node with 1GB memory.
>

On the other hand, percentages make it harder for the administrator to 
know in advance how much unmovable memory will be available when the 
system starts even if the machine changes configuration. The absolute 
figure is easier to understand. If there was a requirement, an alternative 
configuration option could be made available that takes a fixed percentage 
of each node with memory.

> How do you handle headless nodes? I.e. memory nodes with no processors?

The code only cares about memory, not processors.

> Those may be particularly large compared to the rest but these are mainly
> used for movable pages since unmovable things like device drivers buffers
> have to be kept near the processors that take the interrupt.
>

Then what I'd do is specify kernelcore to be

(number_of_nodes_with_processors * largest_amount_of_memory_on_node_with_processors)

That would have all memory near processors available as unmovable memory 
(that movable allocations will still use so they don't always go remote) 
while keeping a large amount of memory on the headless nodes for movable 
allocations only.

If requirements demanded, a configuration option could be made that allows 
the administrator to specify exactly how much unmovable memory he wants on 
a specific node.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
