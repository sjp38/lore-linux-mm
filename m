Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA586B0055
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 17:34:27 -0400 (EDT)
Subject: [PATCH 3/5] mm: refactor unregister_cpu_under_node()
From: Alex Chiang <achiang@hp.com>
Date: Mon, 19 Oct 2009 15:34:25 -0600
Message-ID: <20091019213425.32729.3993.stgit@bob.kio>
In-Reply-To: <20091019212740.32729.7171.stgit@bob.kio>
References: <20091019212740.32729.7171.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

By returning early if the node is not online, we can unindent the
interesting code by two levels.

No functional change.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 drivers/base/node.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index ef7dd22..ffda067 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -243,12 +243,18 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
-	if (node_online(nid)) {
-		struct sys_device *obj = get_cpu_sysdev(cpu);
-		if (obj)
-			sysfs_remove_link(&node_devices[nid].sysdev.kobj,
-					 kobject_name(&obj->kobj));
-	}
+	struct sys_device *obj;
+
+	if (!node_online(nid))
+		return 0;
+
+	obj = get_cpu_sysdev(cpu);
+	if (!obj)
+		return 0;
+
+	sysfs_remove_link(&node_devices[nid].sysdev.kobj,
+			  kobject_name(&obj->kobj));
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
