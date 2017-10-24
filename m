Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A449E6B0253
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 05:39:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z11so18085149pfk.23
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 02:39:06 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 9si6168201pgg.741.2017.10.24.02.38.58
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 02:38:59 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 2/8] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make it not unwind as default
Date: Tue, 24 Oct 2017 18:38:03 +0900
Message-Id: <1508837889-16932-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
References: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

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
fixed like, measuring booting times with 'perf stat --null --repeat 10
$QEMU', where $QEMU launchs a kernel with init=/bin/true:

1. No lockdep enabled

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.756558155 seconds time elapsed                    ( +-  0.09% )

2. Lockdep enabled

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.968710420 seconds time elapsed                    ( +-  0.12% )

3. Lockdep enabled + crossrelease enabled

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       3.153839636 seconds time elapsed                    ( +-  0.31% )

4. Lockdep enabled + crossrelease enabled + this patch applied

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.963669551 seconds time elapsed                    ( +-  0.11% )

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
index 3db9167..90ea784 100644
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
+	 The lockdep "cross-release" feature needs to record stack traces
+	 (of calling functions) for all acquisitions, for eventual later
+	 use during analysis. By default only a single caller is recorded,
+	 because the unwind operation can be very expensive with deeper
+	 stack chains. However, sometimes deeper traces are required for
+	 full analysis. This option turns on the saving of the full stack
+	 trace entries.
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
