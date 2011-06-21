Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9AC996B0159
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 01:09:28 -0400 (EDT)
Date: Tue, 21 Jun 2011 15:09:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 03/12] vmscan: reduce wind up shrinker->nr when
 shrinker can't do work
Message-ID: <20110621050914.GO32466@dastard>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-4-git-send-email-david@fromorbit.com>
 <4DFE997C.2060805@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4DFE997C.2060805@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Mon, Jun 20, 2011 at 09:51:08AM +0900, KOSAKI Motohiro wrote:
> (2011/06/02 16:00), Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > When a shrinker returns -1 to shrink_slab() to indicate it cannot do
> > any work given the current memory reclaim requirements, it adds the
> > entire total_scan count to shrinker->nr. The idea ehind this is that
> > whenteh shrinker is next called and can do work, it will do the work
> > of the previously aborted shrinker call as well.
> > 
> > However, if a filesystem is doing lots of allocation with GFP_NOFS
> > set, then we get many, many more aborts from the shrinkers than we
> > do successful calls. The result is that shrinker->nr winds up to
> > it's maximum permissible value (twice the current cache size) and
> > then when the next shrinker call that can do work is issued, it
> > has enough scan count built up to free the entire cache twice over.
> > 
> > This manifests itself in the cache going from full to empty in a
> > matter of seconds, even when only a small part of the cache is
> > needed to be emptied to free sufficient memory.
> > 
> > Under metadata intensive workloads on ext4 and XFS, I'm seeing the
> > VFS caches increase memory consumption up to 75% of memory (no page
> > cache pressure) over a period of 30-60s, and then the shrinker
> > empties them down to zero in the space of 2-3s. This cycle repeats
> > over and over again, with the shrinker completely trashing the N?node
> > and dentry caches every minute or so the workload continues.
> > 
> > This behaviour was made obvious by the shrink_slab tracepoints added
> > earlier in the series, and made worse by the patch that corrected
> > the concurrent accounting of shrinker->nr.
> > 
> > To avoid this problem, stop repeated small increments of the total
> > scan value from winding shrinker->nr up to a value that can cause
> > the entire cache to be freed. We still need to allow it to wind up,
> > so use the delta as the "large scan" threshold check - if the delta
> > is more than a quarter of the entire cache size, then it is a large
> > scan and allowed to cause lots of windup because we are clearly
> > needing to free lots of memory.
> > 
> > If it isn't a large scan then limit the total scan to half the size
> > of the cache so that windup never increases to consume the whole
> > cache. Reducing the total scan limit further does not allow enough
> > wind-up to maintain the current levels of performance, whilst a
> > higher threshold does not prevent the windup from freeing the entire
> > cache under sustained workloads.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  mm/vmscan.c |   14 ++++++++++++++
> >  1 files changed, 14 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index dce2767..3688f47 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -277,6 +277,20 @@ unsigned long shrink_slab(struct shrink_control *shrink,
> >  		}
> >  
> >  		/*
> > +		 * Avoid excessive windup on fielsystem shrinkers due to large
> > +		 * numbers of GFP_NOFS allocations causing the shrinkers to
> > +		 * return -1 all the time. This results in a large nr being
> > +		 * built up so when a shrink that can do some work comes along
> > +		 * it empties the entire cache due to nr >>> max_pass.  This is
> > +		 * bad for sustaining a working set in memory.
> > +		 *
> > +		 * Hence only allow nr to go large when a large delta is
> > +		 * calculated.
> > +		 */
> > +		if (delta < max_pass / 4)
> > +			total_scan = min(total_scan, max_pass / 2);
> > +
> > +		/*
> >  		 * Avoid risking looping forever due to too large nr value:
> >  		 * never try to free more than twice the estimate number of
> >  		 * freeable entries.
> 
> I guess "max_pass/4" and "min(total_scan, max_pass / 2)" are your heuristic value. right?

Yes.

> If so, please write your benchmark name and its result into the description.

Take your pick.

Anything that generates a large amount of vfs cache pressure
combined with GFP_NOFS memory allocation will show changes in
-behaviour- as you modify these variables.  e.g. creating 50 million
inodes in parallel with fs_mark, parallel chmod -R traversals of
said inodes, parallel rm -rf, etc. The same cache behaviour can be
observed with any of these sorts of cold cache workloads.

I say changes in behaviour rather than performance because just
measuring wall time does not necessarily show any difference in
performance. The bug this fixes is the cache being complete trashed
periodically, but none of the above workloads show significant wall
time differences in behaviour because of this modification as they
don't rely on cache hits for performance. If you have a workload
that actually relies on resident cache hits for good performance,
then you'll see a difference in performance that you can measure
with wall time....

What this change does have an effect on is the variance of the
resident cache size, which I monitor via live graphing of the
various cache metrics. It is not as simple to monitor as having a
single number fall out the bottom that you can point to for
improvement. Details of this is already documented in patch zero of
the series:

https://lkml.org/lkml/2011/6/2/42

Bsically, the above numbers gave the lowest variance in the resident
cache size without preventing the shrinker from being able to free
enough memory for the system to work effectively.

> I mean, currently some mm folks plan to enhance shrinker. So,
> sharing benchmark may help to avoid an accidental regression.

I predict that I will have some bug reporting to do in future. ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
