Message-ID: <45C8B1BC.4080803@redhat.com>
Date: Tue, 06 Feb 2007 11:50:04 -0500
From: Larry Woodman <lwoodman@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/7] Move mlocked pages off the LRU and track them
References: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com> <1170777882.4945.31.camel@localhost>
In-Reply-To: <1170777882.4945.31.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:

>On Mon, 2007-02-05 at 12:52 -0800, Christoph Lameter wrote:
>  
>
>>[RFC] Remove mlocked pages from the LRU and track them
>>
>>The patchset removes mlocked pages from the LRU and maintains a counter
>>for the number of discovered mlocked pages.
>>
>>This is a lazy scheme for accounting for mlocked pages. The pages
>>may only be discovered to be mlocked during reclaim. However, we attempt
>>to detect mlocked pages at various other opportune moments. So in general
>>the mlock counter is not far off the number of actual mlocked pages in
>>the system.
>>
>>Patch against 2.6.20-rc6-mm3
>>
>>Known problems to be resolved:
>>- Page state bit used to mark a page mlocked is not available on i386 with
>>  NUMA.
>>- Note tested on SMP, UP. Need to catch a plane in 2 hours.
>>
>>Tested on:
>>IA64 NUMA 12p
>>    
>>
>
>Note that anon [and shmem] pages in excess of available swap are
>effectively mlocked().  In the field, we have seen non-NUMA x86_64
>systems with 64-128GB [16-32million 4k pages] with little to no
>swap--big data base servers.  The majority of the memory is dedicated to
>large data base shared memory areas.  The remaining is divided between
>program anon and page cache [executable, libs] pages and any other page
>cache pages used by data base utilities, system daemons, ...
>
>The system runs fine until someone runs a backup [or multiple, as there
>are multiple data base instances running].  This over commits memory and
>we end up with all cpus in reclaim, contending for the zone lru lock,
>and walking an active list of 10s of millions of pages looking for pages
>to reclaim.  The reclaim logic spends a lot of time walking the lru
>lists, nominating shmem pages [the majority of pages on the list] for
>reclaim, only to find in shrink_pages() that it can't move the page to
>swap.  So, it puts it back on the list to be retried by the other cpus
>once they obtain the zone lru lock.  System appears to be hung for long
>periods of time.
>
Its actually more complicated that this.  The pagecache pages from the 
backup are
placed on the head of inactive list when they are initialized via 
add_to_page_cache(). 
If they get referenced again, mark_page_accessed() moves then to the 
tail of the
active list.  At this point they wont be considered for deactivation and 
reclamation
until every other page in the system is.  They probably should go on the 
head of the
inactive list if they are not mapped, for at least one more time.  Once 
we start adding
clean, unmapped pagecache pages behind anonymous and mapped system V shared
memory pages on the active list we start swapping while there are better 
pages to select
for reclamation.  This prevents kswapd from keeping the free pages above 
min and
then every caller of __alloc_pages() starts reclaiming memory on every 
zone in the
zone list.  Once the system is in that state the whole distress 
algorithm in shrink_active_list()
doesnt work right any more because it uses prev_priority as the distress 
shift.  This
means that if one caller of shrink_active_list() is deactivating mapped 
anonymous memoy
because the priority got that high(actually low) every caller is 
deactivating mapped
anonymous memoy.  The system degrades to a point where both the active 
and inactive
lists contain a mixture of dirty and clean, mapped and unmapped, 
pagecache and
anonymous memory and every CPU is down in try_to_free_pages() mixing it even
further.

>
>There are a lot of behaviors in the reclaim code that exacerbate the
>problems when we get into this mode, but the long lists of unswappable
>anon/shmem pages is the major culprit.  One of the guys at Red Hat has
>tried a "proof of concept" patch to move all anon/shmem pages in excess
>of swap space to "wired list" [currently global, per node/zone in
>progress] and it seems to alleviate the problem.  
>
>So, Christoph's patch addresses a real problem that we've seen.
>Unfortunately, not all data base applications lock their shmem areas
>into memory.  Excluding pages from consideration for reclaim that can't
>possibly be swapped out due to lack of swap space seems a natural
>extension of this concept.  I expect that many Christoph's customers run
>with swap space that is much smaller than system memory and would
>benefit from this extension.
>
>Lee
>
>  
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
