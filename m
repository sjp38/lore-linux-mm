Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6NJ9NT6017796
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 15:09:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6NJ9NnA341356
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 15:09:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6NJ9MNJ017068
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 15:09:23 -0400
Date: Mon, 23 Jul 2007 12:09:22 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] Memoryless nodes:  use "node_memory_map" for cpuset mems_allowed validation
Message-ID: <20070723190922.GA6036@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070711182250.005856256@sgi.com> <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com> <1184964564.9651.66.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1184964564.9651.66.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 20.07.2007 [16:49:24 -0400], Lee Schermerhorn wrote:
> This fixes a problem I encountered testing Christoph's memoryless nodes
> series.  Applies atop that series.  Other than this, series holds up
> under what testing I've been able to do this week.
> 
> Memoryless Nodes:  use "node_memory_map" for cpusets mems_allowed validation
> 
> cpusets try to ensure that any node added to a cpuset's 
> mems_allowed is on-line and contains memory.  The assumption
> was that online nodes contained memory.  Thus, it is possible
> to add memoryless nodes to a cpuset and then add tasks to this
> cpuset.  This results in continuous series of oom-kill and other
> console stack traces and apparent system hang.
> 
> Change cpusets to use node_states[N_MEMORY] [a.k.a.
> node_memory_map] in place of node_online_map when vetting 
> memories.  Return error if admin attempts to write a non-empty
> mems_allowed node mask containing only memoryless-nodes.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Lee, while looking at this change, I think it ends up fixing
cpuset_mems_allowed() to return nodemasks that only include nodes in
node_states[N_MEMORY]. However, cpuset_current_mems_allowed is a
lockless macro which would still be broken. I think it would need to
becom a static inline nodes_and() in the CPUSET case and a #define
node_states[N_MEMORY] in the non-CPUSET case?

Or perhaps we should adjust cpusets to make it so that the mems_allowed
member only includes nodes that are set in node_states[N_MEMORY]?

What do you think? Paul?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
