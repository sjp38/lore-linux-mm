Date: Tue, 1 May 2007 17:38:59 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Antifrag patchset comments
In-Reply-To: <463723DE.9030507@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0705011737240.6463@skynet.skynet.ie>
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie>
 <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
 <463723DE.9030507@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Nick Piggin wrote:

> Christoph Lameter wrote:
>> On Sat, 28 Apr 2007, Mel Gorman wrote:
>
>>>> 10. Radix tree as reclaimable? radix_tree_node_alloc()
>>>>
>>>> 	Ummm... Its reclaimable in a sense if all the pages are removed
>>>> 	but I'd say not in general.
>>>> 
>>> 
>>> I considered them to be indirectly reclaimable. Maybe it wasn't the best
>>> choice.
>> 
>> 
>> Maybe we need to ask Nick about this one.
>
> I guess they are as reclaimable as the pagecache they hold is. Of
> course, they are yet another type of object that makes higher order
> reclaim inefficient, regardless of lumpy reclaim etc.
>

That can be said of the reclaimable slab caches as well. That is why they
are grouped together. Unlike page cache and buffer pages, the pages involved
cannot be freed without another subsystem being involved.

> ... and also there are things besides pagecache that use radix trees....
>
> I guess you are faced with conflicting problems here. If you do not
> mark things like radix tree nodes and dcache as reclaimable, then your
> unreclaimable category gets expanded and fragmented more quickly.
>

This is understood. It's why the principal mobility types are UNMOVABLE,
RECLAIMABLE and MOVABLE instead of UNMOVABLE and MOVABLE which was suggested
to me in the past.

> On the other hand, if you do mark them (not just radix-trees, but also
> bios, dcache, various other things) as reclaimable, then they make it
> more difficult to reclaim from the reclaimable memory,

This is why dcache and various other things with similar difficulty are
in the RECLAIMABLE areas, not the MOVABLE area. This is deliberate as they
all get to be difficult together. Care is taken to group pages appropriately
so that only easily movable allocations are in the MOVABLE area.

> and they also
> make the reclaimable memory less robust, because you could have pinned
> dentry, or some other radix tree user in there that cannot be reclaimed.
>

Which is why the success rates of hugepage allocation under heavy load
depends more on the number of MOVABLE blocks than RECLAIMABLE.

> I guess making radix tree nodes reclaimable is probably the best of the
> two options at this stage.
>

The ideal would be that some caches would become directly reclaimable over
time including the radix tree nodes. i.e. given a page that belongs to an
inode cache that it would be possible to reclaim all the objects within
that page and free it.

If that was the case for all reclaimable caches, then the RECLAIMABLE portion
of memory becomes much more useful. Right now, it depends on a certain amount
of luck that randomly freeing cache objects will free contiguous blocks in the
RECLAIMABLE area. There was a similar problem for the MOVABLE area until lumpy
reclaim targetted its reclaim. Similar targetting of slab pages is desirable.

> But now that I'm asked, I repeat my dislike for the antifrag patches,
> because of the above -- ie. they're just a heuristic that slows down
> the fragmentation of memory rather than avoids it.
>
> I really oppose any code that _depends_ on higher order allocations.
> Even if only used for performance reasons, I think it is sad because
> a system that eventually gets fragmented will end up with worse
> performance over time, which is just lame.

Although performance could degrade were fragmentation avoidance ineffective,
it seems wrong to miss out on that performance improvement through a dislike
of it.  Any use of high-order pages for performance will be vunerable to
fragmentation and would need to handle it.  I would be interested to see
any proposed uses both to review them and to see how they interact with
fragmentation avoidance, as test cases.

> For those systems that really want a big chunk of memory set aside (for
> hugepages or memory unplugging), I think reservations are reasonable
> because they work and are robust.

Reservations don't really work for memory unplugging at all. Hugepage
reservations have to be done at boot-time which is a difficult requirement
to meet and impossible on batch job and shared systems where reboots do
not take place.

> If we ever _really_ needed arbitrary
> contiguous physical memory for some reason, then I think virtual kernel
> mapping and true defragmentation would be the logical step.
>

Breaking the 1:1 phys:virtual mapping incurs a performance hit that is
persistent. Minimally, things like page_to_pfn() are no longer a simply
calculation which is a bad enough hit. Worse, the kernel can no longer backed by
huge pages because you would have to defragment at the base-page level. The
kernel is backed by huge page entries at the moment for a good reason,
TLB reach is a real problem.

Continuing on, "true defragmentation" would require that the system be
halted so that the defragmentation can take place with everything disabled
so that the copy can take place and every processes pagetables be updated
as pagetables are not always shared.  Even if shared, all processes would
still have to be halted unless the kernel was fully pagable and we were
willing to handle page faults in kernel outside of just the vmalloc area.

