Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0D74D6B0044
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 02:37:45 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id p10so2114662pdj.26
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 23:37:45 -0700 (PDT)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id my2si3015002pab.281.2014.03.13.23.37.31
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 23:37:32 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 6/6] mm: ksm: don't merge lazyfree page
Date: Fri, 14 Mar 2014 15:37:50 +0900
Message-Id: <1394779070-8545-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1394779070-8545-1-git-send-email-minchan@kernel.org>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

I didn't test this patch but just wanted to make lagefree pages KSM.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/ksm.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 68710e80994a..43ca73aa45e7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -470,7 +470,8 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	page = follow_page(vma, addr, FOLL_GET);
 	if (IS_ERR_OR_NULL(page))
 		goto out;
-	if (PageAnon(page) || page_trans_compound_anon(page)) {
+	if ((PageAnon(page) && !PageLazyFree(page)) ||
+			page_trans_compound_anon(page)) {
 		flush_anon_page(vma, page, addr);
 		flush_dcache_page(page);
 	} else {
@@ -1032,13 +1033,20 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 
 	/*
 	 * We need the page lock to read a stable PageSwapCache in
-	 * write_protect_page().  We use trylock_page() instead of
-	 * lock_page() because we don't want to wait here - we
-	 * prefer to continue scanning and merging different pages,
+	 * write_protect_page() and check lazyfree.
+	 * We use trylock_page() instead of lock_page() because we
+	 * don't want to wait here - we prefer to continue scanning
+	 * and merging different pages,
 	 * then come back to this page when it is unlocked.
 	 */
 	if (!trylock_page(page))
 		goto out;
+
+	if (PageLazyFree(page)) {
+		unlock_page(page);
+		goto out;
+	}
+
 	/*
 	 * If this anonymous page is mapped only here, its pte may need
 	 * to be write-protected.  If it's mapped elsewhere, all of its
@@ -1621,7 +1629,7 @@ next_mm:
 				cond_resched();
 				continue;
 			}
-			if (PageAnon(*page) ||
+			if ((PageAnon(*page) && !PageLazyFree(*page)) ||
 			    page_trans_compound_anon(*page)) {
 				flush_anon_page(vma, *page, ksm_scan.address);
 				flush_dcache_page(*page);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
