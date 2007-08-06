Date: Mon, 6 Aug 2007 22:48:12 +0100
Subject: Re: [PATCH] Apply memory policies to top two highest zones when highest zone is ZONE_MOVABLE
Message-ID: <20070806214812.GB6142@skynet.ie>
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de> <20070806121558.e1977ba5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070806121558.e1977ba5.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Lee.Schermerhorn@hp.com, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (06/08/07 12:15), Andrew Morton didst pronounce:
> On Sat, 4 Aug 2007 00:02:17 +0200 Andi Kleen <ak@suse.de> wrote:
> 
> > On Thursday 02 August 2007 19:21:18 Mel Gorman wrote:
> > > The NUMA layer only supports NUMA policies for the highest zone. When
> > > ZONE_MOVABLE is configured with kernelcore=, the the highest zone becomes
> > > ZONE_MOVABLE. The result is that policies are only applied to allocations
> > > like anonymous pages and page cache allocated from ZONE_MOVABLE when the
> > > zone is used.
> > > 
> > > This patch applies policies to the two highest zones when the highest zone
> > > is ZONE_MOVABLE. As ZONE_MOVABLE consists of pages from the highest "real"
> > > zone, it's always functionally equivalent.
> > > 
> > > The patch has been tested on a variety of machines both NUMA and non-NUMA
> > > covering x86, x86_64 and ppc64. No abnormal results were seen in kernbench,
> > > tbench, dbench or hackbench. It passes regression tests from the numactl
> > > package with and without kernelcore= once numactl tests are patched to
> > > wait for vmstat counters to update.
> >  
> > I must honestly say I really hate the patch. It's a horrible hack and makes fast paths
> > slower. When I designed mempolicies I especially tried to avoid things
> > like that, please don't add them through the backdoor now.
> > 
> 
> We don't want to be adding horrible hacks and slowness to the core of
> __alloc_pages().
> 
> So where do we stand on this?  We made a mess of NUMA policies, and merging
> "grouping pages by mobility" would fix that mess, only we're not sure that
> we want to merge those and it's too late for 2.6.23 anwyay?
> 

Grouping pages by mobility would still apply polciies only to
ZONE_MOVABLE when it is configured. What grouping pages by mobility
would relieve is much of the motivation to configure ZONE_MOVABLE at all
for hugepages. The zone has such attributes as being useful to
hot-remove as well as guaranteeing how much memory can be allocated as
hugepages at runtime that is not necessarily provided by grouping pages
by mobility.

> If correct, I would suggest merging the horrible hack for .23 then taking
> it out when we merge "grouping pages by mobility".  But what if we don't do
> that merge?

That hack aspect of the fix is that it alters the hot-path in the
allocator. However, there is a logical way forward.

There are patches in the works that change zonelists from having multiple
zonelists to only having only one zonelist per node that is filtered based
on the allocation flags. The place this filtering happens is the same as what
the "hack" is currently doing. The cost of filtering should be offset by the
reduced size of the node structure and tests with kernbench, hackbench and
tbench seem to confirm that. This will bring the hack into being line with
what we wanted with policies in the first place because things like MPOL_BIND
will try nodes in node-local order instead of node-numeric order as it does
currently.

>From there, we can eliminate policy_zone altogether by applying policies
to all zones but forcing a situation where MPOL_BIND will always contain
one node that GFP_KERNEL allocations can be satisified from. For example,
if I have a NUMAQ that only has ZONE_NORMAL on node 0 and a user tries to
bind to nodes 2+3, they will really bind to nodes 0,2,3 so that GFP_KERNEL
allocations on that process will not return NULL. Alternatively, we could
have mbind return a failure if it doesn't include a node that can satisfy
GFP_KERNEL allocations. Either of these options seem more sensible than
sometimes applying policies and other times not applying them.

The worst aspect is that filtering require many lookups of zone_idx().
However, we may be able to optimise this by keeping the zone index in the
pointer within the zonelist as suggested by Christoph Lameter. However,
I haven't tried implementing it yet to see what it looks like in practice.

I'm for merging the hack for 2.6.23 and having one-zonelist-per-node
ready for 2.6.24. If there is much fear that the hack will persist for too
long, I'm ok with applying policies only to ZONE_MOVABLE when kernelcore=
is specified on the command line as one-zonelist-per-node can fix the same
problem. Ultimately if we agree on patches to eliminate policy_zone altogether,
the problem becomes moot as it no longer exists.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
