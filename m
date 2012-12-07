Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 2BD486B008A
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 17:34:58 -0500 (EST)
Message-ID: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] mm: add node physical memory range to sysfs
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Fri, 07 Dec 2012 14:34:56 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch adds a new 'memrange' file that shows the starting and
ending physical addresses that are associated to a node. This is
useful for identifying specific DIMMs within the system.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 drivers/base/node.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index af1a177..f165a0a 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -211,6 +211,19 @@ static ssize_t node_read_distance(struct device *dev,
 }
 static DEVICE_ATTR(distance, S_IRUGO, node_read_distance, NULL);
 
+static ssize_t node_read_memrange(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	int nid = dev->id;
+	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
+	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
+
+	return sprintf(buf, "%#010Lx-%#010Lx\n",
+		       (unsigned long long) start_pfn << PAGE_SHIFT,
+		       (unsigned long long) (end_pfn << PAGE_SHIFT) - 1);
+}
+static DEVICE_ATTR(memrange, S_IRUGO, node_read_memrange, NULL);
+
 #ifdef CONFIG_HUGETLBFS
 /*
  * hugetlbfs per node attributes registration interface:
@@ -274,6 +287,7 @@ int register_node(struct node *node, int num, struct node *parent)
 		device_create_file(&node->dev, &dev_attr_numastat);
 		device_create_file(&node->dev, &dev_attr_distance);
 		device_create_file(&node->dev, &dev_attr_vmstat);
+		device_create_file(&node->dev, &dev_attr_memrange);
 
 		scan_unevictable_register_node(node);
 
@@ -299,6 +313,7 @@ void unregister_node(struct node *node)
 	device_remove_file(&node->dev, &dev_attr_numastat);
 	device_remove_file(&node->dev, &dev_attr_distance);
 	device_remove_file(&node->dev, &dev_attr_vmstat);
+	device_remove_file(&node->dev, &dev_attr_memrange);
 
 	scan_unevictable_unregister_node(node);
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
