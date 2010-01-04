Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6FC8B600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 20:23:30 -0500 (EST)
Received: by ywh5 with SMTP id 5so27810476ywh.11
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 17:23:28 -0800 (PST)
Date: Mon, 4 Jan 2010 10:23:19 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 -mmotm-2009-12-10-17-19] Fix wrong rss count of smaps
Message-Id: <20100104102319.b878047d.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matt Mackall <mpm@selenic.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Long time ago, We regards zero page as file_rss and
vm_normal_page didn't return NULL in case of zero page

But now, we reinstated ZERO_PAGE and vm_normal_page's implementation
can return NULL in case of zero page.

Then, RSS and PSS can't be matched in smaps_pte_range.
This patch fixes it.

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Acked-by: Matt Mackall <mpm@selenic.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 fs/proc/task_mmu.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 47c03f4..f277c4a 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -361,12 +361,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		if (!pte_present(ptent))
 			continue;
 
-		mss->resident += PAGE_SIZE;
-
 		page = vm_normal_page(vma, addr, ptent);
 		if (!page)
 			continue;
 
+		mss->resident += PAGE_SIZE;
 		/* Accumulate the size in pages that have been accessed. */
 		if (pte_young(ptent) || PageReferenced(page))
 			mss->referenced += PAGE_SIZE;
-- 
1.5.6.3



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
