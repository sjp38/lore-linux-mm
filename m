Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 14E626B0075
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 11:44:21 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z11so5549357lbi.7
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:44:21 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id kz8si18423898lab.23.2014.09.09.08.44.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 08:44:14 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 3/3] mmu_notifier: Add the call-back for mmu_notifier_invalidate_range()
Date: Tue,  9 Sep 2014 17:43:54 +0200
Message-Id: <1410277434-3087-4-git-send-email-joro@8bytes.org>
In-Reply-To: <1410277434-3087-1-git-send-email-joro@8bytes.org>
References: <1410277434-3087-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, joro@8bytes.org, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

From: Joerg Roedel <jroedel@suse.de>

Now that the mmu_notifier_invalidate_range() calls are in
place, add the call-back to allow subsystems to register
against it.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 include/linux/mmu_notifier.h | 37 ++++++++++++++++++++++++++++++++-----
 mm/mmu_notifier.c            | 25 +++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 877d1c8..aa1a6bf 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -95,11 +95,11 @@ struct mmu_notifier_ops {
 	/*
 	 * invalidate_range_start() and invalidate_range_end() must be
 	 * paired and are called only when the mmap_sem and/or the
-	 * locks protecting the reverse maps are held. The subsystem
-	 * must guarantee that no additional references are taken to
-	 * the pages in the range established between the call to
-	 * invalidate_range_start() and the matching call to
-	 * invalidate_range_end().
+	 * locks protecting the reverse maps are held. If the subsystem
+	 * can't guarantee that no additional references are taken to
+	 * the pages in the range, it has to implement the
+	 * invalidate_range() notifier to remove any references taken
+	 * after invalidate_range_start().
 	 *
 	 * Invalidation of multiple concurrent ranges may be
 	 * optionally permitted by the driver. Either way the
@@ -141,6 +141,29 @@ struct mmu_notifier_ops {
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
 				     unsigned long start, unsigned long end);
+
+	/*
+	 * invalidate_range() is either called between
+	 * invalidate_range_start() and invalidate_range_end() when the
+	 * VM has to free pages that where unmapped, but before the
+	 * pages are actually freed, or outside of _start()/_end() when
+	 * page-table pages are about to be freed.
+	 *
+	 * If invalidate_range() is used to manage a non-CPU TLB with
+	 * shared page-tables, it not necessary to implement the
+	 * invalidate_range_start()/end() notifiers, as
+	 * invalidate_range() alread catches the points in time when an
+	 * external TLB range needs to be flushed.
+	 *
+	 * The invalidate_range() function is called under the ptl
+	 * spin-lock and not allowed to sleep.
+	 *
+	 * Note that this function might be called with just a sub-range
+	 * of what was passed to invalidate_range_start()/end(), if
+	 * called between those functions.
+	 */
+	void (*invalidate_range)(struct mmu_notifier *mn, struct mm_struct *mm,
+				 unsigned long start, unsigned long end);
 };
 
 /*
@@ -186,6 +209,8 @@ extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
+extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
+				  unsigned long start, unsigned long end);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
@@ -240,6 +265,8 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range(mm, start, end);
 }
 
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 950813b..a900637 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -192,6 +192,16 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
+		/*
+		 * Call invalidate_range here too to avoid the need for the
+		 * subsystem of having to register an invalidate_range_end
+		 * call-back when there is invalidate_range already. Usually a
+		 * subsystem registers either invalidate_range_start()/end() or
+		 * invalidate_range(), so this will be no additional overhead
+		 * (besides the pointer check).
+		 */
+		if (mn->ops->invalidate_range)
+			mn->ops->invalidate_range(mn, mm, start, end);
 		if (mn->ops->invalidate_range_end)
 			mn->ops->invalidate_range_end(mn, mm, start, end);
 	}
@@ -199,6 +209,21 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
 
+void __mmu_notifier_invalidate_range(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	struct mmu_notifier *mn;
+	int id;
+
+	id = srcu_read_lock(&srcu);
+	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->invalidate_range)
+			mn->ops->invalidate_range(mn, mm, start, end);
+	}
+	srcu_read_unlock(&srcu, id);
+}
+EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
+
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
 				    int take_mmap_sem)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
