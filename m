Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAA784405F6
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:09 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id p22so38559469qka.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:09 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id a64si7630320qkf.331.2017.02.17.07.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:09 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 07/14] migrate: Add copy_page_lists_mthread() function.
Date: Fri, 17 Feb 2017 10:05:44 -0500
Message-Id: <20170217150551.117028-8-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

It supports copying a list of pages via multi-threaded process.
It evenly distributes a list of pages to a group of threads and
uses the same subroutine as copy_page_mthread()

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/copy_pages.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h   |  3 +++
 2 files changed, 65 insertions(+)

diff --git a/mm/copy_pages.c b/mm/copy_pages.c
index c357e7b01042..516c0a1a57f3 100644
--- a/mm/copy_pages.c
+++ b/mm/copy_pages.c
@@ -84,3 +84,65 @@ int copy_pages_mthread(struct page *to, struct page *from, int nr_pages)
 	kfree(work_items);
 	return 0;
 }
+
+int copy_page_lists_mthread(struct page **to, struct page **from, int nr_pages) 
+{
+	int err = 0;
+	unsigned int cthreads, node = page_to_nid(*to);
+	int i;
+	struct copy_info *work_items;
+	int nr_pages_per_page = hpage_nr_pages(*from);
+	const struct cpumask *cpumask = cpumask_of_node(node);
+	int cpu_id_list[32] = {0};
+	int cpu;
+
+	cthreads = nr_copythreads;
+	cthreads = min_t(unsigned int, cthreads, cpumask_weight(cpumask));
+	cthreads = (cthreads / 2) * 2;
+	cthreads = min_t(unsigned int, nr_pages, cthreads);
+
+	work_items = kzalloc(sizeof(struct copy_info)*nr_pages,
+						 GFP_KERNEL);
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
+	for (i = 0; i < nr_pages; ++i) {
+		int thread_idx = i % cthreads;
+
+		INIT_WORK((struct work_struct *)&work_items[i], 
+				  copythread);
+
+		work_items[i].to = kmap(to[i]);
+		work_items[i].from = kmap(from[i]);
+		work_items[i].chunk_size = PAGE_SIZE * hpage_nr_pages(from[i]);
+
+		BUG_ON(nr_pages_per_page != hpage_nr_pages(from[i]));
+		BUG_ON(nr_pages_per_page != hpage_nr_pages(to[i]));
+
+
+		queue_work_on(cpu_id_list[thread_idx], 
+					  system_highpri_wq, 
+					  (struct work_struct *)&work_items[i]);
+	}
+
+	/* Wait until it finishes  */
+	for (i = 0; i < cthreads; ++i)
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
index ccfc2a2969f4..175e08ed524a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -498,4 +498,7 @@ extern const struct trace_print_flags pageflag_names[];
 extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
+extern int copy_page_lists_mthread(struct page **to,
+			struct page **from, int nr_pages);
+
 #endif	/* __MM_INTERNAL_H */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
