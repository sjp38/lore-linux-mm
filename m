Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2016A6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 09:00:11 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j8so139946589lfd.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 06:00:11 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x4si20864781wmx.51.2016.05.02.06.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 06:00:09 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so17020034wmn.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 06:00:09 -0700 (PDT)
Date: Mon, 2 May 2016 15:00:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160502130006.GD25265@dhcp22.suse.cz>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
 <20160428143710.GC31496@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428143710.GC31496@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Thu 28-04-16 16:37:10, Michal Hocko wrote:
[...]
> 7. Hook into vmstat and flush from there? This would drain them
> periodically but it would also introduce an undeterministic interference
> as well.

So I have given this a try (not tested yet) and it doesn't look terribly
complicated. It is hijacking vmstat for a purpose it wasn't intended for
originally but creating a dedicated kenrnel threads/WQ sounds like an
overkill to me. Does this helps or do we have to be more aggressive and
wake up shepherd from the allocator slow path. Could you give it a try
please?
---
diff --git a/mm/internal.h b/mm/internal.h
index b6ead95a0184..876125bd11f4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -488,4 +488,5 @@ extern const struct trace_print_flags pageflag_names[];
 extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
+extern bool pcp_lru_add_need_drain(int cpu);
 #endif	/* __MM_INTERNAL_H */
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
index 7397d9548f21..766f751e3467 100644
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
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
