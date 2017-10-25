Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA1D6B0261
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:11:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w24so16139327pgm.7
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 22:11:42 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 3si979979plz.636.2017.10.24.22.11.39
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 22:11:40 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 2/7] locking/lockdep: Add a boot parameter allowing unwind in cross-release and disable it by default
Date: Wed, 25 Oct 2017 14:11:07 +0900
Message-Id: <1508908272-15757-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
References: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

Johan Hovold reported a heavy performance regression caused by lockdep
cross-release:

 > Boot time (from "Linux version" to login prompt) had in fact doubled
 > since 4.13 where it took 17 seconds (with my current config) compared to
 > the 35 seconds I now see with 4.14-rc4.
 >
 > I quick bisect pointed to lockdep and specifically the following commit:
 >
 >	28a903f63ec0 ("locking/lockdep: Handle non(or multi)-acquisition
 >	               of a crosslock")
 >
 > which I've verified is the commit which doubled the boot time (compared
 > to 28a903f63ec0^) (added by lockdep crossrelease series [1]).

Currently cross-release performs unwind on every acquisition, but that
is very expensive.

This patch makes unwind optional and disables it by default and only
records acquire_ip.

Full stack traces are sometimes required for full analysis, in which
case a boot paramter, crossrelease_fullstack, can be specified.

On my qemu Ubuntu machine (x86_64, 4 cores, 512M), the regression was
fixed. We measure boot times with 'perf stat --null --repeat 10 $QEMU',
where $QEMU launches a kernel with init=/bin/true:

1. No lockdep enabled:

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.756558155 seconds time elapsed                    ( +-  0.09% )

2. Lockdep enabled:

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.968710420 seconds time elapsed                    ( +-  0.12% )

3. Lockdep enabled + cross-release enabled:

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       3.153839636 seconds time elapsed                    ( +-  0.31% )

4. Lockdep enabled + cross-release enabled + this patch applied:

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.963669551 seconds time elapsed                    ( +-  0.11% )

I.e. lockdep cross-release performance is now indistinguishable from
vanilla lockdep.

Reported-by: Johan Hovold <johan@kernel.org>
Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 Documentation/admin-guide/kernel-parameters.txt |  3 +++
 kernel/locking/lockdep.c                        | 19 +++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index ead7f40..4107b01 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -709,6 +709,9 @@
 			It will be ignored when crashkernel=X,high is not used
 			or memory reserved is below 4G.
 
+	crossrelease_fullstack
+			[KNL] Allow to record full stack trace in cross-release
+
 	cryptomgr.notests
                         [KNL] Disable crypto self-tests
 
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index e36e652..160b5d6 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -76,6 +76,15 @@
 #define lock_stat 0
 #endif
 
+static int crossrelease_fullstack;
+static int __init allow_crossrelease_fullstack(char *str)
+{
+	crossrelease_fullstack = 1;
+	return 0;
+}
+
+early_param("crossrelease_fullstack", allow_crossrelease_fullstack);
+
 /*
  * lockdep_lock: protects the lockdep graph, the hashes and the
  *               class/list/hash allocators.
@@ -4863,8 +4872,14 @@ static void add_xhlock(struct held_lock *hlock)
 	xhlock->trace.nr_entries = 0;
 	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
 	xhlock->trace.entries = xhlock->trace_entries;
-	xhlock->trace.skip = 3;
-	save_stack_trace(&xhlock->trace);
+
+	if (crossrelease_fullstack) {
+		xhlock->trace.skip = 3;
+		save_stack_trace(&xhlock->trace);
+	} else {
+		xhlock->trace.nr_entries = 1;
+		xhlock->trace.entries[0] = hlock->acquire_ip;
+	}
 }
 
 static inline int same_context_xhlock(struct hist_lock *xhlock)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
