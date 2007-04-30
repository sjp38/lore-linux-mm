Date: Mon, 30 Apr 2007 19:33:29 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Antifrag patchset comments
In-Reply-To: <Pine.LNX.4.64.0704301026460.6343@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704301926290.4852@skynet.skynet.ie>
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie>
 <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704301016180.32439@skynet.skynet.ie>
 <Pine.LNX.4.64.0704301026460.6343@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Christoph Lameter wrote:

> On Mon, 30 Apr 2007, Mel Gorman wrote:
>
>>> Indeed that is a good thing.... It would be good if a movable area
>>> would be a dynamic split of a zone and not be a separate zone that has to
>>> be configured on the kernel command line.
>> There are problems with doing that. In particular, the zone can only be sized
>> on one direction and can only be sized at the zone boundary because zones do
>> not currently overlap and I believe there will be assumptions made about them
>> not overlapping within a node. It's worth looking into in the future but I'm
>> putting it at the bottom of the TODO list.
>
> Its is better to have a dynamic limit rather than OOMing.
>

I'll certainly give the problem a kick. I simply have a strong feeling 
that dynamically resizing zones will not be very straight-forward and as 
the zone is manually sized by the administrator, I didn't feel strongly 
about it being possible for an admin to put his machine in an OOM-able 
situation.

>>>> If the RECLAIMABLE areas could be properly targeted, it would make sense
>>>> to
>>>> mark these pages RECLAIMABLE instead but that is not the situation today.
>>> What is the problem with targeting?
>> It's currently not possible to target effectively.
>
> Could you be more specific?
>

The situation I wanted to end up with was that a percentage of memory 
could be reclaimed or moved so that contiguous allocations would succeed. 
When reclaiming __GFP_MOVABLE, we can use lumpy reclaim to find a suitable 
area of pages to reclaim. Some of the pages there are buffer pages even 
though they are not movable in the page migration sense of the word.

Given a page allocated for an inode slab cache, we can't reclaim the 
objects in there in the same way as a buffer page can be cleaned and 
discared.

Hence, to increase the amount of memory that can be reclaimed for 
contiguous allocations, I group the buffer pages with other movable pages 
instead of putting them in with __GFP_RECLAIMABLE pages like slab where 
they are not as useful from a future contiguous allocation perspective.

In the event that given a page of slab objects I could be sure of 
reclaiming all the objects in that page and freeing it, then it would make 
sense to group buffer pages with those.

Does that make sense?

>>>> Because they might be ramfs pages which are not movable -
>>>> http://lkml.org/lkml/2006/11/24/150
>>>
>>> URL does not provide any useful information regarding the issue.
>>>
>>
>> Not all pages allocated via shmem_alloc_page() are movable because they may
>> pages for ramfs.
>
> Not familiar with ramfs. There would have to be work on ramfs to make them
> movable?

Minimally yes. I haven't looked too closely at the issue yet because to 
start with, it was enough to know that the pages were not always movable 
or reclaimable in any way other than deleting files.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
