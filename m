Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D82416B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 03:21:26 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j8so7278538lfd.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:21:26 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id gg1si9761358wjd.214.2016.05.05.00.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 00:21:25 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so1873109wme.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:21:25 -0700 (PDT)
Date: Thu, 5 May 2016 09:21:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160505072122.GA4386@dhcp22.suse.cz>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
 <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504203643.GI21490@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Wed 04-05-16 22:36:43, Michal Hocko wrote:
> On Wed 04-05-16 19:41:59, Odzioba, Lukasz wrote:
[...]
> > I have an app which allocates almost all of the memory from numa node and
> > with just second patch and 100 consecutive executions 30-50% got killed.
> 
> This is still not acceptable. So I guess we need a way to kick
> vmstat_shepherd from the reclaim path. I will think about that. Sounds a
> bit tricky at first sight.

OK, it wasn't that tricky afterall. Maybe I have missed something but
the following should work. Or maybe the async nature of flushing turns
out to be just impractical and unreliable and we will end up skipping
THP (or all compound pages) for pcp LRU add cache. Let's see...
---
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 0aa613df463e..7f2c1aef6a09 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -274,4 +274,5 @@ static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
 
 extern const char * const vmstat_text[];
 
+extern void kick_vmstat_update(void);
 #endif /* _LINUX_VMSTAT_H */
diff --git a/mm/internal.h b/mm/internal.h
index b6ead95a0184..876125bd11f4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -488,4 +488,5 @@ extern const struct trace_print_flags pageflag_names[];
 extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
+extern bool pcp_lru_add_need_drain(int cpu);
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 056baf55a88d..5ca829e707f4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3556,6 +3556,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
+	bool vmstat_updated = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3658,6 +3659,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (order && compaction_made_progress(compact_result))
 		compaction_retries++;
 
+	if (!vmstat_updated) {
+		vmstat_updated = true;
+		kick_vmstat_update();
+	}
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
 							&did_some_progress);
diff --git a/mm/swap.c b/mm/swap.c
index 95916142fc46..3937e6caef96 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -667,6 +667,15 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
+bool pcp_lru_add_need_drain(int cpu)
+{
+	return pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
+		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
+		    need_activate_page_drain(cpu);
+}
+
 void lru_add_drain_all(void)
 {
 	static DEFINE_MUTEX(lock);
@@ -680,11 +689,7 @@ void lru_add_drain_all(void)
 	for_each_online_cpu(cpu) {
 		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
 
-		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
-		    need_activate_page_drain(cpu)) {
+		if (pcp_lru_add_need_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			schedule_work_on(cpu, work);
 			cpumask_set_cpu(cpu, &has_work);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7397d9548f21..cf4b095ace1c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -479,6 +479,13 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
 	int changes = 0;
 
+	/*
+	 * Do not try to drain LRU pcp caches because that might be
+	 * expensive - we take locks there etc.
+	 */
+	if (do_pagesets && pcp_lru_add_need_drain(smp_processor_id()))
+		lru_add_drain();
+
 	for_each_populated_zone(zone) {
 		struct per_cpu_pageset __percpu *p = zone->pageset;
 
@@ -1477,7 +1484,8 @@ static bool need_update(int cpu)
 			return true;
 
 	}
-	return false;
+
+	return pcp_lru_add_need_drain(cpu);
 }
 
 void quiet_vmstat(void)
@@ -1542,6 +1550,16 @@ static void vmstat_shepherd(struct work_struct *w)
 		round_jiffies_relative(sysctl_stat_interval));
 }
 
+void kick_vmstat_update(void)
+{
+#ifdef CONFIG_SMP
+	might_sleep();
+
+	if (cancel_delayed_work(&shepherd))
+		vmstat_shepherd(&shepherd.work);
+#endif
+}
+
 static void __init start_shepherd_timer(void)
 {
 	int cpu;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
