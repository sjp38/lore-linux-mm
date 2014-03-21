Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id B80306B0284
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 17:18:00 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2808974pdi.5
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 14:18:00 -0700 (PDT)
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
        by mx.google.com with ESMTPS id m8si4119548pbd.288.2014.03.21.14.17.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 14:17:59 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so2900316pad.31
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 14:17:59 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 4/5] vrange: Set affected pages referenced when marking volatile
Date: Fri, 21 Mar 2014 14:17:34 -0700
Message-Id: <1395436655-21670-5-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

One issue that some potential users were concerned about, was that
they wanted to ensure that all the pages from one volatile range
were purged before we purge pages from a different volatile range.
This would prevent the case where they have 4 large objects, and
the system purges one page from each object, casuing all of the
objects to have to be re-created.

The counter-point to this case, is when an application is using the
SIGBUS semantics to continue to access pages after they have been
marked volatile. In that case, the desire was that the most recently
touched pages be purged last, and only the "cold" pages be purged
from the specified range.

Instead of adding option flags for the various usage model (at least
initially), one way of getting a solutoin for both uses would be to
have the act of marking pages as volatile in effect mark the pages
as accessed. Since all of the pages in the range would be marked
together, they would be of the same "age" and would (approximately)
be purged together. Further, if any pages in the range were accessed
after being marked volatile, they would be moved to the end of the
lru and be purged later.

This patch provides this solution by walking the pages in the range
and setting them accessed when set volatile.

This does have a performance impact, as we have to touch each page
when setting them volatile. Additionally, while setting all the
pages to the same age solves the basic problem, there is still an
open question of: What age all the pages should be set to?

One could consider them all recently accessed, which would put them
at the end of the active lru. Or one could possibly move them all to
the end of the inactive lru, making them more likely to be purged
sooner.

Another possibility would be to not affect the pages at all when
marking them as volatile, and allow applications to use madvise
prior to marking any pages as volatile to age them together, if
that behavior was needed. In that case this patch would be
unnecessary.

Thoughts on the best approach would be greatly appreciated.


Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 mm/vrange.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/mm/vrange.c b/mm/vrange.c
index 28ceb6f..9be8f45 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -79,6 +79,73 @@ static int vrange_check_purged(struct mm_struct *mm,
 
 }
 
+
+/**
+ * vrange_mark_accessed_pte - Marks pte pages in range accessed
+ *
+ * Iterates over the ptes in the pmd and marks the coresponding page
+ * as accessed. This ensures all the pages in the range are of the
+ * same "age", so that when pages are purged, we will most likely purge
+ * them together.
+ */
+static int vrange_mark_accessed_pte(pmd_t *pmd, unsigned long addr,
+					unsigned long end, struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->private;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	if (pmd_trans_huge(*pmd))
+		return 0;
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		if (pte_present(*pte)) {
+			struct page *page;
+
+			page = vm_normal_page(vma, addr, *pte);
+			if (IS_ERR_OR_NULL(page))
+				break;
+			get_page(page);
+			/*
+			 * XXX - So here we may want to do something
+			 * else other then marking the page accessed.
+			 * Setting them to all be the same "age" ensures
+			 * they are pruged together, but its not clear
+			 * what that "age" should be.
+			 */
+			mark_page_accessed(page);
+			put_page(page);
+		}
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+
+	return 0;
+}
+
+
+/**
+ * vrange_mark_range_accessed - Sets up a mm_walk to mark pages accessed
+ *
+ * Sets up and calls wa_page_range() to mark affected pages as accessed.
+ */
+static void vrange_mark_range_accessed(struct vm_area_struct *vma,
+						unsigned long start,
+						unsigned long end)
+{
+	struct mm_walk vrange_walk = {
+		.pmd_entry = vrange_mark_accessed_pte,
+		.mm = vma->vm_mm,
+		.private = vma,
+	};
+
+	walk_page_range(start, end, &vrange_walk);
+}
+
+
 /**
  * do_vrange - Marks or clears VMAs in the range (start-end) as VM_VOLATILE
  *
@@ -165,6 +232,10 @@ static ssize_t do_vrange(struct mm_struct *mm, unsigned long start,
 success:
 		vma->vm_flags = new_flags;
 
+		/* Mark the vma range as accessed */
+		if (mode == VRANGE_VOLATILE)
+			vrange_mark_range_accessed(vma, start, tmp);
+
 		/* update count to distance covered so far*/
 		count = tmp - orig_start;
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
