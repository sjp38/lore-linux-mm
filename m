Subject: Re: NUMA policy issues with ZONE_MOVABLE
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070726225920.GA10225@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	 <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie>
Content-Type: text/plain
Date: Wed, 01 Aug 2007 14:59:39 -0400
Message-Id: <1185994779.5059.87.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

<snip>
> This patch filters only when MPOL_BIND is in use. In non-numa, the
> checks do not exist and in NUMA cases, the filtering usually does not
> take place. I'd like this to be the bug fix for policy + ZONE_MOVABLE
> and then deal with reducing zonelists to see if there is any performance
> gain as well as a simplification in how policies and cpusets are
> implemented.
> 
> Testing shows no difference on non-numa as you'd expect and on NUMA machines,
> there are very small differences on NUMA (kernbench figures range from -0.02%
> to 0.15% differences on machines). Lee, can you test this patch in relation
> to MPOL_BIND?  I'll look at the numactl tests tomorrow as well.
> 

The patches look OK to me.  I got around to testing it today. 
Both atop the Memoryless Nodes series, and directly on 23-rc1-mm1.

Test System: 32GB 4-node ia64, booted with kernelcore=24G.
Yields, about 2GB Movable, and 6G Normal per node.

Filtered zoneinfo:

Node 0, zone   Normal
  pages free     416464
        spanned  425984
        present  424528
Node 0, zone  Movable
  pages free     47195
        spanned  60416
        present  60210
Node 1, zone   Normal
  pages free     388011
        spanned  393216
        present  391871
Node 1, zone  Movable
  pages free     125940
        spanned  126976
        present  126542
Node 2, zone   Normal
  pages free     387849
        spanned  393216
        present  391872
Node 2, zone  Movable
  pages free     126285
        spanned  126976
        present  126542
Node 3, zone   Normal
  pages free     388256
        spanned  393216
        present  391872
Node 3, zone  Movable
  pages free     126575
        spanned  126966
        present  126490
Node 4, zone      DMA
  pages free     31689
        spanned  32767
        present  32656
---
Attempt to allocate a 12G--i.e., > 4*2G--segment interleaved
across nodes 0-3 with memtoy.   I figured this would use up
all of ZONE_MOVABLE on each node and then dip into NORMAL.

root@gwydyr(root):memtoy
memtoy pid:  6558
memtoy>anon a1 12g
memtoy>map a1
memtoy>mbind a1 interleave 0,1,2,3
memtoy>touch a1 w
memtoy:  touched 786432 pages in 10.542 secs

Yields:

Node 0, zone   Normal
  pages free     328392
        spanned  425984
        present  424528
Node 0, zone  Movable
  pages free     37
        spanned  60416
        present  60210
Node 1, zone   Normal
  pages free     300293
        spanned  393216
        present  391871
Node 1, zone  Movable
  pages free     91
        spanned  126976
        present  126542
Node 2, zone   Normal
  pages free     300193
        spanned  393216
        present  391872
Node 2, zone  Movable
  pages free     49
        spanned  126976
        present  126542
Node 3, zone   Normal
  pages free     300448
        spanned  393216
        present  391872
Node 3, zone  Movable
  pages free     56
        spanned  126966
        present  126490
Node 4, zone      DMA
  pages free     31689
        spanned  32767
        present  32656

Looks like most of the movable zone in each node [~8G]
and remainder from normal zones.  Should be ~1G from 
zone normal of each node.  However, memtoy shows something
weird, looking at the location of the 1st 64 pages at each
1G boundary.  Most pages are located as I "expect" [well, I'm
not sure why we start with node 2 at offset 0, instead of 
node 0].

memtoy>where a1
a 0x2000000003c08000 0x000300000000 0x000000000000  rw- private a1
page offset    +00 +01 +02 +03 +04 +05 +06 +07
           0:    2   3   0   1   2   3   0   1
           8:    2   3   0   1   2   3   0   1
          10:    2   3   0   1   2   3   0   1
          18:    2   3   0   1   2   3   0   1
          20:    2   3   0   1   2   3   0   1
          28:    2   3   0   1   2   3   0   1
          30:    2   3   0   1   2   3   0   1
          38:    2   3   0   1   2   3   0   1

