Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 620496B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 08:21:48 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id x1so1386574lff.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:21:48 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id l18si6536075lfl.145.2017.02.09.05.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 05:21:47 -0800 (PST)
From: peter enderborg <peter.enderborg@sonymobile.com>
Subject: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
Date: Thu, 9 Feb 2017 14:21:45 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

This collects stats for shrinker calls and how much
waste work we do within the lowmemorykiller.

Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
---
  drivers/staging/android/Kconfig                 | 11 ++++
  drivers/staging/android/Makefile                |  1 +
  drivers/staging/android/lowmemorykiller.c       |  9 ++-
  drivers/staging/android/lowmemorykiller_stats.c | 85 +++++++++++++++++++++++++
  drivers/staging/android/lowmemorykiller_stats.h | 29 +++++++++
  5 files changed, 134 insertions(+), 1 deletion(-)
  create mode 100644 drivers/staging/android/lowmemorykiller_stats.c
  create mode 100644 drivers/staging/android/lowmemorykiller_stats.h

diff --git a/drivers/staging/android/Kconfig b/drivers/staging/android/Kconfig
index 6c00d6f..96e86c7 100644
--- a/drivers/staging/android/Kconfig
+++ b/drivers/staging/android/Kconfig
@@ -24,6 +24,17 @@ config ANDROID_LOW_MEMORY_KILLER
        scripts (/init.rc), and it defines priority values with minimum free memory size
        for each priority.

+config ANDROID_LOW_MEMORY_KILLER_STATS
+    bool "Android Low Memory Killer: collect statistics"
+    depends on ANDROID_LOW_MEMORY_KILLER
+    default n
+    help
+      Create a file in /proc/lmkstats that includes
+      collected statistics about kills, scans and counts
+      and  interaction with the shrinker. Its content
+      will be different depeding on lmk implementation used.
+
+
  source "drivers/staging/android/ion/Kconfig"

  endif # if ANDROID
diff --git a/drivers/staging/android/Makefile b/drivers/staging/android/Makefile
index 7ed1be7..d710eb2 100644
--- a/drivers/staging/android/Makefile
+++ b/drivers/staging/android/Makefile
@@ -4,3 +4,4 @@ obj-y                    += ion/

  obj-$(CONFIG_ASHMEM)            += ashmem.o
  obj-$(CONFIG_ANDROID_LOW_MEMORY_KILLER)    += lowmemorykiller.o
+obj-$(CONFIG_ANDROID_LOW_MEMORY_KILLER_STATS)    += lowmemorykiller_stats.o
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index ec3b665..15c1b38 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -42,6 +42,7 @@
  #include <linux/rcupdate.h>
  #include <linux/profile.h>
  #include <linux/notifier.h>
+#include "lowmemorykiller_stats.h"

  static u32 lowmem_debug_level = 1;
  static short lowmem_adj[6] = {
@@ -72,6 +73,7 @@ static unsigned long lowmem_deathpending_timeout;
  static unsigned long lowmem_count(struct shrinker *s,
                    struct shrink_control *sc)
  {
+    lmk_inc_stats(LMK_COUNT);
      return global_node_page_state(NR_ACTIVE_ANON) +
          global_node_page_state(NR_ACTIVE_FILE) +
          global_node_page_state(NR_INACTIVE_ANON) +
@@ -95,6 +97,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
                  global_node_page_state(NR_SHMEM) -
                  total_swapcache_pages();

+    lmk_inc_stats(LMK_SCAN);
      if (lowmem_adj_size < array_size)
          array_size = lowmem_adj_size;
      if (lowmem_minfree_size < array_size)
@@ -134,6 +137,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
          if (task_lmk_waiting(p) &&
              time_before_eq(jiffies, lowmem_deathpending_timeout)) {
              task_unlock(p);
+            lmk_inc_stats(LMK_TIMEOUT);
              rcu_read_unlock();
              return 0;
          }
@@ -179,7 +183,9 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
                   other_free * (long)(PAGE_SIZE / 1024));
          lowmem_deathpending_timeout = jiffies + HZ;
          rem += selected_tasksize;
-    }
+        lmk_inc_stats(LMK_KILL);
+    } else
+        lmk_inc_stats(LMK_WASTE);

      lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
               sc->nr_to_scan, sc->gfp_mask, rem);
