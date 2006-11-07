Date: Tue, 7 Nov 2006 18:14:31 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611070947100.3791@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0611071756050.11212@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
 <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
 <Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611031825420.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031124340.15242@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031329480.16397@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611071629040.11212@skynet.skynet.ie>
 <Pine.LNX.4.64.0611070947100.3791@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Nov 2006, Christoph Lameter wrote:

> On Tue, 7 Nov 2006, Mel Gorman wrote:
>
>> Hence, I'm still convinced that slab pages for caches like inode and
>> short-lived allocations need to be clustered separetly.
>
> So the problem seems to be that some slab of "reclaimable" slabs are
> not reclaimable at all even with the most aggressive approach?
>

Right. You may be able to shrink the slab cache considerably, but still 
not empty it. By clustering the pages together, shrinking all the caches 
has a chance of freeing up high order pages but there is no guarantee of 
course.

> Then we have a fundamental issue that we are unable to categorize
> pages correctly. EasyReclaimable pages may be unreclaimable because they
> are mlocked.

They are migratable though. In the patchset I am currently working on, I 
identify pages as Movable, Reclaimable and Unmovable. The redefinitions 
are a bit more logical (especially for mlock) and move away from the idea 
of page reclaim being the only way of getting high order allocations to 
succeed.

> Reclaimable (such as slab pages) may turn out to be not
> reclaimable because some entries are pinned.
>

yep. That will hurt hugepage allocations in those blocks but it should 
help allocations required for network cards with large MTUs for example.

> I think we will run into the same issues for EasyReclaim once an
> application generates a sufficient amount of mlocked pages that are
> placed all over the memory of interest.
>

Yep, I agree. At that point, migration will be required but the clustering 
will be in place so that moving all the "movable" pages will result in 
large contiguous free pages.

> Could it be that the only reason that the current approach works is that
> we have not tested with an application that behaves this way?
>

Probably. The applications I currently test are not mlocking. The tests 
currently run workloads that are known to leave the system in a fragmented 
state when they complete. In this situation, higher-order allocations fail 
even when nothing is running and there are no mlocked() pages on the 
standard allocator.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
