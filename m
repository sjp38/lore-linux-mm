Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 8C43D6B0080
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 17:02:21 -0500 (EST)
Date: Fri, 30 Nov 2012 09:02:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 17/19] drivers: convert shrinkers to new count/scan API
Message-ID: <20121129220211.GD6434@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-18-git-send-email-david@fromorbit.com>
 <b94cdc$7i2bv3@fmsmga001.fm.intel.com>
 <20121128031719.GR6434@dastard>
 <50B5C9A2.6000408@parallels.com>
 <20121128212845.GU6434@dastard>
 <50B7390D.5090906@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B7390D.5090906@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Thu, Nov 29, 2012 at 02:29:33PM +0400, Glauber Costa wrote:
> On 11/29/2012 01:28 AM, Dave Chinner wrote:
> > On Wed, Nov 28, 2012 at 12:21:54PM +0400, Glauber Costa wrote:
> >> On 11/28/2012 07:17 AM, Dave Chinner wrote:
> >>> On Wed, Nov 28, 2012 at 01:13:11AM +0000, Chris Wilson wrote:
> >>>> On Wed, 28 Nov 2012 10:14:44 +1100, Dave Chinner <david@fromorbit.com> wrote:
> >>>>> The shrinker doesn't work on bytes - it works on
> >>>>> + * *objects*.
> >>>>
> >>>> And I thought you were reviewing the shrinker API to be useful where a
> >>>> single object may range between 4K and 4G.
> >>>
> >>> Which requires rewriting all the algorithms to not be dependent on
> >>> the subsystems using a fixed size object. The shrinker control
> >>> function is called shrink_slab() for a reason - it was expected to
> >>> be used to shrink caches of fixed sized objects allocated from slab
> >>> memory.
> >>>
> >>> It has no concept of the amount of memory that each object consumes,
> >>> just an idea of how much *IO* it takes to replace the object in
> >>> memory once it's been reclaimed. The DEFAULT_SEEKS is design to
> >>> encode the fact it generally takes 2 IOs to replace either a LRU
> >>> page or a filesystem slab object, and so balances the scanning based
> >>> on that value. i.e. the shrinker algorithms are solidly based around
> >>> fixed sized objects that have some relationship to the cost of
> >>> physical IO operations to replace them in the cache.
> >>
> >> One nit: It shouldn't take 2IOs to replace a slab object, right?
> >> objects.
> > 
> > A random dentry in a small directory will take on IO to read the
> > inode, then another to read the block the dirent sits in. TO read an
> > inode froma cached dentry will generally take one IO to read the
> > inode, and another to read related, out of inode information (e.g.
> > attributes or extent/block maps). Sometimes it will only take on IO,
> > sometimes it might take 3 or, in the case of dirents, coult take
> > hundreds of IOs if the directory structure is large enough.
> > 
> > So a default of 2 seeks to replace any single dentry/inode in the
> > cache is a pretty good default to use.
> > 
> >> This
> >> should be the cost of allocating a new page, that can contain, multiple
> >> Once the page is in, a new object should be quite cheap to come up with.
> > 
> 
> Indeed. More on this in the next paragraph...

I'm not sure what you are trying to say here. Are you saying that
you think that the IO cost for replacing a slab cache object doesn't
matter?

> > It's not the cost of allocating the page (a couple of microseconds)
> > that is being considered - it the 3-4 orders of magnitude worse cost
> > of reading the object from disk (could be 20ms). The slab/page
> > allocation is lost in the noise compared to the time it takes to
> > fill the page cache page with data or a single slab object.
> > Essentially, slab pages with multiple objects in them are much more
> > expensive to replace in the cache than a page cache page....
> > 
> >> This is a very wild thought, but now that I am diving deep in the
> >> shrinker API, and seeing things like this:
> >>
> >> if (reclaim_state) {
> >>     sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> >>     reclaim_state->reclaimed_slab = 0;
> >> }
> > 
> > That's not part of the shrinker - that's part of the vmscan
> > code, external to the shrinker infrastructure. It's getting
> > information back from the slab caches behind the shrinkers, and it's
> > not the full picture because many shrinkers are not backed by slab
> > caches. It's a work around for not not having accurate feedback from
> > the shrink_slab() code about how many pages were freed.
> > 
> I know it is not part of the shrinkers, and that is precisely my point.
> vmscan needs to go through this kinds of hacks because our API is not
> strong enough to just give it back the answer that matters to the caller.

