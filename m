Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7A078E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 23:18:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u6-v6so1808015pgn.10
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 20:18:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12-v6sor3752618pll.149.2018.09.18.20.18.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 20:18:42 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCH 3/3] drivers/base/node: create a partial offline hints under each node
Date: Wed, 19 Sep 2018 11:17:46 +0800
Message-Id: <1537327066-27852-4-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1537327066-27852-1-git-send-email-kernelfans@gmail.com>
References: <1537327066-27852-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@techsingularity.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

When offline mem, there are two cases: 1st, offline all of memblock under a
node. 2nd, only offline and replace part of mem under a node. For the 2nd
case, there is not need to alloc new page from other nodes, which may incur
extra numa fault to resolve the misplaced issue, and place unnecessary mem
pressure on other nodes. The patch suggests to introduce an interface
 /sys/../node/nodeX/partial_offline to let the user order how to
allocate a new page, i.e. from local node or other nodes.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/base/node.c    | 33 +++++++++++++++++++++++++++++++++
 include/linux/mmzone.h |  1 +
 mm/memory_hotplug.c    | 31 +++++++++++++++++++------------
 3 files changed, 53 insertions(+), 12 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 1ac4c36..64b0cb8 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -25,6 +25,36 @@ static struct bus_type node_subsys = {
 	.dev_name = "node",
 };
 
+static ssize_t read_partial_offline(struct device *dev,
+	struct device_attribute *attr, char *buf)
+{
+	int nid = dev->id;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	ssize_t len = 0;
+
+	if (pgdat->partial_offline)
+		len = sprintf(buf, "1\n");
+	else
+		len = sprintf(buf, "0\n");
+
+	return len;
+}
+
+static ssize_t write_partial_offline(struct device *dev,
+	struct device_attribute *attr, const char *buf, size_t count)
+{
+	int nid = dev->id;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+
+	if (sysfs_streq(buf, "1"))
+		pgdat->partial_offline = true;
+	else if (sysfs_streq(buf, "0"))
+		pgdat->partial_offline = false;
+	else
+		return -EINVAL;
+
+	return strlen(buf);
+}
 
 static ssize_t node_read_cpumap(struct device *dev, bool list, char *buf)
 {
@@ -56,6 +86,8 @@ static inline ssize_t node_read_cpulist(struct device *dev,
 	return node_read_cpumap(dev, true, buf);
 }
 
+static DEVICE_ATTR(partial_offline, 0600, read_partial_offline,
+	write_partial_offline);
 static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
 static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
 
@@ -235,6 +267,7 @@ static struct attribute *node_dev_attrs[] = {
 	&dev_attr_numastat.attr,
 	&dev_attr_distance.attr,
 	&dev_attr_vmstat.attr,
+	&dev_attr_partial_offline.attr,
 	NULL
 };
 ATTRIBUTE_GROUPS(node_dev);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1e22d96..80c44c8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -722,6 +722,7 @@ typedef struct pglist_data {
 	/* Per-node vmstats */
 	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
 	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
+	bool	partial_offline;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 228de4d..3c66075 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1346,18 +1346,10 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 
 static struct page *new_node_page(struct page *page, unsigned long private)
 {
-	int nid = page_to_nid(page);
-	nodemask_t nmask = node_states[N_MEMORY];
-
-	/*
-	 * try to allocate from a different node but reuse this node if there
-	 * are no other online nodes to be used (e.g. we are offlining a part
-	 * of the only existing node)
-	 */
-	node_clear(nid, nmask);
-	if (nodes_empty(nmask))
-		node_set(nid, nmask);
+	nodemask_t nmask = *(nodemask_t *)private;
+	int nid;
 
+	nid = page_to_nid(page);
 	return new_page_nodemask(page, nid, &nmask);
 }
 
@@ -1371,6 +1363,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 	int not_managed = 0;
 	int ret = 0;
 	LIST_HEAD(source);
+	int nid;
+	nodemask_t nmask = node_states[N_MEMORY];
 
 	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
 		if (!pfn_valid(pfn))
@@ -1430,8 +1424,21 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			goto out;
 		}
 
+		page = list_entry(source.next, struct page, lru);
+		nid = page_to_nid(page);
+		if (!NODE_DATA(nid)->partial_offline) {
+			/*
+			 * try to allocate from a different node but reuse this
+			 * node if there are no other online nodes to be used
+			 * (e.g. we are offlining a part of the only existing
+			 * node)
+			 */
+			node_clear(nid, nmask);
+			if (nodes_empty(nmask))
+				node_set(nid, nmask);
+		}
 		/* Allocate a new page from the nearest neighbor node */
-		ret = migrate_pages(&source, new_node_page, NULL, 0,
+		ret = migrate_pages(&source, new_node_page, NULL, &nmask,
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret)
 			putback_movable_pages(&source);
-- 
2.7.4
