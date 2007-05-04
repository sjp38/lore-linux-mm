Message-ID: <463ACFCB.9080003@yahoo.com.au>
Date: Fri, 04 May 2007 16:16:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Antifrag patchset comments
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie> <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com> <463723DE.9030507@yahoo.com.au> <Pine.LNX.4.64.0705011737240.6463@skynet.skynet.ie> <4637FADB.5080009@yahoo.com.au> <Pine.LNX.4.64.0705021340430.6092@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0705021340430.6092@skynet.skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Wed, 2 May 2007, Nick Piggin wrote:
> 
>> Mel Gorman wrote:

>> > reservations have to be done at boot-time which is a difficult
>> > requirement
>> > to meet and impossible on batch job and shared systems where reboots do
>> > not take place.
>>
>> You just have to make a tradeoff about how much memory you want to set
>> aside.
> 
> 
> This tradeoff in sizing the reservation is something that users of shared
> systems have real problems with because a hugepool once sized can only be
> used for hugepage allocations. One compromise lead to the development of
> ZONE_MOVABLE where a portion of memory could be set aside that was usable
> for small pages but that the huge page pool could borrow from.

What's wrong with that? Do we have any of that stuff upstream yet, and
if not, then that probably should be done _first_. From there we can see
what is left for the anti-fragmentation patches...


>> Note that this memory is not wasted, because it is used for user
>> allocations. So I think the downsides of reservations are really
>> overstated.
>>
> 
> This does sound like you think the first step here would be a zone based
> reservation system.  Would you support inclusion of the ZONE_MOVABLE part
> of the patch set?

Ah, that answers my questions. Yes, I don't see why not, if the various
people who were interested in that feature are happy with it. Not that I
looked at the most recent implementation (which patches are they?)


>> > persistent. Minimally, things like page_to_pfn() are no longer a simply
>> > calculation which is a bad enough hit. Worse, the kernel can no longer
>> > backed by
>> > huge pages because you would have to defragment at the base-page level.
>> > The
>> > kernel is backed by huge page entries at the moment for a good reason,
>> > TLB reach is a real problem.
>>
>> Yet this is what you _have_ to do if you must use arbitrary physical
>> memory. And I haven't seen any numbers posted.
>>
> 
> Numbers require an implementation and that is a non-trivial undertaking.
> I've cc'd Dave Hansen who I believe tried breaking 1:1 phys:virtual mapping
> some time in the past. He might have further comments to make.

I'm sure it wouldn't be trivial :)

TLB's are pretty good, though. Virtualised kernels don't seem to take a
huge hit (I had some vague idea that a lot of their performance problems
were with IO).


>> > Continuing on, "true defragmentation" would require that the system be
>> > halted so that the defragmentation can take place with everything
>> > disabled
>> > so that the copy can take place and every processes pagetables be
>> > updated
>> > as pagetables are not always shared.  Even if shared, all processes
>> > would
>> > still have to be halted unless the kernel was fully pagable and we were
>> > willing to handle page faults in kernel outside of just the vmalloc
>> > area.
>>
>> vunmap doesn't need to run with the system halted, so I don't see why
>> unmapping the source page would need to.
>>
> 
> vunmap() is freeing an address range where it knows it is the only accessor
> of any data in that range. It's not the same when there are other processes
> potentially memory in the same area at the same time expecting it to exist.

I don't see what the distinction is. We obviously wouldn't have multiple
processes with different kernel virtual addresses pointing to the same
page. It would be managed almost exactly like vmalloc space is today, I'd
imagine.


>> I don't know why we'd need to handle a full page fault in the kernel if
>> the critical part of the defrag code runs atomically and replaces the
>> pte when it is done.
>>
> 
> And how exactly would one atomically copy a page of data, update the page
> tables and flush the TLB without stalling all writers?  The setup would 
> have
> to mark the PTE for that area read-only and flush the TLB so that other
> processes will fault on write and wait until the migration has completed
> before retrying the fault. That would allow the data to be safely read and
> copied to somewhere else.

Why is there a requirement to prevent stalling of writers?


> It would be at least feasible to back SLAB_RECLAIM_ACCOUNT slabs by a
> virtual map for the purposes of defragmenting it like this. However, it
> would work better in conjunction with fragmentation avoidance instead of
> replacing it because the fragmentation avoidance mechanism could be easily
> used to group virtually-backed allocations together in the same physical
> blocks as much as possible to reduce future migration work.

Yeah, maybe. But what I am getting at is that fragmentation avoidance
isn't _the_ big ticket (as the name implies). Defragmentation is. With
defragmentation in, I think that avoidance makes much more sense.

Now I'm still hoping that neither is necessary... my thought process
on this is to keep hoping that nothing comes up that _requires_ us to
support higher order allocations in the kernel generally.

As an aside, it might actually be nice to be able to reduce MAX_ORDER
significantly after boot in order to reduce page allocator overhead...


>> > This is before even considering the problem of how the kernel copies 
>> the
>> > data between two virtual addresses while it's modifing the page tables
>> > it's depending on to read the data.
>>
>> What's the problem: map the source page into a special area, unmap it
>> from its normal address, allocate a new page, copy the data, swap the
>> mapping.
>>
> 
> You'd have to do something like I described above to handle synchronous
> writes to the area during defragmentation.

Yeah, that's what the "unmap the source page" is (which would also block
reads, and I think would be a better approach to try first, because it
would reduce TLB flushing. Although moving and flushing could probably
be batched, so mapping them readonly first might be a good optimisation
after that).