What matters is that the slab caches are shrunk in proportion to the
page cache. i.e. balanced reclaim. For dentry and inode caches, what
matters is the number of objects reclaimed because the shrinker
algorithm balances based on the relative cost of object replacement
in the cache.

e.g. if you have 1000 pages in the page LRUs, and 1000 objects in
the dentry cache, each takes 1 IO to replace, then if you reclaim 2
pages from the page LRUs and 2 pages from the dentry cache, it will
take 2 IOs to replace the pages in the LRU, but 36 IOs to replace
the objects in the dentry cache that were reclaimed.

This is why the shrinker balances "objects scanned" vs "LRU pages
scanned" - it treats each page as an object and the shrinker relates
that to the relative cost of objects in the slab cache being
reclaimed. i.e. the focus is on keeping a balance between caches,
not reclaiming an absolute number of pages.

Note: I'm not saying this is perfect, what I'm trying to do is let
you know the "why" behind the current algorithm. i.e. why it mostly
works and why ignoring the principles behind why it works is going
fraught with danger...

> > Essentially, the problem is an impedance mismatch between the way
> > the LRUs are scanned/balanced (in pages) and slab caches are managed
> > (by objects). That's what needs unifying...
> > 
> So read my statement again, Dave: this is precisely what I am advocating!

Not clearly enough, obviously :/

> The fact that you are so more concerned with bringing the dentries back
> from disk is just an obvious consequence of your FS background.

No, it's a solution ito a systemic problem that Andrew Morton
identified way back in the 2.5 days that resulting in him implenting
the shrinker infrastructure to directly control the sizes of the
inode and dentry caches. IOWs, the historic reason for having the
shrinkers is to balance dentry/inode caches against the page cache
size to solve performance problems related to cache imbalance
problems.

> The
> problem I was more concerned, is when a user needs to allocate a page
> for whatever reason. We're short on pages, and then we shrink. But the
> shrink gives us nothing. If this is a user-page driven workload, it
> should be better to do this, than to get rid of user pages - which we
> may end up doing if the shrinkers does not release enough pages. This is
> in contrast with a dcache-driven workload, where what you are saying
> makes total sense.

What you are ignoring is that the dcache is a global resource.
trashing the dcache because a user want anonymous memory will affect
system/memcg wide performance degradation, instead of just the
single user application being slowed down. It is preferable that the
user application demanding memory is penalised, not the whole
system.

> In fact, those goals are so orthogonal, that I wonder if it wouldn't be
> worth it to introduce some kind of pressure measurement to determine if
> the workload is kernel-driven or userpages-driven.

Dentry cache growth is user driven - the kernel doesn't walk
directories or open files itself - and is a direct representation of
the recent set of the userspace directory/file accesses. So the
whole concept of "treat the dcache as a kernel driven cache" is
fundamentally flawed.

> I am right now experimenting with something (dcache only for starters)
> like this (simplified version):
> 
> static void dentry_lru_add(struct dentry *dentry)
> {
>         if (!dentry->score) {
>                 struct page *page;
>                 page = virt_to_head_page(dentry);
>                 page->slab_score_page += score;
>                 dentry->score = score();
>         }
> }
> 
> static void __dentry_lru_del(struct dentry *dentry)
> {
>         struct page *page;
>         page = virt_to_head_page(dentry);
> 
>         dentry->d_flags &= ~DCACHE_SHRINK_LIST;
>         page->slab_score_page += dentry->score();
> }

slab_score_page only ever increases according to this code.... :/

> score decreases as the time passes.  So if a page has a very large
> score, it means that it is likely to have a lot of objects that
> are somewhat old.

