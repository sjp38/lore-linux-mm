Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8BEA36B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:37:45 -0400 (EDT)
Date: Thu, 6 Jun 2013 13:37:42 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 13/35] vmscan: per-node deferred work
Message-ID: <20130606033742.GS29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-14-git-send-email-glommer@openvz.org>
 <20130605160815.fb69f7d4d1736455727fc669@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605160815.fb69f7d4d1736455727fc669@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Wed, Jun 05, 2013 at 04:08:15PM -0700, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:29:42 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
> > We already keep per-node LRU lists for objects being shrunk, but the
> > work that is deferred from one run to another is kept global. This
> > creates an impedance problem, where upon node pressure, work deferred
> > will accumulate and end up being flushed in other nodes.
> 
> This changelog would be more useful if it had more specificity.  Where
> do we keep these per-node LRU lists (names of variables?).

In the per-node LRU lists the shrinker walks ;)

> Where do we
> keep the global data? 

In the struct shrinker

> In what function does this other-node flushing
> happen?

Any shrinker that is run on a different node.

> Generally so that readers can go and look at the data structures and
> functions which you're talking about.
> 
> > In large machines, many nodes can accumulate at the same time, all
> > adding to the global counter.
> 
> What global counter?

shrinker->nr

> >  As we accumulate more and more, we start
> > to ask for the caches to flush even bigger numbers.
> 
> Where does this happen?

The shrinker scan loop ;)

> > @@ -186,6 +208,116 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
> >  }
> >  
> >  #define SHRINK_BATCH 128
> > +
> > +static unsigned long
> > +shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> > +		 unsigned long nr_pages_scanned, unsigned long lru_pages,
> > +		 atomic_long_t *deferred)
> > +{
> > +	unsigned long freed = 0;
> > +	unsigned long long delta;
> > +	long total_scan;
> > +	long max_pass;
> > +	long nr;
> > +	long new_nr;
> > +	long batch_size = shrinker->batch ? shrinker->batch
> > +					  : SHRINK_BATCH;
> > +
> > +	if (shrinker->scan_objects) {
> > +		max_pass = shrinker->count_objects(shrinker, shrinkctl);
> > +		WARN_ON(max_pass < 0);
> > +	} else
> > +		max_pass = do_shrinker_shrink(shrinker, shrinkctl, 0);
> > +	if (max_pass <= 0)
> > +		return 0;
> > +
> > +	/*
> > +	 * copy the current shrinker scan count into a local variable
> > +	 * and zero it so that other concurrent shrinker invocations
> > +	 * don't also do this scanning work.
> > +	 */
> > +	nr = atomic_long_xchg(deferred, 0);
> 
> This comment seems wrong.  It implies that "deferred" refers to "the
> current shrinker scan count".  But how are these two the same thing?  A
> "scan count" would refer to the number of objects to be scanned (or
> which were scanned - it's unclear).  Whereas "deferred" would refer to
> the number of those to-be-scanned objects which we didn't process and
> is hence less than or equal to the "scan count".
> 
> It's all very foggy :(  This whole concept of deferral needs more
> explanation, please.

You wrote the shrinker deferal code way back in 2.5.42 (IIRC), so
maybe you can explain it to us? :)

> 
> > +	total_scan = nr;
> > +	delta = (4 * nr_pages_scanned) / shrinker->seeks;
> > +	delta *= max_pass;
> > +	do_div(delta, lru_pages + 1);
> > +	total_scan += delta;
> > +	if (total_scan < 0) {
> > +		printk(KERN_ERR
> > +		"shrink_slab: %pF negative objects to delete nr=%ld\n",
> > +		       shrinker->shrink, total_scan);
> > +		total_scan = max_pass;
> > +	}
> > +
> > +	/*
> > +	 * We need to avoid excessive windup on filesystem shrinkers
> > +	 * due to large numbers of GFP_NOFS allocations causing the
> > +	 * shrinkers to return -1 all the time. This results in a large
> > +	 * nr being built up so when a shrink that can do some work
> > +	 * comes along it empties the entire cache due to nr >>>
> > +	 * max_pass.  This is bad for sustaining a working set in
> > +	 * memory.
> > +	 *
> > +	 * Hence only allow the shrinker to scan the entire cache when
> > +	 * a large delta change is calculated directly.
> > +	 */
> 
> That was an important comment.  So the whole problem we're tackling
> here is fs shrinkers baling out in GFP_NOFS allocations?

commit 3567b59aa80ac4417002bf58e35dce5c777d4164
Author: Dave Chinner <dchinner@redhat.com>
Date:   Fri Jul 8 14:14:36 2011 +1000

    vmscan: reduce wind up shrinker->nr when shrinker can't do work
    
    When a shrinker returns -1 to shrink_slab() to indicate it cannot do
    any work given the current memory reclaim requirements, it adds the
    entire total_scan count to shrinker->nr. The idea ehind this is that
    whenteh shrinker is next called and can do work, it will do the work
    of the previously aborted shrinker call as well.
    
    However, if a filesystem is doing lots of allocation with GFP_NOFS
    set, then we get many, many more aborts from the shrinkers than we
    do successful calls. The result is that shrinker->nr winds up to
    it's maximum permissible value (twice the current cache size) and
    then when the next shrinker call that can do work is issued, it
    has enough scan count built up to free the entire cache twice over.
    
    This manifests itself in the cache going from full to empty in a
    matter of seconds, even when only a small part of the cache is
    needed to be emptied to free sufficient memory.
    
    Under metadata intensive workloads on ext4 and XFS, I'm seeing the
    VFS caches increase memory consumption up to 75% of memory (no page
    cache pressure) over a period of 30-60s, and then the shrinker
    empties them down to zero in the space of 2-3s. This cycle repeats
    over and over again, with the shrinker completely trashing the inode
    and dentry caches every minute or so the workload continues.
    
    This behaviour was made obvious by the shrink_slab tracepoints added
    earlier in the series, and made worse by the patch that corrected
    the concurrent accounting of shrinker->nr.
    
    To avoid this problem, stop repeated small increments of the total
    scan value from winding shrinker->nr up to a value that can cause
    the entire cache to be freed. We still need to allow it to wind up,
    so use the delta as the "large scan" threshold check - if the delta
    is more than a quarter of the entire cache size, then it is a large
    scan and allowed to cause lots of windup because we are clearly
    needing to free lots of memory.
    
    If it isn't a large scan then limit the total scan to half the size
    of the cache so that windup never increases to consume the whole
    cache. Reducing the total scan limit further does not allow enough
    wind-up to maintain the current levels of performance, whilst a
    higher threshold does not prevent the windup from freeing the entire
    cache under sustained workloads.
    
    Signed-off-by: Dave Chinner <dchinner@redhat.com>
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>



-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
