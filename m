Message-Id: <200405222207.i4MM7Zr13055@mail.osdl.org>
Subject: [patch 23/57] Re-add NUMA API statistics
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:07:05 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

Patch readds the sysfs output of the NUMA API statistics.  All my test
scripts need this and it is very useful to check if the policy actually
works.

This got lost when the huge page numa api changes got dropped.

I decided to not resend the huge pages NUMA API changes for now.  Instead I
will wait for this area to settle when demand paged large pages is merged.


---

 25-akpm/drivers/base/node.c |   52 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletion(-)

diff -puN drivers/base/node.c~numa-api-statistics-2 drivers/base/node.c
--- 25/drivers/base/node.c~numa-api-statistics-2	2004-05-22 14:56:25.073279808 -0700
+++ 25-akpm/drivers/base/node.c	2004-05-22 14:56:25.077279200 -0700
@@ -30,13 +30,20 @@ static ssize_t node_read_cpumap(struct s
 
 static SYSDEV_ATTR(cpumap,S_IRUGO,node_read_cpumap,NULL);
 
+/* Can be overwritten by architecture specific code. */
+int __attribute__((weak)) hugetlb_report_node_meminfo(int node, char *buf)
+{
+	return 0;
+}
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct sys_device * dev, char * buf)
 {
+	int n;
 	int nid = dev->id;
 	struct sysinfo i;
 	si_meminfo_node(&i, nid);
-	return sprintf(buf, "\n"
+	n = sprintf(buf, "\n"
 		       "Node %d MemTotal:     %8lu kB\n"
 		       "Node %d MemFree:      %8lu kB\n"
 		       "Node %d MemUsed:      %8lu kB\n"
@@ -51,10 +58,52 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.freehigh),
 		       nid, K(i.totalram-i.totalhigh),
 		       nid, K(i.freeram-i.freehigh));
+	n += hugetlb_report_node_meminfo(nid, buf + n);
+	return n;
 }
+
 #undef K 
 static SYSDEV_ATTR(meminfo,S_IRUGO,node_read_meminfo,NULL);
 
+static ssize_t node_read_numastat(struct sys_device * dev, char * buf)
+{
+	unsigned long numa_hit, numa_miss, interleave_hit, numa_foreign;
+	unsigned long local_node, other_node;
+	int i, cpu;
+	pg_data_t *pg = NODE_DATA(dev->id);
+	numa_hit = 0;
+	numa_miss = 0;
+	interleave_hit = 0;
+	numa_foreign = 0;
+	local_node = 0;
+	other_node = 0;
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		struct zone *z = &pg->node_zones[i];
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			struct per_cpu_pageset *ps = &z->pageset[cpu];
+			numa_hit += ps->numa_hit;
+			numa_miss += ps->numa_miss;
+			numa_foreign += ps->numa_foreign;
+			interleave_hit += ps->interleave_hit;
+			local_node += ps->local_node;
+			other_node += ps->other_node;
+		}
+	}
+	return sprintf(buf,
+		       "numa_hit %lu\n"
+		       "numa_miss %lu\n"
+		       "numa_foreign %lu\n"
+		       "interleave_hit %lu\n"
+		       "local_node %lu\n"
+		       "other_node %lu\n",
+		       numa_hit,
+		       numa_miss,
+		       numa_foreign,
+		       interleave_hit,
+		       local_node,
+		       other_node);
+}
+static SYSDEV_ATTR(numastat,S_IRUGO,node_read_numastat,NULL);
 
 /*
  * register_node - Setup a driverfs device for a node.
@@ -74,6 +123,7 @@ int __init register_node(struct node *no
 	if (!error){
 		sysdev_create_file(&node->sysdev, &attr_cpumap);
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
+		sysdev_create_file(&node->sysdev, &attr_numastat);
 	}
 	return error;
 }

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
