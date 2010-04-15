Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DF4AC6B020C
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:30:25 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 15 Apr 2010 13:29:50 -0400
Message-Id: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/8] Numa: Use Generic Per-cpu Variables for numa_*_id()
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Use Generic Per cpu infrastructure for numa_*_id() V4

Series Against: 2.6.34-rc3-mmotm-100405-1609

Background:

V1 of this series resolved a fairly serious performance problem on our ia64
platforms with memoryless nodes because SLAB cannot cache object from a remote
node, even tho' that node is the effective "local memory node" for a given cpu.
V1 caused no regression in x86_64 [a slight improvement even] for the admittedly
few tests that I ran.

Christoph Lameter suggested the approach implemented in V2 and later:  define
a new function--numa_mem_id()--that returns the "local memory node" for cpus
attached to memoryless nodes.  Christoph also suggested that, while at it, I
could modify the implementation of numa_node_id() [and the related cpu_to_node()]
to use the generic percpu variable implementation.

While implementing V2, I encountered a circular header dependency between:

	topology.h -> percpu.h -> slab.h -> gfp.h -> topology.h

I resolved this by moving the generic percpu functions to
include/asm-generic/percpu.h so that various arch asm/percpu.h could include
that, and topology.h could include asm/percpu.h to avoid including slab.h,
breaking the circular dependency.  Reviewers didn't like that.  Matthew Willcox
suggested that I uninline percpu_alloc()/free() for the !SMP config and remove
slab.h from percpu.h.  I tried that.  I broke the build of a LOT of files.  Tejun
Heo mentioned that percpu-defs.h would be a better place for the generic function
definitions.  V3 implemented that suggestion.

Later, Tejun decided to jump in and remove slab.h from percpu.h and semi-
automagically fix up all of the affected modules.  V4 is implemented atop Tejun's
series now in mmotm.  Again, this solves the slab performance problem on our
servers configured with memoryless nodes, and shows no regression with
hackbench on x86_64.  Of course, more performance testing would be welcome.

The slab changes in patch 6 of the series need review w/rt to node hot plug
that could change the effective "local memory node" for a memoryless node
by inserting a "nearer" node in the zonelists.  An additional patch may be
required to address this.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
