Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAG8AhhV030252
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 13:40:43 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAG8Aigd4452542
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 13:40:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAG8AJfl009244
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 13:40:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 16 Nov 2008 13:40:40 +0530
Message-Id: <20081116081040.25166.65142.sendpatchset@balbir-laptop>
In-Reply-To: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
Subject: [mm] [PATCH 1/4] Memory cgroup hierarchy documentation (v4)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Documentation updates for hierarchy support

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/controllers/memory.txt |   38 ++++++++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 1 deletion(-)

diff -puN Documentation/controllers/memory.txt~memcg-hierarchy-documentation Documentation/controllers/memory.txt
--- linux-2.6.28-rc4/Documentation/controllers/memory.txt~memcg-hierarchy-documentation	2008-11-16 13:14:39.000000000 +0530
+++ linux-2.6.28-rc4-balbir/Documentation/controllers/memory.txt	2008-11-16 13:14:39.000000000 +0530
@@ -289,8 +289,44 @@ will be charged as a new owner of it.
   Because rmdir() moves all pages to parent, some out-of-use page caches can be
   moved to the parent. If you want to avoid that, force_empty will be useful.
 
+6. Hierarchy support
 
-6. TODO
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
+6.1 Enabling hierarchical accounting and reclaim
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
+7. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
