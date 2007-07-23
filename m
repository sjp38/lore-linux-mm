Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6NLmH02032516
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:48:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6NLmHTM517226
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:48:17 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6NLmHrp028981
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:48:17 -0400
Date: Mon, 23 Jul 2007 14:48:16 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] Memoryless nodes:  use "node_memory_map" for cpuset mems_allowed validation
Message-ID: <20070723214816.GC6036@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070711182250.005856256@sgi.com> <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com> <1184964564.9651.66.camel@localhost> <20070723190922.GA6036@us.ibm.com> <1185224393.23917.6.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1185224393.23917.6.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 23.07.2007 [16:59:52 -0400], Lee Schermerhorn wrote:
> On Mon, 2007-07-23 at 12:09 -0700, Nishanth Aravamudan wrote: 
> > On 20.07.2007 [16:49:24 -0400], Lee Schermerhorn wrote:
> > > This fixes a problem I encountered testing Christoph's memoryless nodes
> > > series.  Applies atop that series.  Other than this, series holds up
> > > under what testing I've been able to do this week.
> > > 
> > > Memoryless Nodes:  use "node_memory_map" for cpusets mems_allowed validation
> > > 
> > > cpusets try to ensure that any node added to a cpuset's 
> > > mems_allowed is on-line and contains memory.  The assumption
> > > was that online nodes contained memory.  Thus, it is possible
> > > to add memoryless nodes to a cpuset and then add tasks to this
> > > cpuset.  This results in continuous series of oom-kill and other
> > > console stack traces and apparent system hang.
> > > 
> > > Change cpusets to use node_states[N_MEMORY] [a.k.a.
> > > node_memory_map] in place of node_online_map when vetting 
> > > memories.  Return error if admin attempts to write a non-empty
> > > mems_allowed node mask containing only memoryless-nodes.
> > > 
> > > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> > Lee, while looking at this change, I think it ends up fixing
> > cpuset_mems_allowed() to return nodemasks that only include nodes in
> > node_states[N_MEMORY]. However, cpuset_current_mems_allowed is a
> > lockless macro which would still be broken. I think it would need to
> > becom a static inline nodes_and() in the CPUSET case and a #define
> > node_states[N_MEMORY] in the non-CPUSET case?
> > 
> > Or perhaps we should adjust cpusets to make it so that the mems_allowed
> > member only includes nodes that are set in node_states[N_MEMORY]?
> 
> 
> I thought that's what my patch to nodelist_parse() did.  It ensures that
> current->mems_allowed is correct [contains at least one node with
> memory, and only nodes with memory] at the time it is installed, but
> doesn't consider memory hot plug and node off-lining.  Is this
> [offline/hotplug] your point?

And everytime it is updated, right? (current->mems_allowed). My concern
is purely whether I can then directly use cpuset_current_mems_allowed in
the interleave code for hugetlb.c and it will do the right thing. It
will work, if the #define is changed for !CPUSETS and if your change
guarantess current->mems_allowed is always consistent with
node_states[N_MEMORY].

I think I simply was confused about the full impact of your changes, as
I don't know cpusets that well. I'm going to try and test a memoryless
node box I have at work w/ your change, though, and see what happens.

> Seems like that is an issue that exists in the unpatched code as
> well--i.e., unlike cpuset_mems_allowed(), the lockless, "_current_"
> version does not vet current->mems_allowed against the
> nodes_online_mask.  So, all valid nodes in current->mems_allowed could
> have been off-lined since the mask was installed.  Am I reading this
> right?

True -- I honestly don't know. I doubt much of this code has been fully
audited for full node unplug?

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
