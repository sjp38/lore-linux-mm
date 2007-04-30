Date: Mon, 30 Apr 2007 10:39:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Antifrag patches may benefit from clean up of GFP allocation
 flags
In-Reply-To: <Pine.LNX.4.64.0704301037420.32439@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0704301030380.6343@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704292157200.1863@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704301037420.32439@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Mel Gorman wrote:

> > GFP_PERSISTENT		Long term allocation
> > 
> 
> I don't think this one is needed. It's currently covered by specifying no
> mobility flag at all so GFP_KERNEL == GFP_PERSISTENT for example. Pages
> allocated for modules loading would fall into the same category.
> 
> The flag could be defined but act as documentation only.

That is the intention.

> > GFP_MOVABLE		Allocation of a page that can be moved/reclaimed
> > 			in a targeted way by just performing operations
> > 			on the page itself.
> Nice description of MOVABLE.

Yeah. We need exact description of what these flags mean. Right now there 
is a certain fuzziness around them.

> As they will currently be treated as UNMOVABLE, I think we're ok here but I've
> added it to the TODO list to check out later. What I'm missing here is if SLUB
> would benefit by having all these persistent slabs together. I vagely recall
> that SLUB does something special with packing (for lock reduction maybe?).
> Care to comment?

F.e. SLUB (or SLAB) could be optimized to not keep free slabs around. But 
I think the technical detail should be left up to the development in the 
slab allocators. The important thing is that the slab allocators have some 
idea how the data is being used.

> > SLAB_TEMPORARY		Objects are temporary and will be gone soon.
> > 			This is true for networking packets etc.
> > 			The slab can then waste more memory on allocation
> > 			structures to make sure that no contention occurs.
> > 			Larger sets of free objects may be kept around.
> > 
> 
> Like __GFP_RECLAIMABLE vs __GFP_TEMPORARY, I'll define it as a documentation
> thing and then split them out later to see what it looks like at runtime.

Right. The flag may be interesting to differentiate in the slabs though.
 
> > SLAB_MOVABLE		The slabcache has a callback function that allows
> > 			targeted object moving or removal. The antifrag
> > 			functionality can selectively kick out such a
> > 			page in the same way as a page allocated via
> > 			GFP_MOVABLE.
> > 
> 
> Are there any slabs that can be treated like this today?

Not yet but I have been paving the road there with SLUB. I believe I can 
get the dentry cache to do that soon.


> I didn't do a full audit for these type of allocations. I only caught the ones
> that I knew were occuring on my test machines but I'll use your patch to
> improve the situation. This is something I see improving over time.

Ok but this confirms that the work on the antifrag patches is not 
complete for merging. We need to keep it around at least one additional 
cycle to get the audits etc done.
 
> > Also I wish there would be some /proc file system where one would be able
> > to see the categories of memory in use. The availability of that data
> > may help to guide the antifrag/defrag activities of the page allocator.
> I actually use external kernel modules to gather this sort of information. For
> a while I was also using PAGE_OWNER to export additional information so I knew
> where everything was coming from. They modules are totally unsuitable in the
> kernel though. I'll take a closer look at how the /proc/pid/pagemap interface
> is implemented and see can I do something similar.
> 
> It might also be doable as a systemtap script if the kernel code to do the job
> looks insane.

There needs to be some easy way to access that information. Running 
systemtap is likely too much effort. Look at the SLUB statistics or extend
/proc/buddyinfo or copy it to something like /proc/antifrag.

> Ok, that is doable and I've used patches along those lines in the past but
> never submitted them because "no one will care". Should they always be
> available or only when DEBUG_VM is set? Counting them may be expensive you see
> because it would affect the per-cpu allocator paths but it'll be easy to
> detect.

Right. For now always. The counting can usually be done in such a way 
that it only touches cachelines already in use. I cannot see that you 
would any scans over pages. Its just a matter of modifying counters at 
the right time. I can lend you a hand if you want.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
