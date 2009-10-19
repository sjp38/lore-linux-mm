Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 76B3D6B0055
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 17:34:32 -0400 (EDT)
Subject: [PATCH 4/5] mm: add numa node symlink for cpu devices in sysfs
From: Alex Chiang <achiang@hp.com>
Date: Mon, 19 Oct 2009 15:34:30 -0600
Message-ID: <20091019213430.32729.78995.stgit@bob.kio>
In-Reply-To: <20091019212740.32729.7171.stgit@bob.kio>
References: <20091019212740.32729.7171.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

You can discover which CPUs belong to a NUMA node by examining
/sys/devices/system/node/$node/

However, it's not convenient to go in the other direction, when looking at
/sys/devices/system/cpu/$cpu/

Yes, you can muck about in sysfs, but adding these symlinks makes
life a lot more convenient.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 drivers/base/node.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index ffda067..47a4997 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -227,6 +227,7 @@ struct node node_devices[MAX_NUMNODES];
  */
 int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
+	int ret;
 	struct sys_device *obj;
 
 	if (!node_online(nid))
@@ -236,9 +237,13 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 	if (!obj)
 		return 0;
 
-	return sysfs_create_link(&node_devices[nid].sysdev.kobj,
+	ret = sysfs_create_link(&node_devices[nid].sysdev.kobj,
 				&obj->kobj,
 				kobject_name(&obj->kobj));
+
+	return sysfs_create_link(&obj->kobj,
+				 &node_devices[nid].sysdev.kobj,
+				 kobject_name(&node_devices[nid].sysdev.kobj));
 }
 
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
@@ -254,6 +259,8 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 
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
