Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mABCXS2U022646
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:33:28 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mABCXXKg135692
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:33:33 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mABCXIGO001141
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:33:18 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 11 Nov 2008 18:03:14 +0530
Message-Id: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
Subject: [RFC][mm][PATCH 0/4] Memory cgroup hierarchy introduction (v3)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch follows several iterations of the memory controller hierarchy
patches. The hardwall approach by Kamezawa-San[1]. Version 1 of this patchset
at [2].

The current approach is based on [2] and has the following properties

1. Hierarchies are very natural in a filesystem like the cgroup filesystem.
   A multi-tree hierarchy has been supported for a long time in filesystems.
   When the feature is turned on, we honor hierarchies such that the root
   accounts for resource usage of all children and limits can be set at
   any point in the hierarchy. Any memory cgroup is limited by limits
   along the hierarchy. The total usage of all children of a node cannot
   exceed the limit of the node.
2. The hierarchy feature is selectable and off by default
3. Hierarchies are expensive and the trade off is depth versus performance.
   Hierarchies can also be completely turned off.

The patches are against 2.6.28-rc2-mm1 and were tested in a KVM instance
with SMP and swap turned on.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

v3..v2
======
1. Hierarchy selection logic, now allows use_hierarchy changes only if
   parent's use_hierarchy is set to 0 and there are no children
2. last_scanned_child is protected by cgroup_lock()
3. cgroup_lock() is released before lru_add_drain_all() in
   mem_cgroup_force_empty()

v2..v1
======
1. The hierarchy is now selectable per-subtree
2. The features file has been renamed to use_hierarchy
3. Reclaim now holds cgroup lock and the reclaim does recursive walk and reclaim

Acknowledgements
----------------

Thanks for the feedback from Li Zefan, Kamezawa Hiroyuki, Paul Menage and
others.

Series
------

memcg-hierarchy-documentation.patch
resource-counters-hierarchy-support.patch
memcg-hierarchical-reclaim.patch
memcg-add-hierarchy-selector.patch

Reviews? Comments?

References

1. http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-06/msg05417.html
2. http://kerneltrap.org/mailarchive/linux-kernel/2008/4/19/1513644/thread

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
