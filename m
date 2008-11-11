Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id mABCXu1u006916
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:33:56 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mABCXu74145364
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:33:56 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mABCXttJ004722
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:33:56 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 11 Nov 2008 18:03:38 +0530
Message-Id: <20081111123338.6566.33066.sendpatchset@balbir-laptop>
In-Reply-To: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
Subject: [RFC][mm] [PATCH 1/4] Memory cgroup hierarchy documentation (v3)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Documentation updates for hierarchy support

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/controllers/memory.txt |   37 +++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff -puN Documentation/controllers/memory.txt~memcg-hierarchy-documentation Documentation/controllers/memory.txt
--- linux-2.6.28-rc2/Documentation/controllers/memory.txt~memcg-hierarchy-documentation	2008-11-11 17:51:54.000000000 +0530
+++ linux-2.6.28-rc2-balbir/Documentation/controllers/memory.txt	2008-11-11 17:51:54.000000000 +0530
@@ -245,6 +245,43 @@ cgroup might have some charge associated
 tasks have migrated away from it. Such charges are automatically dropped at
 rmdir() if there are no tasks.
 
+5. Hierarchy support
+
+The memory controller supports a deep hierarchy and hierarchical accounting.
+The hierarchy is created by creating the appropriate cgroups in the
+cgroup filesystem. Consider for example, the following cgroup filesystem
+hierarchy
+
+		root
+	     /  |   \
+           /	|    \
+	  a	b	c
+			| \
+			|  \
+			d   e
+
+In the diagram above, with hierarchical accounting enabled, all memory
+usage of e, is accounted to its ancestors up until the root (i.e, c and root),
+that has memory.use_hierarchy enabled.  If one of the ancestors goes over its
+limit, the reclaim algorithm reclaims from the tasks in the ancestor and the
+children of the ancestor.
+
+5.1 Enabling hierarchical accounting and reclaim
+
+The memory controller by default disables the hierarchy feature. Support
+can be enabled by writing 1 to memory.use_hierarchy file of the root cgroup
+
+# echo 1 > memory.use_hierarchy
+
+The feature can be disabled by
+
+# echo 0 > memory.use_hierarchy
+
+NOTE1: Enabling/disabling will fail if the cgroup already has other
+cgroups created below it.
+
+NOTE2: This feature can be enabled/disabled per subtree.
+
 5. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
