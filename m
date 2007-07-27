Date: Fri, 27 Jul 2007 11:38:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <20070727174622.GD646@skynet.ie>
Message-ID: <Pine.LNX.4.64.0707271135020.16333@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
 <20070726132336.GA18825@skynet.ie> <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
 <20070726225920.GA10225@skynet.ie> <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
 <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
 <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
 <20070727174622.GD646@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007, Mel Gorman wrote:

> Initial tests imply yes but I haven't done broader tests yet. It saves 64
> bytes on the size of the node structure on a non-numa i386 machine so even
> that might be noticable in some cases.

I think you can minimize the impact further by encoding information you
are looking for in the zone pointer. We are scanning for zones and for
node numbers. The zones require up to 2 bits and the nodes up to 10 bits.
So if we page align the zones structure then we have enough bits to encode
the information we are looking for in the pointers. Thus saving us
dereferencing it to check.

This may even be a performance increase vs the current situation.

> > I think this should_filter() creates more overhead than which it saves.
> 
> It's why part of the patch adds a zone_idx field to struct zone instead
> of mucking around with pgdat->node_zones.

See above. Avoid cacheline fetch by using the low bits of the zone pointer 
for zone_idx.

> > Isnt there some way to fold these traversals into a common page allocator 
> > function?
> 
> Probably. When I looked first, each of the users were traversing the zonelist
> slightly differently so it wasn't obvious how to have a single iterator but
> it's a point for improvement.

I wrote most of those and I'd be glad if you could consolidate the code 
somehow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