Same at 1G, 2G and 3G
But, between ~4G through 6+G [I didn't check any finer
granuality and didn't want to watch > 780K pages scroll
by] show:

memtoy>where a1 4g 64p
a 0x2000000003c08000 0x000300000000 0x000000000000  rw- private a1
page offset    +00 +01 +02 +03 +04 +05 +06 +07
       40000:    2   3   1   1   2   3   1   1
       40008:    2   3   1   1   2   3   1   1
       40010:    2   3   1   1   2   3   1   1
       40018:    2   3   1   1   2   3   1   1
       40020:    2   3   1   1   2   3   1   1
       40028:    2   3   1   1   2   3   1   1
       40030:    2   3   1   1   2   3   1   1
       40038:    2   3   1   1   2   3   1   1

Same at 5G, then:

memtoy>where a1 6g 64p
a 0x2000000003c08000 0x000300000000 0x000000000000  rw- private a1
page offset    +00 +01 +02 +03 +04 +05 +06 +07
       60000:    2   3   2   2   2   3   2   2
       60008:    2   3   2   2   2   3   2   2
       60010:    2   3   2   2   2   3   2   2
       60018:    2   3   2   2   2   3   2   2
       60020:    2   3   2   2   2   3   2   2
       60028:    2   3   2   2   2   3   2   2
       60030:    2   3   2   2   2   3   2   2
       60038:    2   3   2   2   2   3   2   2

7G, 8G, ... 11G back to expected pattern.

Thought this might be due to interaction with memoryless node patches, 
so I backed those out and tested Mel's patch again.  This time I
ran memtoy in batch mode and dumped the entire segment page locations
to a file.  Did this twice.   Both looked pretty much the same--i.e.,
the change in pattern occurs at around the same offset into the
segment.  Note that here, the interleave starts at node 3 at offset
zero.

memtoy>where a1 0 0
a 0x200000000047c000 0x000300000000 0x000000000000  rw- private a1
page offset    +00 +01 +02 +03 +04 +05 +06 +07
           0:    3   0   1   2   3   0   1   2
           8:    3   0   1   2   3   0   1   2
          10:    3   0   1   2   3   0   1   2
...
       38c20:    3   0   1   2   3   0   1   2
       38c28:    3   0   1   2   3   0   1   2
       38c30:    3   1   1   2   3   1   1   2
       38c38:    3   1   1   2   3   1   1   2
       38c40:    3   1   1   2   3   1   1   2
...
       5a0c0:    3   1   1   2   3   1   1   2
       5a0c8:    3   1   1   2   3   1   1   2
       5a0d0:    3   1   1   2   3   2   2   2
       5a0d8:    3   2   2   2   3   2   2   2
       5a0e0:    3   2   2   2   3   2   2   2
...
       65230:    3   2   2   2   3   2   2   2
       65238:    3   2   2   2   3   2   2   2
       65240:    3   2   2   2   3   3   3   3
       65248:    3   3   3   3   3   3   3   3
       65250:    3   3   3   3   3   3   3   3
...
       6ab60:    3   3   3   3   3   3   3   3
       6ab68:    3   3   3   3   3   3   3   3
       6ab70:    3   3   3   2   3   0   1   2
       6ab78:    3   0   1   2   3   0   1   2
       6ab80:    3   0   1   2   3   0   1   2
...
and so on to the end of the segment:
       bffe8:    3   0   1   2   3   0   1   2
       bfff0:    3   0   1   2   3   0   1   2
       bfff8:    3   0   1   2   3   0   1   2

The pattern changes occur at about page offsets:

0x38800 = ~ 3.6G
0x5a000 = ~ 5.8G
0x65000 = ~ 6.4G
0x6aa00 = ~ 6.8G

Then I checked zonelist order:
Built 5 zonelists in Zone order, mobility grouping on.  Total pages: 2072583

Looks like we're falling back to ZONE_MOVABLE on the next node when ZONE_MOVABLE
on target node overflows.

Rebooted to "Node order" [numa_zonelist_order sysctl missing in 23-rc1-mm1]
and tried again.  Saw "expected" interleave pattern across entire 12G segment.

Kame-san's patch to just exclude the DMA zones from the zonelists is looking
better--better than changing zonelist order when zone_movable is populated!

But, Mel's patch seems to work OK.  I'll keep it in my stack for later 
stress testing.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
