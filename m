Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9DDD6B000C
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:37:46 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s14-v6so12562813ioc.0
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:37:46 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-am5eur02on0703.outbound.protection.outlook.com. [2a01:111:f400:fe07::703])
        by mx.google.com with ESMTPS id w130-v6si407216iod.188.2018.08.07.08.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:37:44 -0700 (PDT)
Subject: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:37:36 +0300
Message-ID: <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This patch kills all CONFIG_SRCU defines and
the code under !CONFIG_SRCU.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 drivers/base/core.c                                |   42 --------------------
 include/linux/device.h                             |    2 -
 include/linux/rcutiny.h                            |    4 --
 include/linux/srcu.h                               |    5 --
 kernel/notifier.c                                  |    3 -
 kernel/rcu/Kconfig                                 |   12 +-----
 kernel/rcu/tree.h                                  |    5 --
 kernel/rcu/update.c                                |    4 --
 .../selftests/rcutorture/doc/TREE_RCU-kconfig.txt  |    5 --
 9 files changed, 3 insertions(+), 79 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 04bbcd779e11..8483da53c88f 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -44,7 +44,6 @@ early_param("sysfs.deprecated", sysfs_deprecated_setup);
 
 /* Device links support. */
 
-#ifdef CONFIG_SRCU
 static DEFINE_MUTEX(device_links_lock);
 DEFINE_STATIC_SRCU(device_links_srcu);
 
@@ -67,30 +66,6 @@ void device_links_read_unlock(int idx)
 {
 	srcu_read_unlock(&device_links_srcu, idx);
 }
-#else /* !CONFIG_SRCU */
-static DECLARE_RWSEM(device_links_lock);
-
-static inline void device_links_write_lock(void)
-{
-	down_write(&device_links_lock);
-}
-
-static inline void device_links_write_unlock(void)
-{
-	up_write(&device_links_lock);
-}
-
-int device_links_read_lock(void)
-{
-	down_read(&device_links_lock);
-	return 0;
-}
-
-void device_links_read_unlock(int not_used)
-{
-	up_read(&device_links_lock);
-}
-#endif /* !CONFIG_SRCU */
 
 /**
  * device_is_dependent - Check if one device depends on another one
@@ -317,7 +292,6 @@ static void device_link_free(struct device_link *link)
 	kfree(link);
 }
 
-#ifdef CONFIG_SRCU
 static void __device_link_free_srcu(struct rcu_head *rhead)
 {
 	device_link_free(container_of(rhead, struct device_link, rcu_head));
@@ -337,22 +311,6 @@ static void __device_link_del(struct kref *kref)
 	list_del_rcu(&link->c_node);
 	call_srcu(&device_links_srcu, &link->rcu_head, __device_link_free_srcu);
 }
-#else /* !CONFIG_SRCU */
-static void __device_link_del(struct kref *kref)
-{
-	struct device_link *link = container_of(kref, struct device_link, kref);
-
-	dev_info(link->consumer, "Dropping the link to %s\n",
-		 dev_name(link->supplier));
-
-	if (link->flags & DL_FLAG_PM_RUNTIME)
-		pm_runtime_drop_link(link->consumer);
-
-	list_del(&link->s_node);
-	list_del(&link->c_node);
-	device_link_free(link);
-}
-#endif /* !CONFIG_SRCU */
 
 /**
  * device_link_del - Delete a link between two devices.
diff --git a/include/linux/device.h b/include/linux/device.h
index 8f882549edee..524dc17d67be 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -827,9 +827,7 @@ struct device_link {
 	u32 flags;
 	bool rpm_active;
 	struct kref kref;
-#ifdef CONFIG_SRCU
 	struct rcu_head rcu_head;
-#endif
 };
 
 /**
diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index 8d9a0ea8f0b5..63e2b6f2e94a 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -115,11 +115,7 @@ static inline void rcu_irq_exit_irqson(void) { }
 static inline void rcu_irq_enter_irqson(void) { }
 static inline void rcu_irq_exit(void) { }
 static inline void exit_rcu(void) { }
-#ifdef CONFIG_SRCU
 void rcu_scheduler_starting(void);
-#else /* #ifndef CONFIG_SRCU */
-static inline void rcu_scheduler_starting(void) { }
-#endif /* #else #ifndef CONFIG_SRCU */
 static inline void rcu_end_inkernel_boot(void) { }
 static inline bool rcu_is_watching(void) { return true; }
 
diff --git a/include/linux/srcu.h b/include/linux/srcu.h
index 3e72a291c401..27238223a78e 100644
--- a/include/linux/srcu.h
+++ b/include/linux/srcu.h
@@ -60,11 +60,8 @@ int init_srcu_struct(struct srcu_struct *sp);
 #include <linux/srcutiny.h>
 #elif defined(CONFIG_TREE_SRCU)
 #include <linux/srcutree.h>
