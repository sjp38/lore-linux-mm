Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 94A226B009A
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:10:20 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so21005279pde.6
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:10:20 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id f4si24646103pbm.115.2013.12.03.16.10.18
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 16:10:19 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 3/9] mm/rmap: factor lock function out of rmap_walk_anon()
Date: Wed,  4 Dec 2013 09:12:14 +0900
Message-Id: <1386115940-21425-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

When we traverse anon_vma, we need to take a read-side anon_lock.
But there is subtle difference in the situation so that we can't use
same method to take a lock in each cases. Therefore, we need to make
rmap_walk_anon() taking difference lock function.

This patch is the first step, factoring lock function for anon_lock out
of rmap_walk_anon(). It will be used in case of removing migration entry
and in default of rmap_walk_anon().

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/rmap.c b/mm/rmap.c
index a387c44..91c73c4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1680,6 +1680,24 @@ void __put_anon_vma(struct anon_vma *anon_vma)
 }
 
 #ifdef CONFIG_MIGRATION
+static struct anon_vma *rmap_walk_anon_lock(struct page *page)
+{
+	struct anon_vma *anon_vma;
+
+	/*
+	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma_read()
+	 * because that depends on page_mapped(); but not all its usages
+	 * are holding mmap_sem. Users without mmap_sem are required to
+	 * take a reference count to prevent the anon_vma disappearing
+	 */
+	anon_vma = page_anon_vma(page);
+	if (!anon_vma)
+		return NULL;
+
+	anon_vma_lock_read(anon_vma);
+	return anon_vma;
+}
+
 /*
  * rmap_walk() and its helpers rmap_walk_anon() and rmap_walk_file():
  * Called by migrate.c to remove migration ptes, but might be used more later.
@@ -1692,16 +1710,10 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	/*
-	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma_read()
-	 * because that depends on page_mapped(); but not all its usages
-	 * are holding mmap_sem. Users without mmap_sem are required to
-	 * take a reference count to prevent the anon_vma disappearing
-	 */
-	anon_vma = page_anon_vma(page);
+	anon_vma = rmap_walk_anon_lock(page);
 	if (!anon_vma)
 		return ret;
-	anon_vma_lock_read(anon_vma);
+
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
