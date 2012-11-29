Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3C1176B0070
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 05:29:39 -0500 (EST)
Message-ID: <50B7390D.5090906@parallels.com>
Date: Thu, 29 Nov 2012 14:29:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/19] drivers: convert shrinkers to new count/scan API
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <1354058086-27937-18-git-send-email-david@fromorbit.com> <b94cdc$7i2bv3@fmsmga001.fm.intel.com> <20121128031719.GR6434@dastard> <50B5C9A2.6000408@parallels.com> <20121128212845.GU6434@dastard>
In-Reply-To: <20121128212845.GU6434@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On 11/29/2012 01:28 AM, Dave Chinner wrote:
> On Wed, Nov 28, 2012 at 12:21:54PM +0400, Glauber Costa wrote:
>> On 11/28/2012 07:17 AM, Dave Chinner wrote:
>>> On Wed, Nov 28, 2012 at 01:13:11AM +0000, Chris Wilson wrote:
>>>> On Wed, 28 Nov 2012 10:14:44 +1100, Dave Chinner <david@fromorbit.com> wrote:
>>>>> +/*
>>>>> + * XXX: (dchinner) This is one of the worst cases of shrinker abuse I've seen.
>>>>> + *
>>>>> + * i915_gem_purge() expects a byte count to be passed, and the minimum object
>>>>> + * size is PAGE_SIZE.
>>>>
>>>> No, purge() expects a count of pages to be freed. Each pass of the
>>>> shrinker therefore tries to free a minimum of 128 pages.
>>>
>>> Ah, I got the shifts mixed up. I'd been looking at way too much crap
>>> already when I saw this. But the fact this can be misunderstood says
>>> something about the level of documentation that the code has (i.e.
>>> none).
>>>
>>>>> The shrinker doesn't work on bytes - it works on
>>>>> + * *objects*.
>>>>
>>>> And I thought you were reviewing the shrinker API to be useful where a
>>>> single object may range between 4K and 4G.
>>>
>>> Which requires rewriting all the algorithms to not be dependent on
>>> the subsystems using a fixed size object. The shrinker control
>>> function is called shrink_slab() for a reason - it was expected to
>>> be used to shrink caches of fixed sized objects allocated from slab
>>> memory.
>>>
>>> It has no concept of the amount of memory that each object consumes,
>>> just an idea of how much *IO* it takes to replace the object in
>>> memory once it's been reclaimed. The DEFAULT_SEEKS is design to
>>> encode the fact it generally takes 2 IOs to replace either a LRU
>>> page or a filesystem slab object, and so balances the scanning based
>>> on that value. i.e. the shrinker algorithms are solidly based around
>>> fixed sized objects that have some relationship to the cost of
>>> physical IO operations to replace them in the cache.
>>
>> One nit: It shouldn't take 2IOs to replace a slab object, right?
>> objects.
> 
> A random dentry in a small directory will take on IO to read the
> inode, then another to read the block the dirent sits in. TO read an
> inode froma cached dentry will generally take one IO to read the
> inode, and another to read related, out of inode information (e.g.
> attributes or extent/block maps). Sometimes it will only take on IO,
> sometimes it might take 3 or, in the case of dirents, coult take
> hundreds of IOs if the directory structure is large enough.
> 
> So a default of 2 seeks to replace any single dentry/inode in the
> cache is a pretty good default to use.
> 
>> This
>> should be the cost of allocating a new page, that can contain, multiple
>> Once the page is in, a new object should be quite cheap to come up with.
> 

Indeed. More on this in the next paragraph...

> It's not the cost of allocating the page (a couple of microseconds)
> that is being considered - it the 3-4 orders of magnitude worse cost
> of reading the object from disk (could be 20ms). The slab/page
> allocation is lost in the noise compared to the time it takes to
> fill the page cache page with data or a single slab object.
> Essentially, slab pages with multiple objects in them are much more
> expensive to replace in the cache than a page cache page....
> 
>> This is a very wild thought, but now that I am diving deep in the
>> shrinker API, and seeing things like this:
>>
>> if (reclaim_state) {
>>     sc->nr_reclaimed += reclaim_state->reclaimed_slab;
>>     reclaim_state->reclaimed_slab = 0;
>> }
> 
> That's not part of the shrinker - that's part of the vmscan
> code, external to the shrinker infrastructure. It's getting
> information back from the slab caches behind the shrinkers, and it's
> not the full picture because many shrinkers are not backed by slab
> caches. It's a work around for not not having accurate feedback from
> the shrink_slab() code about how many pages were freed.
> 
I know it is not part of the shrinkers, and that is precisely my point.
vmscan needs to go through this kinds of hacks because our API is not
strong enough to just give it back the answer that matters to the caller.

> Essentially, the problem is an impedance mismatch between the way
> the LRUs are scanned/balanced (in pages) and slab caches are managed
> (by objects). That's what needs unifying...
> 
So read my statement again, Dave: this is precisely what I am advocating!

The fact that you are so more concerned with bringing the dentries back
from disk is just an obvious consequence of your FS background. The
problem I was more concerned, is when a user needs to allocate a page
for whatever reason. We're short on pages, and then we shrink. But the
shrink gives us nothing. If this is a user-page driven workload, it
should be better to do this, than to get rid of user pages - which we
may end up doing if the shrinkers does not release enough pages. This is
in contrast with a dcache-driven workload, where what you are saying
makes total sense.

In fact, those goals are so orthogonal, that I wonder if it wouldn't be
worth it to introduce some kind of pressure measurement to determine if
the workload is kernel-driven or userpages-driven.

I am right now experimenting with something (dcache only for starters)
like this (simplified version):

static void dentry_lru_add(struct dentry *dentry)
{
        if (!dentry->score) {
                struct page *page;
                page = virt_to_head_page(dentry);
                page->slab_score_page += score;
                dentry->score = score();
        }
}

static void __dentry_lru_del(struct dentry *dentry)
{
        struct page *page;
        page = virt_to_head_page(dentry);

        dentry->d_flags &= ~DCACHE_SHRINK_LIST;
        page->slab_score_page += dentry->score();
}


score decreases as the time passes. So if a page has a very large score,
it means that it is likely to have a lot of objects that are somewhat
old. When we scan, we start from them. If this is a purely kernel driven
workload, we only delete the objects that are, itself, old. If this is a
user-driven workload, we try to take down the rest as well. With a
grey-area in the middle, maybe...

In fact, this may (I am not bold enough to state anything as certain at
this point!!)  free a lot *less* dentries than the normal shrinkers
would, while still being able to give userspace users what it really
cares about: pages!

The big advantage of scanning through pages, is that it becomes trivial
to either walk it per-zone, or per-memcg, since you can trivially derive
the set of pages that belong to each of them.

The determination of user vs kernel driven workloads can also be done
per-{memcg,zone}. So we can conceivably have a {memcg,zone} that is
receiving a lot of kernel-objects pressure, and another that is
receiving a lot of user-driven pressure, due to the different nature of
their workloads. We would shrink them differently, in this case.

>> I am becoming more convinced that we should have a page-based mechanism,
>> like the rest of vmscan.
> 
> Been thought about and consiered before. Would you like to rewrite
> the slab code?
> 
It would be fun!

>> Also, if we are seeing pressure from someone requesting user pages, what
>> good does it make to free, say, 35 Mb of memory, if this means we are
>> freeing objects across 5k different pages, without actually releasing
>> any of them? (still is TBD if this is a theoretical problem or a
>> practical one). It would maybe be better to free objects that are
>> moderately hot, but are on pages dominated by cold objects...
> 
> Yup, that's a problem, but now you're asking shrinker
> implementations to know  in great detail the physical locality of
> object and not just the temporal locality.  the node-aware LRU list
> does this at a coarse level, but to do page based reclaim you need
> ot track pages in SL*B that contain unreferenced objects as those
> are the only ones that can be reclaimed.
> 
Yes, this is the part that I am still struggling with. What I am
currently trying is to come up with a stable SL*B api that will allow us
to know which objects are alive in a given page, and how to walk them.

Combined with the score mechanism above, we can define minimum scores
for an object to be freed - which relates to how long ago it was marked
- and then free the objects in the page that has a high enough score. If
pressure is kept, we lower the threshold. Do this n times.

> If you have no pages with unreferenced objects, then you don't make
> progress and you have to fall back to freeing unreferenced objects
> from random pages. ANd under most workloads that aren't benchmarks,
> slab object population ends up with little correlation between
> physical and temporal locality. Hence this is the norm rather than
> the exception..
> 

More or less.

Last time I counted, a dentry had 248 bytes. Let's say 256 for
simplicity. So each page will have around 16 dentries (it is actually
usually a bit less than that, due to slab metadata).

In a normal shrink, how many objects do you expect to free ? At some
point, as your scan rate grows, the likelihood of having a bunch of them
in the same page increases, even if not all objects in that page are
cold. But still, we can easily scan the objects in a page with a high
score, and find a bunch of objects that are cold. If it is a
kernel-driven workload, we move on to the next page when they are out.
If it is user driven, it may be worth it to free the others, and give
the user what it wants - a page. Leaving all other thousands of dentries
untouched.


> Also, handling physical locality in this way means we'd need to tie
> the shrinker deep into the SLAB/SLUB/SLOB implementation that is
> being used to allocate the objects..
> 
> There have been various attempts at this sort of thing in the past.
> e.g:
> 
> http://marc.info/?l=linux-mm&m=112810938004047
> 
> or for slab defragmentation:
> 
> https://lkml.org/lkml/2010/1/29/332
> 
> and more on LRUs in slab caches and general shrinker design in that
> thread (definitely worth reading this, at least):
> 
> https://lkml.org/lkml/2010/2/2/499
> 

Thanks for the pointers. I will read them right now. A lot of good ideas
end up being killed by the unseen details, so if I radically change my
mind, I will let you know =)

> And it's made far more complex by the fact that some shrinkers don't
> necessarily free the objects they are working on. e.g. the VFS inode
> cache shrinker basically hands objects to XFS, and the XFS inode
> cache takes over from there (via the XFS inode cache shrinker) to
> free the objects. i.e. two shrinkers act on the same structure...
>
I will dig into this as well. Right now, I don't really understand it.

>>> The API change is the first step in the path to removing these built
>>> in assumptions. The current API is just insane and any attempt to
>>> build on it is going to be futile. 
>>
>> Amen, brother!
>>
>>> The way I see this developing is
>>> this:
>>>
>>> 	- make the shrink_slab count -> scan algorithm per node
>>>
>> pages are per-node.
>>
>>> 	- add information about size of objects in the cache for
>>> 	  fixed size object caches.
>>> 		- the shrinker now has some idea of how many objects
>>> 		  need to be freed to be able to free a page of
>>> 		  memory, as well as the relative penalty for
>>> 		  replacing them.
>> this is still guesswork, telling how many pages it should free, could
>> be a better idea.
>>
>>> 		- tells the shrinker the size of the cache
>>> 		  in bytes so overall memory footprint of the caches
>>> 		  can be taken into account
>>
>>> 	- add new count and scan operations for caches that are
>>> 	  based on memory used, not object counts
>>> 		- allows us to use the same count/scan algorithm for
>>> 		  calculating how much pressure to put on caches
>>> 		  with variable size objects.
>>
>> IOW, pages.
> 
> Not necessarily - if we are going to deal with multiple objects in a
> page as well as multi-page objects, then pages are unable to express
> the full range of possibilities. We may as well use byte counts at
> this point, expecially when you consider page sizes differ on
> different platforms...
> 

bytecounts by themselves doesn't seem that bad to me. It also makes
sense. But I would still note that for that memory to be useful, it must
be in consumable units. What is a consumable unit depends on where the
pressure comes from.

An object is a consumable unit, so if the pressure is coming from the
dentry cache, it is great to free 4000 consumable units - objects. If it
is coming from the page cache, it would be better to free as many pages
as we can, because that is what can be used.

>>> My care factor mostly ends here, as it will allow XFS to corectly
>>> balance the metadata buffer cache (variable size objects) against the
>>> inode, dentry and dquot caches which are object based. The next
>>> steps that I'm about to give you are based on some discussions with
>>> some MM people over bottles of red wine, so take it with a grain of
>>> salt...
>>>
>>> 	- calculate a "pressure" value for each cache controlled by a
>>> 	  shrinker so that the relative memory pressure between
>>> 	  caches can be compared. This allows the shrinkers to bias
>>> 	  reclaim based on where the memory pressure is being
>>> 	  generated
>>>
>>
>> Ok, if a cache is using a lot of memory, this would indicate it has the
>> dominant workload, right?
> 
> Not necessarily. Someone might jus thave run a find across their
> filesystem, and that is where all the pressure is coming from. In
> this case, you don't want that memory prssure to toss out all the
> other caches. I suspect that the "pressure" measure is going to need
> to take into account cache hit rates to work properly...
> 
Indeed you are right, memory usage is a very bad estimate. Let me stand
corrected: memory usage over a sliding time window, or something like
the such.

>> Should we free from it, or should we free from
>> the others, so this ones gets the pages it needs?
> 
> That's the million dollar question...
> 

For god's sake, it's time we stop this bullshit of telling people
"that's the million dollar question". Those fucktards are printing money
like crazy, so we need to correct it for inflation, at the very least.

This is the USD 1,289,648.82 question, using Y2K as a baseline.


>>> 	- start grouping shrinkers into a heirarchy, allowing
>>> 	  related shrinkers (e.g. all the caches in a memcg) to be
>>> 	  shrunk according resource limits that can be placed on the
>>> 	  group. i.e. memory pressure is proportioned across
>>> 	  groups rather than many individual shrinkers.
>>>
>> pages are already grouped like that!
> 
> But shrinkers and slab caches are not.
> 
> Besides, once you start grouping shrinkers, why should we treat the
> page LRU list scanning any differently from any other cache that has
> a shrinker? 
> 

Dunno. Should we?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
