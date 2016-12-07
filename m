Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61AFF6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 08:54:52 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id bk3so84262570wjc.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 05:54:52 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id a127si8450032wmh.83.2016.12.07.05.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 05:54:50 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id a20so28121749wme.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 05:54:50 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] hotplug: make register and unregister notifier API symmetric
Date: Wed,  7 Dec 2016 14:54:38 +0100
Message-Id: <20161207135438.4310-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yu Zhao <yuzhao@google.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Yu Zhao has noticed that __unregister_cpu_notifier only unregisters its
notifiers when HOTPLUG_CPU=y while the registration might succeed even
when HOTPLUG_CPU=n if MODULE is enabled. This means that e.g. zswap
might keep a stale notifier on the list on the manual clean up during
the pool tear down and thus corrupt the list. Resulting in the following

[  144.964346] BUG: unable to handle kernel paging request at ffff880658a2be78
[  144.971337] IP: [<ffffffffa290b00b>] raw_notifier_chain_register+0x1b/0x40
<snipped>
[  145.122628] Call Trace:
[  145.125086]  [<ffffffffa28e5cf8>] __register_cpu_notifier+0x18/0x20
[  145.131350]  [<ffffffffa2a5dd73>] zswap_pool_create+0x273/0x400
[  145.137268]  [<ffffffffa2a5e0fc>] __zswap_param_set+0x1fc/0x300
[  145.143188]  [<ffffffffa2944c1d>] ? trace_hardirqs_on+0xd/0x10
[  145.149018]  [<ffffffffa2908798>] ? kernel_param_lock+0x28/0x30
[  145.154940]  [<ffffffffa2a3e8cf>] ? __might_fault+0x4f/0xa0
[  145.160511]  [<ffffffffa2a5e237>] zswap_compressor_param_set+0x17/0x20
[  145.167035]  [<ffffffffa2908d3c>] param_attr_store+0x5c/0xb0
[  145.172694]  [<ffffffffa290848d>] module_attr_store+0x1d/0x30
[  145.178443]  [<ffffffffa2b2b41f>] sysfs_kf_write+0x4f/0x70
[  145.183925]  [<ffffffffa2b2a5b9>] kernfs_fop_write+0x149/0x180
[  145.189761]  [<ffffffffa2a99248>] __vfs_write+0x18/0x40
[  145.194982]  [<ffffffffa2a9a412>] vfs_write+0xb2/0x1a0
[  145.200122]  [<ffffffffa2a9a732>] SyS_write+0x52/0xa0
[  145.205177]  [<ffffffffa2ff4d97>] entry_SYSCALL_64_fastpath+0x12/0x17

This can be even triggered manually by changing
/sys/module/zswap/parameters/compressor multiple times.

Fix this issue by making unregister APIs symmetric to the register so
there are no surprises.

Fixes: 47e627bc8c9a ("[PATCH] hotplug: Allow modules to use the cpu hotplug notifiers even if !CONFIG_HOTPLUG_CPU")
Cc: stable # zswap requires for 4.3+
Reported-and-tested-by: Yu Zhao <yuzhao@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
the previous version of the patch has been sent [1] and the reporter has
confirmed it works as expected. I have also added more information to
the changelog. Does this looks sensible?

[1] http://lkml.kernel.org/r/20161205060840.GC30758@dhcp22.suse.cz

 include/linux/cpu.h | 15 ++++-----------
 kernel/cpu.c        |  2 +-
 2 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 797d9c8e9a1b..c8938eb21e34 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -105,22 +105,16 @@ extern bool cpuhp_tasks_frozen;
 		{ .notifier_call = fn, .priority = pri };	\
 	__register_cpu_notifier(&fn##_nb);			\
 }
-#else /* #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
-#define cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
-#define __cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
-#endif /* #else #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
 
-#ifdef CONFIG_HOTPLUG_CPU
 extern int register_cpu_notifier(struct notifier_block *nb);
 extern int __register_cpu_notifier(struct notifier_block *nb);
 extern void unregister_cpu_notifier(struct notifier_block *nb);
 extern void __unregister_cpu_notifier(struct notifier_block *nb);
-#else
 
-#ifndef MODULE
-extern int register_cpu_notifier(struct notifier_block *nb);
-extern int __register_cpu_notifier(struct notifier_block *nb);
-#else
+#else /* #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
+#define cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
+#define __cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
+
 static inline int register_cpu_notifier(struct notifier_block *nb)
 {
 	return 0;
@@ -130,7 +124,6 @@ static inline int __register_cpu_notifier(struct notifier_block *nb)
 {
 	return 0;
 }
-#endif
 
 static inline void unregister_cpu_notifier(struct notifier_block *nb)
 {
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 341bf80f80bd..73fb59fda809 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -578,7 +578,6 @@ void __init cpuhp_threads_init(void)
 	kthread_unpark(this_cpu_read(cpuhp_state.thread));
 }
 
-#ifdef CONFIG_HOTPLUG_CPU
 EXPORT_SYMBOL(register_cpu_notifier);
 EXPORT_SYMBOL(__register_cpu_notifier);
 void unregister_cpu_notifier(struct notifier_block *nb)
@@ -595,6 +594,7 @@ void __unregister_cpu_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL(__unregister_cpu_notifier);
 
+#ifdef CONFIG_HOTPLUG_CPU
 /**
  * clear_tasks_mm_cpumask - Safely clear tasks' mm_cpumask for a CPU
  * @cpu: a CPU id
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
