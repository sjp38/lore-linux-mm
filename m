Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 64B836B01A1
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 05:16:52 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so656552pbb.36
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:16:52 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id my2si1008307pbc.68.2014.03.20.02.16.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 02:16:51 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so659735pab.18
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:16:51 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [RESEND PATCH] mm: try_to_unmap_cluster() should lock_page() before mlocking
Date: Thu, 20 Mar 2014 17:16:36 +0800
Message-Id: <1395306996-13993-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, davej@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org, Bob Liu <bob.liu@oracle.com>

From: Vlastimil Babka <vbabka@suse.cz>

A BUG_ON(!PageLocked) was triggered in mlock_vma_page() by Sasha Levin fuzzing
with trinity. The call site try_to_unmap_cluster() does not lock the pages
other than its check_page parameter (which is already locked).

The BUG_ON in mlock_vma_page() is not documented and its purpose is somewhat
unclear, but apparently it serializes against page migration, which could
otherwise fail to transfer the PG_mlocked flag. This would not be fatal, as the
page would be eventually encountered again, but NR_MLOCK accounting would
become distorted nevertheless. This patch adds a comment to the BUG_ON in
mlock_vma_page() and munlock_vma_page() to that effect.

The call site try_to_unmap_cluster() is fixed so that for page != check_page,
trylock_page() is attempted (to avoid possible deadlocks as we already have
check_page locked) and mlock_vma_page() is performed only upon success. If the
page lock cannot be obtained, the page is left without PG_mlocked, which is
again not a problem in the whole unevictable memory design.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 mm/mlock.c |    2 ++
 mm/rmap.c  |   14 ++++++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 4e1a6816..b1eb536 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -79,6 +79,7 @@ void clear_page_mlock(struct page *page)
  */
 void mlock_vma_page(struct page *page)
 {
+	/* Serialize with page migration */
 	BUG_ON(!PageLocked(page));
 
 	if (!TestSetPageMlocked(page)) {
@@ -174,6 +175,7 @@ unsigned int munlock_vma_page(struct page *page)
 	unsigned int nr_pages;
 	struct zone *zone = page_zone(page);
 
+	/* For try_to_munlock() and to serialize with page migration */
 	BUG_ON(!PageLocked(page));
 
 	/*
diff --git a/mm/rmap.c b/mm/rmap.c
index d9d4231..43d429b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1322,9 +1322,19 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		BUG_ON(!page || PageAnon(page));
 
 		if (locked_vma) {
-			mlock_vma_page(page);   /* no-op if already mlocked */
-			if (page == check_page)
+			if (page == check_page) {
+				/* we know we have check_page locked */
+				mlock_vma_page(page);
 				ret = SWAP_MLOCK;
+			} else if (trylock_page(page)) {
+				/*
+				 * If we can lock the page, perform mlock.
+				 * Otherwise leave the page alone, it will be
+				 * eventually encountered again later.
+				 */
+				mlock_vma_page(page);
+				unlock_page(page);
+			}
 			continue;	/* don't unmap */
 		}
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
