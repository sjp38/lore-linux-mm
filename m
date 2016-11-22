Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7796B0261
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:26:26 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id x26so12415746qtb.6
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:26:26 -0800 (PST)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id y127si16834415qkd.149.2016.11.22.08.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:26:25 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH 3/5] migrate: Add copy_page_mt to use multi-threaded page migration.
Date: Tue, 22 Nov 2016 11:25:28 -0500
Message-Id: <20161122162530.2370-4-zi.yan@sent.com>
In-Reply-To: <20161122162530.2370-1-zi.yan@sent.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

From: Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <ziy@nvidia.com>

Internally, copy_page_mt splits a page into multiple threads
and send them as jobs to system_highpri_wq.

Signed-off-by: Zi Yan <ziy@nvidia.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 include/linux/highmem.h |  2 ++
 kernel/sysctl.c         |  1 +
 mm/Makefile             |  2 ++
 mm/copy_page.c          | 96 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 101 insertions(+)
 create mode 100644 mm/copy_page.c

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index bb3f329..519e575 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -236,6 +236,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
 
 #endif
 
+int copy_page_mt(struct page *to, struct page *from, int nr_pages);
+
 static inline void copy_highpage(struct page *to, struct page *from)
 {
 	char *vfrom, *vto;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 706309f..d54ce12 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -97,6 +97,7 @@
 
 #if defined(CONFIG_SYSCTL)
 
+
 /* External variables not in a header file. */
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
diff --git a/mm/Makefile b/mm/Makefile
index 295bd7a..467305b 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -41,6 +41,8 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 
 obj-y += init-mm.o
 
+obj-y += copy_page.o
+
 ifdef CONFIG_NO_BOOTMEM
 	obj-y		+= nobootmem.o
 else
diff --git a/mm/copy_page.c b/mm/copy_page.c
new file mode 100644
index 0000000..ca7ce6c
--- /dev/null
+++ b/mm/copy_page.c
@@ -0,0 +1,96 @@
+/*
+ * Parallel page copy routine.
+ *
+ * Zi Yan <ziy@nvidia.com>
+ *
+ */
+
+#include <linux/highmem.h>
+#include <linux/workqueue.h>
+#include <linux/slab.h>
+#include <linux/freezer.h>
+
+
+const unsigned int limit_mt_num = 4;
+
+/* ======================== multi-threaded copy page ======================== */
+
+struct copy_page_info {
+	struct work_struct copy_page_work;
+	char *to;
+	char *from;
+	unsigned long chunk_size;
+};
+
+static void copy_page_routine(char *vto, char *vfrom,
+	unsigned long chunk_size)
+{
+	memcpy(vto, vfrom, chunk_size);
+}
+
+static void copy_page_work_queue_thread(struct work_struct *work)
+{
+	struct copy_page_info *my_work = (struct copy_page_info *)work;
+
+	copy_page_routine(my_work->to,
+					  my_work->from,
+					  my_work->chunk_size);
+}
+
+int copy_page_mt(struct page *to, struct page *from, int nr_pages)
+{
+	unsigned int total_mt_num = limit_mt_num;
+	int to_node = page_to_nid(to);
+	int i;
+	struct copy_page_info *work_items;
+	char *vto, *vfrom;
+	unsigned long chunk_size;
+	const struct cpumask *per_node_cpumask = cpumask_of_node(to_node);
+	int cpu_id_list[32] = {0};
+	int cpu;
+
+	total_mt_num = min_t(unsigned int, total_mt_num,
+						 cpumask_weight(per_node_cpumask));
+	total_mt_num = (total_mt_num / 2) * 2;
+
+	work_items = kcalloc(total_mt_num, sizeof(struct copy_page_info),
+						 GFP_KERNEL);
+	if (!work_items)
+		return -ENOMEM;
+
+	i = 0;
+	for_each_cpu(cpu, per_node_cpumask) {
+		if (i >= total_mt_num)
+			break;
+		cpu_id_list[i] = cpu;
+		++i;
+	}
+
+	vfrom = kmap(from);
+	vto = kmap(to);
+	chunk_size = PAGE_SIZE*nr_pages / total_mt_num;
+
+	for (i = 0; i < total_mt_num; ++i) {
+		INIT_WORK((struct work_struct *)&work_items[i],
+				  copy_page_work_queue_thread);
+
+		work_items[i].to = vto + i * chunk_size;
+		work_items[i].from = vfrom + i * chunk_size;
+		work_items[i].chunk_size = chunk_size;
+
+		queue_work_on(cpu_id_list[i],
+					  system_highpri_wq,
+					  (struct work_struct *)&work_items[i]);
+	}
+
+	/* Wait until it finishes  */
+	for (i = 0; i < total_mt_num; ++i)
+		flush_work((struct work_struct *)&work_items[i]);
+
+	kunmap(to);
+	kunmap(from);
+
+	kfree(work_items);
+
+	return 0;
+}
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
