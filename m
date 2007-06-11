Date: Mon, 11 Jun 2007 09:42:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some
 are unpopulated
In-Reply-To: <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
 <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
 <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org>
 <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Lee.Schermerhorn@hp.com, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Christoph Lameter wrote:

> Well maybe we better fix this? I put an effort into using only cachelines 
> already used for GFP_THISNODE since this is in a very performance 
> critical path but at that point I was not thinking that we 
> would have memoryless nodes.

Duh. Too bad. The node information is not available in __alloc_pages at 
all. The only thing we have to go on is a zonelist. And the first element 
of that zonelist must no longer be the node from which we picked up 
the zonelist after memoryless nodes come into play.

We could check this for alloc_pages_node() and alloc_pages_current by 
putting in some code into the place where we retrive the zonelist based on 
the current policy.

And looking at that code I can see some more bad consequences of 
memoryless nodes:

1. Interleave to the memoryless node will be redirected to the nearest
   node to the memoryless node. This will typically result in the nearest
   node getting double the allocations if interleave is set.

   So interleave is basically broken. It will no longer spread out the
   allocations properly.

2. MPOL_BIND may allow allocations outside of the nodes specified.
   It assumes that the first item of the zonelist of each node
   is that zone.


So we have a universal assumption in the VM that the first zone of a
zonelist contains the local node. The current way of generating
zonelists for memoryless zones is broken (unsurprisingly since the NUMA 
handling was never designed to handle memoryless nodes).

I think we can to fix all these troubles by adding a empty zone as
a first zone in the zonelist if the node has no memory of its own.
Then we need to make sure that we do the right thing of falling back 
anytime these empty zones will be encountered.

This will have the effect of

1. GFP_THISNODE will fail since there is no memory in the empty zone.

2. MPOL_BIND will not allocate on nodes outside of the specified set
   since there will be an empty zone in the generated zonelist.

3. Interleave will still hit an empty zones and fall back to the next.
   We should add detection of memoryless nodes to mempoliy.c to skip
   those nodes.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
