Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 654426B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 15:19:59 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id kq3so28137939wjc.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 12:19:59 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z11si318730wmh.2.2017.02.07.12.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 12:19:58 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id v77so30317268wmv.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 12:19:58 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, page_alloc: do not depend on cpu hotplug locks inside the allocator
Date: Tue,  7 Feb 2017 21:19:50 +0100
Message-Id: <20170207201950.20482-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dmitry Vyukov <dvyukov@google.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>

From: Michal Hocko <mhocko@suse.com>

Dmitry has reported the following lockdep splat
[<ffffffff81571db1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff8436697e>] __mutex_lock_common kernel/locking/mutex.c:521 [inline]
[<ffffffff8436697e>] mutex_lock_nested+0x24e/0xff0 kernel/locking/mutex.c:621
[<ffffffff818f07ea>] pcpu_alloc+0xbda/0x1280 mm/percpu.c:896
[<ffffffff818f0ee4>] __alloc_percpu+0x24/0x30 mm/percpu.c:1075
[<ffffffff816543e3>] smpcfd_prepare_cpu+0x73/0xd0 kernel/smp.c:44
[<ffffffff814240b4>] cpuhp_invoke_callback+0x254/0x1480 kernel/cpu.c:136
[<ffffffff81425821>] cpuhp_up_callbacks+0x81/0x2a0 kernel/cpu.c:493
[<ffffffff81427bf3>] _cpu_up+0x1e3/0x2a0 kernel/cpu.c:1057
[<ffffffff81427d23>] do_cpu_up+0x73/0xa0 kernel/cpu.c:1087
[<ffffffff81427d68>] cpu_up+0x18/0x20 kernel/cpu.c:1095
[<ffffffff854ede84>] smp_init+0xe9/0xee kernel/smp.c:564
[<ffffffff85482f81>] kernel_init_freeable+0x439/0x690 init/main.c:1010
[<ffffffff84357083>] kernel_init+0x13/0x180 init/main.c:941
[<ffffffff84377baa>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433

cpu_hotplug_begin
  cpu_hotplug.lock
pcpu_alloc
  pcpu_alloc_mutex

[<ffffffff81423012>] get_online_cpus+0x62/0x90 kernel/cpu.c:248
[<ffffffff8185fcf8>] drain_all_pages+0xf8/0x710 mm/page_alloc.c:2385
[<ffffffff81865e5d>] __alloc_pages_direct_reclaim mm/page_alloc.c:3440 [inline]
[<ffffffff81865e5d>] __alloc_pages_slowpath+0x8fd/0x2370 mm/page_alloc.c:3778
[<ffffffff818681c5>] __alloc_pages_nodemask+0x8f5/0xc60 mm/page_alloc.c:3980
[<ffffffff818ed0c1>] __alloc_pages include/linux/gfp.h:426 [inline]
[<ffffffff818ed0c1>] __alloc_pages_node include/linux/gfp.h:439 [inline]
[<ffffffff818ed0c1>] alloc_pages_node include/linux/gfp.h:453 [inline]
[<ffffffff818ed0c1>] pcpu_alloc_pages mm/percpu-vm.c:93 [inline]
[<ffffffff818ed0c1>] pcpu_populate_chunk+0x1e1/0x900 mm/percpu-vm.c:282
[<ffffffff818f0a11>] pcpu_alloc+0xe01/0x1280 mm/percpu.c:998
[<ffffffff818f0eb7>] __alloc_percpu_gfp+0x27/0x30 mm/percpu.c:1062
[<ffffffff817d25b2>] bpf_array_alloc_percpu kernel/bpf/arraymap.c:34 [inline]
[<ffffffff817d25b2>] array_map_alloc+0x532/0x710 kernel/bpf/arraymap.c:99
[<ffffffff817ba034>] find_and_alloc_map kernel/bpf/syscall.c:34 [inline]
[<ffffffff817ba034>] map_create kernel/bpf/syscall.c:188 [inline]
[<ffffffff817ba034>] SYSC_bpf kernel/bpf/syscall.c:870 [inline]
[<ffffffff817ba034>] SyS_bpf+0xd64/0x2500 kernel/bpf/syscall.c:827
[<ffffffff84377941>] entry_SYSCALL_64_fastpath+0x1f/0xc2

pcpu_alloc
  pcpu_alloc_mutex
drain_all_pages
  get_online_cpus
    cpu_hotplug.lock

[<ffffffff81427876>] cpu_hotplug_begin+0x206/0x2e0 kernel/cpu.c:304
[<ffffffff81427ada>] _cpu_up+0xca/0x2a0 kernel/cpu.c:1011
[<ffffffff81427d23>] do_cpu_up+0x73/0xa0 kernel/cpu.c:1087
[<ffffffff81427d68>] cpu_up+0x18/0x20 kernel/cpu.c:1095
[<ffffffff854ede84>] smp_init+0xe9/0xee kernel/smp.c:564
[<ffffffff85482f81>] kernel_init_freeable+0x439/0x690 init/main.c:1010
[<ffffffff84357083>] kernel_init+0x13/0x180 init/main.c:941
[<ffffffff84377baa>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433

cpu_hotplug_begin
  cpu_hotplug.lock

Pulling cpu hotplug locks inside the page allocator is just too
dangerous. Let's remove the dependency by dropping get_online_cpus()
from drain_all_pages. This is not so simple though because now we do not
have a protection against cpu hotplug which means 2 things:
	- the work item might be executed on a different cpu in worker
	  from unbound pool so it doesn't run on pinned on the cpu
	- we have to make sure that we do not race with page_alloc_cpu_dead
	  calling drain_pages_zone

Disabling preemption in drain_local_pages_wq will solve the first
problem drain_local_pages will determine its local CPU from the WQ
context which will be stable after that point, page_alloc_cpu_dead
is pinned to the CPU already. The later condition is achieved
by disabling IRQs in drain_pages_zone.

Fixes: mm, page_alloc: drain per-cpu pages from workqueue context
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c3358d4f7932..b6411816787a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2343,7 +2343,16 @@ void drain_local_pages(struct zone *zone)
 
 static void drain_local_pages_wq(struct work_struct *work)
 {
+	/*
+	 * drain_all_pages doesn't use proper cpu hotplug protection so
+	 * we can race with cpu offline when the WQ can move this from
+	 * a cpu pinned worker to an unbound one. We can operate on a different
+	 * cpu which is allright but we also have to make sure to not move to
+	 * a different one.
+	 */
+	preempt_disable();
 	drain_local_pages(NULL);
+	preempt_enable();
 }
 
 /*
@@ -2379,12 +2388,6 @@ void drain_all_pages(struct zone *zone)
 	}
 
 	/*
-	 * As this can be called from reclaim context, do not reenter reclaim.
-	 * An allocation failure can be handled, it's simply slower
-	 */
-	get_online_cpus();
-
-	/*
 	 * We don't care about racing with CPU hotplug event
 	 * as offline notification will cause the notified
 	 * cpu to drain that CPU pcps and on_each_cpu_mask
@@ -2423,7 +2426,6 @@ void drain_all_pages(struct zone *zone)
 	for_each_cpu(cpu, &cpus_with_pcps)
 		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
 
-	put_online_cpus();
 	mutex_unlock(&pcpu_drain_mutex);
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
