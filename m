Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1656B003B
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:17 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so14194153pad.17
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:16 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ll1si23308157pab.57.2014.01.01.23.13.14
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:16 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 07/16] vrange: Purge volatile pages when memory is tight
Date: Thu,  2 Jan 2014 16:12:15 +0900
Message-Id: <1388646744-15608-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

This patch adds purging logic of volatile pages into direct
reclaim path so that if vrange pages are selected as victim,
they could be discarded rather than swapping out.

Direct purging doesn't consider volatile page's recency because it
would be better to free the page rather than swapping out
another working set pages. This makes sense because userspace
specifies "please remove free these pages when memory is tight"
via the vrange syscall.

This however is an in-kernel behavior and the purging logic
could later change. Applications should not assume anything
about the volatile page purging order, much as they shouldn't
assume anything about the page swapout order.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
[jstultz: commit log tweaks]
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8bff386e65a0..630723812ce3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -43,6 +43,7 @@
 #include <linux/sysctl.h>
 #include <linux/oom.h>
 #include <linux/prefetch.h>
+#include <linux/vrange.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -665,6 +666,7 @@ enum page_references {
 	PAGEREF_RECLAIM,
 	PAGEREF_RECLAIM_CLEAN,
 	PAGEREF_KEEP,
+	PAGEREF_DISCARD,
 	PAGEREF_ACTIVATE,
 };
 
@@ -685,6 +687,13 @@ static enum page_references page_check_references(struct page *page,
 	if (vm_flags & VM_LOCKED)
 		return PAGEREF_RECLAIM;
 
+	/*
+	 * If volatile page is reached on LRU's tail, we discard the
+	 * page without considering recycle the page.
+	 */
+	if (vm_flags & VM_VRANGE)
+		return PAGEREF_DISCARD;
+
 	if (referenced_ptes) {
 		if (PageSwapBacked(page))
 			return PAGEREF_ACTIVATE;
@@ -912,6 +921,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
+		/*
+		 * NOTE: Do not change case ordering.
+		 * If you should change, update mapping after discard_vpage
+		 * because page->mapping could be NULL if it's purged.
+		 */
+		case PAGEREF_DISCARD:
+			if (may_enter_fs && discard_vpage(page) == 0)
+				goto free_it;
 		case PAGEREF_KEEP:
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
