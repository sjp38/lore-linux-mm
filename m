Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 7E0FB6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:32:01 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 17:32:00 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D91096E8FF1
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:11:27 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LMBTfN241382
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:11:29 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LMBTgD014580
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 19:11:29 -0300
Date: Thu, 21 Feb 2013 11:47:33 -0800
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [LSF/MM TOPIC][ATTEND] Handling NUMA layout changes at runtime
Message-ID: <20130221194733.GA3778@negative>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Yes, this is late. Sorry.

I'd like to discuss the following topic:

--

Presently, NUMA layout is determined at boot time and never changes again.
This setup works for real hardware, but virtual machines are more dynamic:
they could be migrated between different hosts, and have to share the physical
memory space with other VMs which are also being moved around or shut down
while other new VMs are started up. As a result, the physical backing memory
that a VM had when it started up changes at runtime.

Problems to be overcome:

	- How should userspace be notified? Do we need new interfaces so
	  applications can query memory to see if it was affected?

	- Can we make the NUMA layout initialization generic? This also
	  implies that all initialization of struct zone/struct
	  page/NODE_DATA() would be made (somewhat) generic.

	- Some one-time allocations now will know they are on a non-optimal
	  node.

	- hotpluged per node data is (in general) not being allocated optimally)

		- NODE_DATA() for hotpluged nodes is allocated off-node (except for
		  ia64).

		- SLUB's kmem_cache_node is always allocated off-node for
		  hotpluged nodes.

	  [Not a new problem, but one that needs solving].

Some more generic NUMA layout/mm init things:

	- boot-time and hotplug NUMA init don't share enough code.

	- architectures do not share mm init code

	- NUMA layout (from init) is kept (if it is kept at all) in only arch
	  specific ways. Memblock _happens_ to contain this info, while also
	  also tracking allocations, and every arch but powerpc discards it as
	  __init/__initdata)

A WIP patchset addressing initial reconfiguration of the page allocator:
https://github.com/jmesmon/linux/tree/dnuma/v25

--
Cody P Schafer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
