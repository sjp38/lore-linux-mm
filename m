Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id B3D696B006E
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 21:12:10 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id u10so3685344lbd.7
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 18:12:10 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id wv9si14117613lbb.53.2014.08.01.18.12.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 18:12:08 -0700 (PDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so3802962lbi.13
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 18:12:07 -0700 (PDT)
From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v4 1/2] mm/highmem: make kmap cache coloring aware
Date: Sat,  2 Aug 2014 05:11:38 +0400
Message-Id: <1406941899-19932-2-git-send-email-jcmvbkbc@gmail.com>
In-Reply-To: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com>
References: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xtensa@linux-xtensa.org
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Steven Hill <Steven.Hill@imgtec.com>, Max Filippov <jcmvbkbc@gmail.com>

User-visible effect:
Architectures that choose this method of maintaining cache coherency
(MIPS and xtensa currently) are able to use high memory on cores with
aliasing data cache. Without this fix such architectures can not use
high memory (in case of xtensa it means that at most 128 MBytes of
physical memory is available).

The problem:
VIPT cache with way size larger than MMU page size may suffer from
aliasing problem: a single physical address accessed via different
virtual addresses may end up in multiple locations in the cache.
Virtual mappings of a physical address that always get cached in
different cache locations are said to have different colors.
L1 caching hardware usually doesn't handle this situation leaving it
up to software. Software must avoid this situation as it leads to
data corruption.

What can be done:
One way to handle this is to flush and invalidate data cache every time
page mapping changes color. The other way is to always map physical page
at a virtual address with the same color. Low memory pages already have
this property. Giving architecture a way to control color of high memory
page mapping allows reusing of existing low memory cache alias handling
code.

How this is done with this patch:
Provide hooks that allow architectures with aliasing cache to align
mapping address of high pages according to their color. Such architectures
may enforce similar coloring of low- and high-memory page mappings and
reuse existing cache management functions to support highmem.

This code is based on the implementation of similar feature for MIPS by
Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v3->v4:
- drop #include <asm/highmem.h> from mm/highmem.c as it's done in
  linux/highmem.h;
- add 'User-visible effect' section to changelog.

Changes v2->v3:
- drop ARCH_PKMAP_COLORING, check gif et_pkmap_color is defined instead;
- add comment stating that arch should place definitions into
  asm/highmem.h, include it directly to mm/highmem.c;
- replace macros with inline functions, change set_pkmap_color to
  get_pkmap_color which better fits inline function model;
- drop get_last_pkmap_nr;
- replace get_next_pkmap_counter with get_pkmap_entries_count, leave
  original counting code;
- introduce get_pkmap_wait_queue_head and make sleeping/waking dependent
  on mapping color;
- move file-scope static variables last_pkmap_nr and pkmap_map_wait into
  get_next_pkmap_nr and get_pkmap_wait_queue_head respectively;
- document new functions;
- expand patch description and change authorship.

Changes v1->v2:
- define set_pkmap_color(pg, cl) as do { } while (0) instead of /* */;
- rename is_no_more_pkmaps to no_more_pkmaps;
- change 'if (count > 0)' to 'if (count)' to better match the original
  code behavior;

 mm/highmem.c | 86 ++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 75 insertions(+), 11 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index b32b70c..123bcd3 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -44,6 +44,66 @@ DEFINE_PER_CPU(int, __kmap_atomic_idx);
  */
 #ifdef CONFIG_HIGHMEM
 
