Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BF0AC6B005C
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 10:36:01 -0400 (EDT)
Received: by pzk5 with SMTP id 5so1571144pzk.12
        for <linux-mm@kvack.org>; Fri, 05 Jun 2009 07:36:00 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC] remove page_table_lock in anon_vma_prepare
Date: Fri,  5 Jun 2009 23:35:53 +0900
Message-Id: <1244212553-21629-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

As I looked over the page_table_lock, it related to page table not anon_vma

I think anon_vma->lock can protect race against threads.
Do I miss something ?

If I am right, we can remove unnecessary page_table_lock holding
in anon_vma_prepare. We can get performance benefit. 

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>
---
 mm/rmap.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index b5c6e12..65b4877 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -113,14 +113,11 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 		}
 		spin_lock(&anon_vma->lock);
 
-		/* page_table_lock to protect against threads */
-		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
 			allocated = NULL;
 		}
-		spin_unlock(&mm->page_table_lock);
 
 		spin_unlock(&anon_vma->lock);
 		if (unlikely(allocated))
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
