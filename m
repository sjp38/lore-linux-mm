Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0A8F26B0083
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:40 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:39 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 04/12] mm: add lock release annotation on do_wp_page()
Date: Thu, 30 Sep 2010 12:50:13 +0900
Message-Id: <1285818621-29890-5-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The do_wp_page() releases @ptl but was missing proper annotation.
Add it. This removes following warnings from sparse:

 mm/memory.c:2337:9: warning: context imbalance in 'do_wp_page' - unexpected unlock
 mm/memory.c:3142:19: warning: context imbalance in 'handle_mm_fault' - different lock contexts for basic block

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/memory.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 219b50a..76fa60e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2107,6 +2107,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		spinlock_t *ptl, pte_t orig_pte)
+	__releases(ptl)
 {
 	struct page *old_page, *new_page;
 	pte_t entry;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
