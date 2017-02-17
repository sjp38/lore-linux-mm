Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78A3A4405FA
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:10 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h53so38299274qth.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:10 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id z88si7664802qtd.90.2017.02.17.07.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:09 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 09/14] mm: migrate: Add exchange_page_mthread() and exchange_page_lists_mthread() to exchange two pages or two page lists.
Date: Fri, 17 Feb 2017 10:05:46 -0500
Message-Id: <20170217150551.117028-10-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

When some pages are going to migrated into a full memory node, instead
of two-step migrate_pages(), we use exchange_page_mthread() to exchange
two pages. This can save two unnecessary page allocations.

Current implmentation only supports anonymous pages.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/copy_pages.c | 133 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h   |   5 +++
 2 files changed, 138 insertions(+)

diff --git a/mm/copy_pages.c b/mm/copy_pages.c
index 516c0a1a57f3..879e2d944ad0 100644
--- a/mm/copy_pages.c
+++ b/mm/copy_pages.c
@@ -146,3 +146,136 @@ int copy_page_lists_mthread(struct page **to, struct page **from, int nr_pages)
 
 	return err;
 }
+static void exchange_page_routine(char *to, char *from, unsigned long chunk_size)
+{
+	u64 tmp;
+	int i;
+
+	for (i = 0; i < chunk_size; i += sizeof(tmp)) {
+		tmp = *((u64*)(from + i));
+		*((u64*)(from + i)) = *((u64*)(to + i));
+		*((u64*)(to + i)) = tmp;
+	}
+}
+
+static void exchange_page_work_queue_thread(struct work_struct *work)
+{
+	struct copy_info *my_work = (struct copy_info*)work;
+
+	exchange_page_routine(my_work->to,
+					  my_work->from,
+					  my_work->chunk_size);
+}
+
+int exchange_page_mthread(struct page *to, struct page *from, int nr_pages)
+{
+	int total_mt_num = nr_copythreads;
+	int to_node = page_to_nid(to);
+	int i;
+	struct copy_info *work_items;
+	char *vto, *vfrom;
+	unsigned long chunk_size;
+	const struct cpumask *per_node_cpumask = cpumask_of_node(to_node);
+	int cpu_id_list[32] = {0};
+	int cpu;
+
+	work_items = kzalloc(sizeof(struct copy_info)*total_mt_num,
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
+				exchange_page_work_queue_thread);
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
+		flush_work((struct work_struct *) &work_items[i]);
+
+	kunmap(to);
+	kunmap(from);
+
+	kfree(work_items);
+
+	return 0;
+}
+
+int exchange_page_lists_mthread(struct page **to, struct page **from,
+		int nr_pages)
+{
+	int err = 0;
+	int total_mt_num = nr_copythreads;
+	int to_node = page_to_nid(*to);
+	int i;
+	struct copy_info *work_items;
+	int nr_pages_per_page = hpage_nr_pages(*from);
+	const struct cpumask *per_node_cpumask = cpumask_of_node(to_node);
+	int cpu_id_list[32] = {0};
+	int cpu;
+
+	work_items = kzalloc(sizeof(struct copy_info)*nr_pages,
+						 GFP_KERNEL);
+	if (!work_items)
+		return -ENOMEM;
+
+	total_mt_num = min_t(int, nr_pages, total_mt_num);
+
+	i = 0;
+	for_each_cpu(cpu, per_node_cpumask) {
+		if (i >= total_mt_num)
+			break;
+		cpu_id_list[i] = cpu;
+		++i;
+	}
+
+	for (i = 0; i < nr_pages; ++i) {
+		int thread_idx = i % total_mt_num;
+
+		INIT_WORK((struct work_struct *)&work_items[i],
+				exchange_page_work_queue_thread);
+
+		work_items[i].to = kmap(to[i]);
+		work_items[i].from = kmap(from[i]);
+		work_items[i].chunk_size = PAGE_SIZE * hpage_nr_pages(from[i]);
+
+		BUG_ON(nr_pages_per_page != hpage_nr_pages(from[i]));
+		BUG_ON(nr_pages_per_page != hpage_nr_pages(to[i]));
+
+
+		queue_work_on(cpu_id_list[thread_idx], system_highpri_wq, (struct work_struct *)&work_items[i]);
+	}
+
+	/* Wait until it finishes  */
+	for (i = 0; i < total_mt_num; ++i)
+		flush_work((struct work_struct *) &work_items[i]);
+
+	for (i = 0; i < nr_pages; ++i) {
+			kunmap(to[i]);
+			kunmap(from[i]);
+	}
+
+	kfree(work_items);
+
+	return err;
+}
diff --git a/mm/internal.h b/mm/internal.h
index 175e08ed524a..b99a634b4d09 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -501,4 +501,9 @@ extern const struct trace_print_flags gfpflag_names[];
 extern int copy_page_lists_mthread(struct page **to,
 			struct page **from, int nr_pages);
 
+extern int exchange_page_mthread(struct page *to, struct page *from,
+			int nr_pages);
+extern int exchange_page_lists_mthread(struct page **to,
+						  struct page **from, 
+						  int nr_pages);
 #endif	/* __MM_INTERNAL_H */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
