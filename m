Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 3B9E36B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 01:27:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CAE383EE0AE
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:27:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0C1245DE50
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:27:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9691645DE4D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:27:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B7B01DB8038
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:27:05 +0900 (JST)
Received: from G01JPEXCHKW28.g01.fujitsu.local (G01JPEXCHKW28.g01.fujitsu.local [10.0.193.111])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 452F91DB803A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:27:05 +0900 (JST)
Message-ID: <50765896.4000300@jp.fujitsu.com>
Date: Thu, 11 Oct 2012 14:26:46 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/2]suppress "Device nodeX does not have a release() function"
 warning
References: <507656D1.5020703@jp.fujitsu.com>
In-Reply-To: <507656D1.5020703@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rientjes@google.com, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

When calling unregister_node(), the function shows following message at
device_release().

"Device 'node2' does not have a release() function, it is broken and must
be fixed."

The reason is node's device struct does not have a release() function.

So the patch registers node_device_release() to the device's release()
function for suppressing the warning message. Additionally, the patch adds
memset() to initialize a node struct into register_node(). Because the node
struct is part of node_devices[] array and it cannot be freed by
node_device_release(). So if system reuses the node struct, it has a garbage.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/base/node.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

Index: linux-3.6/drivers/base/node.c
===================================================================
--- linux-3.6.orig/drivers/base/node.c	2012-10-11 10:04:02.149758748 +0900
+++ linux-3.6/drivers/base/node.c	2012-10-11 10:20:34.111806931 +0900
@@ -252,6 +252,14 @@ static inline void hugetlb_register_node
 static inline void hugetlb_unregister_node(struct node *node) {}
 #endif
 
+static void node_device_release(struct device *dev)
+{
+#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
+	struct node *node_dev = to_node(dev);
+
+	flush_work(&node_dev->node_work);
+#endif
+}
 
 /*
  * register_node - Setup a sysfs device for a node.
@@ -263,8 +271,11 @@ int register_node(struct node *node, int
 {
 	int error;
 
+	memset(node, 0, sizeof(*node));
+
 	node->dev.id = num;
 	node->dev.bus = &node_subsys;
+	node->dev.release = node_device_release;
 	error = device_register(&node->dev);
 
 	if (!error){

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
