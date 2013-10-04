Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCFF6B0032
	for <linux-mm@kvack.org>; Fri,  4 Oct 2013 15:02:59 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so4392470pbb.14
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 12:02:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/2] page-types.c: support KPF_SOFTDIRTY bit
Date: Fri,  4 Oct 2013 15:02:15 -0400
Message-Id: <1380913335-17466-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org

Soft dirty bit allows us to track which pages are written since the
last clear_ref (by "echo 4 > /proc/pid/clear_refs".) This is useful
for userspace applications to know their memory footprints.

Note that the kernel exposes this flag via bit[55] of /proc/pid/pagemap,
and the semantics is not a default one (scheduled to be the default in
the near future.) However, it shifts to the new semantics at the first
clear_ref, and the users of soft dirty bit always do it before utilizing
the bit, so that's not a big deal. Users must avoid relying on the bit
in page-types before the first clear_ref.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/kernel-page-flags.h |  1 +
 tools/vm/page-types.c             | 32 ++++++++++++++++++++------------
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git v3.12-rc2-mmots-2013-09-24-17-03.orig/include/linux/kernel-page-flags.h v3.12-rc2-mmots-2013-09-24-17-03/include/linux/kernel-page-flags.h
index 546eb6a..f65ce09 100644
--- v3.12-rc2-mmots-2013-09-24-17-03.orig/include/linux/kernel-page-flags.h
+++ v3.12-rc2-mmots-2013-09-24-17-03/include/linux/kernel-page-flags.h
@@ -15,5 +15,6 @@
 #define KPF_OWNER_PRIVATE	37
 #define KPF_ARCH		38
 #define KPF_UNCACHED		39
+#define KPF_SOFTDIRTY		40
 
 #endif /* LINUX_KERNEL_PAGE_FLAGS_H */
diff --git v3.12-rc2-mmots-2013-09-24-17-03.orig/tools/vm/page-types.c v3.12-rc2-mmots-2013-09-24-17-03/tools/vm/page-types.c
index 71c9c25..d5e9d6d 100644
--- v3.12-rc2-mmots-2013-09-24-17-03.orig/tools/vm/page-types.c
+++ v3.12-rc2-mmots-2013-09-24-17-03/tools/vm/page-types.c
@@ -59,12 +59,14 @@
 #define PM_PSHIFT_BITS      6
 #define PM_PSHIFT_OFFSET    (PM_STATUS_OFFSET - PM_PSHIFT_BITS)
 #define PM_PSHIFT_MASK      (((1LL << PM_PSHIFT_BITS) - 1) << PM_PSHIFT_OFFSET)
-#define PM_PSHIFT(x)        (((u64) (x) << PM_PSHIFT_OFFSET) & PM_PSHIFT_MASK)
+#define __PM_PSHIFT(x)      (((uint64_t) (x) << PM_PSHIFT_OFFSET) & PM_PSHIFT_MASK)
 #define PM_PFRAME_MASK      ((1LL << PM_PSHIFT_OFFSET) - 1)
 #define PM_PFRAME(x)        ((x) & PM_PFRAME_MASK)
 
+#define __PM_SOFT_DIRTY      (1LL)
 #define PM_PRESENT          PM_STATUS(4LL)
 #define PM_SWAP             PM_STATUS(2LL)
+#define PM_SOFT_DIRTY       __PM_PSHIFT(__PM_SOFT_DIRTY)
 
 
 /*
@@ -83,6 +85,7 @@
 #define KPF_OWNER_PRIVATE	37
 #define KPF_ARCH		38
 #define KPF_UNCACHED		39
+#define KPF_SOFTDIRTY		40
 
 /* [48-] take some arbitrary free slots for expanding overloaded flags
  * not part of kernel API
@@ -132,6 +135,7 @@ static const char * const page_flag_names[] = {
 	[KPF_OWNER_PRIVATE]	= "O:owner_private",
 	[KPF_ARCH]		= "h:arch",
 	[KPF_UNCACHED]		= "c:uncached",
+	[KPF_SOFTDIRTY]		= "f:softdirty",
 
 	[KPF_READAHEAD]		= "I:readahead",
 	[KPF_SLOB_FREE]		= "P:slob_free",
@@ -417,7 +421,7 @@ static int bit_mask_ok(uint64_t flags)
 	return 1;
 }
 
-static uint64_t expand_overloaded_flags(uint64_t flags)
+static uint64_t expand_overloaded_flags(uint64_t flags, uint64_t pme)
 {
 	/* SLOB/SLUB overload several page flags */
 	if (flags & BIT(SLAB)) {
@@ -433,6 +437,9 @@ static uint64_t expand_overloaded_flags(uint64_t flags)
 	if ((flags & (BIT(RECLAIM) | BIT(WRITEBACK))) == BIT(RECLAIM))
 		flags ^= BIT(RECLAIM) | BIT(READAHEAD);
 
+	if (pme & PM_SOFT_DIRTY)
+		flags |= BIT(SOFTDIRTY);
+
 	return flags;
 }
 
@@ -448,11 +455,11 @@ static uint64_t well_known_flags(uint64_t flags)
 	return flags;
 }
 
-static uint64_t kpageflags_flags(uint64_t flags)
+static uint64_t kpageflags_flags(uint64_t flags, uint64_t pme)
 {
-	flags = expand_overloaded_flags(flags);
-
-	if (!opt_raw)
+	if (opt_raw)
+		flags = expand_overloaded_flags(flags, pme);
+	else
 		flags = well_known_flags(flags);
 
 	return flags;
@@ -545,9 +552,9 @@ static size_t hash_slot(uint64_t flags)
 }
 
 static void add_page(unsigned long voffset,
-		     unsigned long offset, uint64_t flags)
+		     unsigned long offset, uint64_t flags, uint64_t pme)
 {
-	flags = kpageflags_flags(flags);
+	flags = kpageflags_flags(flags, pme);
 
 	if (!bit_mask_ok(flags))
 		return;
@@ -569,7 +576,8 @@ static void add_page(unsigned long voffset,
 #define KPAGEFLAGS_BATCH	(64 << 10)	/* 64k pages */
 static void walk_pfn(unsigned long voffset,
 		     unsigned long index,
-		     unsigned long count)
+		     unsigned long count,
+		     uint64_t pme)
 {
 	uint64_t buf[KPAGEFLAGS_BATCH];
 	unsigned long batch;
@@ -583,7 +591,7 @@ static void walk_pfn(unsigned long voffset,
 			break;
 
 		for (i = 0; i < pages; i++)
-			add_page(voffset + i, index + i, buf[i]);
+			add_page(voffset + i, index + i, buf[i], pme);
 
 		index += pages;
 		count -= pages;
@@ -608,7 +616,7 @@ static void walk_vma(unsigned long index, unsigned long count)
 		for (i = 0; i < pages; i++) {
 			pfn = pagemap_pfn(buf[i]);
 			if (pfn)
-				walk_pfn(index + i, pfn, 1);
+				walk_pfn(index + i, pfn, 1, buf[i]);
 		}
 
 		index += pages;
@@ -659,7 +667,7 @@ static void walk_addr_ranges(void)
 
 	for (i = 0; i < nr_addr_ranges; i++)
 		if (!opt_pid)
-			walk_pfn(0, opt_offset[i], opt_size[i]);
+			walk_pfn(0, opt_offset[i], opt_size[i], 0);
 		else
 			walk_task(opt_offset[i], opt_size[i]);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
