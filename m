Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 353B96B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 18:21:26 -0500 (EST)
Date: Tue, 22 Jan 2013 10:21:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC, PATCH 00/19] Numa aware LRU lists and shrinkers
Message-ID: <20130121232121.GG2498@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <50FD6815.90900@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FD6815.90900@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Jan 21, 2013 at 08:08:53PM +0400, Glauber Costa wrote:
> On 11/28/2012 03:14 AM, Dave Chinner wrote:
> > [PATCH 09/19] list_lru: per-node list infrastructure
> > 
> > This makes the generic LRU list much more scalable by changing it to
> > a {list,lock,count} tuple per node. There are no external API
> > changes to this changeover, so is transparent to current users.
> > 
> > [PATCH 10/19] shrinker: add node awareness
> > [PATCH 11/19] fs: convert inode and dentry shrinking to be node
> > 
> > Adds a nodemask to the struct shrink_control for callers of
> > shrink_slab to set appropriately for their reclaim context. This
> > nodemask is then passed by the inode and dentry cache reclaim code
> > to the generic LRU list code to implement node aware shrinking.
> 
> I have a follow up question that popped up from a discussion between me
> and my very American friend Johnny Wheeler, also known as Johannes
> Weiner (CC'd). I actually remember we discussing this, but don't fully
> remember the outcome. And since I can't find it anywhere, it must have
> been in a media other than e-mail. So I thought it would do no harm in
> at least documenting it...
> 
> Why are we doing this per-node, instead of per-zone?
> 
> It seems to me that the goal is to collapse all zones of a node into a
> single list, but since the number of zones is not terribly larger than
> the number of nodes, and zones is where the pressure comes from, what do
> we really gain from this?

The number is quite a bit higher - there are platforms with 5 zones
to a node. The reality is, though, for most platforms slab
allocations come from a single zone - they never come from ZONE_DMA,
ZONE_HIGHMEM or ZONE_MOVEABLE, so there is there is no good reason
for having cache LRUs for these zones. So, two zones at most.

And then there's the complexity issue - it's simple/trivial to user
per node lists, node masks, etc. It's an obvious abstraction that
everyone understands, is simle to understand, acheives exactly the
purpose that is needed and is not tied to the /current/
implementation of the current VM memory management code.

I don't see any good reason for tying LRUs to MM zones. the
original implementation of the per-node shrinkers by Nick Piggin did
this: the LRUs for the dentry and inode caches were embedded in the
struct zone, and it wasn't generically extensible because of that.
i.e. node-aware shrinkers were directly influenced by the zone
infrastructure and so the internal implementation of the mm
subsystem started leaking out and determining how completely
unrelated subsystems need to implement their own cache
management.....

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