This is before even considering the problem of how the kernel copies the
data between two virtual addresses while it's modifing the page tables
it's depending on to read the data. Even more horribly, virtual addresses
in the kernel are no longer physically contiguous which will likely cause
some problems for drivers and possibly DMA engines.

The memory compaction mechanism I have in mind operates on MOVABLE pages
only using the page migration mechanism with the view to keeping MOVABLE and
RECLAIMABLE pages at opposite end of the zone. It doesn't bring the kernel
to the halt like it was a Java Virtual Machine or a lisp interpreter doing
garbage collection.

> AFAIK, nobody has tried to do this yet it seems like the (conceptually)
> simplest and most logical way to go if you absolutely need contig
> memory.
>

I believe there was some work at one point to break the 1:1 phys:virt mapping
that Dave Hansen was involved it. It was a non-trivial breakage and AFAIK,
it made things pretty slow and lost the backing of the kernel address space
with large pages.  Much time has been spent making sure the fragmentation
avoidance patches did not kill performance. As the fragmentation avoidance
stuff improves the TLB usage in the kernel portion of the address space, it
improves performance in some cases. That alone should be considered a positive.

Here are test figures from an x86_64 without min_free_kbytes adjusted
comparing fragmentation avoidance on 2.6.21-rc6-mm1. Newer figures are
being generated but it takes a long time to go through it all.

KernBench Comparison
--------------------
                           2.6.21-rc6-mm1-clean 2.6.21-rc6-mm1-list-based      %diff
User   CPU time                          85.55                     86.27     -0.84%
System CPU time                          35.85                     33.67      6.08%
Total  CPU time                          121.4                    119.94      1.20%

Complaints about kernbench as a valid benchmark aside, it is dependent on
the page allocator's performance. The figures show a 1.2% overall improvement
in total CPU time. The AIM9 results look like

                  2.6.21-rc6-mm1-clean  2.6.21-rc6-mm1-list-based
  1 creat-clo                154674.22                  171921.35   17247.13 11.15% File Creations and Closes/second
  2 page_test                184050.99                  188470.25    4419.26  2.40% System Allocations & Pages/second
  3 brk_test                1840486.50                 2011331.44  170844.94  9.28% System Memory Allocations/second
  6 exec_test                   224.01                     234.71      10.70  4.78% Program Loads/second
  7 fork_test                  3892.04                    4325.22     433.18 11.13% Task Creations/second

More improvements here although I'll admit aim9 can be unreliable on some
machines. The allocation of hugepages under load and at rest look like

HighAlloc Under Load Test Results
                            2.6.21-rc6-mm1-clean  2.6.21-rc6-mm1-list-based 
Order                                         9                          9 
Allocation type                         HighMem                    HighMem 
Attempted allocations                       499                        499 
Success allocs                               33                        361 
Failed allocs                               466                        138 
DMA32 zone allocs                            31                        359 
DMA zone allocs                               2                          2 
Normal zone allocs                            0                          0 
HighMem zone allocs                           0                          0 
EasyRclm zone allocs                          0                          0 
% Success                                     6                         72 
HighAlloc Test Results while Rested
                            2.6.21-rc6-mm1-clean  2.6.21-rc6-mm1-list-based 
Order                                         9                          9 
Allocation type                         HighMem                    HighMem 
Attempted allocations                       499                        499 
Success allocs                              154                        366 
Failed allocs                               345                        133 
DMA32 zone allocs                           152                        364 
DMA zone allocs                               2                          2 
Normal zone allocs                            0                          0 
HighMem zone allocs                           0                          0 
EasyRclm zone allocs                          0                          0 
% Success                                    30                         73

On machines with large TLBs that can fit the entire working set no matter
what, the worst performance regression we've seen is 0.2% in total CPU
time in kernbench which is comparable to what you'd see between kernel
versions. I didn't spot anything out of the way in the performance figures
on test.kernel.org either since fragmentation avoidance was merged.

> But firstly, I think we should fight against needing to do that step.
> I don't care what people say, we are in some position to influence
> hardware vendors, and it isn't the end of the world if we don't run

This is conflating the large page cache discussion with the fragmentation
avoidance patches. If fragmentation avoidance is merged and the page cache
wants to take advantage of it, it will need to;

a) deal with the lack of availability of contiguous pages if fragmentation
    avoidance is ineffective
b) be reviewed to see what its fragmentation behaviour looks like

Similar comments apply to SLUB if it uses order-1 or order-2 contiguous
pages although SLUB is different because as it'll make most reclaimable
allocations the same order. Hence they'll also get freed at the same order
so it suffers less from external fragmentation problems due to less mixing
of orders than one might initially suspect.

