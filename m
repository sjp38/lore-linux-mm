Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1677960021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 21:55:14 -0500 (EST)
Received: by gxk24 with SMTP id 24so9144043gxk.6
        for <linux-mm@kvack.org>; Sun, 27 Dec 2009 18:55:13 -0800 (PST)
Date: Mon, 28 Dec 2009 11:53:15 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page in
 LRU list.
Message-Id: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


VM doesn't add zero page to LRU list. 
It means zero page's churning in LRU list is pointless. 

As a matter of fact, zero page can't be promoted by mark_page_accessed
since it doesn't have PG_lru. 

This patch prevent unecessary mark_page_accessed call of zero page 
alghouth caller want FOLL_TOUCH. 

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memory.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 09e4b1b..485f727 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1152,6 +1152,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 	spinlock_t *ptl;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
+	int zero_pfn = 0;
 
 	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
 	if (!IS_ERR(page)) {
@@ -1196,15 +1197,15 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 
 	page = vm_normal_page(vma, address, pte);
 	if (unlikely(!page)) {
-		if ((flags & FOLL_DUMP) ||
-		    !is_zero_pfn(pte_pfn(pte)))
+		zero_pfn = is_zero_pfn(pte_pfn(pte));
+		if ((flags & FOLL_DUMP) || !zero_pfn )
 			goto bad_page;
 		page = pte_page(pte);
 	}
 
 	if (flags & FOLL_GET)
 		get_page(page);
-	if (flags & FOLL_TOUCH) {
+	if (flags & FOLL_TOUCH && !zero_pfn) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
 			set_page_dirty(page);
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
