Message-ID: <4637FADB.5080009@yahoo.com.au>
Date: Wed, 02 May 2007 12:43:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Antifrag patchset comments
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie> <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com> <463723DE.9030507@yahoo.com.au> <Pine.LNX.4.64.0705011737240.6463@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0705011737240.6463@skynet.skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Tue, 1 May 2007, Nick Piggin wrote:

>> But now that I'm asked, I repeat my dislike for the antifrag patches,
>> because of the above -- ie. they're just a heuristic that slows down
>> the fragmentation of memory rather than avoids it.
>>
>> I really oppose any code that _depends_ on higher order allocations.
>> Even if only used for performance reasons, I think it is sad because
>> a system that eventually gets fragmented will end up with worse
>> performance over time, which is just lame.
> 
> 
> Although performance could degrade were fragmentation avoidance 
> ineffective,
> it seems wrong to miss out on that performance improvement through a 
> dislike
> of it.  Any use of high-order pages for performance will be vunerable to
> fragmentation and would need to handle it.  I would be interested to see
> any proposed uses both to review them and to see how they interact with
> fragmentation avoidance, as test cases.

Not miss out, but use something robust, or try to get the performance
some other way.


>> For those systems that really want a big chunk of memory set aside (for
>> hugepages or memory unplugging), I think reservations are reasonable
>> because they work and are robust.
> 
> 
> Reservations don't really work for memory unplugging at all. Hugepage
> reservations have to be done at boot-time which is a difficult requirement
> to meet and impossible on batch job and shared systems where reboots do
> not take place.

You just have to make a tradeoff about how much memory you want to set
aside. Note that this memory is not wasted, because it is used for user
allocations. So I think the downsides of reservations are really overstated.

Note that in a batch environment where reboots do not take place, the
anti-frag patches can eventually stop working, but the reservations will
not.

AFAIK, reservations work for hypervisor type memory unplugging. For
arbitrary physical memory unplug, I doubt the anti-frag patches work
either. You'd need hardware support or virtually mapped kernel for that.


>> If we ever _really_ needed arbitrary
>> contiguous physical memory for some reason, then I think virtual kernel
>> mapping and true defragmentation would be the logical step.
>>
> 
> Breaking the 1:1 phys:virtual mapping incurs a performance hit that is
> persistent. Minimally, things like page_to_pfn() are no longer a simply
> calculation which is a bad enough hit. Worse, the kernel can no longer 
> backed by
> huge pages because you would have to defragment at the base-page level. The
> kernel is backed by huge page entries at the moment for a good reason,
> TLB reach is a real problem.

Yet this is what you _have_ to do if you must use arbitrary physical
memory. And I haven't seen any numbers posted.


> Continuing on, "true defragmentation" would require that the system be
> halted so that the defragmentation can take place with everything disabled
> so that the copy can take place and every processes pagetables be updated
> as pagetables are not always shared.  Even if shared, all processes would
> still have to be halted unless the kernel was fully pagable and we were
> willing to handle page faults in kernel outside of just the vmalloc area.

vunmap doesn't need to run with the system halted, so I don't see why
unmapping the source page would need to.

I don't know why we'd need to handle a full page fault in the kernel if
the critical part of the defrag code runs atomically and replaces the
pte when it is done.


> This is before even considering the problem of how the kernel copies the
> data between two virtual addresses while it's modifing the page tables
> it's depending on to read the data.

What's the problem: map the source page into a special area, unmap it
from its normal address, allocate a new page, copy the data, swap the
mapping.


> Even more horribly, virtual addresses
> in the kernel are no longer physically contiguous which will likely cause
> some problems for drivers and possibly DMA engines.

Of course it is trivial to _get_ physically contiguous, virtually
contiguous pages, because now you actually have a mechanism to do so.


>> AFAIK, nobody has tried to do this yet it seems like the (conceptually)
>> simplest and most logical way to go if you absolutely need contig
>> memory.
>>
> 
> I believe there was some work at one point to break the 1:1 phys:virt 
> mapping
> that Dave Hansen was involved it. It was a non-trivial breakage and AFAIK,
> it made things pretty slow and lost the backing of the kernel address space
> with large pages.  Much time has been spent making sure the fragmentation
> avoidance patches did not kill performance. As the fragmentation avoidance
> stuff improves the TLB usage in the kernel portion of the address space, it
> improves performance in some cases. That alone should be considered a 
> positive.
> 
> Here are test figures from an x86_64 without min_free_kbytes adjusted
> comparing fragmentation avoidance on 2.6.21-rc6-mm1. Newer figures are
> being generated but it takes a long time to go through it all.

It isn't performance of your patches I'm so worried about. It is that
they only slow down the rate of fragmentation, so why do we want to add
them and why can't we use something more robust?