And if score decreases over time, then a small score means the
entries on the page are older than a page with a large score, right?

> When we scan, we start from them. If this is a purely kernel driven
> workload, we only delete the objects that are, itself, old. If this is a
> user-driven workload, we try to take down the rest as well. With a
> grey-area in the middle, maybe...
> 
> In fact, this may (I am not bold enough to state anything as certain at
> this point!!)  free a lot *less* dentries than the normal shrinkers

The question is this: does it free the right ones? If you have a
single hot dentry on a page full of cold ones, freeing that hot
dentry is the wrong thing to do as it will immediately trigger IO to
bring it back into cache. This is the really problem with page based
slab reclaim....

> would, while still being able to give userspace users what it really
> cares about: pages!

Userspace doesn't care about how the kernel reclaims, tracks or
accounts for memory. All it cares about is having a memory
allocation succeed or fail quickly.

> The big advantage of scanning through pages, is that it becomes trivial
> to either walk it per-zone, or per-memcg, since you can trivially derive
> the set of pages that belong to each of them.

But you really don't have a viable LRU ordering because pages with
mixed hot/cold objects don't look that much different from pages
with all mildly cold objects...

> The determination of user vs kernel driven workloads can also be done
> per-{memcg,zone}. So we can conceivably have a {memcg,zone} that is
> receiving a lot of kernel-objects pressure, and another that is
> receiving a lot of user-driven pressure, due to the different nature of
> their workloads. We would shrink them differently, in this case.

I see that whole concept as fundamentally flawed. Maybe I
misunderstand what you mean by "kernel vs user driven worklaods" as
you haven't really defined what you mean, but I still see the idea
as treating kernel vs userspace driven memory allocation differently
as a vector for insanity. And, in most cases, ensuring kernel memory
allocation succeeds is far, far more important than userspace memory
allocation, so I think that even on this basis this is a
non-starter....

> >> Also, if we are seeing pressure from someone requesting user pages, what
> >> good does it make to free, say, 35 Mb of memory, if this means we are
> >> freeing objects across 5k different pages, without actually releasing
> >> any of them? (still is TBD if this is a theoretical problem or a
> >> practical one). It would maybe be better to free objects that are
> >> moderately hot, but are on pages dominated by cold objects...
> > 
> > Yup, that's a problem, but now you're asking shrinker
> > implementations to know  in great detail the physical locality of
> > object and not just the temporal locality.  the node-aware LRU list
> > does this at a coarse level, but to do page based reclaim you need
> > ot track pages in SL*B that contain unreferenced objects as those
> > are the only ones that can be reclaimed.
> > 
> Yes, this is the part that I am still struggling with. What I am
> currently trying is to come up with a stable SL*B api that will allow us
> to know which objects are alive in a given page, and how to walk them.
> 
> Combined with the score mechanism above, we can define minimum scores
> for an object to be freed - which relates to how long ago it was marked
> - and then free the objects in the page that has a high enough score. If
> pressure is kept, we lower the threshold. Do this n times.
> 
> > If you have no pages with unreferenced objects, then you don't make
> > progress and you have to fall back to freeing unreferenced objects
> > from random pages. ANd under most workloads that aren't benchmarks,
> > slab object population ends up with little correlation between
> > physical and temporal locality. Hence this is the norm rather than
> > the exception..
> > 
> 
> More or less.
> 
> Last time I counted, a dentry had 248 bytes. Let's say 256 for
> simplicity. So each page will have around 16 dentries (it is actually
> usually a bit less than that, due to slab metadata).

IIRC, it's 192 bytes. It was carefully constructed to be exactly
3 cachelines in size for x86_64 when you don't have any lock
debugging turned on.


> In a normal shrink, how many objects do you expect to free ? At some
> point, as your scan rate grows, the likelihood of having a bunch of them
> in the same page increases, even if not all objects in that page are
> cold.  But still, we can easily scan the objects in a page with a high
> score, and find a bunch of objects that are cold. If it is a

How are you scanning those pages?

