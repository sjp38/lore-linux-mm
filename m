Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id B69306B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 00:58:47 -0400 (EDT)
Date: Tue, 2 Apr 2013 15:58:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 00/28] memcg-aware slab shrinking
Message-ID: <20130402045842.GO6369@dastard>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
 <20130401123843.GC5217@sergelap>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130401123843.GC5217@sergelap>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, hughd@google.com, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Apr 01, 2013 at 07:38:43AM -0500, Serge Hallyn wrote:
> Quoting Glauber Costa (glommer@parallels.com):
> > Hi,
> > 
> > Notes:
> > ======
> > 
> > This is v2 of memcg-aware LRU shrinking. I've been testing it extensively
> > and it behaves well, at least from the isolation point of view. However,
> > I feel some more testing is needed before we commit to it. Still, this is
> > doing the job fairly well. Comments welcome.
> 
> Do you have any performance tests (preferably with enough runs with and
> without this patchset to show 95% confidence interval) to show the
> impact this has?  Certainly the feature sounds worthwhile, but I'm
> curious about the cost of maintaining this extra state.

The reason for the node-aware LRUs in the first place is
performance. i.e. to remove the global LRU locks from the shrinkers
and LRU list operations. For XFS (at least) the VFS LRU operations
are significant sources of contention at 16p, and at high CPU counts
they can basically cause spinlock meltdown.

I've done performance testing on them on 16p machines with
fake-numa=4 under such contention generating workloads (e.g. 16-way
concurrent fsmark workloads) and seen that the LRU locks disappear
from the profiles. Performance improvement at this size of machine
under these workloads is still within the run-to-run variance of the
benchmarks I've run, but the fact the lock is no longer in the
profiles at all suggest that scalability for larger machines will be
significantly improved.

As for the memcg side of things, I'll leave that to Glauber....

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
