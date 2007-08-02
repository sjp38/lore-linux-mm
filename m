Subject: Re: NUMA policy issues with ZONE_MOVABLE
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070802171059.GC23133@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	 <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie> <1185994779.5059.87.camel@localhost>
	 <20070802171059.GC23133@skynet.ie>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 13:51:51 -0400
Message-Id: <1186077112.5040.54.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 18:10 +0100, Mel Gorman wrote:
> On (01/08/07 14:59), Lee Schermerhorn didst pronounce:
> > <snip>
> > > This patch filters only when MPOL_BIND is in use. In non-numa, the
> > > checks do not exist and in NUMA cases, the filtering usually does not
> > > take place. I'd like this to be the bug fix for policy + ZONE_MOVABLE
> > > and then deal with reducing zonelists to see if there is any performance
> > > gain as well as a simplification in how policies and cpusets are
> > > implemented.
> > > 
> > > Testing shows no difference on non-numa as you'd expect and on NUMA machines,
> > > there are very small differences on NUMA (kernbench figures range from -0.02%
> > > to 0.15% differences on machines). Lee, can you test this patch in relation
> > > to MPOL_BIND?  I'll look at the numactl tests tomorrow as well.
> > > 
> > 
> > The patches look OK to me.  I got around to testing it today. 
> > Both atop the Memoryless Nodes series, and directly on 23-rc1-mm1.
> > 
> 
> Excellent. Thanks for the test. I hadn't seen memtool in use before, it
> looks great for investigating this sort of thing.

You can grab the latest memtoy at:

http://free.linux.hp.com/~lts/Tools/memtoy-latest.tar.gz

Be sure to read the README about building.  It depends on headhers and
libraries that may not be on your system.  I also have a number of
compile time options and stub libraries that allow me to test on
non-numa platforms...   Other folks who have tried to compile it have
problems the first time, so I tried to document the issues and how to
resolve.


<snip>
> > 
> > Looks like most of the movable zone in each node [~8G]
> > and remainder from normal zones.  Should be ~1G from 
> > zone normal of each node.  However, memtoy shows something
> > weird, looking at the location of the 1st 64 pages at each
> > 1G boundary.  Most pages are located as I "expect" [well, I'm
> > not sure why we start with node 2 at offset 0, instead of 
> > node 0].
> 
> Could it simply because the process started on node 2?  alloc_page_interleave()
> would have taken the zonelist on that node then.

Except alloc_page_interleave() takes a starting node id that it gets
from interleave_nid()--which should use offset based interleaving.  I'll
instrument this to see what's going on when I get a chance.

<snip>
> > 
> > Then I checked zonelist order:
> > Built 5 zonelists in Zone order, mobility grouping on.  Total pages: 2072583
> > 
> > Looks like we're falling back to ZONE_MOVABLE on the next node when ZONE_MOVABLE
> > on target node overflows.
> > 
> 
> Ok, which might have been unexpected to you, but it's behaving as
> advertised for zonelists.

Not unexpected, once I realized what was happening.  As I replied to
Kame, if I had chosen a more realistic [???] -- i.e., smaller --
kernelcore size, I think it would worked as I first expected.

> 
> > Rebooted to "Node order" [numa_zonelist_order sysctl missing in 23-rc1-mm1]
> > and tried again.  Saw "expected" interleave pattern across entire 12G segment.
> > 
> > Kame-san's patch to just exclude the DMA zones from the zonelists is looking
> > better--better than changing zonelist order when zone_movable is populated!
> > 
> > But, Mel's patch seems to work OK.  I'll keep it in my stack for later 
> > stress testing.
> > 
> 
> Great. As this has passed your tests and it passes the numactl
> regression tests (when patched for timing problems) with and without
> kernelcore, I reckon it's good as a bugfix.
> 
> Thanks Lee
> 

My pleasure.  I learned a lot doing it...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
