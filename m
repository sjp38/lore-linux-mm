Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 34A876B0078
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 00:15:17 -0400 (EDT)
Subject: [PATCH v2 2/5] mm: refactor register_cpu_under_node()
From: Alex Chiang <achiang@hp.com>
Date: Wed, 21 Oct 2009 22:15:15 -0600
Message-ID: <20091022041515.15705.26283.stgit@bob.kio>
In-Reply-To: <20091022040814.15705.95572.stgit@bob.kio>
References: <20091022040814.15705.95572.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

By returning early if the node is not online, we can unindent the
interesting code by one level.

No functional change.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 drivers/base/node.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 3108b21..ef7dd22 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -227,16 +227,18 @@ struct node node_devices[MAX_NUMNODES];
  */
 int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
-	if (node_online(nid)) {
-		struct sys_device *obj = get_cpu_sysdev(cpu);
-		if (!obj)
-			return 0;
-		return sysfs_create_link(&node_devices[nid].sysdev.kobj,
-					 &obj->kobj,
-					 kobject_name(&obj->kobj));
-	 }
+	struct sys_device *obj;
 
-	return 0;
+	if (!node_online(nid))
+		return 0;
+
+	obj = get_cpu_sysdev(cpu);
+	if (!obj)
+		return 0;
+
+	return sysfs_create_link(&node_devices[nid].sysdev.kobj,
+				&obj->kobj,
+				kobject_name(&obj->kobj));
 }
 
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
