Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5B3D46B008A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 02:05:30 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DA5343EE0C1
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:05:28 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B77C345DEB3
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:05:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D11645DEA6
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:05:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 900891DB8040
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:05:28 +0900 (JST)
Received: from g01jpexchyt05.g01.fujitsu.local (g01jpexchyt05.g01.fujitsu.local [10.128.194.44])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D9741DB8042
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:05:28 +0900 (JST)
Message-ID: <4FF28B9B.5010409@jp.fujitsu.com>
Date: Tue, 3 Jul 2012 15:05:15 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v2 12/13] memory-hotplug : add node_device_release
References: <4FF287C3.4030901@jp.fujitsu.com>
In-Reply-To: <4FF287C3.4030901@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

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

---
 drivers/base/node.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-3.5-rc4/drivers/base/node.c
===================================================================
--- linux-3.5-rc4.orig/drivers/base/node.c	2012-07-03 14:21:44.882432167 +0900
+++ linux-3.5-rc4/drivers/base/node.c	2012-07-03 14:22:23.296951921 +0900
@@ -252,6 +252,12 @@ static inline void hugetlb_register_node
 static inline void hugetlb_unregister_node(struct node *node) {}
 #endif

+static void node_device_release(struct device *dev)
+{
+	struct node *node_dev = to_node(dev);
+
+	memset(node_dev, 0, sizeof(struct node));
+}

 /*
  * register_node - Setup a sysfs device for a node.
@@ -265,6 +271,7 @@ int register_node(struct node *node, int

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
