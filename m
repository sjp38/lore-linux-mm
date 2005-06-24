Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5OMQeqo551342
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 18:26:40 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5OMQehE330620
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 16:26:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5OMQdVI006373
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 16:26:39 -0600
Subject: [PATCH 5/6] CKRM: Add config support for mem controller
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
Content-Type: text/plain
Date: Fri, 24 Jun 2005 15:26:38 -0700
Message-Id: <1119651998.5105.23.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech <ckrm-tech@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Patch 5 of 6 patches to support memory controller under CKRM framework.
Provides some config parameter support. Details about the config
parameters
in the Documentation patch.
----------------------------------------

 include/linux/ckrm_mem.h        |   14 ++++
 include/linux/ckrm_mem_inline.h |    4 +
 kernel/ckrm/ckrm_memcore.c      |  127 ++++++++++++++++++++++++++++++++
++++++--
 kernel/ckrm/ckrm_memctlr.c      |   49 +++++++++++++++
 mm/vmscan.c                     |   96 ++++++++++++++++++++++++++++--
 5 files changed, 279 insertions(+), 11 deletions(-)

Content-Disposition: inline; filename=11-05-mem_guar-config

Index: linux-2.6.12/include/linux/ckrm_mem.h
===================================================================
--- linux-2.6.12.orig/include/linux/ckrm_mem.h
+++ linux-2.6.12/include/linux/ckrm_mem.h
@@ -63,16 +63,28 @@ struct ckrm_mem_res {
 	int nr_dontcare;		/* # of dont care children */
 
 	struct ckrm_zone ckrm_zone[MAX_NR_ZONES];
+
+ 	struct list_head shrink_list;	/* list of classes that are near
+				 	 * limit and need to be shrunk
+					 */
+	int shrink_count;
+	unsigned long last_shrink;
 };
 
+#define CLS_AT_LIMIT		(1)
+
 extern atomic_t ckrm_mem_real_count;
 extern struct ckrm_res_ctlr mem_rcbs;
 extern struct ckrm_mem_res *ckrm_mem_root_class;
 extern struct list_head ckrm_memclass_list;
+extern struct list_head ckrm_shrink_list;
 extern spinlock_t ckrm_mem_lock;
 extern spinlock_t ckrm_overguar_lock[MAX_NR_ZONES];
 extern int ckrm_nr_mem_classes;
 extern unsigned int ckrm_tot_lru_pages;
