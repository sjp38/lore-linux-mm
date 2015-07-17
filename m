Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7162D28034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:53:54 -0400 (EDT)
Received: by iggf3 with SMTP id f3so43574118igg.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:53:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g63si9955006ioj.58.2015.07.17.11.53.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:53:53 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 10/15] HMM: use CPU page table during invalidation.
Date: Fri, 17 Jul 2015 14:52:20 -0400
Message-Id: <1437159145-6548-11-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Jerome Glisse <jglisse@redhat.com>

From: Jerome Glisse <jglisse@redhat.com>

Once we store the dma mapping inside the secondary page table we can
no longer easily find back the page backing an address. Instead use
the cpu page table which still has the proper information, except for
the invalidate_page() case which is handled by using the page passed
by the mmu_notifier layer.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 53 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 35 insertions(+), 18 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 826080b..0ecc3b0 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -47,9 +47,11 @@
 static struct mmu_notifier_ops hmm_notifier_ops;
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
@@ -223,7 +225,9 @@ again:
 	}
 }
 
-static void hmm_update(struct hmm *hmm, struct hmm_event *event)
+static void hmm_update(struct hmm *hmm,
+		       struct hmm_event *event,
+		       struct page *page)
 {
 	struct hmm_mirror *mirror;
 
@@ -236,7 +240,7 @@ static void hmm_update(struct hmm *hmm, struct hmm_event *event)
 again:
 	down_read(&hmm->rwsem);
 	hlist_for_each_entry(mirror, &hmm->mirrors, mlist)
-		if (hmm_mirror_update(mirror, event)) {
+		if (hmm_mirror_update(mirror, event, page)) {
 			mirror = hmm_mirror_ref(mirror);
 			up_read(&hmm->rwsem);
 			hmm_mirror_kill(mirror);
@@ -304,7 +308,7 @@ static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
 
 		/* Make sure everything is unmapped. */
 		hmm_event_init(&event, mirror->hmm, 0, -1UL, HMM_MUNMAP);
-		hmm_mirror_update(mirror, &event);
+		hmm_mirror_update(mirror, &event, NULL);
 
 		mirror->device->ops->release(mirror);
 		hmm_mirror_unref(&mirror);
@@ -338,9 +342,10 @@ static void hmm_mmu_mprot_to_etype(struct mm_struct *mm,
 	*etype = HMM_NONE;
 }
 
-static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
-					struct mm_struct *mm,
-					const struct mmu_notifier_range *range)
+static void hmm_notifier_invalidate(struct mmu_notifier *mn,
+				    struct mm_struct *mm,
+				    struct page *page,
+				    const struct mmu_notifier_range *range)
 {
 	struct hmm_event event;
 	unsigned long start = range->start, end = range->end;
@@ -379,7 +384,14 @@ static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 	hmm_event_init(&event, hmm, start, end, event.etype);
 
-	hmm_update(hmm, &event);
+	hmm_update(hmm, &event, page);
+}
+
+static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
+{
+	hmm_notifier_invalidate(mn, mm, NULL, range);
 }
 
 static void hmm_notifier_invalidate_page(struct mmu_notifier *mn,
@@ -393,7 +405,7 @@ static void hmm_notifier_invalidate_page(struct mmu_notifier *mn,
 	range.start = addr & PAGE_MASK;
 	range.end = range.start + PAGE_SIZE;
 	range.event = mmu_event;
-	hmm_notifier_invalidate_range_start(mn, mm, &range);
+	hmm_notifier_invalidate(mn, mm, page, &range);
 }
 
 static struct mmu_notifier_ops hmm_notifier_ops = {
@@ -545,23 +557,27 @@ void hmm_mirror_unref(struct hmm_mirror **mirror)
 EXPORT_SYMBOL(hmm_mirror_unref);
 
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
 
 	hmm_pt_iter_init(&iter, &mirror->pt);
+	mm_pt_iter_init(&mm_iter, mirror->hmm->mm);
 	for (addr = event->start; addr != event->end;) {
 		unsigned long next = event->end;
 		dma_addr_t *hmm_pte;
@@ -582,10 +598,10 @@ static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
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
@@ -595,6 +611,7 @@ static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
 		hmm_pt_iter_directory_unlock(&iter);
 	}
 	hmm_pt_iter_fini(&iter);
+	mm_pt_iter_fini(&mm_iter);
 }
 
 static inline bool hmm_mirror_is_dead(struct hmm_mirror *mirror)
@@ -979,7 +996,7 @@ static void hmm_mirror_kill(struct hmm_mirror *mirror)
 
 		/* Make sure everything is unmapped. */
 		hmm_event_init(&event, mirror->hmm, 0, -1UL, HMM_MUNMAP);
-		hmm_mirror_update(mirror, &event);
+		hmm_mirror_update(mirror, &event, NULL);
 
 		device->ops->release(mirror);
 		hmm_mirror_unref(&mirror);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
