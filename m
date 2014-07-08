Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1686B0038
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 19:52:03 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so5849081qcx.8
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:52:03 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id ce2si57368506qcb.7.2014.07.08.16.52.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 16:52:02 -0700 (PDT)
Received: by mail-qc0-f180.google.com with SMTP id r5so5800555qcx.25
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:52:02 -0700 (PDT)
Date: Tue, 8 Jul 2014 19:51:57 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 2/8] mm: differentiate unmap for vmscan from other unmap.
Message-ID: <20140708235157.GC5222@gmail.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-3-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1404856801-11702-3-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Tue, Jul 08, 2014 at 05:59:59PM -0400, j.glisse@gmail.com wrote:
From: Jerome Glisse <jglisse@redhat.com>

New code will need to be able to differentiate between a regular unmap and
an unmap trigger by vmscan in which case we want to be as quick as possible.

Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jerome Glisse <jglisse@redhat.com>
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
index c035a2a..c931f05 100644
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
