Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 55BBF6B0055
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:21 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so14104971pab.6
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:21 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gm1si15344151pac.100.2014.01.01.23.13.18
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:19 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 12/16] vrange: Support background purging for vrange-file
Date: Thu,  2 Jan 2014 16:12:20 +0900
Message-Id: <1388646744-15608-13-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

Add support to purge vrange file pages.

This is useful, since some filesystems like shmem/tmpfs use anonymous
pages, which won't be aged off the page LRU if swap is disabled.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
[jstultz: Commit message tweaks]
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vrange.c |   57 +++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 49 insertions(+), 8 deletions(-)

diff --git a/mm/vrange.c b/mm/vrange.c
index ed89835bcff4..51875f256592 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -13,6 +13,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/mm_inline.h>
 #include <linux/migrate.h>
+#include <linux/pagevec.h>
 #include <linux/shmem_fs.h>
 
 static struct kmem_cache *vrange_cachep;
@@ -853,24 +854,64 @@ out:
 	return ret;
 }
 
+static int __discard_vrange_file(struct address_space *mapping,
+			struct vrange *vrange, unsigned long *ret_discard)
+{
+	struct pagevec pvec;
+	pgoff_t index;
+	int i, ret = 0;
+	unsigned long nr_discard = 0;
+	unsigned long start_idx = vrange->node.start;
+	unsigned long end_idx = vrange->node.last;
+	const pgoff_t start = start_idx >> PAGE_CACHE_SHIFT;
+	pgoff_t end = end_idx >> PAGE_CACHE_SHIFT;
+	LIST_HEAD(pagelist);
+
+	pagevec_init(&pvec, 0);
+	index = start;
+	while (index <= end && pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+			index = page->index;
+			if (index > end)
+				break;
+			if (isolate_lru_page(page))
+				continue;
+			list_add(&page->lru, &pagelist);
+			inc_zone_page_state(page, NR_ISOLATED_ANON);
+		}
+		pagevec_release(&pvec);
+		cond_resched();
+		index++;
+	}
+
+	if (!list_empty(&pagelist))
+		nr_discard = discard_vrange_pagelist(&pagelist);
+
+	*ret_discard = nr_discard;
+	putback_lru_pages(&pagelist);
+
+	return ret;
+}
+
 static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard)
 {
 	int ret = 0;
-	struct mm_struct *mm;
 	struct vrange_root *vroot;
 	vroot = vrange->owner;
 
-	/* TODO : handle VRANGE_FILE */
-	if (vroot->type != VRANGE_MM)
-		goto out;
+	if (vroot->type == VRANGE_MM) {
+		struct mm_struct *mm = vroot->object;
+		ret = __discard_vrange_anon(mm, vrange, nr_discard);
+	} else if (vroot->type == VRANGE_FILE) {
+		struct address_space *mapping = vroot->object;
+		ret = __discard_vrange_file(mapping, vrange, nr_discard);
+	}
 
-	mm = vroot->object;
-	ret = __discard_vrange_anon(mm, vrange, nr_discard);
-out:
 	return ret;
 }
 
-
 #define VRANGE_SCAN_THRESHOLD	(4 << 20)
 
 unsigned long shrink_vrange(enum lru_list lru, struct lruvec *lruvec,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
