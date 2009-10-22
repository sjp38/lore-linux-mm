Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6361D6B0082
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 00:15:27 -0400 (EDT)
Subject: [PATCH v2 4/5] mm: add numa node symlink for cpu devices in sysfs
From: Alex Chiang <achiang@hp.com>
Date: Wed, 21 Oct 2009 22:15:25 -0600
Message-ID: <20091022041525.15705.6794.stgit@bob.kio>
In-Reply-To: <20091022040814.15705.95572.stgit@bob.kio>
References: <20091022040814.15705.95572.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

You can discover which CPUs belong to a NUMA node by examining
/sys/devices/system/node/node#/

However, it's not convenient to go in the other direction, when looking at
/sys/devices/system/cpu/cpu#/

Yes, you can muck about in sysfs, but adding these symlinks makes
life a lot more convenient.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 drivers/base/node.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index ffda067..24fa962 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -227,6 +227,7 @@ struct node node_devices[MAX_NUMNODES];
  */
 int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
+	int ret;
 	struct sys_device *obj;
 
 	if (!node_online(nid))
@@ -236,9 +237,15 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 	if (!obj)
 		return 0;
 
-	return sysfs_create_link(&node_devices[nid].sysdev.kobj,
+	ret = sysfs_create_link(&node_devices[nid].sysdev.kobj,
 				&obj->kobj,
 				kobject_name(&obj->kobj));
+	if (ret)
+		return ret;
+
+	return sysfs_create_link(&obj->kobj,
+				 &node_devices[nid].sysdev.kobj,
+				 kobject_name(&node_devices[nid].sysdev.kobj));
 }
 
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
@@ -254,6 +261,8 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 
 	sysfs_remove_link(&node_devices[nid].sysdev.kobj,
 			  kobject_name(&obj->kobj));
+	sysfs_remove_link(&obj->kobj,
+			  kobject_name(&node_devices[nid].sysdev.kobj));
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
