Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id EC1A96B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:58:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 371203EE081
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:58:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F03C45DE5A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:58:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E683C45DE52
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:58:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D5F301DB8041
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:58:13 +0900 (JST)
Received: from g01jpexchkw03.g01.fujitsu.local (g01jpexchkw03.g01.fujitsu.local [10.0.194.42])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E6B01DB803A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:58:13 +0900 (JST)
Message-ID: <4FEAA0E2.2080003@jp.fujitsu.com>
Date: Wed, 27 Jun 2012 14:57:54 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH 11/12] memory-hotplug : add node_device_release
References: <4FEA9C88.1070800@jp.fujitsu.com>
In-Reply-To: <4FEA9C88.1070800@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

When calling unregister_node(), the function shows following message at
device_release().

Device 'node2' does not have a release() function, it is broken and must be fixed.

So the patch implements node_device_release()

CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Index: linux-3.5-rc1/drivers/base/node.c
===================================================================
--- linux-3.5-rc1.orig/drivers/base/node.c	2012-06-14 09:09:53.000000000 +0900
+++ linux-3.5-rc1/drivers/base/node.c	2012-06-25 18:40:45.810261969 +0900
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
