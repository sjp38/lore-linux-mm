Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 1A1736B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 03:22:27 -0400 (EDT)
Date: Mon, 13 May 2013 17:21:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 00/31] kmemcg shrinkers
Message-ID: <20130513072159.GN32675@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <20130513071359.GM32675@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130513071359.GM32675@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org

On Mon, May 13, 2013 at 05:14:00PM +1000, Dave Chinner wrote:
> On Sun, May 12, 2013 at 10:13:21PM +0400, Glauber Costa wrote:
> > Initial notes: ==============
> > 
> > Mel, Dave, this is the last round of fixes I have for the
> > series. The fixes are few, and I was mostly interested in
> > getting this out based on an up2date tree so Dave can verify it.
> > This should apply fine ontop of Friday's linux-next.
> > Alternatively, please grab from branch "kmemcg-lru-shrinker" at:
> > 
> > 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git
> > 
> > Main changes from *v5: * Rebased to linux-next, and fix the
> > conflicts with the dcache.  * Make sure LRU_RETRY only retry
> > once * Prevent the bcache shrinker to scan the caches when
> > disabled (by returning 0 in the count function) * Fix i915
> > return code when mutex cannot be acquired.  * Only scan
> > less-than-batch objects in memcg scenarios
> 
> Ok, this is behaving a *lot* better than v5 in terms of initial
> balance and sustained behaviour under pure inode/dentry press
> workloads. The previous version was all over the place, not to
> mention unstable and prone to unrealted lockups in the block
> layer.
> 
> However, I'm not sure that the LRUness of reclaim is working
> correctly at this point. When I switch from a write only workload
> to a read-only workload (i.e. fsmark finishes and find starts), I
> see this:
....
> So, yeah, there's still some broken stuff in this patchset that
> needs fixing.  The script that I'm running to trigger these
> problems is pretty basic - it's the same workload I've been using
> for the past 3 years for measuring metadata performance of
> filesystems:

And unmounting an XFS filesystem after running this workload is
hanging from time to time due to a reference counting problem on a
buffer....

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
