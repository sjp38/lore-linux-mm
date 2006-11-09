Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kA9JkWou235962
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 06:46:32 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kA9Jd1F9152552
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 06:39:11 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kA9JZZH9007993
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 06:35:35 +1100
From: Balbir Singh <balbir@in.ibm.com>
Date: Fri, 10 Nov 2006 01:05:23 +0530
Message-Id: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com>
Subject: [RFC][PATCH 0/8] RSS controller for containers
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: dev@openvz.org, ckrm-tech@lists.sourceforge.net, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, haveblue@us.ibm.com, rohitseth@google.com, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Here is set of patches that implements a *simple minded* RSS controller
for containers.  It would be nice to split up the memory controller design
and implementation in phases

1. RSS control
2. Page Cache control (with split clean and dirty accounting/control)
3. mlock() control
4. Kernel accounting and control

The beancounter implementation follows a very similar approach. The split
up makes the design of the controller easier. RSS for example, can be tracked
per mm_struct. Page Cache could be tracked per inode, per thread
or per mm_struct (depending on what form is most suitable).

The definition of RSS was debated on lkml, please see

	http://lkml.org/lkml/2006/10/10/130

This patchset is a proof of concept implementation and the accounting can
be easily adapted to meet the definition of RSS as and when it is re-defined
or revisited. The changes required should be small.

The reclamation logic has been borrowed from Dave Hansen's challenged
memory controller and from shrink_all_memory(). The accounting was inspired
from Rohit Seth's container patches.

The good
--------

No additional pointers required in struct page.
There is also a lot of scope for code reuse in tracking the rss of a process
(this reuse is yet to be exploited).

The not so good
---------------
The patches contain a lot of debugging code.

Applying the patches
--------------------
This patchset has been developed on top of 2.6.19-rc2 with the latest
containers patch applied.

To run and test this patch, additional fixes are required.

Please see
	
	http://lkml.org/lkml/2006/11/6/10
	http://lkml.org/lkml/2006/11/6/245


Series
------
container-res-groups-fix-parsing.patch
container-memctlr-setup.patch
container-memctlr-callbacks.patch
container-memctlr-acct.patch
container-memctlr-task-migration.patch
container-memctlr-shares.patch
container-memctlr-reclaim.patch

Setup
-----
To test the series, here's what you need to do

0. Get the latest containers patches against 2.6.19-rc2
1. Apply all the fixes
2. Apply these patches
3. Build the kernel and mount the container filesystem
	mount -t container container /container

4. Disable cpuset's (to simply assignment of tasks to resource groups)

	cd /container
	echo 0 > cpuset_enabled

5. Add the current task to a new group

	mkdir /container/a
	echo $$ > tasks
	cat memctlr_stats

6. Set limits

	echo "res=memctlr,max_shares=10" > memctlr_shares

7. Spin the system, hang it, revolve it, crash it!!
8. Please provide feedback, both code review and any thing else that
   can be useful for further development

Testing
-------
Kernbench was run on these patches and it did not show any significant
overhead in the tests.


-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
