Date: Tue, 19 Sep 2006 12:31:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <Pine.LNX.4.63.0609191212390.7746@chino.corp.google.com>
Message-ID: <Pine.LNX.4.64.0609191224560.6976@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060916044847.99802d21.pj@sgi.com>
 <20060916083825.ba88eee8.akpm@osdl.org> <20060916145117.9b44786d.pj@sgi.com>
 <20060916161031.4b7c2470.akpm@osdl.org> <Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
 <Pine.LNX.4.63.0609191212390.7746@chino.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@osdl.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I guess this is the expected result. the __cpuset_zone_allowed bottleneck 
is gone.

What is workable would be to dynamically create new nodes.

The system would consist of node 0 .... MAX_PHYSNODES -1  which would 
be physical nodes.

Additional nodes beyond X MAX_PHYSNODES - 1 ... MAX_NUMNODES -1 would be 
contrainers.

A container could be created through a node hotplug API. When a node is 
created one specifies how much memory from which nodes should be assigned 
to that container / node.

Then the system will take elements off the freelists of the source nodes 
and use these as building blocks for the new nodes. All the page 
flags must be updated with the new container node number or the 
section_to_node table must be updated.

Then we should have a fully functioning node with proper statistics for 
operations. Swap / zone reclaim should work as usual on NUMA systems. The 
slab will generate its node specific structures for the new node. One 
can then cage applications using cpusets in that node.

If the container node is brought down then all pages in the node must be 
freed and will coalesce back into large higher order pages that were taken 
off the source nodes freelists. The page->flags need to be updated to 
point to the source node and then the higher order pages can be freed
back to the origin node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
