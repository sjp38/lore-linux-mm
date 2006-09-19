Date: Tue, 19 Sep 2006 14:12:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <Pine.LNX.4.64.0609191224560.6976@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.63.0609191401360.8253@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060916044847.99802d21.pj@sgi.com>
 <20060916083825.ba88eee8.akpm@osdl.org> <20060916145117.9b44786d.pj@sgi.com>
 <20060916161031.4b7c2470.akpm@osdl.org> <Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
 <Pine.LNX.4.63.0609191212390.7746@chino.corp.google.com>
 <Pine.LNX.4.64.0609191224560.6976@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Sep 2006, Christoph Lameter wrote:

> What is workable would be to dynamically create new nodes.
> 
> The system would consist of node 0 .... MAX_PHYSNODES -1  which would 
> be physical nodes.
> 
> Additional nodes beyond X MAX_PHYSNODES - 1 ... MAX_NUMNODES -1 would be 
> contrainers.
> 

I had something similiar working when I abstracted some of the x86_64 
numa=fake capabilities to work on real NUMA machines.

> A container could be created through a node hotplug API. When a node is 
> created one specifies how much memory from which nodes should be assigned 
> to that container / node.
> 

If the memory from existing nodes are used to create the new node, then 
any tasks assigned to that parent node through cpusets will be degraded.  
Not a problem since the user would be aware of this affect on node 
creation, but you'd need callback_mutex and task_lock for each task 
within the parent node and possibly rcu_read_lock for the mems_generation.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
