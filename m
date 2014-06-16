Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 37DE36B003B
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 05:27:54 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id ma3so4018045pbc.15
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 02:27:53 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id fv4si10272328pbb.224.2014.06.16.02.27.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 02:27:53 -0700 (PDT)
Message-ID: <539EB7EE.3050502@huawei.com>
Date: Mon, 16 Jun 2014 17:25:02 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 4/8] mm: introduce cache_reclaim_s
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>

This patch introduces a parameters cache_reclaim_s. It is used to reclaim
page cache in circles.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/swap.h |    2 ++
 kernel/sysctl.c      |    8 ++++++++
 mm/vmscan.c          |    4 ++++
 3 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index dcbe1a3..bd85493 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -359,6 +359,8 @@ extern unsigned long vm_cache_limit_ratio_max;
 extern unsigned long vm_cache_limit_mbytes;
 extern unsigned long vm_cache_limit_mbytes_min;
 extern unsigned long vm_cache_limit_mbytes_max;
+extern unsigned long vm_cache_reclaim_s;
+extern unsigned long vm_cache_reclaim_s_min;
 extern int cache_limit_ratio_sysctl_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
 extern int cache_limit_mbytes_sysctl_handler(struct ctl_table *table, int write,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9bb6f38..a8a09c4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1290,6 +1290,14 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &vm_cache_limit_mbytes_min,
 		.extra2		= &vm_cache_limit_mbytes_max,
 	},
+	{
+		.procname	= "cache_reclaim_s",
+		.data		= &vm_cache_reclaim_s,
+		.maxlen		= sizeof(vm_cache_reclaim_s),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1		= &vm_cache_reclaim_s_min,
+	},
 #ifdef CONFIG_COMPACTION
 	{
 		.procname	= "compact_memory",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 707d3e3..61cedfc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -137,6 +137,8 @@ unsigned long vm_cache_limit_ratio_max;
 unsigned long vm_cache_limit_mbytes __read_mostly;
 unsigned long vm_cache_limit_mbytes_min;
 unsigned long vm_cache_limit_mbytes_max;
+unsigned long vm_cache_reclaim_s __read_mostly;
+unsigned long vm_cache_reclaim_s_min;
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
@@ -3390,6 +3392,8 @@ static void shrink_page_cache_init(void)
 	vm_cache_limit_mbytes = 0;
 	vm_cache_limit_mbytes_min = 0;
 	vm_cache_limit_mbytes_max = totalram_pages;
+	vm_cache_reclaim_s = 0;
+	vm_cache_reclaim_s_min = 0;
 }
 
 static unsigned long __shrink_page_cache(gfp_t mask)
-- 
1.6.0.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
