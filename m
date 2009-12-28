Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D14D860021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 23:48:20 -0500 (EST)
Received: by ywh5 with SMTP id 5so14172892ywh.11
        for <linux-mm@kvack.org>; Sun, 27 Dec 2009 20:48:19 -0800 (PST)
Date: Mon, 28 Dec 2009 13:46:19 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH -mmotm-2009-12-10-17-19] Fix wrong rss count of smaps
Message-Id: <20091228134619.92ba28f6.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>


I am not sure we have to account zero page with file_rss. 
Hugh and Kame's new zero page doesn't do it. 
As side effect of this, we can prevent innocent process which have a lot
of zero page when OOM happens. 
(But I am not sure there is a process like this :)
So I think not file_rss counting is not bad. 

RSS counting zero page with file_rss helps any program using smaps?
If we have to keep the old behavior, I have to remake this patch. 

== CUT_HERE ==

Long time ago, We regards zero page as file_rss and
vm_normal_page doesn't return NULL.

But now, we reinstated ZERO_PAGE and vm_normal_page's implementation
can return NULL in case of zero page. Also we don't count it with
file_rss any more.

Then, RSS and PSS can't be matched.
For consistency, Let's ignore zero page in smaps_pte_range.

CC: Matt Mackall <mpm@selenic.com>
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
