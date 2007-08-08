Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple
	zonelists v2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070808214420.GD2441@skynet.ie>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
	 <Pine.LNX.4.64.0708081025330.12652@schroedinger.engr.sgi.com>
	 <1186597819.5055.37.camel@localhost>  <20070808214420.GD2441@skynet.ie>
Content-Type: text/plain
Date: Wed, 08 Aug 2007 18:40:07 -0400
Message-Id: <1186612807.5055.106.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-08 at 22:44 +0100, Mel Gorman wrote:
> On (08/08/07 14:30), Lee Schermerhorn didst pronounce:
> > On Wed, 2007-08-08 at 10:36 -0700, Christoph Lameter wrote:
> > > On Wed, 8 Aug 2007, Mel Gorman wrote:
> > > 
<snip>
> > > > o Remove bind_zonelist() (Patch in progress, very messy right now)
> > > 
> > > Will this also allow us to avoid always hitting the first node of an 
> > > MPOL_BIND first?
> > 
> > An idea:
> > 
> > Apologies if someone already suggested this and I missed it.  Too much
> > traffic...
> > 
> > instead of passing a zonelist for BIND policy, how about passing [to
> > __alloc_pages(), I think] a starting node, a nodemask, and gfp flags for
> > zone and modifiers. 
> 
> Yes, this has come up before although it wasn't my initial suggestion. I
> thought maybe it was yours but I'm not sure anymore. I'm working through
> it at the moment. 

I've heard/seen Christoph mention passing a nodemask to alloc_pages a
few times, but hadn't seen any of the details.  Got me thinking..

> With the patch currently, a a nodemask is passed in for
> filtering which should be enough as the zonelist being used should be enough
> information to indicate the starting node.

It'll take me a while to absorb the patch, so I'll just ask:  Where does
the zonelist for the argument come from?  If the the bind policy
zonelist is removed, then does it come from a node?  There'll be only
one per node with your other patches, right?  So you had to have a node
id, to look up the zonelist?  Do you need the zonelist elsewhere,
outside of alloc_pages()?  If not, why not just let alloc_pages look it
up from a starting node [which I think can be determined from the
policy]?  

OK, that's a lot of questions.  no need to answer.  That's just what I'm
thinking re: all this.  I'll wait and see how the patch develops.
  
> 
> The signature of __alloc_pages() becomes
> 
> static page * fastcall
> __alloc_pages_nodemask(gfp_t gfp_mask, nodemask_t *nodemask,
>                unsigned int order, struct zonelist *zonelist)
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
> 
> The last one is the most interesting. Much of the patch in development
> involves deleting the custom node stuff. I've included the patch below if
> you're curious. I wanted to get one-zonelist out first to see if we could
> agree on that before going further with it.

Again, it'll be a while. 

Thanks,
Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
