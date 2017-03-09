Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 943E76B042F
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 01:26:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 67so96346993pfg.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:26:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 2si5522995pgi.1.2017.03.08.22.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 22:26:36 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v296JGUX119600
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 01:26:36 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 292h0m5ccm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:26:36 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Mar 2017 16:26:29 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v296QHO450790514
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 17:26:25 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v296PpZ6024789
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 17:25:51 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 3/6] mm/migrate: Add copy_pages_mthread function
Date: Thu,  9 Mar 2017 11:55:32 +0530
In-Reply-To: <20170217112453.307-4-khandual@linux.vnet.ibm.com>
References: <20170217112453.307-4-khandual@linux.vnet.ibm.com>
Message-Id: <20170309062532.30913-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

This change adds a new function copy_pages_mthread to enable multi threaded
page copy which can be utilized during migration. This function splits the
page copy request into multiple threads which will handle individual chunk
and send them as jobs to system_highpri_wq work queue.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
* Updated cthread calculations, taking care of divide by zero issues,
  picking up the right single thread, defining NR_COPYTHREADS, fixing
  the build problem on i386 etc.

 include/linux/highmem.h |  2 ++
 mm/Makefile             |  2 ++
 mm/copy_pages_mthread.c | 95 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 99 insertions(+)
 create mode 100644 mm/copy_pages_mthread.c

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index bb3f329..e1f4f1b 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -236,6 +236,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
 
 #endif
 
+int copy_pages_mthread(struct page *to, struct page *from, int nr_pages);
+
 static inline void copy_highpage(struct page *to, struct page *from)
 {
 	char *vfrom, *vto;
diff --git a/mm/Makefile b/mm/Makefile
index 295bd7a..cc27e76 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -41,6 +41,8 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 
 obj-y += init-mm.o
 
+obj-y += copy_pages_mthread.o
+
 ifdef CONFIG_NO_BOOTMEM
 	obj-y		+= nobootmem.o
 else
diff --git a/mm/copy_pages_mthread.c b/mm/copy_pages_mthread.c
new file mode 100644
index 0000000..5af861c
--- /dev/null
+++ b/mm/copy_pages_mthread.c
@@ -0,0 +1,95 @@
+/*
+ * This implements parallel page copy function through multi
+ * threaded work queues.
+ *
+ * Copyright (C) Zi Yan <ziy@nvidia.com>, Nov 2016
+ *
+ * Licensed under the terms of the GNU GPL, version 2.
+ */
+#include <linux/highmem.h>
+#include <linux/workqueue.h>
+#include <linux/slab.h>
+#include <linux/freezer.h>
+
+/*
+ * NR_COPYTHREADS can be the highest number of threads for given
+ * node on any architecture. The actual number of copy threads
+ * will be limited by the cpumask weight of the target node.
+ */
+#define NR_COPYTHREADS 8
+
+struct copy_info {
+	struct work_struct copy_work;
+	char *to;
+	char *from;
+	unsigned long chunk_size;
+};
+
+static void copy_pages(char *vto, char *vfrom, unsigned long size)
+{
+	memcpy(vto, vfrom, size);
+}
+
+static void copythread(struct work_struct *work)
+{
+	struct copy_info *info = (struct copy_info *) work;
+
+	copy_pages(info->to, info->from, info->chunk_size);
+}
+
+int copy_pages_mthread(struct page *to, struct page *from, int nr_pages)
+{
+	struct cpumask *cpumask;
+	struct copy_info *work_items;
+	char *vto, *vfrom;
+	unsigned long i, cthreads, cpu, node, chunk_size;
+	int cpu_id_list[NR_COPYTHREADS] = {0};
+
+	node = page_to_nid(to);
+	cpumask = (struct cpumask *) cpumask_of_node(node);
+	cthreads = min_t(unsigned int, NR_COPYTHREADS, cpumask_weight(cpumask));
+	cthreads = (cthreads / 2) * 2;
+	if (!cthreads)
+		cthreads = 1;
+
+	work_items = kcalloc(cthreads, sizeof(struct copy_info), GFP_KERNEL);
+	if (!work_items)
+		return -ENOMEM;
+
+	/*
+	 * XXX: On a memory-only CPU-less NUMA node it will
+	 * just fallback using cpu[0] in a single threaded
+	 * manner to do the page copy. On single CPU target
+	 * node that CPU will be used for the page copy.
+	 */
+	i = 0;
+	for_each_cpu(cpu, cpumask) {
+		if (i >= cthreads)
+			break;
+		cpu_id_list[i] = cpu;
+		++i;
+	}
+
+	vfrom = kmap(from);
+	vto = kmap(to);
+	chunk_size = PAGE_SIZE * nr_pages / cthreads;
+
+	for (i = 0; i < cthreads; ++i) {
+		INIT_WORK((struct work_struct *) &work_items[i], copythread);
+
+		work_items[i].to = vto + i * chunk_size;
+		work_items[i].from = vfrom + i * chunk_size;
+		work_items[i].chunk_size = chunk_size;
+
+		queue_work_on(cpu_id_list[i], system_highpri_wq,
+					(struct work_struct *) &work_items[i]);
+	}
+
+	for (i = 0; i < cthreads; ++i)
+		flush_work((struct work_struct *) &work_items[i]);
+
+	kunmap(to);
+	kunmap(from);
+	kfree(work_items);
+	return 0;
+}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
