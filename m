Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 628076B0072
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 22:17:24 -0500 (EST)
Date: Wed, 28 Nov 2012 14:17:19 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 17/19] drivers: convert shrinkers to new count/scan API
Message-ID: <20121128031719.GR6434@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-18-git-send-email-david@fromorbit.com>
 <b94cdc$7i2bv3@fmsmga001.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b94cdc$7i2bv3@fmsmga001.fm.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Wed, Nov 28, 2012 at 01:13:11AM +0000, Chris Wilson wrote:
> On Wed, 28 Nov 2012 10:14:44 +1100, Dave Chinner <david@fromorbit.com> wrote:
> > +/*
> > + * XXX: (dchinner) This is one of the worst cases of shrinker abuse I've seen.
> > + *
> > + * i915_gem_purge() expects a byte count to be passed, and the minimum object
> > + * size is PAGE_SIZE.
> 
> No, purge() expects a count of pages to be freed. Each pass of the
> shrinker therefore tries to free a minimum of 128 pages.

Ah, I got the shifts mixed up. I'd been looking at way too much crap
already when I saw this. But the fact this can be misunderstood says
something about the level of documentation that the code has (i.e.
none).

> > The shrinker doesn't work on bytes - it works on
> > + * *objects*.
> 
> And I thought you were reviewing the shrinker API to be useful where a
> single object may range between 4K and 4G.

Which requires rewriting all the algorithms to not be dependent on
the subsystems using a fixed size object. The shrinker control
function is called shrink_slab() for a reason - it was expected to
be used to shrink caches of fixed sized objects allocated from slab
memory.

It has no concept of the amount of memory that each object consumes,
just an idea of how much *IO* it takes to replace the object in
memory once it's been reclaimed. The DEFAULT_SEEKS is design to
encode the fact it generally takes 2 IOs to replace either a LRU
page or a filesystem slab object, and so balances the scanning based
on that value. i.e. the shrinker algorithms are solidly based around
fixed sized objects that have some relationship to the cost of
physical IO operations to replace them in the cache.

The API change is the first step in the path to removing these built
in assumptions. The current API is just insane and any attempt to
build on it is going to be futile. The way I see this developing is
this:

	- make the shrink_slab count -> scan algorithm per node

	- add information about size of objects in the cache for
	  fixed size object caches.
		- the shrinker now has some idea of how many objects
		  need to be freed to be able to free a page of
		  memory, as well as the relative penalty for
		  replacing them.
		- tells the shrinker the size of the cache
		  in bytes so overall memory footprint of the caches
		  can be taken into account

	- add new count and scan operations for caches that are
	  based on memory used, not object counts
		- allows us to use the same count/scan algorithm for
		  calculating how much pressure to put on caches
		  with variable size objects.

My care factor mostly ends here, as it will allow XFS to corectly
balance the metadata buffer cache (variable size objects) against the
inode, dentry and dquot caches which are object based. The next
steps that I'm about to give you are based on some discussions with
some MM people over bottles of red wine, so take it with a grain of
salt...

	- calculate a "pressure" value for each cache controlled by a
	  shrinker so that the relative memory pressure between
	  caches can be compared. This allows the shrinkers to bias
	  reclaim based on where the memory pressure is being
	  generated

	- start grouping shrinkers into a heirarchy, allowing
	  related shrinkers (e.g. all the caches in a memcg) to be
	  shrunk according resource limits that can be placed on the
	  group. i.e. memory pressure is proportioned across
	  groups rather than many individual shrinkers.

	- comments have been made to the extent that with generic
	  per-node lists and a node aware shrinker, all of the page
	  scanning could be driven by the shrinker infrastructure,
	  rather than the shrinkers being driven by how many pages
	  in the page cache just got scanned for reclaim.

	  IOWs, the main memory reclaim algorithm walks all the
	  shrinkers groups to calculate overall memory pressure,
	  calculate how much reclaim is necessary, and then
	  proportion reclaim across all the shrinker groups. i.e.
	  everything is a shrinker.

This patch set is really just the start of a long process. balance
between the page cache and VFS/filesystem shrinkers is critical to
the efficient operation of the OS under many, many workloads, so I'm
not about to change more than oe little thing at a time. This API
change is just one little step. You'll get what you want eventually,
but you're not going to get it as a first step.

> > + * But the craziest part comes when i915_gem_purge() has walked all the objects
> > + * and can't free any memory. That results in i915_gem_shrink_all() being
> > + * called, which idles the GPU and frees everything the driver has in it's
> > + * active and inactive lists. It's basically hitting the driver with a great big
> > + * hammer because it was busy doing stuff when something else generated memory
> > + * pressure. This doesn't seem particularly wise...
> > + */
> 
> As opposed to triggering an OOM? The choice was between custom code for
> a hopefully rare code path in a situation of last resort, or first
> implementing the simplest code that stopped i915 from starving the
> system of memory.

And when it's something else that is causing the memory pressue?
The shrinker gets called whenever somethign runs low on memory - it
might be called thousands of times a second so there's a very good
chance you have very little to free after the first purge has
occurred. After than you're going to idle the GPU and purge all the
memory on every single shrinker call, even though the GPU is not
generating memory pressure and not causing the shrinkers to run.
That's why it's crazy - it's got close to worst case behaviour when
the GPU is already using as little memory as possible.

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
