Subject: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
Content-Type: text/plain
Date: Mon, 27 Aug 2007 17:02:08 -0400
Message-Id: <1188248528.5952.95.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: clameter@sgi.com, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Here's a cleaned up version that addresses Christoph's comments.

Lee
===============
PATCH Add node 'states' sysfs class attribute v2

Against:  2.6.23-rc3-mm1

V1 -> V2:
+ style cleanup
+ drop 'len' variable in print_node_states();  compute from
  final size.
+ use nodelist_scnprintf() for state masks.

Add a sysfs class attribute file to /sys/devices/system/node
to display node state masks.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/base/node.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 70 insertions(+), 1 deletion(-)

Index: Linux/drivers/base/node.c
===================================================================
--- Linux.orig/drivers/base/node.c	2007-08-27 12:31:32.000000000 -0400
+++ Linux/drivers/base/node.c	2007-08-27 16:30:18.000000000 -0400
@@ -12,6 +12,7 @@
 #include <linux/topology.h>
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
+#include <linux/device.h>
 
 static struct sysdev_class node_class = {
 	set_kset_name("node"),
@@ -232,8 +233,76 @@ void unregister_one_node(int nid)
 	unregister_node(&node_devices[nid]);
 }
 
+/*
+ * [node] states attribute
+ */
+static char * node_state_names[] = {
+	"possible:",
+	"on-line:",
+	"normal memory:",
+#ifdef CONFIG_HIGHMEM
+	"high memory:",
+#endif
+	"cpu:",
+};
+
+static ssize_t
+print_node_states(struct class *class, char *buf)
+{
+	int i;
+	int n;
+	ssize_t  size = PAGE_SIZE;
+
+	for (i = 0; i < NR_NODE_STATES; i++) {
+		n = snprintf(buf, size, "%14s  ", node_state_names[i]);
+		if (n <= 0)
+			break;
+		buf += n;
+		size -= n;
+		if (size <= 0)
+			break;
+
+		n = nodelist_scnprintf(buf, size, node_states[i]);
+		if (n <= 0)
+			break;
+		buf += n;
+		size -=n;
+		if (size <= 0)
+			break;
+
+		n = snprintf(buf, size, "\n");
+		if (n <= 0)
+			break;
+		buf += n;
+		size -= n;
+		if (size <= 0)
+			break;
+	}
+
+	if (n > 0) {
+		n = PAGE_SIZE;
+		if (size > 0)
+			n -= size;
+	}
+	return n;
+}
+
+static CLASS_ATTR(states, 0444, print_node_states, NULL);
+
+static int node_states_init(void)
+{
+	return sysfs_create_file(&node_class.kset.kobj,
+				&class_attr_states.attr);
+}
+
 static int __init register_node_type(void)
 {
-	return sysdev_class_register(&node_class);
+	int ret;
+
+	ret = sysdev_class_register(&node_class);
+	if (!ret)
+		ret = node_states_init();
+
+	return ret;
 }
 postcore_initcall(register_node_type);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
