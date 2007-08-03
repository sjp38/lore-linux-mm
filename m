Date: Fri, 3 Aug 2007 16:53:22 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from MPOL_INTERLEAVE masks
Message-ID: <20070803075322.GA18267@linux-sh.org>
References: <1185566878.5069.123.camel@localhost> <20070728151912.c541aec0.kamezawa.hiroyu@jp.fujitsu.com> <1185812028.5492.79.camel@localhost> <20070801101651.GA9113@linux-sh.org> <1185975558.5059.18.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1185975558.5059.18.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, ak@suse.de, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 01, 2007 at 09:39:18AM -0400, Lee Schermerhorn wrote:
> On Wed, 2007-08-01 at 19:16 +0900, Paul Mundt wrote:
> > If we can differentiate between MPOL_INTERLEAVE from the kernel's point
> > of view, and explicit MPOL_INTERLEAVE specifiers via mbind() from
> > userspace, that works fine for my case. However, the mpol_new() changes
> > in this patch deny small nodes the ability to ever be included in an
> > MPOL_INTERLEAVE policy, when it's only the kernel policy that I have a
> > problem with.
> 
> Ah, but it would only "deny small nodes" if you nominate them in the
> boot option.  I haven't changed your heuristic in numa_policy_init.  So,
> it will still eliminate small nodes from the boot time interleave
> nodemask, independent of whether or not you specify them in the
> no_interleave_nodes list.
> 
> Or am I missing your point?

That's correct, as long as the size heuristic remains in
numa_policy_init() there's no problem with this. The point was more that
if we were able to use N_INTERLEAVE nodes for the system init policy, it
would be possible to do away with the size heuristic entirely.

Effectively we want the same things, but whereas you want the interleave
nodes to be something applied to all policies, I'm mostly concerned with
keeping the kernel away from the nodes we don't want to interleave.
Userland is basically a free-for-all in terms of the allowable nodemask,
so I don't have a need to restrict MPOL_INTERLEAVE policies once the
system is up.

The size heuristic itself is a bit of a kludge anyhow. I'd like to have a
single point where I can tell the kernel "these nodes are special, don't
use them unless you've been asked". And that's certainly something I
don't have an issue flagging in the pgdat when constructing the nodes in
the first place (at which point we already know which ones are special,
without having to bother with command line options). Whether this is
something that's best as a special node state or not is something that
will need some toying with. On the other hand, simply being able to take the
system init node list and keep that "pinned" is another option, so we
don't end up allocating there even if node 0 is under pressure.

Page migration also poses an interesting problem, in that we don't have a
problem in migrating pages between and off of these nodes, but we do not
want to migrate pages that started out in system memory to them, as the
node will run out of pages too quickly (and also gives those pages up to
whatever is migrated first, rather than something that actually _wants_
those pages out of performance considerations). I don't see an easy way
to do this without having a page flag that indicates whether migration to
special nodes is permitted or not, and setting that when the page is
allocated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
