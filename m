Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 887F66B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:52:59 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id x13so4866341qcv.29
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:52:59 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id p7si12565163qga.20.2014.05.02.06.52.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:52:58 -0700 (PDT)
Received: by mail-qc0-f170.google.com with SMTP id x13so4866328qcv.29
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:52:58 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 01/11] mm: differentiate unmap for vmscan from other unmap.
Date: Fri,  2 May 2014 09:52:00 -0400
Message-Id: <1399038730-25641-2-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

New code will need to be able to differentiate between a regular unmap and
an unmap trigger by vmscan in which case we want to be as quick as possible.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/rmap.h | 7 ++++---
 mm/memory-failure.c  | 2 +-
 mm/vmscan.c          | 4 ++--
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b66c211..575851f 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -72,9 +72,10 @@ struct anon_vma_chain {
 };
 
 enum ttu_flags {
-	TTU_UNMAP = 0,			/* unmap mode */
-	TTU_MIGRATION = 1,		/* migration mode */
-	TTU_MUNLOCK = 2,		/* munlock mode */
+	TTU_VMSCAN = 0,			/* unmap for vmscan mode */
+	TTU_POISON = 1,			/* unmap mode */
+	TTU_MIGRATION = 2,		/* migration mode */
+	TTU_MUNLOCK = 3,		/* munlock mode */
 	TTU_ACTION_MASK = 0xff,
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index efb55b3..c61722b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -854,7 +854,7 @@ static int page_action(struct page_state *ps, struct page *p,
 static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 				  int trapno, int flags, struct page **hpagep)
 {
-	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
+	enum ttu_flags ttu = TTU_POISON | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
 	int ret;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 049f324..e261fc5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1158,7 +1158,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	}
 
 	ret = shrink_page_list(&clean_pages, zone, &sc,
-			TTU_UNMAP|TTU_IGNORE_ACCESS,
+			TTU_VMSCAN|TTU_IGNORE_ACCESS,
 			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
 	list_splice(&clean_pages, page_list);
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
@@ -1511,7 +1511,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_VMSCAN,
 				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
 				&nr_writeback, &nr_immediate,
 				false);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
