Date: Mon, 6 Aug 2007 15:31:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when
 highest zone is ZONE_MOVABLE
In-Reply-To: <20070806214812.GB6142@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708061519420.4263@schroedinger.engr.sgi.com>
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de>
 <20070806121558.e1977ba5.akpm@linux-foundation.org> <20070806214812.GB6142@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Mel Gorman wrote:

> > So where do we stand on this?  We made a mess of NUMA policies, and merging
> > "grouping pages by mobility" would fix that mess, only we're not sure that
> > we want to merge those and it's too late for 2.6.23 anwyay?
> > 
> 
> Grouping pages by mobility would still apply polciies only to
> ZONE_MOVABLE when it is configured. What grouping pages by mobility
> would relieve is much of the motivation to configure ZONE_MOVABLE at all
> for hugepages. The zone has such attributes as being useful to

Ultimately ZONE_MOVABLE can be removed. AFAIK ZONE_MOVABLE is a temporary 
stepping stone to address concerns of about defrag reliability. Somehow 
the stepping stone got into .23 without the real thing.

An additional issue with the current ZONE_MOVABLE in .23 is that the 
tentative association of ZONE_MOVABLE with HIGHMEM also makes use of large 
pages by SLUB not possible.

> There are patches in the works that change zonelists from having multiple
> zonelists to only having only one zonelist per node that is filtered based
> on the allocation flags. The place this filtering happens is the same as what
> the "hack" is currently doing. The cost of filtering should be offset by the
> reduced size of the node structure and tests with kernbench, hackbench and
> tbench seem to confirm that. This will bring the hack into being line with
> what we wanted with policies in the first place because things like MPOL_BIND
> will try nodes in node-local order instead of node-numeric order as it does
> currently.

I'd like to see that patch.
 
> >From there, we can eliminate policy_zone altogether by applying policies
> to all zones but forcing a situation where MPOL_BIND will always contain
> one node that GFP_KERNEL allocations can be satisified from. For example,
> if I have a NUMAQ that only has ZONE_NORMAL on node 0 and a user tries to
> bind to nodes 2+3, they will really bind to nodes 0,2,3 so that GFP_KERNEL
> allocations on that process will not return NULL. Alternatively, we could
> have mbind return a failure if it doesn't include a node that can satisfy
> GFP_KERNEL allocations. Either of these options seem more sensible than
> sometimes applying policies and other times not applying them.

We would still need to check on which nodes which zones area available. 
Zones that are not available on all zones would need to be exempt from 
policies. Maybe one could define an upper boundary of zones that are 
policed? On NUMAQ zones up to ZONE_NORMAL would be under policy. On x86_64 
this may only include ZONE_DMA. A similar thing would occur on ia64 with 
the 4G DMA zone. Maybe policy_zone could become configurable?
 
> I'm for merging the hack for 2.6.23 and having one-zonelist-per-node
> ready for 2.6.24. If there is much fear that the hack will persist for too

Why not for .23? It does not seem to be too much code?

> long, I'm ok with applying policies only to ZONE_MOVABLE when kernelcore=
> is specified on the command line as one-zonelist-per-node can fix the same
> problem. Ultimately if we agree on patches to eliminate policy_zone altogether,
> the problem becomes moot as it no longer exists.

We cannot have a kernel release with broken mempolicy. We either need the 
patch here or the one-zonelist patch for .23.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
