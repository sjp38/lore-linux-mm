Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBE736B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 13:49:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q203so3808730wmb.0
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 10:49:47 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id 128si10704012wmy.232.2017.10.11.10.49.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 10:49:46 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm/rmap: remove redundant variable cend
Date: Wed, 11 Oct 2017 18:49:42 +0100
Message-Id: <20171011174942.1372-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Variable cend is set but never read, hence it is redundant and can be
removed.

Cleans up clang build warning: Value stored to 'cend' is never read

Fixes: 369ea8242c0f ("mm/rmap: update to new mmu_notifier semantic v2")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/rmap.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 787c07fb37dc..ffbea6a9e12d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -899,7 +899,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
 
 	while (page_vma_mapped_walk(&pvmw)) {
-		unsigned long cstart, cend;
+		unsigned long cstart;
 		int ret = 0;
 
 		cstart = address = pvmw.address;
@@ -915,7 +915,6 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			entry = pte_wrprotect(entry);
 			entry = pte_mkclean(entry);
 			set_pte_at(vma->vm_mm, address, pte, entry);
-			cend = cstart + PAGE_SIZE;
 			ret = 1;
 		} else {
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
@@ -931,7 +930,6 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
 			cstart &= PMD_MASK;
-			cend = cstart + PMD_SIZE;
 			ret = 1;
 #else
 			/* unexpected pmd-mapped page? */
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
