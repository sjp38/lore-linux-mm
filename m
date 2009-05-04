Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 919A36B00A5
	for <linux-mm@kvack.org>; Mon,  4 May 2009 11:19:15 -0400 (EDT)
Subject: Re: [PATCH] Limit initial tasks' and top level cpuset's
	mems_allowed to nodes with memory
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Reply-To: lts@ldl.fc.hp.com
In-Reply-To: <49FEBD27.1030606@cn.fujitsu.com>
References: <1241406364.9211.18.camel@lts-notebook>
	 <49FEBD27.1030606@cn.fujitsu.com>
Content-Type: text/plain
Date: Mon, 04 May 2009 11:17:41 -0400
Message-Id: <1241450261.7166.51.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: lts@ldl.fc.hp.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-numa <linux-numa@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Doug Chapman <doug.chapman@hp.com>, Eric Whitney <eric.whitney@hp.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-05-04 at 18:02 +0800, Miao Xie wrote: 
> on 2009-5-4 11:06 Lee Schermerhorn wrote:
> > Against:  2.6.20-rc3-mmotm-090428-1631
> > 
> > Since cpusetmm-update-tasks-mems_allowed-in-time.patch removed the call outs
> > to cpuset_update_task_memory_state(), tasks in the top cpuset don't get their
> > mems_allowed updated to just nodes with memory.  cpuset_init()initializes
> > the top cpuset's mems_allowed with nodes_setall() and 
> > cpuset_init_current_mems_allowed() and kernel_init() initialize the kernel
> > initialization tasks' mems_allowed to all possible nodes.  Tasks in the top
> > cpuset that inherit the init task's mems_allowed without modification will
> > have all possible nodes set.  This can be seen by examining the Mems_allowed
> > field in /proc/<pid>/status in such a task.
> > 
> > "numactl --interleave=all" also initializes the interleave node mask to all
> > ones, depending on the masking with mems_allowed to eliminate non-existent
> > nodes and nodes without memory.  As this was not happening, the interleave
> > policy was attempting to dereference non-existent nodes.
> > 
> > This patch modifies the nodes_setall() calls in two cpuset init functions and
> > the initialization of task #1's mems_allowed to use node_states[N_HIGH_MEMORY]. 
> > This mask has been initialized to contain only existing nodes with memory by
> > the time the respective init functions are called.
> 
> You forget to modify the cpuset_attach(). This function will initialize the
> mems_allowed of the task which is being moved into the top cpuset by node_possible_map.

Thanks, I'll look at that.  I had tested moving tasks between cpusets
and thought that it was working, but I'd been looking at this for a
while and could have been imagining it.  I'll look for all uses of
node_possible_map, etc.

> 
> Beside that, if you use node_states[N_HIGH_MEMORY] to initialize the mems_allowed
> of the tasks in the top cpuset, you must update it when adding a node with memory into
> the system. So you also must modify cpuset_track_online_nodes().

So, we'll need to walk the tasks in the top-level cpuset and update
their mems_allowed on node on/off-line.  I'd have thought we already did
that, but must admit I didn't check.  I'll take a look at how
cpuset_track_online_nodes() interacts with mems_allowed, ...

Lee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