> >>> 	- add new count and scan operations for caches that are
> >>> 	  based on memory used, not object counts
> >>> 		- allows us to use the same count/scan algorithm for
> >>> 		  calculating how much pressure to put on caches
> >>> 		  with variable size objects.
> >>
> >> IOW, pages.
> > 
> > Not necessarily - if we are going to deal with multiple objects in a
> > page as well as multi-page objects, then pages are unable to express
> > the full range of possibilities. We may as well use byte counts at
> > this point, expecially when you consider page sizes differ on
> > different platforms...
> > 
> 
> bytecounts by themselves doesn't seem that bad to me. It also makes
> sense. But I would still note that for that memory to be useful, it must
> be in consumable units. What is a consumable unit depends on where the
> pressure comes from.
> 
> An object is a consumable unit, so if the pressure is coming from the
> dentry cache, it is great to free 4000 consumable units - objects. If it
> is coming from the page cache, it would be better to free as many pages
> as we can, because that is what can be used.

For the page cache, the consumable unit is a page. This is what I've
been trying to say - you're looking at the page cache as pages, not
as consumable units. There's nothing special about the page cache,
it's just full of objects that are a single page in size, and so a
generic shrinker algorithms can be applied to them just as easily as
the dentry cache...



> >>> My care factor mostly ends here, as it will allow XFS to corectly
> >>> balance the metadata buffer cache (variable size objects) against the
> >>> inode, dentry and dquot caches which are object based. The next
> >>> steps that I'm about to give you are based on some discussions with
> >>> some MM people over bottles of red wine, so take it with a grain of
> >>> salt...
> >>>
> >>> 	- calculate a "pressure" value for each cache controlled by a
> >>> 	  shrinker so that the relative memory pressure between
> >>> 	  caches can be compared. This allows the shrinkers to bias
> >>> 	  reclaim based on where the memory pressure is being
> >>> 	  generated
> >>>
> >>
> >> Ok, if a cache is using a lot of memory, this would indicate it has the
> >> dominant workload, right?
> > 
> > Not necessarily. Someone might jus thave run a find across their
> > filesystem, and that is where all the pressure is coming from. In
> > this case, you don't want that memory prssure to toss out all the
> > other caches. I suspect that the "pressure" measure is going to need
> > to take into account cache hit rates to work properly...
> > 
> Indeed you are right, memory usage is a very bad estimate. Let me stand
> corrected: memory usage over a sliding time window, or something like
> the such.

/me handwaves about how it might work.

This will need a lot of active research, so coming up with something
that works without heuristics is something that is way beyond what
I'm considering right now.

> >> Should we free from it, or should we free from
> >> the others, so this ones gets the pages it needs?
> > 
> > That's the million dollar question...
> 
> For god's sake, it's time we stop this bullshit of telling people
> "that's the million dollar question". Those fucktards are printing money
> like crazy, so we need to correct it for inflation, at the very least.
> 
> This is the USD 1,289,648.82 question, using Y2K as a baseline.

:)

> 
> 
> >>> 	- start grouping shrinkers into a heirarchy, allowing
> >>> 	  related shrinkers (e.g. all the caches in a memcg) to be
> >>> 	  shrunk according resource limits that can be placed on the
> >>> 	  group. i.e. memory pressure is proportioned across
> >>> 	  groups rather than many individual shrinkers.
> >>>
> >> pages are already grouped like that!
> > 
> > But shrinkers and slab caches are not.
> > 
> > Besides, once you start grouping shrinkers, why should we treat the
> > page LRU list scanning any differently from any other cache that has
> > a shrinker? 
> > 
> 
> Dunno. Should we?

Another USD 1,289,648.82 question ;)

We currently base all our memory reclaim decisions on contents of
the LRU lists without taking into account the various other caches
in the system. I think we really should be taking into account the
usages of all the caches in the system before deciding exactly what
we should be trying to reclaim and where we reclaim from.

That kind of implies a level playing field for all caches, rather
than the primary (page LRUs) vs secondary (shrinkers) reclaim
architecture we have now. Given the observation we could treat the
page LRUs as an object based shrinker implementation....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
