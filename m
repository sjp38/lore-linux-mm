Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id ACFF06B0081
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:45:46 -0400 (EDT)
Received: by mail-pz0-f49.google.com with SMTP id q36so2826975dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:45:46 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 10/14] mm,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:33 +0200
Message-Id: <1335681937-3715-10-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, ebiederm@xmission.com, akpm@linux-foundation.org, tglx@linutronix.de
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Simplify sysctl handler by removing user input checks and using the callback
provided by the sysctl table.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/mmzone.h    |   15 ++++---------
 include/linux/writeback.h |   19 ++++-------------
 kernel/sysctl.c           |   30 ++++++++++++++++++---------
 mm/page-writeback.c       |   48 ++++++++++++--------------------------------
 mm/page_alloc.c           |   37 ++++++----------------------------
 5 files changed, 50 insertions(+), 99 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5c4880b..52fc184 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -824,17 +824,12 @@ static inline int is_dma(struct zone *zone)
 
 /* These two functions are used to setup the per zone pages min values */
 struct ctl_table;
-int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
+int min_free_kbytes_sysctl_handler(void);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
-int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
-int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
-int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
-			void __user *, size_t *, loff_t *);
-int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
-			void __user *, size_t *, loff_t *);
+int lowmem_reserve_ratio_sysctl_handler(void);
+int percpu_pagelist_fraction_sysctl_handler(void);
+int sysctl_min_unmapped_ratio_sysctl_handler(void);
+int sysctl_min_slab_ratio_sysctl_handler(void);
 
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 3309736..9081cf1 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -137,22 +137,13 @@ extern int vm_highmem_is_dirtyable;
 extern int block_dump;
 extern int laptop_mode;
 
-extern int dirty_background_ratio_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
-extern int dirty_background_bytes_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
-extern int dirty_ratio_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
-extern int dirty_bytes_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
+extern int dirty_background_ratio_handler(void);
+extern int dirty_background_bytes_handler(void);
+extern int dirty_ratio_handler(void);
+extern int dirty_bytes_handler(void);
 
 struct ctl_table;
-int dirty_writeback_centisecs_handler(struct ctl_table *, int,
-				      void __user *, size_t *, loff_t *);
+int dirty_writeback_centisecs_handler(void);
 
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index eef7508..3c403fd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1055,7 +1055,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &dirty_background_ratio,
 		.maxlen		= sizeof(dirty_background_ratio),
 		.mode		= 0644,
-		.proc_handler	= dirty_background_ratio_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= dirty_background_ratio_handler,
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
@@ -1064,7 +1065,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &dirty_background_bytes,
 		.maxlen		= sizeof(dirty_background_bytes),
 		.mode		= 0644,
-		.proc_handler	= dirty_background_bytes_handler,
+		.proc_handler	= proc_doulongvec_minmax,
+		.callback	= dirty_background_bytes_handler,
 		.extra1		= &one_ul,
 	},
 	{
@@ -1072,7 +1074,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &vm_dirty_ratio,
 		.maxlen		= sizeof(vm_dirty_ratio),
 		.mode		= 0644,
-		.proc_handler	= dirty_ratio_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= dirty_ratio_handler,
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
@@ -1081,7 +1084,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &vm_dirty_bytes,
 		.maxlen		= sizeof(vm_dirty_bytes),
 		.mode		= 0644,
-		.proc_handler	= dirty_bytes_handler,
+		.proc_handler	= proc_doulongvec_minmax,
+		.callback	= dirty_bytes_handler,
 		.extra1		= &dirty_bytes_min,
 	},
 	{
@@ -1089,7 +1093,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &dirty_writeback_interval,
 		.maxlen		= sizeof(dirty_writeback_interval),
 		.mode		= 0644,
-		.proc_handler	= dirty_writeback_centisecs_handler,
+		.proc_handler	= proc_dointvec,
+		.callback	= dirty_writeback_centisecs_handler,
 	},
 	{
 		.procname	= "dirty_expire_centisecs",
@@ -1165,7 +1170,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &sysctl_lowmem_reserve_ratio,
 		.maxlen		= sizeof(sysctl_lowmem_reserve_ratio),
 		.mode		= 0644,
-		.proc_handler	= lowmem_reserve_ratio_sysctl_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= lowmem_reserve_ratio_sysctl_handler,
 	},
 	{
 		.procname	= "drop_caches",
@@ -1200,7 +1206,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &min_free_kbytes,
 		.maxlen		= sizeof(min_free_kbytes),
 		.mode		= 0644,
-		.proc_handler	= min_free_kbytes_sysctl_handler,
+		.proc_handler	= proc_dointvec,
+		.callback	= min_free_kbytes_sysctl_handler,
 		.extra1		= &zero,
 	},
 	{
@@ -1208,7 +1215,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &percpu_pagelist_fraction,
 		.maxlen		= sizeof(percpu_pagelist_fraction),
 		.mode		= 0644,
-		.proc_handler	= percpu_pagelist_fraction_sysctl_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= percpu_pagelist_fraction_sysctl_handler,
 		.extra1		= &min_percpu_pagelist_fract,
 	},
 #ifdef CONFIG_MMU
