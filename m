Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 071AB4405EF
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:09 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h56so38564849qtc.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:09 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id h32si7661749qth.4.2017.02.17.07.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:08 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 03/14] mm/migrate: Add copy_pages_mthread function
Date: Fri, 17 Feb 2017 10:05:40 -0500
Message-Id: <20170217150551.117028-4-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

This change adds a new function copy_pages_mthread to enable multi threaded
page copy which can be utilized during migration. This function splits the
page copy request into multiple threads which will handle individual chunk
and send them as jobs to system_highpri_wq work queue.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/highmem.h |  2 ++
 mm/Makefile             |  2 ++
 mm/copy_pages.c         | 86 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 90 insertions(+)
 create mode 100644 mm/copy_pages.c

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index bb3f3297062a..e1f4f1b82812 100644
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
index aa0aa17cb413..cdd4bab9cc66 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -43,6 +43,8 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 
 obj-y += init-mm.o
 
+obj-y += copy_pages.o
+
 ifdef CONFIG_NO_BOOTMEM
 	obj-y		+= nobootmem.o
 else
diff --git a/mm/copy_pages.c b/mm/copy_pages.c
new file mode 100644
index 000000000000..c357e7b01042
--- /dev/null
+++ b/mm/copy_pages.c
@@ -0,0 +1,86 @@
+/*
+ * This implements parallel page copy function through multi threaded
+ * work queues.
+ *
+ * Zi Yan <ziy@nvidia.com>
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ */
+#include <linux/highmem.h>
+#include <linux/workqueue.h>
+#include <linux/slab.h>
+#include <linux/freezer.h>
+
+/*
+ * nr_copythreads can be the highest number of threads for given node
+ * on any architecture. The actual number of copy threads will be
+ * limited by the cpumask weight of the target node.
+ */
+unsigned int nr_copythreads = 8;
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
+	unsigned int node = page_to_nid(to);
+	const struct cpumask *cpumask = cpumask_of_node(node);
+	struct copy_info *work_items;
+	char *vto, *vfrom;
+	unsigned long i, cthreads, cpu, chunk_size;
+	int cpu_id_list[32] = {0};
+
+	cthreads = nr_copythreads;
+	cthreads = min_t(unsigned int, cthreads, cpumask_weight(cpumask));
+	cthreads = (cthreads / 2) * 2;
+	work_items = kcalloc(cthreads, sizeof(struct copy_info), GFP_KERNEL);
+	if (!work_items)
+		return -ENOMEM;
+
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
+					  (struct work_struct *) &work_items[i]);
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
