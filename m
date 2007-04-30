Date: Mon, 30 Apr 2007 19:46:42 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Antifrag patches may benefit from clean up of GFP allocation
 flags
In-Reply-To: <Pine.LNX.4.64.0704301030380.6343@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704301933350.4852@skynet.skynet.ie>
References: <Pine.LNX.4.64.0704292157200.1863@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704301037420.32439@skynet.skynet.ie>
 <Pine.LNX.4.64.0704301030380.6343@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Christoph Lameter wrote:

> On Mon, 30 Apr 2007, Mel Gorman wrote:
>
>>> GFP_PERSISTENT		Long term allocation
>>>
>>
>> I don't think this one is needed. It's currently covered by specifying no
>> mobility flag at all so GFP_KERNEL == GFP_PERSISTENT for example. Pages
>> allocated for modules loading would fall into the same category.
>>
>> The flag could be defined but act as documentation only.
>
> That is the intention.
>

Perfect. I have a set of patches ready along these lines that I hope to 
send soon.

>>> GFP_MOVABLE		Allocation of a page that can be moved/reclaimed
>>> 			in a targeted way by just performing operations
>>> 			on the page itself.
>> Nice description of MOVABLE.
>
> Yeah. We need exact description of what these flags mean. Right now there
> is a certain fuzziness around them.
>

Ok, I'll take a new look at documenting this better.

>> As they will currently be treated as UNMOVABLE, I think we're ok here but I've
>> added it to the TODO list to check out later. What I'm missing here is if SLUB
>> would benefit by having all these persistent slabs together. I vagely recall
>> that SLUB does something special with packing (for lock reduction maybe?).
>> Care to comment?
>
> F.e. SLUB (or SLAB) could be optimized to not keep free slabs around. But
> I think the technical detail should be left up to the development in the
> slab allocators. The important thing is that the slab allocators have some
> idea how the data is being used.
>

Ok, I'll put this down as something to revisit. I'll need to look around 
to see how many slabs would use such a PERSISTENT flag and how they might 
benefit from it.

>>> SLAB_TEMPORARY		Objects are temporary and will be gone soon.
>>> 			This is true for networking packets etc.
>>> 			The slab can then waste more memory on allocation
>>> 			structures to make sure that no contention occurs.
>>> 			Larger sets of free objects may be kept around.
>>>
>>
>> Like __GFP_RECLAIMABLE vs __GFP_TEMPORARY, I'll define it as a documentation
>> thing and then split them out later to see what it looks like at runtime.
>
> Right. The flag may be interesting to differentiate in the slabs though.
>

Starting as a documentation thing and moving on sounds like a reasonable 
plan for now. Checking how a slab allocation would be able to use the 
information for improved behavior sounds like a separate project rather 
than one that is directly tied to the fragmentation avoidance patches.

>>> SLAB_MOVABLE		The slabcache has a callback function that allows
>>> 			targeted object moving or removal. The antifrag
>>> 			functionality can selectively kick out such a
>>> 			page in the same way as a page allocated via
>>> 			GFP_MOVABLE.
>>>
>>
>> Are there any slabs that can be treated like this today?
>
> Not yet but I have been paving the road there with SLUB. I believe I can
> get the dentry cache to do that soon.
>

Once it exists, I'll be happy to move the dentry cache to a SLAB_MOVABLE 
and start testing.

>
>> I didn't do a full audit for these type of allocations. I only caught the ones
>> that I knew were occuring on my test machines but I'll use your patch to
>> improve the situation. This is something I see improving over time.
>
> Ok but this confirms that the work on the antifrag patches is not
> complete for merging. We need to keep it around at least one additional
> cycle to get the audits etc done.
>

Harsh. Temporary allocations that I might have missed are not causing any 
problems I could detect.

>>> Also I wish there would be some /proc file system where one would be able
>>> to see the categories of memory in use. The availability of that data
>>> may help to guide the antifrag/defrag activities of the page allocator.
>>
>> I actually use external kernel modules to gather this sort of information. For
>> a while I was also using PAGE_OWNER to export additional information so I knew
>> where everything was coming from. They modules are totally unsuitable in the
>> kernel though. I'll take a closer look at how the /proc/pid/pagemap interface
>> is implemented and see can I do something similar.
>>
>> It might also be doable as a systemtap script if the kernel code to do the job
>> looks insane.
>
> There needs to be some easy way to access that information. Running
> systemtap is likely too much effort. Look at the SLUB statistics or extend
> /proc/buddyinfo or copy it to something like /proc/antifrag.
>

I'll look at SLUB statistics and see what a /proc/antifrag would look 
like. Using /proc/buddyinfo is likely to be considered as clutter for most 
people.

>> Ok, that is doable and I've used patches along those lines in the past but
>> never submitted them because "no one will care". Should they always be
>> available or only when DEBUG_VM is set? Counting them may be expensive you see
>> because it would affect the per-cpu allocator paths but it'll be easy to
>> detect.
>
> Right. For now always. The counting can usually be done in such a way
> that it only touches cachelines already in use. I cannot see that you
> would any scans over pages. Its just a matter of modifying counters at
> the right time. I can lend you a hand if you want.
>

I'll put together a patch and send them to you and hopefully you'll spot 
if they could have been implemented better. The old patches I have along 
these lines are too ugly to live and made no attempt to be clever so I'll 
be starting again after looking again at how other counters are 
implemented.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
