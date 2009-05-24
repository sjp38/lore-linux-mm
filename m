Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C6F526B0055
	for <linux-mm@kvack.org>; Sun, 24 May 2009 09:43:54 -0400 (EDT)
Date: Sun, 24 May 2009 22:44:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3] zone_reclaim is always 0 by default
In-Reply-To: <20090522122609.GC29447@sgi.com>
References: <20090521114408.63D0.A69D9226@jp.fujitsu.com> <20090522122609.GC29447@sgi.com>
Message-Id: <20090524214554.084F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> OK.  While I did not object earlier, I am starting to feel a NACK
> coming on.
> 
> How did you determine this is the source of your problems?  What leads
> you to believe this is the correct fix instead of an easy change which
> affects some random benchmark?
> 
> Let me clear, I believe you are seeing an impact from reclaim.  I do
> not agree it is necessarily a negative impact for the majority of users.
> 
> 
> On Thu, May 21, 2009 at 11:47:01AM +0900, KOSAKI Motohiro wrote:
> > 
> > Subject: [PATCH v3] zone_reclaim is always 0 by default
> > 
> > Current linux policy is, zone_reclaim_mode is enabled by default if the machine
> > has large remote node distance. it's because we could assume that large distance
> > mean large server until recently.
> > 
> > Unfortunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> > memory controller. IOW it's seen as NUMA from software view.
> > Some Core i7 machine has large remote node distance.
> > 
> > Yanmin reported zone_reclaim_mode=1 cause large apache regression.
> > 
> >     One Nehalem machine has 12GB memory,
> >     but there is always 2GB free although applications accesses lots of files.
> >     Eventually we located the root cause as zone_reclaim_mode=1.
> 
> Your root cause analysis is suspect.  You found a knob to turn which
> suddenly improved performance for one specific un-tuned server workload.

You'd think.

Actually, I have both HPC and server area job experience. 
I've seen zone reclaim improve some workload performance and decrease
another some workload (note, it's include hpc workload).
if you haven't seen zone_reclaim decrease performance, it mean
you don't test this feature enough widely.

The fact is, workload dependency charactetistics of zone reclaim is
widely known from very ago.
Even Documentaion/sysctl/vm.txt said, 

> It may be beneficial to switch off zone reclaim if the system is
> used for a file server and all of memory should be used for caching files
> from disk. In that case the caching effect is more important than
> data locality.

Nobody except you oppose this.




> > Actually, zone_reclaim_mode=1 mean "I dislike remote node allocation rather than
> > disk access", it makes performance improvement to HPC workload.
> > but it makes performance regression desktop, file server and web server.
> 
> zone_reclaim_mode merely means try to free any local unused page before
> going off node.  I have never seen off-node allocations precluded as
> long as the local node's pages are in use.  The effect on your one test
> shows that unused page cache pages get properly discarded and reused by
> the allocator.

You'd think.

Don't you have x86 machine? you can test zone_reclaim_mode on desktop by
using fake-numa.

Actually, your "local unused page" is _not_ unused. zone reclaim drop
oldest file backed non-dirty page.
if you think non-dirty mean unused, you don't understand linux memory management.
Only overkill system memory gurantee oldest page is unused.



> > In general, workload depended configuration shouldn't put into default settings.
> > Plus, desktop and file/web server eco-system is much larger than hpc's.
> 
> I believe you are putting a workload dependent configuration in as the
> default.  You have not shown this improves anything other than a poorly
> configured system running apache responds better on your tests.  I can
> make a common sense argument that both =1 and =0 are better.  I think
> the fact that it has been =1 for so long and not caused significant
> issues should at least be factored in.  Making an exception for the
> new hardware on the block makes sense as well.

You'd think.

performance issue have been exist. but it merely mean hpc and high-end server
could avoid it. because they are skillfull engineer.



> > Thus, zone_reclaim == 0 is better by default.
> 
> How did you determine better by default?  I think we already established
> that apache is a server workload and not a desktop workload.  Earlier
> you were arguing that we need this turned off to improve the desktop
> environment.  You have not established this improves desktop performance.
> Actually, you have not established it improves apache performance or
> server performance.  You have documented it improves memory utilization,
> but that is not always the same as faster.

The fact is, low-end machine performace depend on cache hitting ratio widely.
improving memory utilization mean improving cache hitting ratio.

Plus, I already explained about desktop use case. multiple worst case scenario 
can happend on it easily.

if big process consume memory rather than node size, zone-reclaim
decrease performance largely.

zone reclaim decrease page-cache hitting ratio. some desktop don't have
much memory. cache missies does'nt only increase latency, but also
increase unnecessary I/O. desktop don't have rich I/O bandwidth rather than
server or hpc. it makes bad I/O affect.

inter zone imbalancing issue makes another cache hitting ratio decreasing.



> Sorry for being difficult about this, but you are tweaking a knob that
> completely changes performance for my typical workload.  Reclaim has
> been the source of great frustration for me over the years.
> 
> Hopefully this is not arrogance on my part, but if you went back to
> something equivalent to my earlier patch which allowed the architecture
> to decide the default, I would go back to not objecting despite the lack
> of proof this is the right fix.  You never did specify what was wrong
> with that patch.  It was simple to understand, accomplished your needs
> as well as mine, allowed flexibility in implementing the default as the
> #define could be expanded to include arch specific checks if sub-arches
> find they need a different default than the rest of the arch.  Compared to
> "Just remove the default", that seems preferable.

firstly, I'd say I think your patch is enough considerable. 

However, your past explanation is really wrong and bogus.
I wrote

> If this imbalance is an x86_64 only problem, then we could do something
> simple like the following untested patch.  This leaves the default
> for everyone except x86_64.

and I wrote it isn't true. after that, you haven't provide addisional
explanation.

Nobody ack CODE-ONLY-PATCH. _You_ have to explain _why_ you think 
your approach is better.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
