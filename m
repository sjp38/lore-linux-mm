Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 70CB06B003C
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 05:28:17 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so841791pad.26
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 02:28:17 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id uq10si13071384pac.1.2014.06.16.02.28.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 02:28:16 -0700 (PDT)
Message-ID: <539EB7F1.7080302@huawei.com>
Date: Mon, 16 Jun 2014 17:25:05 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 5/8] mm: implement page cache reclaim in circles
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>

Create a work on each online cpu, and schedule it in circles to reclaim
page cache.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/vmscan.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 61cedfc..d7f866e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -140,6 +140,7 @@ unsigned long vm_cache_limit_mbytes_max;
 unsigned long vm_cache_reclaim_s __read_mostly;
 unsigned long vm_cache_reclaim_s_min;
 
+static DEFINE_PER_CPU(struct delayed_work, vmscan_work);
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
@@ -3384,8 +3385,23 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 }
 #endif /* CONFIG_HIBERNATION */
 
+static void shrink_page_cache_work(struct work_struct *w)
+{
+	struct delayed_work *work = to_delayed_work(w);
+
+	if (vm_cache_reclaim_s == 0) {
+		schedule_delayed_work(work, round_jiffies_relative(120 * HZ));
+		return;
+	}
+
+	shrink_page_cache(GFP_KERNEL);
+	schedule_delayed_work(work, round_jiffies_relative(vm_cache_reclaim_s * HZ));
+}
+
 static void shrink_page_cache_init(void)
 {
+	int cpu;
+
 	vm_cache_limit_ratio = 0;
 	vm_cache_limit_ratio_min = 0;
 	vm_cache_limit_ratio_max = 100;
@@ -3394,6 +3410,13 @@ static void shrink_page_cache_init(void)
 	vm_cache_limit_mbytes_max = totalram_pages;
 	vm_cache_reclaim_s = 0;
 	vm_cache_reclaim_s_min = 0;
+
+	for_each_online_cpu(cpu) {
+		struct delayed_work *work = &per_cpu(vmscan_work, cpu);
+		INIT_DEFERRABLE_WORK(work, shrink_page_cache_work);
+		schedule_delayed_work_on(cpu, work,
+			__round_jiffies_relative(vm_cache_reclaim_s * HZ, cpu));
+	}
 }
 
 static unsigned long __shrink_page_cache(gfp_t mask)
@@ -3428,6 +3451,8 @@ static int cpu_callback(struct notifier_block *nfb, unsigned long action,
 			void *hcpu)
 {
 	int nid;
+	long cpu = (long)hcpu;
+	struct delayed_work *work = &per_cpu(vmscan_work, cpu);
 
 	if (action == CPU_ONLINE || action == CPU_ONLINE_FROZEN) {
 		for_each_node_state(nid, N_MEMORY) {
@@ -3441,6 +3466,22 @@ static int cpu_callback(struct notifier_block *nfb, unsigned long action,
 				set_cpus_allowed_ptr(pgdat->kswapd, mask);
 		}
 	}
+
+	switch (action) {
+	case CPU_ONLINE:
+		if (work->work.func == NULL)
+			INIT_DEFERRABLE_WORK(work, shrink_page_cache_work);
+		schedule_delayed_work_on(cpu, work,
+			__round_jiffies_relative(vm_cache_reclaim_s * HZ, cpu));
+		break;
+	case CPU_DOWN_PREPARE:
+		cancel_delayed_work_sync(work);
+		work->work.func = NULL;
+		break;
+	default:
+		break;
+	}
+
 	return NOTIFY_OK;
 }
 
-- 
1.6.0.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
