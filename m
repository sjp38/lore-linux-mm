Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2FF676B0093
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 05:31:01 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC V7 PATCH 18/19] memory-hotplug: add node_device_release
Date: Mon, 20 Aug 2012 17:35:41 +0800
Message-Id: <1345455342-27752-19-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1345455342-27752-1-git-send-email-wency@cn.fujitsu.com>
References: <1345455342-27752-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

When calling unregister_node(), the function shows following message at
device_release().

Device 'node2' does not have a release() function, it is broken and must be
fixed.

So the patch implements node_device_release()

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/base/node.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index af1a177..9bc2f57 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -252,6 +252,13 @@ static inline void hugetlb_register_node(struct node *node) {}
 static inline void hugetlb_unregister_node(struct node *node) {}
 #endif
 
+static void node_device_release(struct device *dev)
+{
+	struct node *node_dev = to_node(dev);
+
+	flush_work(&node_dev->node_work);
+	memset(node_dev, 0, sizeof(struct node));
+}
 
 /*
  * register_node - Setup a sysfs device for a node.
@@ -265,6 +272,7 @@ int register_node(struct node *node, int num, struct node *parent)
 
 	node->dev.id = num;
 	node->dev.bus = &node_subsys;
+	node->dev.release = node_device_release;
 	error = device_register(&node->dev);
 
 	if (!error){
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
