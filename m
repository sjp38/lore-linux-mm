Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1177B6B005A
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 09:51:19 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 16 Jun 2009 09:52:53 -0400
Message-Id: <20090616135253.25248.96346.sendpatchset@lts-notebook>
In-Reply-To: <20090616135228.25248.22018.sendpatchset@lts-notebook>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook>
Subject: [PATCH 2/5] Add nodes_allowed members to hugepages hstate struct
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 2/5] add nodes_allowed members to hugepages hstate struct

Against:  17may09 mmotm

This patch adds a nodes_allowed nodemask_t pointer and a
__nodes_allowed nodemask_t to the hstate struct for constraining
fresh hugepage allocations.  It then adds sysfs attributes and
boot command line options to set and [for sysfs attributes] query
the allowed nodes mask.

A separate patch will hook up this nodes_allowed mask/pointer to
fresh huge page allocation and promoting of surplus pages to
persistent.  Another patch will add a 'sysctl' hugepages_nodes_allowed
to /proc/sys/vm.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/hugetlb.h |    2 +
 mm/hugetlb.c            |   86 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 88 insertions(+)

Index: linux-2.6.30-rc8-mmotm-090603-1633/include/linux/hugetlb.h
===================================================================
--- linux-2.6.30-rc8-mmotm-090603-1633.orig/include/linux/hugetlb.h	2009-06-04 12:59:31.000000000 -0400
+++ linux-2.6.30-rc8-mmotm-090603-1633/include/linux/hugetlb.h	2009-06-04 12:59:32.000000000 -0400
@@ -193,6 +193,8 @@ struct hstate {
 	unsigned long resv_huge_pages;
 	unsigned long surplus_huge_pages;
 	unsigned long nr_overcommit_huge_pages;
+	nodemask_t *nodes_allowed;
+	nodemask_t __nodes_allowed;
 	struct list_head hugepage_freelists[MAX_NUMNODES];
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
Index: linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c
===================================================================
--- linux-2.6.30-rc8-mmotm-090603-1633.orig/mm/hugetlb.c	2009-06-04 12:59:31.000000000 -0400
+++ linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c	2009-06-04 12:59:32.000000000 -0400
@@ -40,6 +40,9 @@ __initdata LIST_HEAD(huge_boot_pages);
 static struct hstate * __initdata parsed_hstate;
 static unsigned long __initdata default_hstate_max_huge_pages;
 static unsigned long __initdata default_hstate_size;
+static struct hstate __initdata default_boot_hstate = {
+	.nodes_allowed = &node_online_map,
+};
 
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
@@ -1102,6 +1105,9 @@ static void __init hugetlb_init_hstates(
 	struct hstate *h;
 
 	for_each_hstate(h) {
+		if (!h->nodes_allowed)
+			h->nodes_allowed = &node_online_map;
+
 		/* oversize hugepages were init'ed in early boot */
 		if (h->order < MAX_ORDER)
 			hugetlb_hstate_alloc_pages(h);
@@ -1335,6 +1341,62 @@ static ssize_t nr_overcommit_hugepages_s
 }
 HSTATE_ATTR(nr_overcommit_hugepages);
 
+static ssize_t nodes_allowed_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = kobj_to_hstate(kobj);
+	int len = 3;
+
+	if (h->nodes_allowed == &node_online_map)
+		strcpy(buf, "all");
+	else
+		len = nodelist_scnprintf(buf, PAGE_SIZE,
+					*h->nodes_allowed);
+
+	if (len)
+		buf[len++] = '\n';
+
+	return len;
+}
+
+static int set_hstate_nodes_allowed(struct hstate *h, const char *buf,
+					bool lock)
+{
+	nodemask_t nodes_allowed;
+	int ret = 1;
+	bool all = !strncasecmp(buf, "all", 3);
+
+	if (!all)
+		ret = !nodelist_parse(buf, nodes_allowed);
+	if (ret) {
+		if (lock)
+			spin_lock(&hugetlb_lock);
+
+		if (all) {
+			h->nodes_allowed = &node_online_map;
+		} else {
+			h->__nodes_allowed = nodes_allowed;
+			h->nodes_allowed = &h->__nodes_allowed;
+		}
+
+		if (lock)
+			spin_unlock(&hugetlb_lock);
+	}
+	return ret;
+}
+
+static ssize_t nodes_allowed_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	struct hstate *h = kobj_to_hstate(kobj);
+
+	if (set_hstate_nodes_allowed(h, buf, 1))
+		return count;
+	else
+		return 0;
+}
+HSTATE_ATTR(nodes_allowed);
+
 static ssize_t free_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
@@ -1362,6 +1424,7 @@ HSTATE_ATTR_RO(surplus_hugepages);
 static struct attribute *hstate_attrs[] = {
 	&nr_hugepages_attr.attr,
 	&nr_overcommit_hugepages_attr.attr,
+	&nodes_allowed_attr.attr,
 	&free_hugepages_attr.attr,
 	&resv_hugepages_attr.attr,
 	&surplus_hugepages_attr.attr,
@@ -1436,6 +1499,13 @@ static int __init hugetlb_init(void)
 	if (default_hstate_max_huge_pages)
 		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
 
+	if (default_boot_hstate.nodes_allowed != &node_online_map) {
+		default_hstate.__nodes_allowed =
+					default_boot_hstate.__nodes_allowed;
+		default_hstate.nodes_allowed =
+					&default_hstate.__nodes_allowed;
+	}
+
 	hugetlb_init_hstates();
 
 	gather_bootmem_prealloc();
@@ -1471,6 +1541,7 @@ void __init hugetlb_add_hstate(unsigned 
 	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
 					huge_page_size(h)/1024);
 
+	h->nodes_allowed = &node_online_map;
 	parsed_hstate = h;
 }
 
@@ -1518,6 +1589,21 @@ static int __init hugetlb_default_setup(
 }
 __setup("default_hugepagesz=", hugetlb_default_setup);
 
+static int __init hugetlb_nodes_allowed_setup(char *s)
+{
+	struct hstate *h = &default_boot_hstate;
+
+	/*
+	 * max_hstate means we've parsed a hugepagesz= parameter, so
+	 * use the [most recently] parsed_hstate.  Else use default.
+	 */
+	if (max_hstate)
+		h = parsed_hstate;
+
+	return set_hstate_nodes_allowed(h, s, 0);
+}
+__setup("hugepages_nodes_allowed=", hugetlb_nodes_allowed_setup);
+
 static unsigned int cpuset_mems_nr(unsigned int *array)
 {
 	int node;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
