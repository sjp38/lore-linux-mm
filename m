Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8C56B04A1
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:30:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x64so12772879wmg.11
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:30:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u11si3953216eda.521.2017.07.27.08.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jul 2017 08:30:49 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/3] sched/loadavg: consolidate LOAD_INT, LOAD_FRAC macros
Date: Thu, 27 Jul 2017 11:30:08 -0400
Message-Id: <20170727153010.23347-2-hannes@cmpxchg.org>
In-Reply-To: <20170727153010.23347-1-hannes@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

There are several identical definitions of those macros in places that
mess with fixed-point load averages. Provide an official version.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/powerpc/platforms/cell/spufs/sched.c | 3 ---
 arch/s390/appldata/appldata_os.c          | 4 ----
 drivers/cpuidle/governors/menu.c          | 4 ----
 fs/proc/loadavg.c                         | 3 ---
 include/linux/sched/loadavg.h             | 3 +++
 kernel/debug/kdb/kdb_main.c               | 7 +------
 6 files changed, 4 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/sched.c b/arch/powerpc/platforms/cell/spufs/sched.c
index 1fbb5da17dd2..de544070def3 100644
--- a/arch/powerpc/platforms/cell/spufs/sched.c
+++ b/arch/powerpc/platforms/cell/spufs/sched.c
@@ -1071,9 +1071,6 @@ void spuctx_switch_state(struct spu_context *ctx,
 	}
 }
 
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
-
 static int show_spu_loadavg(struct seq_file *s, void *private)
 {
 	int a, b, c;
diff --git a/arch/s390/appldata/appldata_os.c b/arch/s390/appldata/appldata_os.c
index 45b3178200ab..a8aac17e1e82 100644
--- a/arch/s390/appldata/appldata_os.c
+++ b/arch/s390/appldata/appldata_os.c
@@ -24,10 +24,6 @@
 
 #include "appldata.h"
 
-
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
-
 /*
  * OS data
  *
diff --git a/drivers/cpuidle/governors/menu.c b/drivers/cpuidle/governors/menu.c
index b2330fd69e34..3d7275ea541d 100644
--- a/drivers/cpuidle/governors/menu.c
+++ b/drivers/cpuidle/governors/menu.c
@@ -132,10 +132,6 @@ struct menu_device {
 	int		interval_ptr;
 };
 
-
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
-
 static inline int get_loadavg(unsigned long load)
 {
 	return LOAD_INT(load) * 10 + LOAD_FRAC(load) / 10;
diff --git a/fs/proc/loadavg.c b/fs/proc/loadavg.c
index 983fce5c2418..111a25e4b088 100644
--- a/fs/proc/loadavg.c
+++ b/fs/proc/loadavg.c
@@ -9,9 +9,6 @@
 #include <linux/seqlock.h>
 #include <linux/time.h>
 
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
-
 static int loadavg_proc_show(struct seq_file *m, void *v)
 {
 	unsigned long avnrun[3];
diff --git a/include/linux/sched/loadavg.h b/include/linux/sched/loadavg.h
index 4264bc6b2c27..745483bb5cca 100644
--- a/include/linux/sched/loadavg.h
+++ b/include/linux/sched/loadavg.h
@@ -26,6 +26,9 @@ extern void get_avenrun(unsigned long *loads, unsigned long offset, int shift);
 	load += n*(FIXED_1-exp); \
 	load >>= FSHIFT;
 
+#define LOAD_INT(x) ((x) >> FSHIFT)
+#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
+
 extern void calc_global_load(unsigned long ticks);
 
 #endif /* _LINUX_SCHED_LOADAVG_H */
diff --git a/kernel/debug/kdb/kdb_main.c b/kernel/debug/kdb/kdb_main.c
index c8146d53ca67..2dddd25ccd7a 100644
--- a/kernel/debug/kdb/kdb_main.c
+++ b/kernel/debug/kdb/kdb_main.c
@@ -2571,16 +2571,11 @@ static int kdb_summary(int argc, const char **argv)
 	}
 	kdb_printf("%02ld:%02ld\n", val.uptime/(60*60), (val.uptime/60)%60);
 
-	/* lifted from fs/proc/proc_misc.c::loadavg_read_proc() */
-
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
 	kdb_printf("load avg   %ld.%02ld %ld.%02ld %ld.%02ld\n",
 		LOAD_INT(val.loads[0]), LOAD_FRAC(val.loads[0]),
 		LOAD_INT(val.loads[1]), LOAD_FRAC(val.loads[1]),
 		LOAD_INT(val.loads[2]), LOAD_FRAC(val.loads[2]));
-#undef LOAD_INT
-#undef LOAD_FRAC
+
 	/* Display in kilobytes */
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	kdb_printf("\nMemTotal:       %8lu kB\nMemFree:        %8lu kB\n"
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
