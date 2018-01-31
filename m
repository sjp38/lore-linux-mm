Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F73A6B0007
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:28 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 34so11194911uaq.11
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:28 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i6si1060116vkb.368.2018.01.31.15.04.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:27 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 01/13] mm: add a percpu_pagelist_batch sysctl interface
Date: Wed, 31 Jan 2018 18:04:01 -0500
Message-Id: <20180131230413.27653-2-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

From: Aaron Lu <aaron.lu@intel.com>

---
 include/linux/mmzone.h |  2 ++
 kernel/sysctl.c        |  9 +++++++++
 mm/page_alloc.c        | 40 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 50 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 67f2e3c38939..c05529473b80 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -891,6 +891,8 @@ int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int percpu_pagelist_batch_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 557d46728577..1602bc14bf0d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -108,6 +108,7 @@ extern unsigned int core_pipe_limit;
 extern int pid_max;
 extern int pid_max_min, pid_max_max;
 extern int percpu_pagelist_fraction;
+extern int percpu_pagelist_batch;
 extern int latencytop_enabled;
 extern unsigned int sysctl_nr_open_min, sysctl_nr_open_max;
 #ifndef CONFIG_MMU
@@ -1458,6 +1459,14 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= percpu_pagelist_fraction_sysctl_handler,
 		.extra1		= &zero,
 	},
+	{
+		.procname	= "percpu_pagelist_batch",
+		.data		= &percpu_pagelist_batch,
+		.maxlen		= sizeof(percpu_pagelist_batch),
+		.mode		= 0644,
+		.proc_handler	= percpu_pagelist_batch_sysctl_handler,
+		.extra1		= &zero,
+	},
 #ifdef CONFIG_MMU
 	{
 		.procname	= "max_map_count",
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76c9688b6a0a..d7078ed68b01 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -130,6 +130,7 @@ unsigned long totalreserve_pages __read_mostly;
 unsigned long totalcma_pages __read_mostly;
 
 int percpu_pagelist_fraction;
+int percpu_pagelist_batch;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
 /*
@@ -5544,7 +5545,8 @@ static void pageset_set_high_and_batch(struct zone *zone,
 			(zone->managed_pages /
 				percpu_pagelist_fraction));
 	else
-		pageset_set_batch(pcp, zone_batchsize(zone));
+		pageset_set_batch(pcp, percpu_pagelist_batch ?
+				percpu_pagelist_batch : zone_batchsize(zone));
 }
 
 static void __meminit zone_pageset_init(struct zone *zone, int cpu)
@@ -7266,6 +7268,42 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
 	return ret;
 }
 
+int percpu_pagelist_batch_sysctl_handler(struct ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	struct zone *zone;
+	int old_percpu_pagelist_batch;
+	int ret;
+
+	mutex_lock(&pcp_batch_high_lock);
+	old_percpu_pagelist_batch = percpu_pagelist_batch;
+
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (!write || ret < 0)
+		goto out;
+
+	/* Sanity checking to avoid pcp imbalance */
+	if (percpu_pagelist_batch <= 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* No change? */
+	if (percpu_pagelist_batch == old_percpu_pagelist_batch)
+		goto out;
+
+	for_each_populated_zone(zone) {
+		unsigned int cpu;
+
+		for_each_possible_cpu(cpu)
+			pageset_set_high_and_batch(zone,
+					per_cpu_ptr(zone->pageset, cpu));
+	}
+out:
+	mutex_unlock(&pcp_batch_high_lock);
+	return ret;
+}
+
 #ifdef CONFIG_NUMA
 int hashdist = HASHDIST_DEFAULT;
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
