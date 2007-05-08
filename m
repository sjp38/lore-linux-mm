Subject: Re: [PATCH] change zonelist order v5 [1/3] implements zonelist
	order selection
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705081104180.9941@schroedinger.engr.sgi.com>
References: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070508201642.c63b3f65.kamezawa.hiroyu@jp.fujitsu.com>
	 <1178643985.5203.27.camel@localhost>
	 <Pine.LNX.4.64.0705081021340.9446@schroedinger.engr.sgi.com>
	 <1178645622.5203.53.camel@localhost>
	 <Pine.LNX.4.64.0705081104180.9941@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 08 May 2007 16:37:06 -0400
Message-Id: <1178656627.5203.84.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-08 at 11:05 -0700, Christoph Lameter wrote:
> On Tue, 8 May 2007, Lee Schermerhorn wrote:
> 
> > > So far testing is IA64 only?
> > Yes, so far.  I will test on an Opteron platform this pm.  
> > Assume that no news is good news.
> 
> A better assumption: no news -> no testing. 

Before you asked, yes.  I meant after the last message, if you didn't
hear from me, everything worked fine.  And it does, sort of...


> You probably need a 
> configuration with a couple of nodes. Maybesomething less symmetric than 
> Kame? I.e. have 4GB nodes and then DMA32 takes out a sizeable chunk of it?
> 

I tested on a 2 socket, 4GB Opteron blade.  All memory is either DMA32
or DMA.  I added some ad hoc instrumentation to the build_zonelist_*
functions to see what's happening.  I have verified that the patches
appear to build the zonelists correctly:

default -> node order, because "low_kmem" [DMA+DMA32] > total_mem/2.
Zone lists:
DMA:  DMA-0
DMA32: DMA32-0, DMA-0, DMA32-1
Normal:  same as DMA32 [no normal memory]
Movable:  same as DMA32 & Normal

explicit zone order also builds as expected:
DMA:  DMA-0
DMA32:  DMA32-1, DMA32-0, DMA-0
and same for normal and movable

However, a curious thing happens:  in either order, allocations seem to
overflow to the remote DMA32 before dipping into the DMA!!!?  I'm using
memtoy to create a large [3+GB] anon segment and locking it down.

I need to check a non-patched kernel to see if it behaves the same way,
and examine the code to see why...  For one thing, the kernel seems to
do a bit better at reclaiming memory before overflowing.  Eventually, it
will dip into DMA and finally get killed--OOM.

I'll be off-line most of the rest of the week, so I probably won't get
to investigate much further nor test on a larger socket count/memory
system until next week.  

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
