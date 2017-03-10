Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8BE280911
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:51:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b140so2926133wme.3
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 03:51:44 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id o125si2550716wmg.18.2017.03.10.03.51.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 03:51:43 -0800 (PST)
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 10 Mar 2017 11:46:22 +0000
Message-ID: <lsq.1489146382.803002161@decadent.org.uk>
Subject: [PATCH 3.16 082/370] hotplug: Make register and unregister
 notifier API symmetric
In-Reply-To: <lsq.1489146380.780052105@decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: akpm@linux-foundation.org, Dan Streetman <ddstreet@ieee.org>, Michal Hocko <mhocko@suse.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org

3.16.42-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Michal Hocko <mhocko@suse.com>

commit 777c6e0daebb3fcefbbd6f620410a946b07ef6d0 upstream.

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
Reported-and-tested-by: Yu Zhao <yuzhao@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>
Link: http://lkml.kernel.org/r/20161207135438.4310-1-mhocko@kernel.org
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[bwh: Backported to 3.16: keep definition of cpu_notify_nofail() conditional
 on CONFIG_HOTPLUG_CPU]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -122,22 +122,16 @@ enum {
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
@@ -147,7 +141,6 @@ static inline int __register_cpu_notifie
 {
 	return 0;
 }
-#endif
 
 static inline void unregister_cpu_notifier(struct notifier_block *nb)
 {
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -210,12 +210,6 @@ static int cpu_notify(unsigned long val,
 	return __cpu_notify(val, v, -1, NULL);
 }
 
-#ifdef CONFIG_HOTPLUG_CPU
-
-static void cpu_notify_nofail(unsigned long val, void *v)
-{
-	BUG_ON(cpu_notify(val, v));
-}
 EXPORT_SYMBOL(register_cpu_notifier);
 EXPORT_SYMBOL(__register_cpu_notifier);
 
@@ -233,6 +227,13 @@ void __ref __unregister_cpu_notifier(str
 }
 EXPORT_SYMBOL(__unregister_cpu_notifier);
 
+#ifdef CONFIG_HOTPLUG_CPU
+
+static void cpu_notify_nofail(unsigned long val, void *v)
+{
+	BUG_ON(cpu_notify(val, v));
+}
+
 /**
  * clear_tasks_mm_cpumask - Safely clear tasks' mm_cpumask for a CPU
  * @cpu: a CPU id

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