+/*
+ * Architecture with aliasing data cache may define the following family of
+ * helper functions in its asm/highmem.h to control cache color of virtual
+ * addresses where physical memory pages are mapped by kmap.
+ */
+#ifndef get_pkmap_color
+
+/*
+ * Determine color of virtual address where the page should be mapped.
+ */
+static inline unsigned int get_pkmap_color(struct page *page)
+{
+	return 0;
+}
+#define get_pkmap_color get_pkmap_color
+
+/*
+ * Get next index for mapping inside PKMAP region for page with given color.
+ */
+static inline unsigned int get_next_pkmap_nr(unsigned int color)
+{
+	static unsigned int last_pkmap_nr;
+
+	last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
+	return last_pkmap_nr;
+}
+
+/*
+ * Determine if page index inside PKMAP region (pkmap_nr) of given color
+ * has wrapped around PKMAP region end. When this happens an attempt to
+ * flush all unused PKMAP slots is made.
+ */
+static inline int no_more_pkmaps(unsigned int pkmap_nr, unsigned int color)
+{
+	return pkmap_nr == 0;
+}
+
+/*
+ * Get the number of PKMAP entries of the given color. If no free slot is
+ * found after checking that many entries, kmap will sleep waiting for
+ * someone to call kunmap and free PKMAP slot.
+ */
+static inline int get_pkmap_entries_count(unsigned int color)
+{
+	return LAST_PKMAP;
+}
+
+/*
+ * Get head of a wait queue for PKMAP entries of the given color.
+ * Wait queues for different mapping colors should be independent to avoid
+ * unnecessary wakeups caused by freeing of slots of other colors.
+ */
+static inline wait_queue_head_t *get_pkmap_wait_queue_head(unsigned int color)
+{
+	static DECLARE_WAIT_QUEUE_HEAD(pkmap_map_wait);
+
+	return &pkmap_map_wait;
+}
+#endif
+
 unsigned long totalhigh_pages __read_mostly;
 EXPORT_SYMBOL(totalhigh_pages);
 
@@ -68,13 +128,10 @@ unsigned int nr_free_highpages (void)
 }
 
 static int pkmap_count[LAST_PKMAP];
-static unsigned int last_pkmap_nr;
 static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(kmap_lock);
 
 pte_t * pkmap_page_table;
 
-static DECLARE_WAIT_QUEUE_HEAD(pkmap_map_wait);
-
 /*
  * Most architectures have no use for kmap_high_get(), so let's abstract
  * the disabling of IRQ out of the locking in that case to save on a
@@ -161,15 +218,17 @@ static inline unsigned long map_new_virtual(struct page *page)
 {
 	unsigned long vaddr;
 	int count;
+	unsigned int last_pkmap_nr;
+	unsigned int color = get_pkmap_color(page);
 
 start:
-	count = LAST_PKMAP;
+	count = get_pkmap_entries_count(color);
 	/* Find an empty entry */
 	for (;;) {
-		last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
-		if (!last_pkmap_nr) {
+		last_pkmap_nr = get_next_pkmap_nr(color);
+		if (no_more_pkmaps(last_pkmap_nr, color)) {
 			flush_all_zero_pkmaps();
-			count = LAST_PKMAP;
+			count = get_pkmap_entries_count(color);
 		}
 		if (!pkmap_count[last_pkmap_nr])
 			break;	/* Found a usable entry */
@@ -181,12 +240,14 @@ start:
 		 */
 		{
 			DECLARE_WAITQUEUE(wait, current);
+			wait_queue_head_t *pkmap_map_wait =
+				get_pkmap_wait_queue_head(color);
 
 			__set_current_state(TASK_UNINTERRUPTIBLE);
-			add_wait_queue(&pkmap_map_wait, &wait);
+			add_wait_queue(pkmap_map_wait, &wait);
 			unlock_kmap();
 			schedule();
-			remove_wait_queue(&pkmap_map_wait, &wait);
+			remove_wait_queue(pkmap_map_wait, &wait);
 			lock_kmap();
 
 			/* Somebody else might have mapped it while we slept */
@@ -274,6 +335,8 @@ void kunmap_high(struct page *page)
 	unsigned long nr;
 	unsigned long flags;
 	int need_wakeup;
+	unsigned int color = get_pkmap_color(page);
+	wait_queue_head_t *pkmap_map_wait;
 
 	lock_kmap_any(flags);
 	vaddr = (unsigned long)page_address(page);
@@ -299,13 +362,14 @@ void kunmap_high(struct page *page)
 		 * no need for the wait-queue-head's lock.  Simply
 		 * test if the queue is empty.
 		 */
-		need_wakeup = waitqueue_active(&pkmap_map_wait);
+		pkmap_map_wait = get_pkmap_wait_queue_head(color);
+		need_wakeup = waitqueue_active(pkmap_map_wait);
 	}
 	unlock_kmap_any(flags);
 
 	/* do wake-up, if needed, race-free outside of the spin lock */
 	if (need_wakeup)
-		wake_up(&pkmap_map_wait);
+		wake_up(pkmap_map_wait);
 }
 
 EXPORT_SYMBOL(kunmap_high);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