Ideally, any subsystem using larger pages does a better job than a "reasonable
job". At worst, any use of contiguous pages should continue to work if they
are not available and at *worst*, it's performance should comparable to base
page usage.

Your assertion seems to be that it's better to always run slow than run
quickly in some situations with the possibility it might slow down later. We
have seen some evidence that fragmentation avoidance gives more consistent
results when running kernbench during the lifetime of the system than without
it. Without it, there are slowdowns probably due to reduced TLB reach.

> optimally on some hardware today. I say we try to avoid higher order
> allocations. It will be hard to ever remove this large amount of
> machinery once the code is in.
>
> So to answer Andrew's request for review, I have looked through the
> patches at times, and they don't seem to be technically wrong (I would
> have prefered that it use resizable zones rather than new sub-zone
> zones, but hey...).

The resizable zones option was considered as well and it seemed messier than
what the current stuff does. Not only do we have to deal with overlapping
non-contiguous zones, but things like the page->flags identifying which
zone a page belongs to have to be moved out (not enough bits) and you get
an explosion of zones like

ZONE_DMA_UNMOVABLE
ZONE_DMA_RECLAIMABLE
ZONE_DMA_MOVABLE
ZONE_DMA32_UNMOVABLE

etc. Everything else aside, that will interact terribly with reclaim.

In the end, it would also suffer from similar problems with the size of
the RECLAIMABLE areas in comparison to MOVABLE and resizing zones would
be expensive.

> However I am against the whole direction they go
> in, so I haven't really looked at them lately.
>
> I think the direction we should take is firstly ask whether we can do
> a reasonable job with PAGE_SIZE pages, secondly ask whether we can do
> an acceptable special-case (eg. reserve memory),

Hugepage-wise, memory gets reserved and it's a problem on systems that
have changing requirements for the number of hugepages they need available.
i.e. the current real use cases for the reservation model have runtime and
system management problems.  From what I understand, some customers have
bought bigger machines and not used huge pages because the reserve model
was too difficult to deal with.

Base pages are unusuable for memory hot-remove particularly on ppc64 running
virtual machines where it wants to move memory in 16MB chunks between
machine partitions.

> lastly, _actually_
> do defragmentation of kernel memory. Anti-frag would come somewhere
> after that last step, as a possible optimisation.
>

This is in the wrong order. Defragmentation of memory makes way more sense
when anti-fragmentation is already in place. There is less memory that
will require moving. Full defragmentation requires breaking 1:1 phys:virt
mapping or halting the machine to get useful work done. Anti-fragmentation
using memory compaction of MOVABLE pages should handle the situation without
breaking 1:1 mappings.

> So I haven't been following where we're at WRT the requirements. Why
> can we not do with PAGE_SIZE pages or memory reserves?

PAGE_SIZE pages cannot grow the hugepage pool. The size of the hugepage
pool required for the lifetime of the system is not always known. PPC64 is
not able to hot-remove a single page and the balloon driver from Xen has
it's own problems. As already stated, reserves come with their own host of
problems that people are not willing to deal with.

> If it is a
> matter of efficiency, then how much does it matter, and to whom?
>

The kernel already uses huge PTE entries in its portion of the address
space because TLB reach is a real problem. Grouping kernel allocations
together in the same hugepages improves overall performance due to reduced
TLB pressure. This is a general improvement and how much of an effect it
has depends on the workload and the TLB size.

>From your other mail

> Oh, and: why won't they get upset if memory does eventually end up
> getting fragmented?

For hugepages, it's annoying because the application will have to fallback to
using small pages which is not always possible and it loses performance. I
get bad emails but the system survives. For memory hot-remove (be it
virtualisation, power saving or whatever), I get sent another complaining
email because the memory can not be removed but the system again lives.

So, for those two use cases, if memory gets fragmented there is a non-critical
bug report and the problem gets kicked by me with some egg on my face.

Going forward, the large page cache stuff will need to deal with a situation
where contiguous pages are not available. What I see happening is that an API
like buffered_rmqueue() is available that gives back an amount of memory in
a list that is as contiguous as possible. This seems feasible and it would
be best if stats were maintained on how often contiguous pages were actually
used to diagnose bug reports that look like "IO performs really well for a
few weeks but then starts slowing up". At worst it should regress to the
vanilla kernels performance at which point I get a complaining email but
again, the system survives.

SLUB using higher orders needs to be tested but as it is using lower orders
to begin with, it may not be an issue. If the minimum page size it uses is
fixed, then many blocks within the RECLAIMABLE areas will be the same size
in the vast majority of cases. As they get freed, they'll be freeing at the
same minimum order so it should not hit external fragmentation problems. This
hypothesis will need to be tested heavily before merging but the bug reports
at least will be really obvious (system went BANG) and I'm in the position
to kick this quite heavily using the test.kernel.org system.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
