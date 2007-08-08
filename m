Date: Wed, 8 Aug 2007 16:35:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple
 zonelists v2
In-Reply-To: <20070808214420.GD2441@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708081633190.17335@schroedinger.engr.sgi.com>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0708081025330.12652@schroedinger.engr.sgi.com>
 <1186597819.5055.37.camel@localhost> <20070808214420.GD2441@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Mel Gorman wrote:

> 
> >  For various policies, the arguments would look like this:
> > Policy		start node	nodemask
> > 
> > default		local node	cpuset_current_mems_allowed
> > 
> > preferred	preferred_node	cpuset_current_mems_allowed
> > 
> > interleave	computed node	cpuset_current_mems_allowed
> > 
> > bind		local node	policy nodemask [replaces bind
> > 				zonelist in mempolicy]
> > 

GFP_THISNODE could be realized by only setting the desired nodenumber in 
the nodemask.

> The last one is the most interesting. Much of the patch in development
> involves deleting the custom node stuff. I've included the patch below if
> you're curious. I wanted to get one-zonelist out first to see if we could
> agree on that before going further with it.

I think we do.

> > Then, just walk the zonelist for the starting node--already ordered by
> > distance--filtering by gfp_zone() and nodemask.  Done "right", this
> > should always return memory from the closest allowed node [based on the
> > nodemask argument] to the starting node.  And, it would eliminate the
> > custom zonelists for bind policy.  Can also eliminate cpuset checks in
> > the allocation loop because that constraint would already be applied to
> > the nodemask argument.
> > 
> 
> This is what I'm hoping. I haven't looked closely enough to be sure this will
> work but currently I see no reason why it couldn't and it might eliminate
> some of the NUMA-specific paths in the allocator.

Right. But lets first get the general case for the single nodelist 
accepted (with the zoneid optimizations?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
