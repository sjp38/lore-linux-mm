Date: Sun, 19 Aug 2007 03:18:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cpusets vs. mempolicy and how to get interleaving
In-Reply-To: <46C63D5D.3020107@google.com>
Message-ID: <alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
References: <46C63BDE.20602@google.com> <46C63D5D.3020107@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Aug 2007, Ethan Solomita wrote:

>     Ideally, we want a task to express its preference for interleaved memory
> allocations without having to provide a list of nodes. The kernel will
> automatically round-robin amongst the task's mems_allowed.
> 

Just pass the result of

	grep Mems_allowed /proc/pid/status | awk '{ print $2 }' | sed s/,//

to set_mempolicy() with MPOL_INTERLEAVE.

>     At least in our environment, an independent "cpuset manager" process may
> choose to rewrite a cpuset's mems file at any time, possibly increasing or
> decreasing the number of available nodes. If weight(mems_allowed) is
> decreased, the task's MPOL_INTERLEAVE policy's nodemask will be shrunk to fit
> the new mems_allowed. If weight(mems_allowed) is grown, the policy's nodemask
> will not gain new nodes.
> 

This is not unlike the traditional use of cpusets; a cpuset's mems_allowed 
may be freely changed at any time.

If the weight of a task's mems_allowed decreases, you would want a simple 
remap from the old nodemask to the new nodemask.  node_remap() provides 
this functionality already.

>     What we want is for the task to "set it and forget it," i.e. to express a
> preference for interleaving and then never worry about NUMA again. If the
> nodemask sent via sys_mempolicy(MPOL_INTERLEAVE) served as a mask against
> mems_allowed, then we would specify an all-1s nodemask.
> 

It already does exactly what you want.

cpuset_update_task_memory_state() is invoked anytime an allocation with 
__GFP_WAIT is requested via alloc_pages_current() in process context in 
addition to alloc_page_vma() for any userspace mapped pages.

If a task's mems_allowed has changed in its cpuset behind the task's back, 
mpol_rebind_policy() is called for that task's mempolicy with a pointer to 
the cpuset's mems_allowed.  This will be considered the new mems_allowed 
for the task and is stored in its task_struct.

mpol_rebind_policy() will rebind MPOL_INTERLEAVE policies by remapping the 
old mems_allowed nodemask with the new nodemask from the cpuset and, at 
the same time, update task->il_next to specify the next node to allocate 
from as reflected by the new nodemask.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
