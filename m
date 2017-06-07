Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9F16B02B4
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 19:04:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v102so3033150wrc.8
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 16:04:38 -0700 (PDT)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id n17si2733084wra.263.2017.06.07.16.04.35
        for <linux-mm@kvack.org>;
        Wed, 07 Jun 2017 16:04:36 -0700 (PDT)
From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 3.10 020/250] hotplug: Make register and unregister notifier API symmetric
Date: Thu,  8 Jun 2017 00:56:46 +0200
Message-Id: <1496876436-32402-21-git-send-email-w@1wt.eu>
In-Reply-To: <1496876436-32402-1-git-send-email-w@1wt.eu>
References: <1496876436-32402-1-git-send-email-w@1wt.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux@roeck-us.net
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, Thomas Gleixner <tglx@linutronix.de>, Jiri Slaby <jslaby@suse.cz>, Willy Tarreau <w@1wt.eu>

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

[js] backport to 3.12

Fixes: 47e627bc8c9a ("[PATCH] hotplug: Allow modules to use the cpu hotplug notifiers even if !CONFIG_HOTPLUG_CPU")
Reported-and-tested-by: Yu Zhao <yuzhao@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>
Link: http://lkml.kernel.org/r/20161207135438.4310-1-mhocko@kernel.org
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 include/linux/cpu.h | 12 +++---------
 kernel/cpu.c        |  3 +--
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 9f3c7e8..d0d5946 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -119,22 +119,16 @@ enum {
 		{ .notifier_call = fn, .priority = pri };	\
 	register_cpu_notifier(&fn##_nb);			\
 }
-#else /* #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
-#define cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
-#endif /* #else #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
-#ifdef CONFIG_HOTPLUG_CPU
 extern int register_cpu_notifier(struct notifier_block *nb);
 extern void unregister_cpu_notifier(struct notifier_block *nb);
-#else
 
-#ifndef MODULE
-extern int register_cpu_notifier(struct notifier_block *nb);
-#else
+#else /* #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
+#define cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
+
 static inline int register_cpu_notifier(struct notifier_block *nb)
 {
 	return 0;
 }
-#endif
 
 static inline void unregister_cpu_notifier(struct notifier_block *nb)
 {
diff --git a/kernel/cpu.c b/kernel/cpu.c
index bc255e2..a6c2424 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -185,8 +185,6 @@ static int cpu_notify(unsigned long val, void *v)
 	return __cpu_notify(val, v, -1, NULL);
 }
 
-#ifdef CONFIG_HOTPLUG_CPU
-
 static void cpu_notify_nofail(unsigned long val, void *v)
 {
 	BUG_ON(cpu_notify(val, v));
@@ -201,6 +199,7 @@ void __ref unregister_cpu_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL(unregister_cpu_notifier);
 
+#ifdef CONFIG_HOTPLUG_CPU
 /**
  * clear_tasks_mm_cpumask - Safely clear tasks' mm_cpumask for a CPU
  * @cpu: a CPU id
-- 
2.8.0.rc2.1.gbe9624a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
