Date: Thu, 2 Nov 2006 20:58:20 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
 <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
 <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Nov 2006, Christoph Lameter wrote:

> On Thu, 2 Nov 2006, Andy Whitcroft wrote:
>
>> with no reclaimable blocks regardless of algorithm.  Unless we are going
>> to allow all pages to be reclaimed (which is a massive job of
>> unthinkable proportions IMO) then we need some kind of placement scheme
>> to aid reclaim.
>
> The pages clearly need to be separated according to movable and
> unmovable. However, I think reclaimable needs to be the default
> and some simple measures will make a significant portion of the pages that
> we cannot currently move movable.
>

Ok... list-based anti-frag identified three types of pages. From the 
leading mail;

EasyReclaimable - These are userspace pages that are easily reclaimable. This
         flag is set when it is known that the pages will be trivially reclaimed
         by writing the page out to swap or syncing with backing storage

KernelReclaimable - These are allocations for some kernel caches that are
         reclaimable or allocations that are known to be very short-lived.

KernelNonReclaimable - These are pages that are allocated by the kernel that
         are not trivially reclaimed. For example, the memory allocated for a
         loaded module would be in this category. By default, allocations are
         considered to be of this type

The EasyReclaimable and KernelReclaimable allocations are marked with 
__GFP flags.

Now, you want to separate pages according to movable and unmovable. 
Broadly speaking, EasyReclaimable == Movable and 
KernelReclaimable+KernelNonReclaimable == Non-Movable. However, while 
KernelReclaimable are Non-Movable, they can be reclaimed by purging 
caches. So, if we redefined the three terms to be Movable, Reclaimable and 
Non-Movable, you get the separation you are looking for at least within a 
MAX_ORDER_NR_PAGES.

> Unmovable pages need to be managed with some sort of special scheme and
> are need to be kept together in a separate pool or something, They do not
> need memory policy support f.e. Regular allocations should be left
> unchanged and continue to be handled as is. Unmovable pages may have a
> special flag or be handled in some special way.
>

"Special way" to me is just "place them somewhere smart". If their 
location was really important for hot-unplug, a placement policy could 
always use MAX_ORDER_NR_PAGES at the lower PFNs in a zone for them. This 
should be easier than introducing additional memory pools, zones or other 
mechanisms.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
