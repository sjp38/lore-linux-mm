Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 89840900015
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:33:51 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so59390370qkd.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:51 -0700 (PDT)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id 93si1516136qkw.104.2015.05.21.12.33.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:33:50 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so64240727qkg.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:50 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 10/36] HMM: use CPU page table during invalidation.
Date: Thu, 21 May 2015 15:31:19 -0400
Message-Id: <1432236705-4209-11-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Jerome Glisse <jglisse@redhat.com>

From: Jerome Glisse <jglisse@redhat.com>

Once we store the dma mapping inside the secondary page table we can
no longer easily find back the page backing an address. Instead use
the cpu page table which still has the proper informations, except for
the invalidate_page() case which is handled by using the page passed
by the mmu_notifier layer.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 51 ++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 34 insertions(+), 17 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 93d6f5e..8ec9ffa 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -50,9 +50,11 @@ static inline struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror);
 static inline void hmm_mirror_unref(struct hmm_mirror **mirror);
 static void hmm_mirror_kill(struct hmm_mirror *mirror);
 static inline int hmm_mirror_update(struct hmm_mirror *mirror,
-				    struct hmm_event *event);
+				    struct hmm_event *event,
+				    struct page *page);
 static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
-				 struct hmm_event *event);
+				 struct hmm_event *event,
+				 struct page *page);
 
 
 /* hmm_event - use to track information relating to an event.
@@ -232,7 +234,9 @@ again:
 	}
 }
 
-static void hmm_update(struct hmm *hmm, struct hmm_event *event)
+static void hmm_update(struct hmm *hmm,
+		       struct hmm_event *event,
+		       struct page *page)
 {
 	struct hmm_mirror *mirror;
 
@@ -245,7 +249,7 @@ static void hmm_update(struct hmm *hmm, struct hmm_event *event)
 again:
 	down_read(&hmm->rwsem);
 	hlist_for_each_entry(mirror, &hmm->mirrors, mlist)
-		if (hmm_mirror_update(mirror, event)) {
+		if (hmm_mirror_update(mirror, event, page)) {
 			mirror = hmm_mirror_ref(mirror);
 			up_read(&hmm->rwsem);
 			hmm_mirror_kill(mirror);
@@ -343,9 +347,10 @@ static void hmm_mmu_mprot_to_etype(struct mm_struct *mm,
 	*etype = HMM_NONE;
 }
 
-static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						struct mm_struct *mm,
-						const struct mmu_notifier_range *range)
+static void hmm_notifier_invalidate(struct mmu_notifier *mn,
+				    struct mm_struct *mm,
+				    struct page *page,
+				    const struct mmu_notifier_range *range)
 {
 	struct hmm_event event;
 	unsigned long start = range->start, end = range->end;
@@ -386,7 +391,14 @@ static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 	hmm_event_init(&event, hmm, start, end, event.etype);
 
-	hmm_update(hmm, &event);
+	hmm_update(hmm, &event, page);
+}
+
+static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
+						struct mm_struct *mm,
+						const struct mmu_notifier_range *range)
+{
+	hmm_notifier_invalidate(mn, mm, NULL, range);
 }
 
 static void hmm_notifier_invalidate_page(struct mmu_notifier *mn,
@@ -400,7 +412,7 @@ static void hmm_notifier_invalidate_page(struct mmu_notifier *mn,
 	range.start = addr & PAGE_MASK;
 	range.end = range.start + PAGE_SIZE;
 	range.event = mmu_event;
-	hmm_notifier_invalidate_range_start(mn, mm, &range);
+	hmm_notifier_invalidate(mn, mm, page, &range);
 }
 
 static struct mmu_notifier_ops hmm_notifier_ops = {
@@ -551,23 +563,27 @@ static inline void hmm_mirror_unref(struct hmm_mirror **mirror)
 }
 
 static inline int hmm_mirror_update(struct hmm_mirror *mirror,
-				    struct hmm_event *event)
+				    struct hmm_event *event,
+				    struct page *page)
 {
 	struct hmm_device *device = mirror->device;
 	int ret = 0;
 
 	ret = device->ops->update(mirror, event);
-	hmm_mirror_update_pt(mirror, event);
+	hmm_mirror_update_pt(mirror, event, page);
 	return ret;
 }
 
 static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
-				 struct hmm_event *event)
+				 struct hmm_event *event,
+				 struct page *page)
 {
 	unsigned long addr;
 	struct hmm_pt_iter iter;
+	struct mm_pt_iter mm_iter;
 
 	hmm_pt_iter_init(&iter);
+	mm_pt_iter_init(&mm_iter, mirror->hmm->mm);
 	for (addr = event->start; addr != event->end;) {
 		unsigned long end, next;
 		dma_addr_t *hmm_pte;
@@ -593,10 +609,10 @@ static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
 				continue;
 			if (hmm_pte_test_and_clear_dirty(hmm_pte) &&
 			    hmm_pte_test_write(hmm_pte)) {
-				struct page *page;
-
-				page = pfn_to_page(hmm_pte_pfn(*hmm_pte));
-				set_page_dirty(page);
+				page = page ? : mm_pt_iter_page(&mm_iter, addr);
+				if (page)
+					set_page_dirty(page);
+				page = NULL;
 			}
 			*hmm_pte &= event->pte_mask;
 			if (hmm_pte_test_valid_pfn(hmm_pte))
@@ -606,6 +622,7 @@ static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
 		hmm_pt_iter_directory_unlock(&iter, &mirror->pt);
 	}
 	hmm_pt_iter_fini(&iter, &mirror->pt);
+	mm_pt_iter_fini(&mm_iter);
 }
 
 static inline bool hmm_mirror_is_dead(struct hmm_mirror *mirror)
@@ -988,7 +1005,7 @@ static void hmm_mirror_kill(struct hmm_mirror *mirror)
 
 	/* Make sure everything is unmapped. */
 	hmm_event_init(&event, mirror->hmm, 0, -1UL, HMM_MUNMAP);
-	hmm_mirror_update(mirror, &event);
+	hmm_mirror_update(mirror, &event, NULL);
 
 	down_write(&mirror->hmm->rwsem);
 	if (!hlist_unhashed(&mirror->mlist)) {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
