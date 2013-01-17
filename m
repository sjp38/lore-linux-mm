Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 6344A6B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 23:22:50 -0500 (EST)
Date: Thu, 17 Jan 2013 15:22:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
Message-ID: <20130117042245.GG2498@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-10-git-send-email-david@fromorbit.com>
 <50F6FDC8.5020909@parallels.com>
 <20130116225521.GF2498@dastard>
 <50F7475F.90609@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F7475F.90609@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On Wed, Jan 16, 2013 at 04:35:43PM -0800, Glauber Costa wrote:
> 
> >> The superblocks only, are present by the dozens even in a small system,
> >> and I believe the whole goal of this API is to get more users to switch
> >> to it. This can easily use up a respectable bunch of megs.
> >>
> >> Isn't it a bit too much ?
> > 
> > Maybe, but for active superblocks it only takes a handful of cached
> > inodes to make this 16k look like noise, so I didn't care. Indeed, a
> > typical active filesystem could be consuming gigabytes of memory in
> > the slab, so 16k is a tiny amount of overhead to track this amount
> > of memory more efficiently.
> > 
> > Most other LRU/shrinkers are tracking large objects and only have a
> > single LRU instance machine wide. Hence the numbers arguments don't
> > play out well in favour of a more complex, dynamic solution for
> > them, either. Sometimes dumb and simple is the best approach ;)
> > 
> 
> Being dumb and simple myself, I'm of course forced to agree.

:)

> Let me give you more context so you can understand my deepest fears better:
> 
> >> I am wondering if we can't do better in here and at least allocate+grow
> >> according to the actual number of nodes.
> > 
> > We could add hotplug notifiers and grow/shrink the node array as
> > they get hot plugged, but that seems unnecessarily complex given
> > how rare such operations are.
> > 
> > If superblock proliferation is the main concern here, then doing
> > somethign as simple as allowing filesystems to specify they want
> > numa aware LRU lists via a mount_bdev() flag would solve this
> > problem. If the flag is set, then full numa lists are created.
> > Otherwise the LRU list simply has a "single node" and collapses all node
> > IDs down to 0 and ignores all NUMA optimisations...
> > 
> > That way the low item count virtual filesystems like proc, sys,
> > hugetlbfs, etc won't use up memory, but filesytems that actually
> > make use of NUMA awareness still get the more expensive, scalable
> > implementation. Indeed, any subsystem that is not performance or
> > location sensitive can use the simple single list version, so we can
> > avoid overhead in that manner system wide...
> > 
> 
> Deepest fears:
> 
> 1) snakes.

Snakes are merely poisonous. Drop Bears are far more dangerous :P

> 2) It won't surprise you to know that I am adapting your work, which
> provides a very sane and helpful API, to memcg shrinking.
> 
> The dumb and simple approach in there is to copy all lrus that are
> marked memcg aware at memcg creation time. The API is kept the same,
> but when you do something like list_lru_add(lru, obj), for instance, we
> derive the memcg context from obj and relay it to the right list.

At which point, you don't want the overhead of per-node lists.

The problem I see here is that someone might still need the
scalability of the per-node lists. If someone runs a large memcg in terms
of CPU and memory, then we most definitely are going to need to
retain per-node lists regardless of the fact that the workload is
running in a constrained environment. And if you are running a mix
of large and small containers, then one static solution is not going
to cut it for some workload.

This is a problem that superblock contexts don't care about - they
are global by their very nature. Hence I'm wondering if trying to
fit these two very different behaviours into the one LRU list is
the wrong approach.

Consider this: these patches give us a generic LRU list structure.
It currently uses a list_head in each object for indexing, and we
are talking about single LRU lists because of this limitation and
trying to build infrastructure that can support this indexing
mechanism.

I think that all of thses problems go away if we replace the
list_head index in the object with a "struct lru_item" index. To
start with, it's just a s/list_head/lru_item/ changeover, but from
there we can expand.

What I'm getting at is that we want to have multiple axis of
tracking and reclaim, but we only have a single axis for tracking.
If the lru_item grew a second list_head called "memcg_lru", then
suddenly the memcg LRUs can be maintained separately to the global
(per-superblock) LRU. i.e.:

struct lru_item {
	struct list_head global_list;
	struct list_head memcg_list;
}

And then you can use whatever tracking structure you want for a
memcg LRU list. Indeed, this would allow per-node lists for the
global LRU, and whatever LRU type is appropriate for the memcg using
the object (e.g. single list for small memcgs, per-node for large
memcgs)....

i.e. rather than trying to make the infrastructure jump through hoops
to only have one LRU index per object, have a second index that
allows memcg's to have a separate LRU index and a method for the
global LRU structure to find them. This woul dallow memcg specific
shrinker callouts switch to the memcg LRU rather than the global LRU
and operate on that. That way we still only instantiate a single
LRU/shrinker pair per cache context, but the memcg code doesn't need
to duplicate the entire LRU infrastructure into every memcg that
contains that type of object for that cache context....

/me stops rambling....

> Your current suggestion of going per-node only in the performance
> critical filesystems could also possibly work, provided this count is
> expected to be small.

The problem is deciding on a per filesystem basis. I was thinking
that all filesytsems of a specific type would use a particular type
of structure, not that specific instances of a filesystem could use
different types....

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
