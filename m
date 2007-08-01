Date: Wed, 1 Aug 2007 20:21:16 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from MPOL_INTERLEAVE masks
Message-ID: <20070801112116.GA9617@linux-sh.org>
References: <1185566878.5069.123.camel@localhost> <200708011233.02103.ak@suse.de> <20070801110120.GA9449@linux-sh.org> <200708011307.44189.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200708011307.44189.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 01, 2007 at 01:07:43PM +0200, Andi Kleen wrote:
> 
> > As long as interleaving is possible after boot, then yes. It's only the
> > boot-time interleave that we would like to avoid,
> 
> But when anybody does interleaving later it could just as easily
> fill up your small nodes, couldn't it?
> 
Yes, but these are in embedded environments where we have control over
what the applications are doing. Most of these sorts of things are for
applications where we know what sort of latency requires we have to deal
with, and so the workload is very much tied to the worst-case range of
nodes, or just to a particular node. We might only have certain buffers
that need to be backed by faster memory as well, so while most of the
application pages will come from node 0 (system memory), certain other
allocations will come from other nodes. We've been experimenting with
doing that through tmpfs with mpol tuning.

In the general case however it's fairly safe to include the tiny nodes as
part of a larger set with a prefer policy so we don't immediately OOM.

> Boot time allocations are small compared to what user space
> later can allocate.
> 
Yes, we only want certain applications to explicitly poke at those nodes,
but they do have a use case for interleave, so it is not functionality I
would want to lose completely.

> And do you really want them in the normal fallback lists? The normal zone
> reservation heuristics probably won't work unless you put them into
> special low zones.
> 
That's something else to look at also, though I would very much like to
avoid having to construct custom zonelists. it would be nice to keep things as
simple and as non-invasive as possible. As far as the existing NUMA code
goes, we're not quite all the way there yet in terms of supporting these
things as well as we can, but it has proven to be a pretty good starting
point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