-#elif defined(CONFIG_SRCU)
-#error "Unknown SRCU implementation specified to kernel configuration"
 #else
-/* Dummy definition for things like notifiers.  Actual use gets link error. */
-struct srcu_struct { };
+#error "Unknown SRCU implementation specified to kernel configuration"
 #endif
 
 void call_srcu(struct srcu_struct *sp, struct rcu_head *head,
diff --git a/kernel/notifier.c b/kernel/notifier.c
index 6196af8a8223..6e4b55e74736 100644
--- a/kernel/notifier.c
+++ b/kernel/notifier.c
@@ -402,7 +402,6 @@ int raw_notifier_call_chain(struct raw_notifier_head *nh,
 }
 EXPORT_SYMBOL_GPL(raw_notifier_call_chain);
 
-#ifdef CONFIG_SRCU
 /*
  *	SRCU notifier chain routines.    Registration and unregistration
  *	use a mutex, and call_chain is synchronized by SRCU (no locks).
@@ -529,8 +528,6 @@ void srcu_init_notifier_head(struct srcu_notifier_head *nh)
 }
 EXPORT_SYMBOL_GPL(srcu_init_notifier_head);
 
-#endif /* CONFIG_SRCU */
-
 static ATOMIC_NOTIFIER_HEAD(die_chain);
 
 int notrace notify_die(enum die_val val, const char *str,
diff --git a/kernel/rcu/Kconfig b/kernel/rcu/Kconfig
index 9210379c0353..f52e55e33f0a 100644
--- a/kernel/rcu/Kconfig
+++ b/kernel/rcu/Kconfig
@@ -49,28 +49,20 @@ config RCU_EXPERT
 
 	  Say N if you are unsure.
 
-config SRCU
-	bool
-	help
-	  This option selects the sleepable version of RCU. This version
-	  permits arbitrary sleeping or blocking within RCU read-side critical
-	  sections.
-
 config TINY_SRCU
 	bool
-	default y if SRCU && TINY_RCU
+	default y if TINY_RCU
 	help
 	  This option selects the single-CPU non-preemptible version of SRCU.
 
 config TREE_SRCU
 	bool
-	default y if SRCU && !TINY_RCU
+	default y if !TINY_RCU
 	help
 	  This option selects the full-fledged version of SRCU.
 
 config TASKS_RCU
 	def_bool PREEMPT
-	select SRCU
 	help
 	  This option enables a task-based RCU implementation that uses
 	  only voluntary context switch (not preemption!), idle, and
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index 4e74df768c57..b7f76400a45e 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -489,12 +489,7 @@ static bool rcu_nohz_full_cpu(struct rcu_state *rsp);
 static void rcu_dynticks_task_enter(void);
 static void rcu_dynticks_task_exit(void);
 
-#ifdef CONFIG_SRCU
 void srcu_online_cpu(unsigned int cpu);
 void srcu_offline_cpu(unsigned int cpu);
-#else /* #ifdef CONFIG_SRCU */
-void srcu_online_cpu(unsigned int cpu) { }
-void srcu_offline_cpu(unsigned int cpu) { }
-#endif /* #else #ifdef CONFIG_SRCU */
 
 #endif /* #ifndef RCU_TREE_NONCORE */
diff --git a/kernel/rcu/update.c b/kernel/rcu/update.c
index 39cb23d22109..90de81c98524 100644
--- a/kernel/rcu/update.c
+++ b/kernel/rcu/update.c
@@ -210,8 +210,6 @@ void rcu_test_sync_prims(void)
 	synchronize_sched_expedited();
 }
 
-#if !defined(CONFIG_TINY_RCU) || defined(CONFIG_SRCU)
-
 /*
  * Switch to run-time mode once RCU has fully initialized.
  */
@@ -224,8 +222,6 @@ static int __init rcu_set_runtime_mode(void)
 }
 core_initcall(rcu_set_runtime_mode);
 
-#endif /* #if !defined(CONFIG_TINY_RCU) || defined(CONFIG_SRCU) */
-
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key rcu_lock_key;
 struct lockdep_map rcu_lock_map =
diff --git a/tools/testing/selftests/rcutorture/doc/TREE_RCU-kconfig.txt b/tools/testing/selftests/rcutorture/doc/TREE_RCU-kconfig.txt
index af6fca03602f..b4f015c3244a 100644
--- a/tools/testing/selftests/rcutorture/doc/TREE_RCU-kconfig.txt
+++ b/tools/testing/selftests/rcutorture/doc/TREE_RCU-kconfig.txt
@@ -73,9 +73,4 @@ CONFIG_TASKS_RCU
 
 	These are controlled by CONFIG_PREEMPT and/or CONFIG_SMP.
 
-CONFIG_SRCU
-
-	Selected by CONFIG_RCU_TORTURE_TEST, so cannot disable.
-
-
 boot parameters ignored: TBD
