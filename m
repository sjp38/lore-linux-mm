Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8A8616B0083
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:16:56 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 09:14:32 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q219BEQ93616808
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:11:14 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q219GitV003864
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:16:44 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 1/9] mm:  move hugetlbfs region tracking function to common code
Date: Thu,  1 Mar 2012 14:46:12 +0530
Message-Id: <1330593380-1361-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch moves the hugetlbfs region tracking function to
common code. We will be using this in later patches in the
series.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/region.h |   28 +++++++++
 mm/Makefile            |    2 +-
 mm/region.c            |  158 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 187 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/region.h
 create mode 100644 mm/region.c

diff --git a/include/linux/region.h b/include/linux/region.h
new file mode 100644
index 0000000..a8a5b46
--- /dev/null
+++ b/include/linux/region.h
@@ -0,0 +1,28 @@
+/*
+ * Copyright IBM Corporation, 2012
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2.1 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+#ifndef _LINUX_REGION_H
+#define _LINUX_REGION_H
+
+struct file_region {
+	struct list_head link;
+	long from;
+	long to;
+};
+
+extern long region_add(struct list_head *head, long from, long to);
+extern long region_chg(struct list_head *head, long from, long to);
+extern long region_truncate(struct list_head *head, long end);
+extern long region_count(struct list_head *head, long from, long to);
+#endif
diff --git a/mm/Makefile b/mm/Makefile
index 50ec00e..8828a1b 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -14,7 +14,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   page_isolation.o mm_init.o mmu_context.o percpu.o \
 			   $(mmu-y)
-obj-y += init-mm.o
+obj-y += init-mm.o region.o
 
 ifdef CONFIG_NO_BOOTMEM
 	obj-y		+= nobootmem.o
diff --git a/mm/region.c b/mm/region.c
new file mode 100644
index 0000000..ab59fe7
--- /dev/null
+++ b/mm/region.c
@@ -0,0 +1,158 @@
+/*
+ * Copyright IBM Corporation, 2012
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2.1 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+#include <linux/cgroup.h>
+#include <linux/slab.h>
+#include <linux/hugetlb.h>
+#include <linux/list.h>
+#include <linux/region.h>
+
+long region_add(struct list_head *head, long from, long to)
+{
+	struct file_region *rg, *nrg, *trg;
+
+	/* Locate the region we are either in or before. */
+	list_for_each_entry(rg, head, link)
+		if (from <= rg->to)
+			break;
+
+	/* Round our left edge to the current segment if it encloses us. */
+	if (from > rg->from)
+		from = rg->from;
+
+	/* Check for and consume any regions we now overlap with. */
+	nrg = rg;
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		if (rg->from > to)
+			break;
+
+		/* If this area reaches higher then extend our area to
+		 * include it completely.  If this is not the first area
+		 * which we intend to reuse, free it. */
+		if (rg->to > to)
+			to = rg->to;
+		if (rg != nrg) {
+			list_del(&rg->link);
+			kfree(rg);
+		}
+	}
+	nrg->from = from;
+	nrg->to = to;
+	return 0;
+}
+
+long region_chg(struct list_head *head, long from, long to)
+{
+	struct file_region *rg, *nrg;
+	long chg = 0;
+
+	/* Locate the region we are before or in. */
+	list_for_each_entry(rg, head, link)
+		if (from <= rg->to)
+			break;
+
+	/* If we are below the current region then a new region is required.
+	 * Subtle, allocate a new region at the position but make it zero
+	 * size such that we can guarantee to record the reservation. */
+	if (&rg->link == head || to < rg->from) {
+		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+		if (!nrg)
+			return -ENOMEM;
+		nrg->from = from;
+		nrg->to   = from;
+		INIT_LIST_HEAD(&nrg->link);
+		list_add(&nrg->link, rg->link.prev);
+
+		return to - from;
+	}
+
+	/* Round our left edge to the current segment if it encloses us. */
+	if (from > rg->from)
+		from = rg->from;
+	chg = to - from;
+
+	/* Check for and consume any regions we now overlap with. */
+	list_for_each_entry(rg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		if (rg->from > to)
+			return chg;
+
+		/* We overlap with this area, if it extends further than
+		 * us then we must extend ourselves.  Account for its
+		 * existing reservation. */
+		if (rg->to > to) {
+			chg += rg->to - to;
+			to = rg->to;
+		}
+		chg -= rg->to - rg->from;
+	}
+	return chg;
+}
+
+long region_truncate(struct list_head *head, long end)
+{
+	struct file_region *rg, *trg;
+	long chg = 0;
+
+	/* Locate the region we are either in or before. */
+	list_for_each_entry(rg, head, link)
+		if (end <= rg->to)
+			break;
+	if (&rg->link == head)
+		return 0;
+
+	/* If we are in the middle of a region then adjust it. */
+	if (end > rg->from) {
+		chg = rg->to - end;
+		rg->to = end;
+		rg = list_entry(rg->link.next, typeof(*rg), link);
+	}
+
+	/* Drop any remaining regions. */
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		chg += rg->to - rg->from;
+		list_del(&rg->link);
+		kfree(rg);
+	}
+	return chg;
+}
+
+long region_count(struct list_head *head, long from, long to)
+{
+	struct file_region *rg;
+	long chg = 0;
+
+	/* Locate each segment we overlap with, and count that overlap. */
+	list_for_each_entry(rg, head, link) {
+		int seg_from;
+		int seg_to;
+
+		if (rg->to <= from)
+			continue;
+		if (rg->from >= to)
+			break;
+
+		seg_from = max(rg->from, from);
+		seg_to = min(rg->to, to);
+
+		chg += seg_to - seg_from;
+	}
+
+	return chg;
+}
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
