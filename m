Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C90176B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 17:55:26 -0500 (EST)
Date: Thu, 17 Jan 2013 09:55:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
Message-ID: <20130116225521.GF2498@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-10-git-send-email-david@fromorbit.com>
 <50F6FDC8.5020909@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F6FDC8.5020909@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On Wed, Jan 16, 2013 at 11:21:44AM -0800, Glauber Costa wrote:
> On 11/27/2012 03:14 PM, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Now that we have an LRU list API, we can start to enhance the
> > implementation.  This splits the single LRU list into per-node lists
> > and locks to enhance scalability. Items are placed on lists
> > according to the node the memory belongs to. To make scanning the
> > lists efficient, also track whether the per-node lists have entries
> > in them in a active nodemask.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  include/linux/list_lru.h |   14 ++--
> >  lib/list_lru.c           |  160 +++++++++++++++++++++++++++++++++++-----------
> >  2 files changed, 129 insertions(+), 45 deletions(-)
> > 
> > diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> > index 3423949..b0e3ba2 100644
> > --- a/include/linux/list_lru.h
> > +++ b/include/linux/list_lru.h
> > @@ -8,21 +8,23 @@
> >  #define _LRU_LIST_H 0
> >  
> >  #include <linux/list.h>
> > +#include <linux/nodemask.h>
> >  
> > -struct list_lru {
> > +struct list_lru_node {
> >  	spinlock_t		lock;
> >  	struct list_head	list;
> >  	long			nr_items;
> > +} ____cacheline_aligned_in_smp;
> > +
> > +struct list_lru {
> > +	struct list_lru_node	node[MAX_NUMNODES];
> > +	nodemask_t		active_nodes;
> >  };
> >  
> MAX_NUMNODES will default to 1 << 9, if I'm not mistaken. Your
> list_lru_node seems to be around 32 bytes on 64-bit systems (128 with
> debug). So we're talking about 16k per lru.

*nod*

It is relatively little compared to the number of inodes typically
on a LRU.

> The superblocks only, are present by the dozens even in a small system,
> and I believe the whole goal of this API is to get more users to switch
> to it. This can easily use up a respectable bunch of megs.
> 
> Isn't it a bit too much ?

Maybe, but for active superblocks it only takes a handful of cached
inodes to make this 16k look like noise, so I didn't care. Indeed, a
typical active filesystem could be consuming gigabytes of memory in
the slab, so 16k is a tiny amount of overhead to track this amount
of memory more efficiently.

Most other LRU/shrinkers are tracking large objects and only have a
single LRU instance machine wide. Hence the numbers arguments don't
play out well in favour of a more complex, dynamic solution for
them, either. Sometimes dumb and simple is the best approach ;)

> I am wondering if we can't do better in here and at least allocate+grow
> according to the actual number of nodes.

We could add hotplug notifiers and grow/shrink the node array as
they get hot plugged, but that seems unnecessarily complex given
how rare such operations are.

If superblock proliferation is the main concern here, then doing
somethign as simple as allowing filesystems to specify they want
numa aware LRU lists via a mount_bdev() flag would solve this
problem. If the flag is set, then full numa lists are created.
Otherwise the LRU list simply has a "single node" and collapses all node
IDs down to 0 and ignores all NUMA optimisations...

That way the low item count virtual filesystems like proc, sys,
hugetlbfs, etc won't use up memory, but filesytems that actually
make use of NUMA awareness still get the more expensive, scalable
implementation. Indeed, any subsystem that is not performance or
location sensitive can use the simple single list version, so we can
avoid overhead in that manner system wide...

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
