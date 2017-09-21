Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C66086B0253
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 03:45:30 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 23so3688712lfs.0
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 00:45:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor242346lfd.77.2017.09.21.00.45.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 00:45:29 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH] KSM: Replace jhash2 with xxhash
Date: Thu, 21 Sep 2017 10:45:19 +0300
Message-Id: <20170921074519.9333-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timofey Titovets <nefelim4ag@gmail.com>

xxhash much faster then jhash,
ex. for x86_64 host:
PAGE_SIZE: 4096, loop count: 1048576
jhash2:   0xacbc7a5b            time: 1907 ms,  th:  2251.9 MiB/s
xxhash32: 0x570da981            time: 739 ms,   th:  5809.4 MiB/s
xxhash64: 0xa1fa032ab85bbb62    time: 371 ms,   th: 11556.6 MiB/s

xxhash64 on x86_32 work with ~ same speed as jhash2.
xxhash32 on x86_32 work with ~ same speed as for x86_64

So replace jhash with xxhash,
and use fastest version for current target ARCH.

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
---
 mm/Kconfig |  1 +
 mm/ksm.c   | 25 ++++++++++++++++++-------
 2 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 9c4bdddd80c2..252ab266ac23 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -305,6 +305,7 @@ config MMU_NOTIFIER
 config KSM
 	bool "Enable KSM for page merging"
 	depends on MMU
+	select XXHASH
 	help
 	  Enable Kernel Samepage Merging: KSM periodically scans those areas
 	  of an application's address space that an app has advised may be
diff --git a/mm/ksm.c b/mm/ksm.c
index 15dd7415f7b3..e012d9778c18 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -25,7 +25,8 @@
 #include <linux/pagemap.h>
 #include <linux/rmap.h>
 #include <linux/spinlock.h>
-#include <linux/jhash.h>
+#include <linux/xxhash.h>
+#include <linux/bitops.h> /* BITS_PER_LONG */
 #include <linux/delay.h>
 #include <linux/kthread.h>
 #include <linux/wait.h>
@@ -51,6 +52,12 @@
 #define DO_NUMA(x)	do { } while (0)
 #endif
 
+#if BITS_PER_LONG == 64
+typedef	u64	xxhash;
+#else
+typedef	u32	xxhash;
+#endif
+
 /*
  * A few notes about the KSM scanning process,
  * to make it easier to understand the data structures below:
@@ -186,7 +193,7 @@ struct rmap_item {
 	};
 	struct mm_struct *mm;
 	unsigned long address;		/* + low bits used for flags below */
-	unsigned int oldchecksum;	/* when unstable */
+	xxhash oldchecksum;		/* when unstable */
 	union {
 		struct rb_node node;	/* when node of unstable tree */
 		struct {		/* when listed from stable tree */
@@ -255,7 +262,7 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
 /* Checksum of an empty (zeroed) page */
-static unsigned int zero_checksum __read_mostly;
+static xxhash zero_checksum __read_mostly;
 
 /* Whether to merge empty (zeroed) pages with actual zero pages */
 static bool ksm_use_zero_pages __read_mostly;
@@ -982,11 +989,15 @@ static int unmerge_and_remove_all_rmap_items(void)
 }
 #endif /* CONFIG_SYSFS */
 
-static u32 calc_checksum(struct page *page)
+static xxhash calc_checksum(struct page *page)
 {
-	u32 checksum;
+	xxhash checksum;
 	void *addr = kmap_atomic(page);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+#if BITS_PER_LONG == 64
+	checksum = xxh64(addr, PAGE_SIZE, 0);
+#else
+	checksum = xxh32(addr, PAGE_SIZE, 0);
+#endif
 	kunmap_atomic(addr);
 	return checksum;
 }
@@ -1994,7 +2005,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	struct page *tree_page = NULL;
 	struct stable_node *stable_node;
 	struct page *kpage;
-	unsigned int checksum;
+	xxhash checksum;
 	int err;
 	bool max_page_sharing_bypass = false;
 
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