@@ -196,6 +202,7 @@ static struct shrinker lowmem_shrinker = {
  static int __init lowmem_init(void)
  {
      register_shrinker(&lowmem_shrinker);
+    init_procfs_lmk();
      return 0;
  }
  device_initcall(lowmem_init);
diff --git a/drivers/staging/android/lowmemorykiller_stats.c b/drivers/staging/android/lowmemorykiller_stats.c
new file mode 100644
index 0000000..673691c
--- /dev/null
+++ b/drivers/staging/android/lowmemorykiller_stats.c
@@ -0,0 +1,85 @@
+/*
+ *  lowmemorykiller_stats
+ *
+ *  Copyright (C) 2017 Sony Mobile Communications Inc.
+ *
+ *  Author: Peter Enderborg <peter.enderborg@sonymobile.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+/* This code is bookkeeping of statistical information
+ * from lowmemorykiller and provide a node in proc "/proc/lmkstats".
+ */
+
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include "lowmemorykiller_stats.h"
+
+struct lmk_stats {
+    atomic_long_t scans; /* counter as in shrinker scans */
+    atomic_long_t kills; /* the number of sigkills sent */
+    atomic_long_t waste; /* the numer of extensive calls that did
+                  * not lead to anything
+                  */
+    atomic_long_t timeout; /* counter for shrinker calls that needed
+                * to be cancelled due to pending kills
+                */
+    atomic_long_t count; /* number of shrinker count calls */
+    atomic_long_t unknown; /* internal */
+} st;
+
+void lmk_inc_stats(int key)
+{
+    switch (key) {
+    case LMK_SCAN:
+        atomic_long_inc(&st.scans);
+        break;
+    case LMK_KILL:
+        atomic_long_inc(&st.kills);
+        break;
+    case LMK_WASTE:
+        atomic_long_inc(&st.waste);
+        break;
+    case LMK_TIMEOUT:
+        atomic_long_inc(&st.timeout);
+        break;
+    case LMK_COUNT:
+        atomic_long_inc(&st.count);
+        break;
+    default:
+        atomic_long_inc(&st.unknown);
+        break;
+    }
+}
+
+static int lmk_proc_show(struct seq_file *m, void *v)
+{
+    seq_printf(m, "kill: %ld\n", atomic_long_read(&st.kills));
+    seq_printf(m, "scan: %ld\n", atomic_long_read(&st.scans));
+    seq_printf(m, "waste: %ld\n", atomic_long_read(&st.waste));
+    seq_printf(m, "timeout: %ld\n", atomic_long_read(&st.timeout));
+    seq_printf(m, "count: %ld\n", atomic_long_read(&st.count));
+    seq_printf(m, "unknown: %ld (internal)\n",
+           atomic_long_read(&st.unknown));
+
+    return 0;
+}
+
+static int lmk_proc_open(struct inode *inode, struct file *file)
+{
+    return single_open(file, lmk_proc_show, PDE_DATA(inode));
+}
+
+static const struct file_operations lmk_proc_fops = {
+    .open        = lmk_proc_open,
+    .read        = seq_read,
+    .release    = single_release
+};
+
+int __init init_procfs_lmk(void)
+{
+    proc_create_data(LMK_PROCFS_NAME, 0444, NULL, &lmk_proc_fops, NULL);
+    return 0;
+}
diff --git a/drivers/staging/android/lowmemorykiller_stats.h b/drivers/staging/android/lowmemorykiller_stats.h
new file mode 100644
index 0000000..abeb6924
--- /dev/null
+++ b/drivers/staging/android/lowmemorykiller_stats.h
@@ -0,0 +1,29 @@
+/*
+ *  lowmemorykiller_stats interface
+ *
+ *  Copyright (C) 2017 Sony Mobile Communications Inc.
+ *
+ *  Author: Peter Enderborg <peter.enderborg@sonymobile.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+
+enum  lmk_kill_stats {
+    LMK_SCAN = 1,
+    LMK_KILL = 2,
+    LMK_WASTE = 3,
+    LMK_TIMEOUT = 4,
+    LMK_COUNT = 5
+};
+
+#define LMK_PROCFS_NAME "lmkstats"
+
+#ifdef CONFIG_ANDROID_LOW_MEMORY_KILLER_STATS
+void lmk_inc_stats(int key);
+int __init init_procfs_lmk(void);
+#else
+static inline void lmk_inc_stats(int key) { return; };
+static inline int __init init_procfs_lmk(void) { return 0; };
+#endif
-- 
2.4.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
