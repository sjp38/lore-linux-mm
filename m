Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id E5DC96B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:18:17 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so31711167pdb.9
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 00:18:17 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ey4si13293579pdb.189.2015.02.24.00.18.16
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 00:18:17 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH RFC 1/4] mm: throttle MADV_FREE
Date: Tue, 24 Feb 2015 17:18:14 +0900
Message-Id: <1424765897-27377-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Minchan Kim <minchan@kernel.org>

Recently, Shaohua reported that MADV_FREE is much slower than
MADV_DONTNEED in his MADV_FREE bomb test. The reason is many of
applications went to stall with direct reclaim since kswapd's
reclaim speed isn't fast than applications's allocation speed
so that it causes lots of stall and lock contention.

This patch throttles MADV_FREEing so it works only if there
are enough pages in the system which will not trigger backgroud/
direct reclaim. Otherwise, MADV_FREE falls back to MADV_DONTNEED
because there is no point to delay freeing if we know system
is under memory pressure.

When I test the patch on my 3G machine + 12 CPU + 8G swap,
test: 12 processes

loop = 5;
mmap(512M);
while (loop--) {
	memset(512M);
	madvise(MADV_FREE or MADV_DONTNEED);
}

1) dontneed: 6.78user 234.09system 0:48.89elapsed
2) madvfree: 6.03user 401.17system 1:30.67elapsed
3) madvfree + this ptach: 5.68user 113.42system 0:36.52elapsed

It's clearly win.

Reported-by: Shaohua Li <shli@kernel.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 6d0fcb8921c2..81bb26ecf064 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -523,8 +523,17 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		 * XXX: In this implementation, MADV_FREE works like
 		 * MADV_DONTNEED on swapless system or full swap.
 		 */
-		if (get_nr_swap_pages() > 0)
-			return madvise_free(vma, prev, start, end);
+		if (get_nr_swap_pages() > 0) {
+			unsigned long threshold;
+			/*
+			 * If we have trobule with memory pressure(ie,
+			 * under high watermark), free pages instantly.
+			 */
+			threshold = min_free_kbytes >> (PAGE_SHIFT - 10);
+			threshold = threshold + (threshold >> 1);
+			if (nr_free_pages() > threshold)
+				return madvise_free(vma, prev, start, end);
+		}
 		/* passthrough */
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
