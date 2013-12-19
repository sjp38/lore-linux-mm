Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id D8F9E6B0037
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 13:37:09 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so1376559qeb.20
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 10:37:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r4si1598124qcl.35.2013.12.19.10.37.08
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 10:37:08 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] fs/proc/page.c: add PageAnon check to surely detect thp
Date: Thu, 19 Dec 2013 13:36:54 -0500
Message-Id: <1387478214-10369-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

stable_page_flags() checks !PageHuge && PageTransCompound && PageLRU to
know that a specified page is thp or not. But sometimes it's not enough
and we fail to detect thp when the thp is on pagevec. This happens only
for a few seconds after LRU list operations, but it makes it difficult to
control our applications depending on this flag.

So this patch adds another check PageAnon to detect thps on pagevec.
It might not give the future extensibility for thp pagecache, but it's
OK at least for now.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/page.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git v3.13-rc4.orig/fs/proc/page.c v3.13-rc4/fs/proc/page.c
index b8730d9ebaee..cab84b6272ed 100644
--- v3.13-rc4.orig/fs/proc/page.c
+++ v3.13-rc4/fs/proc/page.c
@@ -118,10 +118,12 @@ u64 stable_page_flags(struct page *page)
 	/*
 	 * PageTransCompound can be true for non-huge compound pages (slab
 	 * pages or pages allocated by drivers with __GFP_COMP) because it
-	 * just checks PG_head/PG_tail, so we need to check PageLRU to make
-	 * sure a given page is a thp, not a non-huge compound page.
+	 * just checks PG_head/PG_tail, so we need to check PageLRU/PageAnon
+	 * to make sure a given page is a thp, not a non-huge compound page.
 	 */
-	else if (PageTransCompound(page) && PageLRU(compound_trans_head(page)))
+	else if (PageTransCompound(page) &&
+		 (PageLRU(compound_trans_head(page)) ||
+		  PageAnon(compound_trans_head(page))))
 		u |= 1 << KPF_THP;
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
