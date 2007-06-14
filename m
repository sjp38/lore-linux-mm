Date: Thu, 14 Jun 2007 07:24:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
In-Reply-To: <1181830705.5410.13.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706140721510.28544@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com>  <20070612205738.548677035@sgi.com>
 <1181769033.6148.116.camel@localhost>  <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com>
 <1181830705.5410.13.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, Lee Schermerhorn wrote:

> > That check is already done by __alloc_pages.
> 
> You mean in get_page_from_freelist()?  No, it only checks that the zone
> under consideration is on the same node as the zone at the start of the
> list.  This can be off-node if the node is populated only at lower
> zones; and the zonelists are in zone-order.

See the later discussion. I did not see the use the nodes pgdat here that 
you only have in alloc_pages_node().

> > Ummm... Slub would need to consult node_memory_map instead I guess.
> 
> Probably should check the node_memory_map to avoid attempting
> allocations from completely memoryless nodes.  However, it should still
> be able to handle nulls from alloc_pages_nodes() because of the
> scenarios discussed above.

It is able to handle NULLs during usual operations but not during bootstrap.

> Again, node_memory_map can't detect the "first zone in zonelist
> off-node" situation.  That's the one that alloc_pages_node() must guard
> against.   So, it can/should/must return NULL when attempting to
> allocate from a higher zone that is off-node.

I think GFP_THISNODE should not fail in that case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
