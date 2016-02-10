Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 89459828DF
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 09:51:24 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id 9so23369869iom.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 06:51:24 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id f68si5974474iof.1.2016.02.10.06.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 06:51:23 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 1/3] mm: move max_map_count bits into mm.h
Date: Wed, 10 Feb 2016 17:52:19 +0300
Message-ID: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

max_map_count sysctl unrelated to scheduler. Move its bits from
include/linux/sched/sysctl.h to include/linux/mm.h.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 include/linux/mm.h           | 21 +++++++++++++++++++++
 include/linux/sched/sysctl.h | 21 ---------------------
 mm/mmap.c                    |  1 -
 mm/mremap.c                  |  1 -
 mm/nommu.c                   |  1 -
 5 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 516e149..979bc83 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -82,6 +82,27 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #define mm_forbids_zeropage(X)	(0)
 #endif
 
+/*
+ * Default maximum number of active map areas, this limits the number of vmas
+ * per mm struct. Users can overwrite this number by sysctl but there is a
+ * problem.
+ *
+ * When a program's coredump is generated as ELF format, a section is created
+ * per a vma. In ELF, the number of sections is represented in unsigned short.
+ * This means the number of sections should be smaller than 65535 at coredump.
+ * Because the kernel adds some informative sections to a image of program at
+ * generating coredump, we need some margin. The number of extra sections is
+ * 1-3 now and depends on arch. We use "5" as safe margin, here.
+ *
+ * ELF extended numbering allows more than 65535 sections, so 16-bit bound is
+ * not a hard limit any more. Although some userspace tools can be surprised by
+ * that.
+ */
+#define MAPCOUNT_ELF_CORE_MARGIN	(5)
+#define DEFAULT_MAX_MAP_COUNT	(USHRT_MAX - MAPCOUNT_ELF_CORE_MARGIN)
+
+extern int sysctl_max_map_count;
+
 extern unsigned long sysctl_user_reserve_kbytes;
 extern unsigned long sysctl_admin_reserve_kbytes;
 
diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index c9e4731..5f7d334 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -14,27 +14,6 @@ extern int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
 enum { sysctl_hung_task_timeout_secs = 0 };
 #endif
 
-/*
- * Default maximum number of active map areas, this limits the number of vmas
- * per mm struct. Users can overwrite this number by sysctl but there is a
- * problem.
- *
- * When a program's coredump is generated as ELF format, a section is created
- * per a vma. In ELF, the number of sections is represented in unsigned short.
- * This means the number of sections should be smaller than 65535 at coredump.
- * Because the kernel adds some informative sections to a image of program at
- * generating coredump, we need some margin. The number of extra sections is
- * 1-3 now and depends on arch. We use "5" as safe margin, here.
- *
- * ELF extended numbering allows more than 65535 sections, so 16-bit bound is
- * not a hard limit any more. Although some userspace tools can be surprised by
- * that.
- */
-#define MAPCOUNT_ELF_CORE_MARGIN	(5)
-#define DEFAULT_MAX_MAP_COUNT	(USHRT_MAX - MAPCOUNT_ELF_CORE_MARGIN)
-
-extern int sysctl_max_map_count;
-
 extern unsigned int sysctl_sched_latency;
 extern unsigned int sysctl_sched_min_granularity;
 extern unsigned int sysctl_sched_wakeup_granularity;
diff --git a/mm/mmap.c b/mm/mmap.c
index 2f2415a..4afb2a2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -37,7 +37,6 @@
 #include <linux/khugepaged.h>
 #include <linux/uprobes.h>
 #include <linux/rbtree_augmented.h>
-#include <linux/sched/sysctl.h>
 #include <linux/notifier.h>
 #include <linux/memory.h>
 #include <linux/printk.h>
diff --git a/mm/mremap.c b/mm/mremap.c
index d77946a..e8329d1 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -20,7 +20,6 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
-#include <linux/sched/sysctl.h>
 #include <linux/uaccess.h>
 #include <linux/mm-arch-hooks.h>
 
diff --git a/mm/nommu.c b/mm/nommu.c
index fbf6f0f1..9bdf8b1 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -33,7 +33,6 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/audit.h>
-#include <linux/sched/sysctl.h>
 #include <linux/printk.h>
 
 #include <asm/uaccess.h>
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
