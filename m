Date: Fri, 4 May 2007 11:03:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change global zonelist order v4 [0/2]
In-Reply-To: <200705041036.01904.jbarnes@virtuousgeek.org>
Message-ID: <Pine.LNX.4.64.0705041055370.23539@schroedinger.engr.sgi.com>
References: <20070427144530.ae42ee25.kamezawa.hiroyu@jp.fujitsu.com>
 <1178299460.5236.35.camel@localhost> <Pine.LNX.4.64.0705041027030.22643@schroedinger.engr.sgi.com>
 <200705041036.01904.jbarnes@virtuousgeek.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Jesse Barnes wrote:

> You mentioned that if node 0 has a small ZONE_NORMAL and the ZONE_DMA for 
> the system, defaulting to using ZONE_NORMAL on all nodes first would be a 
> bad idea.  Is that really true?  Maybe for ZONE_DMA32 it is since that 
> first node could have a few gigs of memory, but for regular ZONE_DMA it's 
> probably the right thing to do...

If the fallback sequence is f.e. Node 0 NORMAL (500m) Node 1 NORMAL(4G) 
node 2 Normal (4G) ... many more ... Node 0 DMA32 (~4G) Node 0 DMA then 
memory is frequently going to be not optimally placed for allocations from 
processes running on node 0 because node 0 is memory starved. 
Allocations will be made from node 1 which may create a shortage there 
which fall again. Could be a cascade effect because the symmetry in 
memory is no longer there.

The proposal to create an additional node may solve that to some extend by placing the 
DMA node nearer to node 0.

Maybe the best approach is to leave things as is and just be careful with 
I/O to 32 bits? I do not think there is an easy solution. A 64 bit NUMA 
platforms should have I/O that is 64 bit capable and not restricted to DMA 
zones.

> > So aside from the comment issues Lee already pointed out, I think 
> Kamezawa-san's patch from 
> http://marc.info/?l=linux-mm&m=117758484122663&w=4 seems reasonable.

If we are going to do this then the patch needs to be fine tuned first and 
the impact on core code needs to be minimized. I want to make really sure 
that platforms without DMA zones work right, if zones are empty it should 
work right and weird x86_64 combinations of NORMAL, DMA and DMA32 
distributed over various nodes would need to be covered and tested first.

How will this affect NUMAQ (32 bit NUMA) where we have HIGHMEM on the 
(most) nodes and NORMAL/DMA on node 0?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
