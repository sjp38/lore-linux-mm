Subject: [PATCH/RFC]  Add node 'states' sysfs class attribute
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
Content-Type: text/plain
Date: Mon, 27 Aug 2007 13:48:24 -0400
Message-Id: <1188236904.5952.72.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: clameter@sgi.com, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Christoph suggested something like this a while back, as a new /proc
file.  Believing, perhaps incorrectly, that new /proc files are
discouraged, I have implemented this as a sysfs class attribute on the
'node' system device class.

Works on my numa platform:  4 nodes with cpus, one memory only node.

Questions:

1)  if this is useful, do we need/want the possible mask?

2)  how about teaching nodemask_scnprintf() to suppress leading
    words of all zeros?

Lee
===========================

PATCH Add node 'states' sysfs class attribute

Against:  2.6.23-rc3-mm1

Add a sysfs class attribute file /sys/devices/system/node/states
to display node state masks:

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/base/node.c |   73 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 72 insertions(+), 1 deletion(-)

Index: Linux/drivers/base/node.c
===================================================================
--- Linux.orig/drivers/base/node.c	2007-08-27 12:31:32.000000000 -0400
+++ Linux/drivers/base/node.c	2007-08-27 13:25:19.000000000 -0400
@@ -12,6 +12,7 @@
 #include <linux/topology.h>
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
+#include <linux/device.h>
 
 static struct sysdev_class node_class = {
 	set_kset_name("node"),
@@ -232,8 +233,78 @@ void unregister_one_node(int nid)
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
+	size_t  size = PAGE_SIZE;
+	ssize_t len = 0;
+
+	for (i=0; i < NR_NODE_STATES; ++i) {
+		n = snprintf(buf, size, "%16s ", node_state_names[i]);
+		if (n < 0)
+			break;
+		buf += n;
+		len += n;
+		size -= n;
+		if (size < 0)
+			break;
+
+		n = nodemask_scnprintf(buf, size, node_states[i]);
+		if (n < 0)
+			break;
+		buf += n;
+		len += n;
+		size -=n;
+		if (size < 0)
+			break;
+
+		n = snprintf(buf, size, "\n");
+		if (n < 0)
+			break;
+		buf += n;
+		len += n;
+		size -= n;
+		if (size < 0)
+			break;
+	}
+
+	return n < 0 ? n : len;
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
+	if (ret)
+		goto out;
+
+	ret = node_states_init();
+
+out:
+	return ret;
 }
 postcore_initcall(register_node_type);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
