Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 87CCB6B0036
	for <linux-mm@kvack.org>; Wed, 22 May 2013 02:27:08 -0400 (EDT)
Date: Wed, 22 May 2013 16:26:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 00/34] kmemcg shrinkers
Message-ID: <20130522062657.GU24543@dastard>
References: <1368994047-5997-1-git-send-email-glommer@openvz.org>
 <519B1C45.5090201@parallels.com>
 <20130521071800.GN24543@dastard>
 <519B21D5.9090109@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519B21D5.9090109@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, hughd@google.com

On Tue, May 21, 2013 at 11:27:17AM +0400, Glauber Costa wrote:
> On 05/21/2013 11:18 AM, Dave Chinner wrote:
> > On Tue, May 21, 2013 at 11:03:33AM +0400, Glauber Costa wrote:
> >> On 05/20/2013 12:06 AM, Glauber Costa wrote:
> >>> Initial notes:
> >>> ==============
> >>>
> >>> Please pay attention to new patches that are debuting in this series. Patch1
> >>> changes our unused countries for int to long, since Dave noticed that it wasn't
> >>> being enough in some cases. Aside from that, the major change is that we now
> >>> compute and keep deferred work per-node (Patch13). The biggest effect of this,
> >>> is that to avoid storing a new nodemask in the stack, I am passing only the
> >>> node id down to the API. This means that the lru API *does not* take a nodemask
> >>> any longer, which in turn, makes it simpler.
> >>>
> >>> I deeply considered this matter, and decided this would be the best way to go.
> >>> It is not different from what I have already done for memcgs: Only a single one
> >>> is passed down, and the complexity of scanning them is moved upwards to the
> >>> caller, where all the scanning logic should belong anyway.
> >>>
> >>> If you want, you can also grab from branch "kmemcg-lru-shrinker" at:
> >>>
> >>> 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git
> >>>
> >>> I hope the performance problems are all gone. My testing now shows a smoother
> >>> and steady state for the objects during the lifetime of the workload, and
> >>> postmark numbers are closer to base, although we do deviate a bit.
> >>>
> >>
> >> Mel, Dave, et. al.
> >>
> >> I have applied some more fixes for things I have found here and there as
> >> a result of a new round of testing. I won't post the result here until
> >> Thursday or Friday, to avoid patchbombing you guys. In the meantime I
> >> will be merging comments I receive from this version.
> >>
> >> My git tree is up to date, so if you want to test it further, please
> >> pick that up.
> > 
> > Will do. I hope to do some testing of it tommorrow.
> > 
> >> I am attaching the result of my postmark run. I think the results look
> >> really good now.
> > 
> > What's version and command line you are using - I'll see if i can
> > reproduce the same results on my test system....
> > 
> 
> I am using Mel's mmtest. So I cloned it, changed to config to run the
> postmark benchmark set TEST_PARTITION to my disk, TEST_FILESYSTEM to
> ext3 (specially that fsmark was already running xfs with your script),
> and then ./run-mmtests.sh <name_of_test>

Well, I haven't got to running postmark yet, but so far the
behaviour of this version of the patch series on my usual benchmarks
is, well, damn good. Better than I've ever seen it, and I'd say that
big change is due to the per-node reclaim deferral.

The overall cache balance and stability is as close to identical to
a single node machine(*) as I've ever seen for the workloads I've
run.  It's a little more variable than for the single node tst runs,
but the curves all have the same height, the same shape and same
relative behaviour. Compared to 3.9 numa behaviour, they are worlds
apart.

(*) Same VM, only difference is fake-numa=4 for the numa results.

In terms of performance, the difference is mostly within the
variance of the the benchmarks, maybe ever so slightly faster.  e.g.
for the fsmark workload I posted previously (50m zero length files,
walk then, remove them), then numbers are:

		create	walk	remove
3.9		8m07s	5m42s	11m50s
3.10-lru	8m13s	5m29s	11m40s

Of note, under mixed page cache/slab workloads that generate memory
pressure, I am seeing slightly elevated system CPU time. Nothing in
profiles show up as being significantly different, so it may just be
that because kswapd is not emptying the caches all the time more of
the reclaim work is being accounted to the user processes...

There is one problem I've found, however, but I haven't got to the
bottom of. During concurrent inode read workloads (find, grep, etc)
I'm getting a hang in the XFS inode cache. It's finding an xfs inode
in the XFS inode cache, but when it tries to grab the VFS inode,
that fails. This means we have an XFS inode without the
XFS_IRECLAIMABLE flag set but with I_FREEING|I_WILL_FREE set on the
VFS inode. That means the VFS has let go of the inode and destroyed
it, but XFS doesn't think that it has been destroyed. It's stuck in
limbo.

This isn't easily reproducable, so it might take me a while to track
down. however....


.... I went looking at the xfs inode reclaim code, and realised
there's something missing from the overall patch set. The patch that
does node-aware reclaim of the XFS inode cache is missing, as well
as the followup that cleans up the mess that is no longer needed.
I'll port these patches forward from my old guilt tree that contains
them, and post them once I have them working. I'll also try to get
to the bottom of whatever strangeness is causing this hang...

But, overall, the system is behaviing very well, and so from an
infrastructure perspective I think the patch set is in pretty good
shape. Nice work, Glauber. :)

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