@@ -1277,7 +1285,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &sysctl_min_unmapped_ratio,
 		.maxlen		= sizeof(sysctl_min_unmapped_ratio),
 		.mode		= 0644,
-		.proc_handler	= sysctl_min_unmapped_ratio_sysctl_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= sysctl_min_unmapped_ratio_sysctl_handler,
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
@@ -1286,7 +1295,8 @@ static struct ctl_table vm_table[] = {
 		.data		= &sysctl_min_slab_ratio,
 		.maxlen		= sizeof(sysctl_min_slab_ratio),
 		.mode		= 0644,
-		.proc_handler	= sysctl_min_slab_ratio_sysctl_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= sysctl_min_slab_ratio_sysctl_handler,
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 9dec97f..3898114 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -350,58 +350,38 @@ static void update_completion_period(void)
 	writeback_set_ratelimit();
 }
 
-int dirty_background_ratio_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+int dirty_background_ratio_handler(void)
 {
-	int ret;
-
-	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
-	if (ret == 0 && write)
-		dirty_background_bytes = 0;
-	return ret;
+	dirty_background_bytes = 0;
+	return 0;
 }
 
-int dirty_background_bytes_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+int dirty_background_bytes_handler(void)
 {
-	int ret;
-
-	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
-	if (ret == 0 && write)
-		dirty_background_ratio = 0;
-	return ret;
+	dirty_background_ratio = 0;
+	return 0;
 }
 
-int dirty_ratio_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+int dirty_ratio_handler(void)
 {
 	int old_ratio = vm_dirty_ratio;
-	int ret;
 
-	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
-	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
+	if (vm_dirty_ratio != old_ratio) {
 		update_completion_period();
 		vm_dirty_bytes = 0;
 	}
-	return ret;
+	return 0;
 }
 
-int dirty_bytes_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+int dirty_bytes_handler(void)
 {
 	unsigned long old_bytes = vm_dirty_bytes;
-	int ret;
 
-	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
-	if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
+	if (vm_dirty_bytes != old_bytes) {
 		update_completion_period();
 		vm_dirty_ratio = 0;
 	}
-	return ret;
+	return 0;
 }
 
 /*
@@ -1500,10 +1480,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 /*
  * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
  */
-int dirty_writeback_centisecs_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+int dirty_writeback_centisecs_handler(void)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
 	bdi_arm_supers_timer();
 	return 0;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b951de..1638fc1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5193,29 +5193,19 @@ int __meminit init_per_zone_wmark_min(void)
 module_init(init_per_zone_wmark_min)
 
 /*
- * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so 
- *	that we can call two helper functions whenever min_free_kbytes
+ * min_free_kbytes_sysctl_handler - called whenever min_free_kbytes
  *	changes.
  */
-int min_free_kbytes_sysctl_handler(ctl_table *table, int write, 
-	void __user *buffer, size_t *length, loff_t *ppos)
+int min_free_kbytes_sysctl_handler(void)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
-	if (write)
-		setup_per_zone_wmarks();
+	setup_per_zone_wmarks();
 	return 0;
 }
 
 #ifdef CONFIG_NUMA
-int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+int sysctl_min_unmapped_ratio_sysctl_handler(void)
 {
 	struct zone *zone;
-	int rc;
-
-	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (rc)
-		return rc;
 
 	for_each_zone(zone)
 		zone->min_unmapped_pages = (zone->present_pages *
@@ -5223,15 +5213,9 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
-int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+int sysctl_min_slab_ratio_sysctl_handler(void)
 {
 	struct zone *zone;
-	int rc;
-
-	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (rc)
-		return rc;
 
 	for_each_zone(zone)
 		zone->min_slab_pages = (zone->present_pages *
@@ -5249,10 +5233,8 @@ int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
  * minimum watermarks. The lowmem reserve ratio can only make sense
  * if in function of the boot time zone sizes.
  */
-int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+int lowmem_reserve_ratio_sysctl_handler(void)
 {
-	proc_dointvec_minmax(table, write, buffer, length, ppos);
 	setup_per_zone_lowmem_reserve();
 	return 0;
 }
@@ -5263,16 +5245,11 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
  * can have before it gets flushed back to buddy allocator.
  */
 
-int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+int percpu_pagelist_fraction_sysctl_handler(void)
 {
 	struct zone *zone;
 	unsigned int cpu;
-	int ret;
 
-	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (!write || (ret == -EINVAL))
-		return ret;
 	for_each_populated_zone(zone) {
 		for_each_possible_cpu(cpu) {
 			unsigned long  high;
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
