Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 798446B0036
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 22:00:52 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so5191297qcx.8
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 19:00:52 -0700 (PDT)
Received: from mail-qc0-x22e.google.com (mail-qc0-x22e.google.com [2607:f8b0:400d:c01::22e])
        by mx.google.com with ESMTPS id p96si16219992qgp.2.2014.06.27.19.00.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 19:00:52 -0700 (PDT)
Received: by mail-qc0-f174.google.com with SMTP id x13so5120561qcv.19
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 19:00:52 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <j.glisse@gmail.com>
Subject: [PATCH 2/6] mm: differentiate unmap for vmscan from other unmap.
Date: Fri, 27 Jun 2014 22:00:20 -0400
Message-Id: <1403920822-14488-3-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, torvalds@linux-foundation.org, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

New code will need to be able to differentiate between a regular unmap and
an unmap trigger by vmscan in which case we want to be as quick as possible.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/rmap.h | 15 ++++++++-------
 mm/memory-failure.c  |  2 +-
 mm/vmscan.c          |  4 ++--
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index be57450..eddbc07 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -72,13 +72,14 @@ struct anon_vma_chain {
 };
 
 enum ttu_flags {
-	TTU_UNMAP = 1,			/* unmap mode */
-	TTU_MIGRATION = 2,		/* migration mode */
-	TTU_MUNLOCK = 4,		/* munlock mode */
-
-	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
-	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
-	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
+	TTU_VMSCAN = 1,			/* unmap for vmscan */
+	TTU_POISON = 2,			/* unmap for poison */
+	TTU_MIGRATION = 4,		/* migration mode */
+	TTU_MUNLOCK = 8,		/* munlock mode */
+
+	TTU_IGNORE_MLOCK = (1 << 9),	/* ignore mlock */
+	TTU_IGNORE_ACCESS = (1 << 10),	/* don't age */
+	TTU_IGNORE_HWPOISON = (1 << 11),/* corrupted page is recoverable */
 };
 
 #ifdef CONFIG_MMU
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index a7a89eb..ba176c4 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -887,7 +887,7 @@ static int page_action(struct page_state *ps, struct page *p,
 static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 				  int trapno, int flags, struct page **hpagep)
 {
-	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
+	enum ttu_flags ttu = TTU_POISON | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
 	int ret;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6d24fd6..5a7d286 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1163,7 +1163,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	}
 
 	ret = shrink_page_list(&clean_pages, zone, &sc,
-			TTU_UNMAP|TTU_IGNORE_ACCESS,
+			TTU_VMSCAN|TTU_IGNORE_ACCESS,
 			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
 	list_splice(&clean_pages, page_list);
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
@@ -1518,7 +1518,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
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
