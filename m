Date: Sun, 16 Jan 2005 16:21:17 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] Avoiding fragmentation through different allocator
In-Reply-To: <20050115172317.3C0F.YGOTO@us.fujitsu.com>
Message-ID: <Pine.LNX.4.58.0501161613350.16492@skynet>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB008C77C45@fmsmsx406.amr.corp.intel.com>
 <Pine.LNX.4.58.0501122247390.18142@skynet> <20050115172317.3C0F.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 15 Jan 2005, Yasunori Goto wrote:

> There are 2 types of memory hotplug.
>
> a)SMP machine case
>   A some part of memory will be added and removed.
>
> b)NUMA machine case.
>   Whole of a node will be able to remove and add.
>   However, if a block of memory like DIMM is broken and disabled,
>   Its close from a).
>
> How to know where is hotpluggable bank is platform/archtecture
> dependent issue.
>  ex) Asking to ACPI.
>      Just node0 become unremovable, and other nodes are removable.
>      etc...
>

Is there an architecture-independant way of finding this out?

> In current your patch, first attribute of all pages are NoRclm.
> But if your patches has interface to decide where will be Rclm for
> each arch/platform, it might be good.
>

It doesn't have an API as such. In page_alloc.c, there is a function
get_pageblock_type() that returns what type of allocation the block of
memory is being used for. There is no guarentee there is only those type
of allocations there though.

>
> > The danger is
> > that allocations would fail because non-hotplug banks were already full
> > and pageout would not happen because the watermarks were satisified.
>
> In this case, if user can change attribute Rclm area to
> NoRclm, it is better than nothing.
> In hotplug patches, there will be new zone as ZONE_REMOVABLE.

What's the current attidute for adding a new zone? I felt there would be
resistence as a new zone would affect a lot of code paths and be yet
another zone that needed balancing. For example, is there a HIGHMEM
version of the ZONE_REMOVABLE or could normal and highmem be in this zone?

> But in this patch, this change attribute is a little bit difficult.
> (At first remove the pages from free_area of removable zone,
>  then add them to free_area of Un-removable zone.)
> Probably its change is easier in your patch.
>

I think the difficulty would be similar because it's still Move Pages From
A To B.

> I agree that dividing per-cpu caches is not good way.
> But if Kernel-nonreclaimable allocation use its UserRclm pool,
> its removable memory bank will be harder to remove suddenly.
> Is it correct? If so, it is not good for memory hotplug.
> Hmmmm.
>

It is correct. However, this will only happen in low-memory conditions.
For a kernel-nonreclaimable allocation to use the userrclm pool, three
conditions have to be met;

1. Kernel-nonreclaimable pool has no pages
2. There are no global 2^MAX_ORDER pages
3. Kern-reclaimable pool has no pages

This is because of the fallback order. If you were interested in testing a
particular workload, you could apply the patch, run a workload and then
look at /proc/buddyinfo. There are three counters at the end of the
output like this;

KernNoRclm Fallback count: 0
KernRclm   Fallback count: 0
UserRclm   Fallback count: 425

A fallback can get counted twice. For example, if KernNoRclm falls back to
KernRclm and then UserRclm, it's considered to be two fallbacks.

I also have (yet another) tool that is able to track exactly where each
type of allocation is. If you wanted to know precisely where each page is
and see how many non-reclaimable pages are ending up in the wrong place,
the tool could be modified to do that.

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