>> > Even more horribly, virtual addresses
>> > in the kernel are no longer physically contiguous which will likely
>> > cause
>> > some problems for drivers and possibly DMA engines.
>>
>> Of course it is trivial to _get_ physically contiguous, virtually
>> contiguous pages, because now you actually have a mechanism to do so.
>>
> 
> I think that would require that the kernel portion have a split between the
> vmap() like area and a 1:1 virt:phys area - i.e. similar to today except 
> the
> vmalloc() region is bigger. It is difficult to predict what the impact of a
> much expanded use of the vmalloc area would be.

Yeah that would probably be reasonable. So huge tlbs could still be used
for various large boot time structures.

Predicting the impact of it? Could we look at how something like KVM
performs when using 4K pages for its memory map?


>> It isn't performance of your patches I'm so worried about. It is that
>> they only slow down the rate of fragmentation, so why do we want to add
>> them and why can't we use something more robust?
>>
> 
> Because as I've maintained for quite some time, I see the patches as
> a pre-requisite for a more complete and robust solution for dealing with
> external fragmentation. I see the merits of what you are suggesting but 
> feel
> it can be built up incrementally starting with the fragmentation avoidance
> stuff, then compacting MOVABLE pages towards the end of the zone before
> finally dealing with full defragmentation.  But I am reluctant to built
> large bodies of work on top of a foundation with an uncertain future.

The first thing we need to decide is if there is a big need to support
higher order allocations generally in the kernel. I'm still a "no" with
that one :)

If and when we decide "yes", I don't see how anti-fragmentation does much
good for that -- all the new wonderful higher order allocations we add in
will need fallbacks, and things can slowly degrade over time which I'm
sorry but that really sucks.

I think that to decide yes, we have to realise that requires real
defragmentation. At that point, OK, I'm not going to split hairs over
whether you think anti-frag logically belongs first (I think it
doesn't :)).

>> hugepages are a good example of where you can use reservations.
>>
> 
> Except that it has to be sized at boot-time, can never grow and users find
> it very inflexible in the real world where requirements change over time
> and a reboot is required to effectively change these reservations.
> 
>> You could even use reservations for higher order pagecache (rather than
>> crapping the whole thing up with small-pages fallbacks everywhere).
>>
> 
> True, although that means that an administrator is then required to size
> their buffer cache at boot time if they are using high order pagecache. I
> doubt they'll like that any more than sizing a hugepage pool.
> 
>> I don't think it is. Because the only reason to need more than a couple
>> of physically contiguous pages is to work around hardware limitations or
>> inefficiency.
>>
> 
> A low TLB reach with base page size is a real problem that some classes of
> users have to deal with. Sometimes there just is no easy way around having
> to deal with large amounts of data at the same time.

To the 3 above: yes, I completely know we are not and never will be
absolutely optimal for everyone. And the end-game for Linux, if there
is one, I don't think is to be in a state that is perfect for everyone
either. I don't think any feature can be justified simply because
"someone" wants it, even if those someones are people running benchmarks
at big companies.


>> No. My assertion is that we should speed things up in other ways, eg.
> 
> 
> The principal reason I developed fragmentation avoidance was to relax
> restrictions on the resizing of the huge page pool where it's not a 
> question
> of poor performance, it's a question of simply not working. The large page
> cache stuff arrived later as a potential additional benefiticary of lower
> fragmentation as well as SLUB.

So that's even worse than a purely for performance patch, because it
can now work for a while and then randomly stop working eventually.


>> > what the current stuff does. Not only do we have to deal with
>> > overlapping
>> > non-contiguous zones,
>>
>> We have to do that anyway, don't we?
>>
> 
> Where do we deal with overlapping non-contiguous zones within a node today?

In the buddy allocator and physical memory models, I guess?

http://marc.info/?l=linux-mm&m=114774325131397&w=2

Doesn't that imply overlapping non-contiguous zones?


>> > but things like the page->flags identifying which
>> > zone a page belongs to have to be moved out (not enough bits)
>>
>> Another 2 bits? I think on most architectures that should be OK,
>> shouldn't it?
>>
> 
> page->flags is not exactly flush with space. The last I heard, there
> were 3 bits free and there was work being done to remove some of them so
> more could be used.

No, you wouldn't be using that part of the flags, but the other
part. AFAIK there is reasonable amount of room on 64-bit, and only
on huge NUMA 32-bit (ie. dinosaurs) is it a squeeze... but it falls
back to an out of line thingy anyway.


>> > and you get
>> > an explosion of zones like
>> > > ZONE_DMA_UNMOVABLE
>> > ZONE_DMA_RECLAIMABLE
>> > ZONE_DMA_MOVABLE
>> > ZONE_DMA32_UNMOVABLE
>>
>> So of course you don't make them visible to the API. Just select them
>> based on your GFP_ movable flags.
>>
> 
> Just because they are invisible to the API does not mean they are invisible
> to the size of pgdat->node_zones[] and the size of the zone fallback lists.
> Christoph will eventually complain about the number of zones having doubled
> or tripled.

Well there is already a reasonable amount of duplication, eg pcp lists.
And I think it is much better to put up with a couple of complaints from
Christoph rather than introduce something entirely new if possible. Hey
it might even give people an incentive to improve the existing schemes.


>> > etc.
>>
>> What is etc? Are those the best reasons why this wasn't made to use 
>> zones?
>>
> 
> No, I simply thought those problems were bad enough without going into
> additional ones - here's another one. If a block of pages has to move
> between zones, page->flags has to be updated which means a lock to the page
> has to be acquired to guard against concurrent use before moving the zone.

If you're only moving free pages, then the page allocator lock should be
fine. There may be a couple of other places that would need help (eg
swsusp)...

... but anyway, I'll snip the rest because I didn't want to digress into
implementation details so much (now I'm sorry for bringing it up).

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
