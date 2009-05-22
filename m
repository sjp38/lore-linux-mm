Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 138666B004D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 08:25:48 -0400 (EDT)
Date: Fri, 22 May 2009 07:26:09 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH v3] zone_reclaim is always 0 by default
Message-ID: <20090522122609.GC29447@sgi.com>
References: <20090521114408.63D0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090521114408.63D0.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Robin Holt <holt@sgi.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

OK.  While I did not object earlier, I am starting to feel a NACK
coming on.

How did you determine this is the source of your problems?  What leads
you to believe this is the correct fix instead of an easy change which
affects some random benchmark?

Let me clear, I believe you are seeing an impact from reclaim.  I do
not agree it is necessarily a negative impact for the majority of users.


On Thu, May 21, 2009 at 11:47:01AM +0900, KOSAKI Motohiro wrote:
> 
> Subject: [PATCH v3] zone_reclaim is always 0 by default
> 
> Current linux policy is, zone_reclaim_mode is enabled by default if the machine
> has large remote node distance. it's because we could assume that large distance
> mean large server until recently.
> 
> Unfortunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> memory controller. IOW it's seen as NUMA from software view.
> Some Core i7 machine has large remote node distance.
> 
> Yanmin reported zone_reclaim_mode=1 cause large apache regression.
> 
>     One Nehalem machine has 12GB memory,
>     but there is always 2GB free although applications accesses lots of files.
>     Eventually we located the root cause as zone_reclaim_mode=1.

Your root cause analysis is suspect.  You found a knob to turn which
suddenly improved performance for one specific un-tuned server workload.

> Actually, zone_reclaim_mode=1 mean "I dislike remote node allocation rather than
> disk access", it makes performance improvement to HPC workload.
> but it makes performance regression desktop, file server and web server.

zone_reclaim_mode merely means try to free any local unused page before
going off node.  I have never seen off-node allocations precluded as
long as the local node's pages are in use.  The effect on your one test
shows that unused page cache pages get properly discarded and reused by
the allocator.

> In general, workload depended configuration shouldn't put into default settings.
> Plus, desktop and file/web server eco-system is much larger than hpc's.

I believe you are putting a workload dependent configuration in as the
default.  You have not shown this improves anything other than a poorly
configured system running apache responds better on your tests.  I can
make a common sense argument that both =1 and =0 are better.  I think
the fact that it has been =1 for so long and not caused significant
issues should at least be factored in.  Making an exception for the
new hardware on the block makes sense as well.

> Thus, zone_reclaim == 0 is better by default.

How did you determine better by default?  I think we already established
that apache is a server workload and not a desktop workload.  Earlier
you were arguing that we need this turned off to improve the desktop
environment.  You have not established this improves desktop performance.
Actually, you have not established it improves apache performance or
server performance.  You have documented it improves memory utilization,
but that is not always the same as faster.

Sorry for being difficult about this, but you are tweaking a knob that
completely changes performance for my typical workload.  Reclaim has
been the source of great frustration for me over the years.

Hopefully this is not arrogance on my part, but if you went back to
something equivalent to my earlier patch which allowed the architecture
to decide the default, I would go back to not objecting despite the lack
of proof this is the right fix.  You never did specify what was wrong
with that patch.  It was simple to understand, accomplished your needs
as well as mine, allowed flexibility in implementing the default as the
#define could be expanded to include arch specific checks if sub-arches
find they need a different default than the rest of the arch.  Compared to
"Just remove the default", that seems preferable.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
