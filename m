Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E5C526B007E
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 16:42:42 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2709383pzk.14
        for <linux-mm@kvack.org>; Sat, 09 Jul 2011 13:42:40 -0700 (PDT)
From: Dmitry Fink <dmitry.fink@palm.com>
Subject: [PATCH] mmap: Fix and tidy up overcommit page arithmetic
Date: Sat,  9 Jul 2011 13:42:29 -0700
Message-Id: <1310244149-9885-1-git-send-email-dmitry.fink@palm.com>
In-Reply-To: <alpine.LSU.2.00.1107081433240.2840@sister.anvils>
References: <alpine.LSU.2.00.1107081433240.2840@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Fink <dmitry.fink@palm.com>

- shmem pages are not immediately available, but they are not
potentially available either, even if we swap them out, they will
just relocate from memory into swap, total amount of immediate and
potentially available memory is not going to be affected, so we
shouldn't count them as potentially free in the first place.

- nr_free_pages() is not an expensive operation anymore, there is
no need to split the decision making in two halves and repeat code.

Signed-off-by: Dmitry Fink <dmitry.fink@palm.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Hugh Dickins <hughd@google.com>
---
 mm/mmap.c  |   33 +++++++++++++--------------------
 mm/nommu.c |   29 +++++++++++------------------
 2 files changed, 24 insertions(+), 38 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index d49736f..6b26cc3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -124,7 +124,16 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
-		free = global_page_state(NR_FILE_PAGES);
+		free = global_page_state(NR_FREE_PAGES);
+		free += global_page_state(NR_FILE_PAGES);
+
+		/* shmem pages shouldn't be counted as free in this
+		 * case, they can't be purged, only swapped out, and
+		 * that won't affect the overall amount of available
+		 * memory in the system.
+		 */
+		free -= global_page_state(NR_SHMEM);
+
 		free += nr_swap_pages;
 
 		/*
@@ -136,34 +145,18 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		free += global_page_state(NR_SLAB_RECLAIMABLE);
 
 		/*
-		 * Leave the last 3% for root
-		 */
-		if (!cap_sys_admin)
-			free -= free / 32;
-
-		if (free > pages)
-			return 0;
-
-		/*
-		 * nr_free_pages() is very expensive on large systems,
-		 * only call if we're about to fail.
-		 */
-		n = nr_free_pages();
-
-		/*
 		 * Leave reserved pages. The pages are not for anonymous pages.
 		 */
-		if (n <= totalreserve_pages)
+		if (free <= totalreserve_pages)
 			goto error;
 		else
-			n -= totalreserve_pages;
+			free -= totalreserve_pages;
 
 		/*
 		 * Leave the last 3% for root
 		 */
 		if (!cap_sys_admin)
-			n -= n / 32;
-		free += n;
+			free -= free / 32;
 
 		if (free > pages)
 			return 0;
diff --git a/mm/nommu.c b/mm/nommu.c
index 9edc897..510048d 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1887,7 +1887,16 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
-		free = global_page_state(NR_FILE_PAGES);
+		free = global_page_state(NR_FREE_PAGES);
+		free += global_page_state(NR_FILE_PAGES);
+
+		/* shmem pages shouldn't be counted as free in this
+		 * case, they can't be purged, only swapped out, and
+		 * that won't affect the overall amount of available
+		 * memory in the system.
+		 */
+		free -= global_page_state(NR_SHMEM);
+
 		free += nr_swap_pages;
 
 		/*
@@ -1899,21 +1908,6 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		free += global_page_state(NR_SLAB_RECLAIMABLE);
 
 		/*
-		 * Leave the last 3% for root
-		 */
-		if (!cap_sys_admin)
-			free -= free / 32;
-
-		if (free > pages)
-			return 0;
-
-		/*
-		 * nr_free_pages() is very expensive on large systems,
-		 * only call if we're about to fail.
-		 */
-		n = nr_free_pages();
-
-		/*
 		 * Leave reserved pages. The pages are not for anonymous pages.
 		 */
 		if (n <= totalreserve_pages)
@@ -1925,8 +1919,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 * Leave the last 3% for root
 		 */
 		if (!cap_sys_admin)
-			n -= n / 32;
-		free += n;
+			free -= free / 32;
 
 		if (free > pages)
 			return 0;
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
