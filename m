Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8C8p89g006542
	for <linux-mm@kvack.org>; Tue, 12 Sep 2006 01:51:08 -0700
Date: Mon, 11 Sep 2006 23:16:23 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: A solution for more GFP_xx flags?
Message-Id: <20060911231623.a0d811ba.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609111920590.7815@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609111920590.7815@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> struct allocation_control {
> 	unsigned long flags;	/* Traditional flags */
> 	int node;
> 	struct cpuset_context *cpuset;

I don't understand what purpose this cpuset pointer has.

The main (heavily traveled) code paths beneath __alloc_pages() don't
look at the tasks cpuset at all, and the less traveled code paths only
look at the current tasks cpuset.

I have no clue how the above cpuset pointer could (usefully) be
anything other than just a copy of current->cpuset.  Also, without
serious reworking of the locking and likely some performance impact, I
have no idea what use this cpuset pointer would be on the main memory
allocation code paths.

The cpuset imposed constraints on an allocation are represented by the
mems_allowed nodemask and the flags PF_SPREAD_PAGE and PF_SPREAD_SLAB
in the task struct.  If the memory constraints imposed by a tasks
cpuset change, then these constraints are transfered to the tasks
mems_allowed and flags by the routine cpuset_update_task_memory_state().

Unlike mm/mempolicy.c NUMA mempolicies, one task -can- change the cpuset
of another task.  This forces us to have fancier (more expensive)
locking on cpusets, and that means we have to keep cpusets off the hot
memory allocation code paths and instead cache their constraints in the
task struct.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
