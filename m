Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706121143530.30754@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
	 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
	 <20070611221036.GA14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
	 <1181657940.5592.19.camel@localhost>
	 <Pine.LNX.4.64.0706121143530.30754@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 12 Jun 2007 15:17:19 -0400
Message-Id: <1181675840.5592.123.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-12 at 11:45 -0700, Christoph Lameter wrote:
> On Tue, 12 Jun 2007, Lee Schermerhorn wrote:
> 
> > > Could be much simpler:
> > > 
> > > if (pgdat->node_present_pages)
> > > 	node_set_populated(local_node);
> > 
> > As a minimum, we need to exclude a node with only zone DMA memory for
> > this to work on our platforms.  For that, I think the current code is
> > the simplest because we still need to check if the first zone is
> > "on-node" and !DMA.
> 
> You are changing the definition of populated node.

Well, I initially created the populated node map to mean nodes that
contained memory at "policy zone"--specifically for use by the huge page
allocator.  I did this because you and others didn't want the hugetlb
code to know about the innards of zonelists, etc.  Made sense, so I came
up with a definition that worked for the platforms I tried it on.
However, as we've discussed here, it would prevent allocation of
hugepages on a DMA32-only x86_64 node if any other node had higher order
memory.  

Now, Nish is proposing to use the populated map to filter policy-based
interleaved allocations.  My definition of populated map won't work for
that.  So, YOU are the one changing the definition.  I'm OK with that if
it solves a more generic problem.  My patch hadn't gone in anyway.


> > And, I think we need both cases--set and reset populated map bit--to
> > handle memory/node hotplug.  So something like:
> 
> Yes memory unplug will need to clear the bit if a complete node is
> cleared. But we do not support node unplug yet. So it is okay for now and 
> it is doubtful that the build_zonelist function is going to be called for 
> the node that is being removed.
> 
> > Need to define 'is_zone-dma()' to test the zone or unconditionally
> > return false depending on whether ZONE_DMA is configured.
> 
> CONFIG_ZONE_DMA already exists.

Yes, but I didn't want to stick #ifdefs in the functions if I didn't
have to.  But, it's a moot point.  After looking at it more, I've
decided there may be no definition of populated map that works reliably
for huge page allocation on all of the platform configurations.
However, if GFP_THISNODE guarantees no off-node allocations, that may do
the trick.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
