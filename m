Subject: [PATCH/RFC] Add node states sysfs class attributeS - V4
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
	 <20070827201822.2506b888.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
	 <20070827222912.8b364352.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
	 <20070827231214.99e3c33f.akpm@linux-foundation.org>
	 <1188309928.5079.37.camel@localhost>
	 <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
	 <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com>
	 <1188398621.5121.13.camel@localhost>
	 <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 30 Aug 2007 11:19:16 -0400
Message-Id: <1188487157.5794.40.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Nish Aravamudan <nish.aravamudan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Try, try again.  Maybe closer this time.

Question:  do we need/want to display the normal and high memory masks
separately for systems with HIGHMEM?  If not, I'd suggest changing the
print_nodes_state() function to take a nodemask_t* instead of a state
enum and expose a single 'has_memory' attribute that we print using
something like:

static ssize_t print_nodes_has_memory(struct sysdev_class *class,
						char *buf)
{
	nodemask_t has_memory = node_states[N_NORMAL_MEMORY];

	if (N_HIGH_MEMORY - N_NORMAL_MEMORY)
		nodes_or(has_memory, has_memory, node_states[N_HIGH_MEMORY]);

	return print_nodes_state(&has_memory, buf);
}

The compiler should eliminate the 'or' when HIGHMEM is not configured.
But, we'd probably be doing the node_states[] index computation in each
print function.

Thoughts?

Lee
====================

PATCH Add node 'states' sysfs class attributes v4

Against:  2.6.23-rc3-mm1

V3 -> V4:
+ drop the annotations -- not needed with one value per file.
+ this simplifies print_nodes_state()
+ fix "function return type on separate line" style glitch

V2 -> V3:
+ changed to per state sysfs file -- "one value per file"

V1 -> V2:
+ style cleanup
+ drop 'len' variable in print_node_states();  compute from
  final size.

Add a per node state sysfs class attribute file to
/sys/devices/system/node to display node state masks.

E.g., on a 4-cell HP ia64 NUMA platform, we have 5 nodes:
4 representing the actual hardware cells and one memory-only
pseudo-node representing a small amount [512MB] of "hardware
interleaved" memory.  With this patch, in /sys/devices/system/node
we see:

#ls -1F /sys/devices/system/node
has_cpu
has_normal_memory
node0/
node1/
node2/
node3/
node4/
online
possible
#cat /sys/devices/system/node/possible
0-255
#cat /sys/devices/system/node/online
0-4
#cat /sys/devices/system/node/has_normal_memory
0-4
#cat /sys/devices/system/node/has_cpu
0-3

N.B., NOT TESTED with CONFIG_HIGHMEM=y.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/base/node.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 93 insertions(+), 1 deletion(-)

Index: Linux/drivers/base/node.c
===================================================================
--- Linux.orig/drivers/base/node.c	2007-08-29 15:18:53.000000000 -0400
+++ Linux/drivers/base/node.c	2007-08-30 10:38:44.000000000 -0400
@@ -12,6 +12,7 @@
 #include <linux/topology.h>
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
+#include <linux/device.h>
 
 static struct sysdev_class node_class = {
 	set_kset_name("node"),
@@ -232,8 +233,99 @@ void unregister_one_node(int nid)
 	unregister_node(&node_devices[nid]);
 }
 
+/*
+ * node states attributes
+ */
+
+static ssize_t print_nodes_state(enum node_states state, char *buf)
+{
+	int n;
+
+	n = nodelist_scnprintf(buf, PAGE_SIZE, node_states[state]);
+	if (n <= 0)
+		goto done;
+	if (PAGE_SIZE - n > 1) {
+		*(buf + n++) = '\n';
+		*(buf + n++) = '\0';
+	}
+done:
+	return n;
+}
+
+static ssize_t print_nodes_possible(struct sysdev_class *class, char *buf)
+{
+	return print_nodes_state(N_POSSIBLE, buf);
+}
+
+static ssize_t print_nodes_online(struct sysdev_class *class, char *buf)
+{
+	return print_nodes_state(N_ONLINE, buf);
+}
+
+static ssize_t print_nodes_has_normal_memory(struct sysdev_class *class,
+						char *buf)
+{
+	return print_nodes_state(N_NORMAL_MEMORY, buf);
+}
+
+static ssize_t print_nodes_has_cpu(struct sysdev_class *class, char *buf)
+{
+	return print_nodes_state(N_CPU, buf);
+}
+
+static SYSDEV_CLASS_ATTR(possible, 0444, print_nodes_possible, NULL);
+static SYSDEV_CLASS_ATTR(online, 0444, print_nodes_online, NULL);
+static SYSDEV_CLASS_ATTR(has_normal_memory, 0444, print_nodes_has_normal_memory,
+									NULL);
+static SYSDEV_CLASS_ATTR(has_cpu, 0444, print_nodes_has_cpu, NULL);
+
+#ifdef CONFIG_HIGHMEM
+static ssize_t print_nodes_has_high_memory(struct sysdev_class *class,
+						 char *buf)
+{
+	return print_nodes_state(N_HIGH_MEMORY, buf);
+}
+
+static SYSDEV_CLASS_ATTR(has_high_memory, 0444, print_nodes_has_high_memory,
+									 NULL);
+#endif
+
+struct sysdev_class_attribute *node_state_attr[] = {
+	&attr_possible,
+	&attr_online,
+	&attr_has_normal_memory,
+#ifdef CONFIG_HIGHMEM
+	&attr_has_high_memory,
+#endif
+	&attr_has_cpu,
+};
+
+static int node_states_init(void)
+{
+	int i;
+	int err = 0;
+
+	for (i = 0;  i < NR_NODE_STATES; i++) {
+		int ret;
+		ret = sysdev_class_create_file(&node_class, node_state_attr[i]);
+		if (!err)
+			err = ret;
+	}
+	return err;
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
+	/*
+	 * Note:  we're not going to unregister the node class if we fail
+	 * to register the node state class attribute files.
+	 */
+	return ret;
 }
 postcore_initcall(register_node_type);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
