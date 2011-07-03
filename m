Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DB42C6B0012
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 15:40:28 -0400 (EDT)
Received: by pzk4 with SMTP id 4so1008480pzk.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 12:40:26 -0700 (PDT)
From: Dmitry Fink <finikk@gmail.com>
Subject: [PATCH 1/1] mmap: Don't count shmem pages as free in __vm_enough_memory
Date: Sun,  3 Jul 2011 12:39:23 -0700
Message-Id: <1309721963-5577-1-git-send-email-dmitry.fink@palm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dmitry Fink <dmitry.fink@palm.com>

shmem pages can't be reclaimed and if they are swapped out
that doesn't affect the overall available memory in the system,
so don't count them along with the rest of the file backed pages.

Signed-off-by: Dmitry Fink <dmitry.fink@palm.com>
---
 mm/mmap.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index b88624f..3a34dc2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -119,6 +119,13 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		unsigned long n;
 
 		free = global_page_state(NR_FILE_PAGES);
+
+		/* shmem pages shouldn't be counted as free in this
+		 * case, they can't be purged, only swapped out, and
+		 * that won't affect the overall amount of available
+		 * memory in the system. */
+		free -= global_page_state(NR_SHMEM);
+
 		free += nr_swap_pages;
 
 		/*
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
