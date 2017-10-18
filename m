Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 79C826B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 05:13:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z80so3137516pff.11
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:13:38 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z14si6668452pgc.589.2017.10.18.02.13.36
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 02:13:37 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make it not unwind as default
Date: Wed, 18 Oct 2017 18:13:25 +0900
Message-Id: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

Johan Hovold reported a performance regression by crossrelease like:

> Boot time (from "Linux version" to login prompt) had in fact doubled
> since 4.13 where it took 17 seconds (with my current config) compared to
> the 35 seconds I now see with 4.14-rc4.
>
> I quick bisect pointed to lockdep and specifically the following commit:
>
> 	28a903f63ec0 ("locking/lockdep: Handle non(or multi)-acquisition
> 	               of a crosslock")
>
> which I've verified is the commit which doubled the boot time (compared
> to 28a903f63ec0^) (added by lockdep crossrelease series [1]).

Currently crossrelease performs unwind on every acquisition. But, that
overloads systems too much. So this patch makes unwind optional and set
it to N as default. Instead, it records only acquire_ip normally. Of
course, unwind is sometimes required for full analysis. In that case, we
can set CROSSRELEASE_STACK_TRACE to Y and use it.

In my qemu ubuntu machin (x86_64, 4 cores, 512M), the regression was
fixed like, measuring timestamp of "Freeing unused kernel memory":

1. No lockdep enabled
   Average : 1.543353 secs

2. Lockdep enabled
   Average : 1.570806 secs

3. Lockdep enabled + crossrelease enabled
   Average : 1.870317 secs

4. Lockdep enabled + crossrelease enabled + this patch applied
   Average : 1.574143 secs

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/lockdep.h  |  4 ++++
 kernel/locking/lockdep.c |  5 +++++
 lib/Kconfig.debug        | 15 +++++++++++++++
 3 files changed, 24 insertions(+)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index bfa8e0b..70358b5 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -278,7 +278,11 @@ struct held_lock {
 };
 
 #ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#ifdef CONFIG_CROSSRELEASE_STACK_TRACE
 #define MAX_XHLOCK_TRACE_ENTRIES 5
+#else
+#define MAX_XHLOCK_TRACE_ENTRIES 1
+#endif
 
 /*
  * This is for keeping locks waiting for commit so that true dependencies
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index e36e652..5c2ddf2 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4863,8 +4863,13 @@ static void add_xhlock(struct held_lock *hlock)
 	xhlock->trace.nr_entries = 0;
 	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
 	xhlock->trace.entries = xhlock->trace_entries;
+#ifdef CONFIG_CROSSRELEASE_STACK_TRACE
 	xhlock->trace.skip = 3;
 	save_stack_trace(&xhlock->trace);
+#else
+	xhlock->trace.nr_entries = 1;
+	xhlock->trace.entries[0] = hlock->acquire_ip;
+#endif
 }
 
 static inline int same_context_xhlock(struct hist_lock *xhlock)
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 3db9167..5be7bdd 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1225,6 +1225,21 @@ config LOCKDEP_COMPLETIONS
 	 A deadlock caused by wait_for_completion() and complete() can be
 	 detected by lockdep using crossrelease feature.
 
+config CROSSRELEASE_STACK_TRACE
+	bool "Record more than one entity of stack trace in crossrelease"
+	depends on LOCKDEP_CROSSRELEASE
+	default n
+	help
+	 Crossrelease feature needs to record stack traces for all
+	 acquisitions for later use. And only acquire_ip is normally
+	 recorded because the unwind operation is too expensive. However,
+	 sometimes more than acquire_ip are required for full analysis.
+	 In the case that we need to record more than one entity of
+	 stack trace using unwind, this feature would be useful, with
+	 taking more overhead.
+
+	 If unsure, say N.
+
 config DEBUG_LOCKDEP
 	bool "Lock dependency engine debugging"
 	depends on DEBUG_KERNEL && LOCKDEP
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
