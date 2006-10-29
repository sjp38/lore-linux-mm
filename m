Date: Sat, 28 Oct 2006 17:59:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Avoid allocating interleave from almost full nodes
In-Reply-To: <200610272112.12118.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0610281741140.14058@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271943540.10933@schroedinger.engr.sgi.com>
 <200610272112.12118.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2006, Andi Kleen wrote:

> > Should we find that all nodes are marked as full then we disregard
> > the limit and allocate from the next node without any checks.
> 
> And when only one node is not full the interleaved allocations will
> all go to that node? I'm not sure that's a good idea.

It will go to that node until its filled up like the rest of the nodes. 
The intend of interleave is after all to even out allocations amoung all 
nodes and this follows that spirit.

> In general I think it's a bad hack: Who says the allocations
> of the process who filled a node is more important than the interleaving
> process? I think it would be better to keep them being equal citizens
> and allocate interleaving everywhere.

What currently happens is that we overallocate a node and we then fall 
back to a neighboring node. So we are already clustering the allocations
on particular nodes right now. But we are very rude right now and allocate 
from a node until its completely filled up. Processes running on the node
then either have to go off node for allocations or start reclaiming 
memory.

The patch avoids that situation as long as feasable by spreading to less 
filled nodes once we have reached the threshold.

The allocations of a process which does local allocations are more 
important since these are local allocations. This is data for exclusive 
use by that process. Interleave allocations are made for data that is 
shared between processes running on multiple nodes. For those allocations 
locality does matter less.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
