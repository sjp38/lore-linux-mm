Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 780306B003B
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 05:27:54 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so1619253pdj.14
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 02:27:54 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id pm3si10310881pbb.64.2014.06.16.02.27.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 02:27:53 -0700 (PDT)
Message-ID: <539EB7E2.9060805@huawei.com>
Date: Mon, 16 Jun 2014 17:24:50 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/8] mm: introduce cache_limit_ratio and cache_limit_mbytes
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>

This patch introduces two parameters cache_limit_ratio and cache_limit_mbytes.
They are used to limit page cache amount.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/swap.h |   10 ++++++++++
 kernel/sysctl.c      |   18 ++++++++++++++++++
 mm/page_alloc.c      |   39 +++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c          |   17 +++++++++++++++++
 4 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3507115..7e362d7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -353,6 +353,16 @@ extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
+extern unsigned long vm_cache_limit_ratio;
+extern unsigned long vm_cache_limit_ratio_min;
+extern unsigned long vm_cache_limit_ratio_max;
+extern unsigned long vm_cache_limit_mbytes;
+extern unsigned long vm_cache_limit_mbytes_min;
+extern unsigned long vm_cache_limit_mbytes_max;
+extern int cache_limit_ratio_sysctl_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *length, loff_t *ppos);
+extern int cache_limit_mbytes_sysctl_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *length, loff_t *ppos);
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 74f5b58..9bb6f38 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1272,6 +1272,24 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &one,
 		.extra2		= &four,
 	},
+	{
+		.procname	= "cache_limit_ratio",
+		.data		= &vm_cache_limit_ratio,
+		.maxlen		= sizeof(vm_cache_limit_ratio),
+		.mode		= 0644,
+		.proc_handler	= cache_limit_ratio_sysctl_handler,
+		.extra1		= &vm_cache_limit_ratio_min,
+		.extra2		= &vm_cache_limit_ratio_max,
+	},
+	{
+		.procname	= "cache_limit_mbytes",
+		.data		= &vm_cache_limit_mbytes,
+		.maxlen		= sizeof(vm_cache_limit_mbytes),
+		.mode		= 0644,
+		.proc_handler	= cache_limit_mbytes_sysctl_handler,
+		.extra1		= &vm_cache_limit_mbytes_min,
+		.extra2		= &vm_cache_limit_mbytes_max,
+	},
 #ifdef CONFIG_COMPACTION
 	{
 		.procname	= "compact_memory",
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..a9cc034 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5790,6 +5790,45 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
+int cache_limit_ratio_sysctl_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int ret;
+
+	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos);
+	if (ret)
+		return ret;
+	if (write) {
+		vm_cache_limit_mbytes = totalram_pages
+			* vm_cache_limit_ratio / 100
+			* PAGE_SIZE / (1024 * 1024UL);
+		if (vm_cache_limit_ratio)
+			printk(KERN_WARNING "cache limit set to %ld%\n",
+				vm_cache_limit_ratio);
+	}
+	return 0;
+}
+
+int cache_limit_mbytes_sysctl_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int ret;
+
+	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos);
+	if (ret)
+		return ret;
+	if (write) {
+		vm_cache_limit_ratio = (vm_cache_limit_mbytes
+			* ((1024 * 1024UL) / PAGE_SIZE)
+			+ totalram_pages / 200)
+			* 100 / totalram_pages;
+		if (vm_cache_limit_mbytes)
+			printk(KERN_WARNING "cache limit set to %ldMB\n",
+				vm_cache_limit_mbytes);
+	}
+	return 0;
+}
+
 #ifdef CONFIG_NUMA
 int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 32c661d..37ea902 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -131,6 +131,12 @@ struct scan_control {
  */
 int vm_swappiness = 60;
 unsigned long vm_total_pages;	/* The total number of pages which the VM controls */
+unsigned long vm_cache_limit_ratio;
+unsigned long vm_cache_limit_ratio_min;
+unsigned long vm_cache_limit_ratio_max;
+unsigned long vm_cache_limit_mbytes __read_mostly;
+unsigned long vm_cache_limit_mbytes_min;
+unsigned long vm_cache_limit_mbytes_max;
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
@@ -3373,6 +3379,16 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 }
 #endif /* CONFIG_HIBERNATION */
 
+static void shrink_page_cache_init(void)
+{
+	vm_cache_limit_ratio = 0;
+	vm_cache_limit_ratio_min = 0;
+	vm_cache_limit_ratio_max = 100;
+	vm_cache_limit_mbytes = 0;
+	vm_cache_limit_mbytes_min = 0;
+	vm_cache_limit_mbytes_max = totalram_pages;
+}
+
 /* It's optimal to keep kswapds on the same CPUs as their memory, but
    not required for correctness.  So if the last cpu in a node goes
    away, we get changed to run anywhere: as the first one comes back,
@@ -3442,6 +3458,7 @@ static int __init kswapd_init(void)
 	for_each_node_state(nid, N_MEMORY)
  		kswapd_run(nid);
 	hotcpu_notifier(cpu_callback, 0);
+	shrink_page_cache_init();
 	return 0;
 }
 
-- 
1.6.0.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