+extern int ckrm_mem_shrink_count;
+extern int ckrm_mem_shrink_to;
+extern int ckrm_mem_shrink_interval;
 
 extern void ckrm_mem_migrate_mm(struct mm_struct *, struct ckrm_mem_res
*);
 extern void ckrm_mem_migrate_all_pages(struct ckrm_mem_res *,
@@ -84,6 +96,8 @@ extern int ckrm_class_limit_ok(struct ck
 
 extern struct ckrm_zone *ckrm_get_max_overguar_czone(int);
 
+extern void ckrm_shrink_atlimit(struct ckrm_mem_res *);
+
 #else
 
 #define ckrm_mem_migrate_mm(a, b)			do {} while (0)
Index: linux-2.6.12/include/linux/ckrm_mem_inline.h
===================================================================
--- linux-2.6.12.orig/include/linux/ckrm_mem_inline.h
+++ linux-2.6.12/include/linux/ckrm_mem_inline.h
@@ -26,6 +26,8 @@
 
 #ifdef CONFIG_CKRM_RES_MEM
 
+#define ckrm_shrink_list_empty() list_empty(&ckrm_shrink_list)
+
 static inline struct ckrm_mem_res *
 ckrm_task_memclass(struct task_struct *tsk)
 {
@@ -324,6 +326,8 @@ static inline void ckrm_add_tail_inactiv
 
 #else
 
+#define ckrm_shrink_list_empty()		(1)
+
 static inline void *
 ckrm_task_memclass(struct task_struct *tsk)
 {
Index: linux-2.6.12/kernel/ckrm/ckrm_memcore.c
===================================================================
--- linux-2.6.12.orig/kernel/ckrm/ckrm_memcore.c
+++ linux-2.6.12/kernel/ckrm/ckrm_memcore.c
@@ -42,6 +42,7 @@ LIST_HEAD(ckrm_memclass_list);
 spinlock_t ckrm_mem_lock; /* protects list above */
 unsigned int ckrm_tot_lru_pages; /* # of pages in the system */
 int ckrm_nr_mem_classes = 0;
+int ckrm_mem_state = 0;
 struct ckrm_mem_res *ckrm_mem_root_class;
 atomic_t ckrm_mem_real_count = ATOMIC_INIT(0);
 
@@ -52,6 +53,7 @@ EXPORT_SYMBOL_GPL(ckrm_memclass_list);
 EXPORT_SYMBOL_GPL(ckrm_mem_lock);
 EXPORT_SYMBOL_GPL(ckrm_tot_lru_pages);
 EXPORT_SYMBOL_GPL(ckrm_nr_mem_classes);
+EXPORT_SYMBOL_GPL(ckrm_mem_state);
 EXPORT_SYMBOL_GPL(ckrm_mem_root_class);
 EXPORT_SYMBOL_GPL(ckrm_mem_real_count);
 
@@ -101,8 +103,10 @@ mem_res_initcls_one(struct ckrm_mem_res 
 	res->pg_guar = CKRM_SHARE_DONTCARE;
 	res->pg_limit = CKRM_SHARE_DONTCARE;
 	res->implicit_guar = CKRM_SHARE_DONTCARE;
+	res->last_shrink = jiffies;
 
 	INIT_LIST_HEAD(&res->mcls_list);
+	INIT_LIST_HEAD(&res->shrink_list);
 
 	for_each_zone(zone) {
 		INIT_LIST_HEAD(&res->ckrm_zone[zindex].active_list);
@@ -248,6 +252,11 @@ mem_res_alloc(struct ckrm_core_class *co
 		ckrm_nr_mem_classes++;
 	} else
 		printk(KERN_ERR "MEM_RC: alloc: GFP_ATOMIC failed\n");
+
+	/* enable the controller if the user defined atleast 1 class */
+	if (ckrm_nr_mem_classes > 1)
+		ckrm_mem_state = 1;
+
 	return res;
 }
 
@@ -402,6 +411,9 @@ mem_set_share_values(void *my_res, struc
 		set_impl_guar_children(parres);
 	}
 
+	/* If the user has changed the shares, enable the controller */
+	ckrm_mem_state = 1;
+
 	return rc;
 }
 
@@ -499,6 +511,23 @@ mem_change_resclass(void *tsk, void *old
 	return;
 }
 
+#define MEM_STATE "state"
+#define MEM_FAIL_OVER "fail_over"
+#define MEM_SHRINK_AT "shrink_at"
+#define MEM_SHRINK_TO "shrink_to"
+#define MEM_SHRINK_COUNT "num_shrinks"
+#define MEM_SHRINK_INTERVAL "shrink_interval"
+
+int ckrm_mem_fail_at = 110;
+int ckrm_mem_shrink_at = 90;
+int ckrm_mem_shrink_to = 80;
+int ckrm_mem_shrink_count = 10;
+int ckrm_mem_shrink_interval = 10;
+
+EXPORT_SYMBOL_GPL(ckrm_mem_fail_at);
+EXPORT_SYMBOL_GPL(ckrm_mem_shrink_at);
+EXPORT_SYMBOL_GPL(ckrm_mem_shrink_to);
+
 static int
 mem_show_config(void *my_res, struct seq_file *sfile)
 {
@@ -506,24 +535,110 @@ mem_show_config(void *my_res, struct seq
 
 	if (!res)
 		return -EINVAL;
-	printk(KERN_INFO "show_config called for %s resource of class %s\n",
-			MEM_RES_NAME, res->core->name);
 
-	seq_printf(sfile, "res=%s", MEM_RES_NAME);
+	seq_printf(sfile, "res=%s,%s=%d,%s=%d,%s=%d,%s=%d,%s=%d,%s=%d\n",
+		MEM_RES_NAME,
+		MEM_STATE, ckrm_mem_state,
+		MEM_FAIL_OVER, ckrm_mem_fail_at,
+		MEM_SHRINK_AT, ckrm_mem_shrink_at,
+		MEM_SHRINK_TO, ckrm_mem_shrink_to,
+		MEM_SHRINK_COUNT, ckrm_mem_shrink_count,
+		MEM_SHRINK_INTERVAL, ckrm_mem_shrink_interval);
 
 	return 0;
 }
 
+typedef int __bitwise memclass_token_t;
+
+enum memclass_token {
+	mem_state = (__force memclass_token_t) 1,
+	mem_fail_over = (__force memclass_token_t) 2,
+	mem_shrink_at = (__force memclass_token_t) 3,
+	mem_shrink_to = (__force memclass_token_t) 4,
+	mem_shrink_count = (__force memclass_token_t) 5,
+	mem_shrink_interval = (__force memclass_token_t) 6,
+	mem_err = (__force memclass_token_t) 7
+};
+
+static match_table_t mem_tokens = {
+	{mem_state, MEM_STATE "=%d"},
+	{mem_fail_over, MEM_FAIL_OVER "=%d"},
+	{mem_shrink_at, MEM_SHRINK_AT "=%d"},
+	{mem_shrink_to, MEM_SHRINK_TO "=%d"},
+	{mem_shrink_count, MEM_SHRINK_COUNT "=%d"},
+	{mem_shrink_interval, MEM_SHRINK_INTERVAL "=%d"},
+	{mem_err, NULL},
+};
+
 static int
 mem_set_config(void *my_res, const char *cfgstr)
 {
+	char *p;
 	struct ckrm_mem_res *res = my_res;
+	int err = 0, val;
 
 	if (!res)
 		return -EINVAL;
-	printk(KERN_INFO "set_config called for %s resource of class %s\n",
-			MEM_RES_NAME, res->core->name);
-	return 0;
+
+	while ((p = strsep((char**)&cfgstr, ",")) != NULL) {
+		substring_t args[MAX_OPT_ARGS];
+		int token;
+		if (!*p)
+			continue;
+
+		token = match_token(p, mem_tokens, args);
+		switch (token) {
+		case mem_state:
+			err = -EINVAL;
+			match_int(args, &val);
+			switch (val) {
+			case 0:
+				if (ckrm_nr_mem_classes > 1)
+					break;
+				/* FALLTHRU */
+			case 1:
+				ckrm_mem_state = val;
+				err = 0;
+				break;
+			default:
+				break;
+			}
+			break;
+		case mem_fail_over:
+			if (match_int(args, &val) || (val <= 0))
+				err = -EINVAL;
+			else
+				ckrm_mem_fail_at = val;
+			break;
+		case mem_shrink_at:
+			if (match_int(args, &val) || (val <= 0))
+				err = -EINVAL;
+			else
+				ckrm_mem_shrink_at = val;
+			break;
+		case mem_shrink_to:
+			if (match_int(args, &val) || (val < 0) || (val > 100))
+				err = -EINVAL;
+			else
+				ckrm_mem_shrink_to = val;
+			break;
+		case mem_shrink_count:
+			if (match_int(args, &val) || (val <= 0))
+				err = -EINVAL;
+			else
+				ckrm_mem_shrink_count = val;
+			break;
+		case mem_shrink_interval:
+			if (match_int(args, &val) || (val <= 0))
+				err = -EINVAL;
+			else
+				ckrm_mem_shrink_interval = val;
+			break;
+		default:
+			err = -EINVAL;
+		}
+	}
+	return err;
 }
 
 static int
Index: linux-2.6.12/kernel/ckrm/ckrm_memctlr.c
===================================================================
--- linux-2.6.12.orig/kernel/ckrm/ckrm_memctlr.c
+++ linux-2.6.12/kernel/ckrm/ckrm_memctlr.c
@@ -59,10 +59,13 @@ ckrm_del_from_guar_list(struct ckrm_zone
 	}
 }
 
+extern int ckrm_mem_state;
+
 void
 add_use_count(struct ckrm_mem_res *cls, int borrow, int zindex, int
cnt)
 {
 	int i, pg_total = 0;
+	extern int ckrm_mem_shrink_at;
 	struct ckrm_mem_res *parcls = ckrm_memclass(cls->parent);
 
 	if (!cls)
@@ -82,6 +85,12 @@ add_use_count(struct ckrm_mem_res *cls, 
 	} else
 		atomic_add(cnt, &ckrm_mem_real_count);
 	ckrm_add_to_guar_list(&cls->ckrm_zone[zindex], zindex);
+
+	if (ckrm_mem_state && (cls->pg_limit != CKRM_SHARE_DONTCARE) &&
+			(pg_total >=
+			((ckrm_mem_shrink_at * cls->pg_limit) / 100)) &&
+			(!test_bit(CLS_AT_LIMIT, &cls->flags)))
+		ckrm_shrink_atlimit(cls);
 	return;
 }
 
@@ -113,7 +122,7 @@ ckrm_class_limit_ok(struct ckrm_mem_res 
 {
 	int ret, i, pg_total = 0;
 
-	if ((mem_rcbs.resid == -1) || !cls)
+	if ((ckrm_mem_state == 0) || (mem_rcbs.resid == -1) || !cls)
 		return 1;
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		pg_total += cls->pg_total[i];
@@ -123,6 +132,10 @@ ckrm_class_limit_ok(struct ckrm_mem_res 
 	} else
 		ret = (pg_total <= cls->pg_limit);
 
+	/* If we are failing, just nudge the back end */
+	if (ret == 0)
+		ckrm_shrink_atlimit(cls);
+
 	return ret;
 }
 
@@ -407,3 +420,37 @@ ckrm_get_max_overguar_czone(int zindex)
 
 	return maxczone;
 }
+LIST_HEAD(ckrm_shrink_list);
+
+void
+ckrm_shrink_atlimit(struct ckrm_mem_res *cls)
+{
+	struct zone *zone;
+	unsigned long flags;
+	int order;
+
+	if (!cls || (cls->pg_limit == CKRM_SHARE_DONTCARE))
+		return;
+	if (test_and_set_bit(CLS_AT_LIMIT, &cls->flags))
+		return;
+	if (time_after(jiffies, cls->last_shrink +
+				ckrm_mem_shrink_interval * HZ)) {
+		cls->last_shrink = jiffies;
+		cls->shrink_count = 0;
+	}
+	cls->shrink_count++;
+	if (cls->shrink_count > ckrm_mem_shrink_count) {
+		clear_bit(CLS_AT_LIMIT, &cls->flags);
+		return;
+	}
+	spin_lock_irqsave(&ckrm_mem_lock, flags);
+	list_add(&cls->shrink_list, &ckrm_shrink_list);
+	spin_unlock_irqrestore(&ckrm_mem_lock, flags);
+	for_each_zone(zone) {
+		/* This is just a number to get to wakeup kswapd */
+		order = cls->pg_total[0] -
+			((ckrm_mem_shrink_to * cls->pg_limit) / 100);
+		wakeup_kswapd(zone, order);
+		break; /* only once is enough */
+	}
+}
Index: linux-2.6.12/mm/vmscan.c
===================================================================
--- linux-2.6.12.orig/mm/vmscan.c
+++ linux-2.6.12/mm/vmscan.c
@@ -869,6 +869,88 @@ shrink_ckrmzone(struct ckrm_zone *czone,
 		}
 	}
 }
+
+/* FIXME: This function needs to be given more thought. */
+static void
+ckrm_shrink_class(struct ckrm_mem_res *cls)
+{
+	struct scan_control sc;
+	struct zone *zone;
+	int zindex = 0, cnt, act_credit = 0, inact_credit = 0;
+
+	sc.nr_mapped = read_page_state(nr_mapped);
+	sc.nr_scanned = 0;
+	sc.nr_reclaimed = 0;
+	sc.priority = 0; /* always very high priority */
+	sc.swap_cluster_max = SWAP_CLUSTER_MAX;
+
+	for_each_zone(zone) {
+		int zone_total, zone_limit, active_limit,
+					inactive_limit, clszone_limit;
+		struct ckrm_zone *czone;
+		u64 temp;
+
+		czone = &cls->ckrm_zone[zindex];
+
+		zone->temp_priority = zone->prev_priority;
+		zone->prev_priority = sc.priority;
+
+		zone_total = zone->nr_active + zone->nr_inactive
+						+ zone->free_pages;
+
+		temp = (u64) cls->pg_limit * zone_total;
+		do_div(temp, ckrm_tot_lru_pages);
+		zone_limit = (int) temp;
+		clszone_limit = (ckrm_mem_shrink_to * zone_limit) / 100;
+		active_limit = (2 * clszone_limit) / 3; /* 2/3rd in active */
+		inactive_limit = clszone_limit / 3; /* 1/3rd in inactive */
+
+		sc.ckrm_active = 0;
+		cnt = czone->nr_active + act_credit - active_limit;
+		if (cnt > 0) {
+			sc.ckrm_active = (unsigned long) cnt;
+			act_credit = 0;
+		} else
+			act_credit += cnt;
+
+		sc.ckrm_inactive = 0;
+		cnt = sc.ckrm_active + inact_credit +
+					(czone->nr_inactive - inactive_limit);
+		if (cnt > 0) {
+			sc.ckrm_inactive = (unsigned long) cnt;
+			inact_credit = 0;
+		} else
+			inact_credit += cnt;
+
+		if (sc.ckrm_active || sc.ckrm_inactive) {
+			sc.nr_to_reclaim = sc.ckrm_inactive;
+			shrink_ckrmzone(czone, &sc);
+		}
+		zone->prev_priority = zone->temp_priority;
+		zindex++;
+	}
+}
+
+static void
+ckrm_shrink_classes(void)
+{
+	struct ckrm_mem_res *cls;
+
+	spin_lock_irq(&ckrm_mem_lock);
+	while (!ckrm_shrink_list_empty()) {
+		cls =  list_entry(ckrm_shrink_list.next, struct ckrm_mem_res,
+				shrink_list);
+		list_del(&cls->shrink_list);
+		spin_unlock_irq(&ckrm_mem_lock);
+		ckrm_shrink_class(cls);
+		clear_bit(CLS_AT_LIMIT, &cls->flags);
+		spin_lock_irq(&ckrm_mem_lock);
+	}
+	spin_unlock_irq(&ckrm_mem_lock);
+}
+
+#else
+#define ckrm_shrink_classes()	do { } while(0)
 #endif
 
 /*
@@ -1135,7 +1217,8 @@ loop_again:
 					continue;
 
 				if (!zone_watermark_ok(zone, order,
-						zone->pages_high, 0, 0, 0)) {
+						zone->pages_high, 0, 0, 0) &&
+						ckrm_shrink_list_empty()) {
 					end_zone = i;
 					goto scan;
 				}
@@ -1171,7 +1254,8 @@ scan:
 
 			if (nr_pages == 0) {	/* Not software suspend */
 				if (!zone_watermark_ok(zone, order,
-						zone->pages_high, end_zone, 0, 0))
+					zone->pages_high, end_zone, 0, 0) &&
+						ckrm_shrink_list_empty())
 					all_zones_ok = 0;
 			}
 			zone->temp_priority = priority;
@@ -1300,7 +1384,10 @@ static int kswapd(void *p)
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
-		balance_pgdat(pgdat, 0, order);
+		if (!ckrm_shrink_list_empty())
+			ckrm_shrink_classes();
+		else
+			balance_pgdat(pgdat, 0, order);
 	}
 	return 0;
 }
@@ -1316,7 +1403,8 @@ void wakeup_kswapd(struct zone *zone, in
 		return;
 
 	pgdat = zone->zone_pgdat;
-	if (zone_watermark_ok(zone, order, zone->pages_low, 0, 0, 0))
+	if (zone_watermark_ok(zone, order, zone->pages_low, 0, 0, 0) &&
+			ckrm_shrink_list_empty())
 		return;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
