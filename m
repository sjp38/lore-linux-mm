Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E3A676B0039
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 05:27:53 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so3721432pab.32
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 02:27:53 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id ye4si10305989pbb.103.2014.06.16.02.27.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 02:27:53 -0700 (PDT)
Message-ID: <539EB7F5.9090201@huawei.com>
Date: Mon, 16 Jun 2014 17:25:09 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 6/8] mm: introduce cache_reclaim_weight
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>

This patch introduces a parameters cache_reclaim_weight. It is used to
speed up page cache reclaim.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/swap.h |    3 +++
 kernel/sysctl.c      |    9 +++++++++
 mm/vmscan.c          |    6 ++++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index bd85493..db912b2 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -361,6 +361,9 @@ extern unsigned long vm_cache_limit_mbytes_min;
 extern unsigned long vm_cache_limit_mbytes_max;
 extern unsigned long vm_cache_reclaim_s;
 extern unsigned long vm_cache_reclaim_s_min;
+extern unsigned long vm_cache_reclaim_weight;
+extern unsigned long vm_cache_reclaim_weight_min;
+extern unsigned long vm_cache_reclaim_weight_max;
 extern int cache_limit_ratio_sysctl_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
 extern int cache_limit_mbytes_sysctl_handler(struct ctl_table *table, int write,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index a8a09c4..452e0d3 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1298,6 +1298,15 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_doulongvec_minmax,
 		.extra1		= &vm_cache_reclaim_s_min,
 	},
+	{
+		.procname	= "cache_reclaim_weight",
+		.data		= &vm_cache_reclaim_weight,
+		.maxlen		= sizeof(vm_cache_reclaim_weight),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1		= &vm_cache_reclaim_weight_min,
+		.extra2		= &vm_cache_reclaim_weight_max,
+	},
 #ifdef CONFIG_COMPACTION
 	{
 		.procname	= "compact_memory",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d7f866e..d179be6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -139,6 +139,9 @@ unsigned long vm_cache_limit_mbytes_min;
 unsigned long vm_cache_limit_mbytes_max;
 unsigned long vm_cache_reclaim_s __read_mostly;
 unsigned long vm_cache_reclaim_s_min;
+unsigned long vm_cache_reclaim_weight __read_mostly;
+unsigned long vm_cache_reclaim_weight_min;
+unsigned long vm_cache_reclaim_weight_max;
 
 static DEFINE_PER_CPU(struct delayed_work, vmscan_work);
 static LIST_HEAD(shrinker_list);
@@ -3410,6 +3413,9 @@ static void shrink_page_cache_init(void)
 	vm_cache_limit_mbytes_max = totalram_pages;
 	vm_cache_reclaim_s = 0;
 	vm_cache_reclaim_s_min = 0;
+	vm_cache_reclaim_weight = 1;
+	vm_cache_reclaim_weight_min = 1;
+	vm_cache_reclaim_weight_max = 100;
 
 	for_each_online_cpu(cpu) {
 		struct delayed_work *work = &per_cpu(vmscan_work, cpu);
-- 
1.6.0.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
