Date: Thu, 9 Aug 2007 15:47:26 +0100
Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple zonelists v2
Message-ID: <20070809144726.GA22405@skynet.ie>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0708081025330.12652@schroedinger.engr.sgi.com> <1186597819.5055.37.camel@localhost> <20070808214420.GD2441@skynet.ie> <1186612807.5055.106.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1186612807.5055.106.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/08/07 18:40), Lee Schermerhorn didst pronounce:
> On Wed, 2007-08-08 at 22:44 +0100, Mel Gorman wrote:
>
> <SNIP>
>
> > With the patch currently, a a nodemask is passed in for
> > filtering which should be enough as the zonelist being used should be enough
> > information to indicate the starting node.
> 
> It'll take me a while to absorb the patch, so I'll just ask:  Where does
> the zonelist for the argument come from? If the the bind policy
> zonelist is removed, then does it come from a node? 

Yes, it gets the zonelist from the node and uses a nodemask to ignore
zones within it.

> There'll be only
> one per node with your other patches, right?  So you had to have a node
> id, to look up the zonelist? 

You have the local node_id to lookup the zonelist with. The policy
provides a nodemask then instead of a zonelist for filtering purposes.

> Do you need the zonelist elsewhere,
> outside of alloc_pages()?  If not, why not just let alloc_pages look it
> up from a starting node [which I think can be determined from the
> policy]?
> 

The starting node can be determined from where we are currently running
on. Even if the local node is not in the nodemask, we'd still filter it
as normal.

> OK, that's a lot of questions.  no need to answer.  That's just what I'm
> thinking re: all this.  I'll wait and see how the patch develops.
>   
> > 
> > The signature of __alloc_pages() becomes
> > 
> > static page * fastcall
> > __alloc_pages_nodemask(gfp_t gfp_mask, nodemask_t *nodemask,
> >                unsigned int order, struct zonelist *zonelist)
> > 
> > >  For various policies, the arguments would look like this:
> > > Policy		start node	nodemask
> > > 
> > > default		local node	cpuset_current_mems_allowed
> > > 
> > > preferred	preferred_node	cpuset_current_mems_allowed
> > > 
> > > interleave	computed node	cpuset_current_mems_allowed
> > > 
> > > bind		local node	policy nodemask [replaces bind
> > > 				zonelist in mempolicy]
> > > 
> > 
> > The last one is the most interesting. Much of the patch in development
> > involves deleting the custom node stuff. I've included the patch below if
> > you're curious. I wanted to get one-zonelist out first to see if we could
> > agree on that before going further with it.
> 
> Again, it'll be a while. 
> 

Thanks anyway.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
