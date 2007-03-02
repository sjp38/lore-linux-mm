Date: Fri, 2 Mar 2007 11:34:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302113412.eeacb60d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070301160915.6da876c5.akpm@linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@skynet.ie, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Mar 2007 16:09:15 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 1 Mar 2007 10:12:50 +0000
> mel@skynet.ie (Mel Gorman) wrote:
> 
> > Any opinion on merging these patches into -mm
> > for wider testing?
> 
> I'm a little reluctant to make changes to -mm's core mm unless those
> changes are reasonably certain to be on track for mainline, so let's talk
> about that.
> 
> What worries me is memory hot-unplug and per-container RSS limits.  We
> don't know how we're going to do either of these yet, and it could well be
> that the anti-frag work significantly complexicates whatever we end up
> doing there.
> 
> For prioritisation purposes I'd judge that memory hot-unplug is of similar
> value to the antifrag work (because memory hot-unplug permits DIMM
> poweroff).

About memory-hot-unplug, I'm now writing a new patch-set for memory-unplug for
showing my overview and roadmap. I'm now debugging it. I think I will be able to
post them as RFC in a week.

At least, ZONE_MOVABLE(or something partitioning memory) is necessary for
memory-hot-unplug like DIMM-poweroff. (I'm now using my own ZONE_MOVABLE patch, but
It is O.K. to migrate to Mel's one if it's ready to be merged.)


> Our basic unit of memory management is the zone.  Right now, a zone maps
> onto some hardware-imposed thing.  But the zone-based MM works *well*.  I
> suspect that a good way to solve both per-container RSS and mem hotunplug
> is to split the zone concept away from its hardware limitations: create a
> "software zone" and a "hardware zone".  All the existing page allocator and
> reclaim code remains basically unchanged, and it operates on "software
> zones".  Each software zones always lies within a single hardware zone. 
> The software zones are resizeable.  For per-container RSS we give each
> container one (or perhaps multiple) resizeable software zones.
> 
> For memory hotunplug, some of the hardware zone's software zones are marked
> reclaimable and some are not; DIMMs which are wholly within reclaimable
> zones can be depopulated and powered off or removed.
> 
Hmm...software-zone seems attractive.
I remember someone posted pesuedo-zone(pzone) patch in past.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