hugepages are a good example of where you can use reservations.

You could even use reservations for higher order pagecache (rather than
crapping the whole thing up with small-pages fallbacks everywhere).


>> But firstly, I think we should fight against needing to do that step.
>> I don't care what people say, we are in some position to influence
>> hardware vendors, and it isn't the end of the world if we don't run
> 
> 
> This is conflating the large page cache discussion with the fragmentation
> avoidance patches. If fragmentation avoidance is merged and the page cache
> wants to take advantage of it, it will need to;

I don't think it is. Because the only reason to need more than a couple
of physically contiguous pages is to work around hardware limitations or
inefficiency.


> a) deal with the lack of availability of contiguous pages if fragmentation
>    avoidance is ineffective
> b) be reviewed to see what its fragmentation behaviour looks like
> 
> Similar comments apply to SLUB if it uses order-1 or order-2 contiguous
> pages although SLUB is different because as it'll make most reclaimable
> allocations the same order. Hence they'll also get freed at the same order
> so it suffers less from external fragmentation problems due to less mixing
> of orders than one might initially suspect.

Surely you can still have failure cases where you get fragmentation in your
unmovable thingy.


> Ideally, any subsystem using larger pages does a better job than a 
> "reasonable
> job". At worst, any use of contiguous pages should continue to work if they
> are not available and at *worst*, it's performance should comparable to 
> base
> page usage.
> 
> Your assertion seems to be that it's better to always run slow than run
> quickly in some situations with the possibility it might slow down 
> later. We
> have seen some evidence that fragmentation avoidance gives more consistent
> results when running kernbench during the lifetime of the system than 
> without
> it. Without it, there are slowdowns probably due to reduced TLB reach.

No. My assertion is that we should speed things up in other ways, eg.
by making the small pages case faster or by using something robust
like reservations. On a lot of systems it is actually quite a problem
if performance slows down over time, regardless of whether the base
performance is about the same as a non-slowing kernel.


>> optimally on some hardware today. I say we try to avoid higher order
>> allocations. It will be hard to ever remove this large amount of
>> machinery once the code is in.
>>
>> So to answer Andrew's request for review, I have looked through the
>> patches at times, and they don't seem to be technically wrong (I would
>> have prefered that it use resizable zones rather than new sub-zone
>> zones, but hey...).
> 
> 
> The resizable zones option was considered as well and it seemed messier 
> than
> what the current stuff does. Not only do we have to deal with overlapping
> non-contiguous zones,

We have to do that anyway, don't we?

> but things like the page->flags identifying which
> zone a page belongs to have to be moved out (not enough bits)

Another 2 bits? I think on most architectures that should be OK,
shouldn't it?

> and you get
> an explosion of zones like
> 
> ZONE_DMA_UNMOVABLE
> ZONE_DMA_RECLAIMABLE
> ZONE_DMA_MOVABLE
> ZONE_DMA32_UNMOVABLE

So of course you don't make them visible to the API. Just select them
based on your GFP_ movable flags.


> etc.

What is etc? Are those the best reasons why this wasn't made to use zones?


> Everything else aside, that will interact terribly with reclaim.

Why? And why does the current scheme not? Doesn't seem like it would have
to be a given. You _are_ allowed to change some things.


> In the end, it would also suffer from similar problems with the size of
> the RECLAIMABLE areas in comparison to MOVABLE and resizing zones would
> be expensive.

Why is it expensive but resizing your other things is not? And if you
already have non-contiguous overlapping zones, you _could_ even just
make them all the same size and just move pages between them.


> This is in the wrong order. Defragmentation of memory makes way more sense
> when anti-fragmentation is already in place. There is less memory that
> will require moving. Full defragmentation requires breaking 1:1 phys:virt
> mapping or halting the machine to get useful work done. Anti-fragmentation
> using memory compaction of MOVABLE pages should handle the situation 
> without
> breaking 1:1 mappings.

My arguments are about anti-fragmentation _not_ making sense without
defragmentation.


>> So I haven't been following where we're at WRT the requirements. Why
>> can we not do with PAGE_SIZE pages or memory reserves?
> 
> 
> PAGE_SIZE pages cannot grow the hugepage pool. The size of the hugepage
> pool required for the lifetime of the system is not always known. PPC64 is
> not able to hot-remove a single page and the balloon driver from Xen has
> it's own problems. As already stated, reserves come with their own host of
> problems that people are not willing to deal with.

I don't understand exactly what you mean? You don't have a hugepage pool,
but an always-reclaimable pool. So you can use this for any kind of
pagecache and even anonymous and mlocked memory assuming you account for
it correctly so it can be moved away if needed.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
