Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAD16B0032
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 08:22:21 -0400 (EDT)
From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 2/3] mmu_notifier: Add invalidate_range_free_pages() notifier
Date: Fri, 21 Oct 2011 14:21:47 +0200
Message-ID: <1319199708-17777-3-git-send-email-joerg.roedel@amd.com>
In-Reply-To: <1319199708-17777-1-git-send-email-joerg.roedel@amd.com>
References: <1319199708-17777-1-git-send-email-joerg.roedel@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, joro@8bytes.org, Joerg Roedel <joerg.roedel@amd.com>

This notifier closes an important gap in the current
invalidate_range_start()/end() notifiers. The _start() part
is called when all pages are still mapped while the _end()
notifier is called when all pages are potentially unmapped
and already freed.

This does not allow to manage external (non-CPU) hardware
TLBs with MMU-notifiers because there is no way to prevent
that hardware will esablish new TLB entries between the
calls of these two functions. But this is a requirement to
the subsytem that implements these existing notifiers.

To allow managing external TLBs the MMU-notifiers need to
catch the moment when pages are unmapped but not yet freed.
This new notifier catches that moment and notifies the
interested subsytem when pages that were unmapped are about
to be freed. The new notifier will only be called between
invalidate_range_start()/end().

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 include/linux/mmu_notifier.h |   32 +++++++++++++++++++++++++++-----
 mm/mmu_notifier.c            |   13 +++++++++++++
 2 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index b9469d6..199813f 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -94,11 +94,17 @@ struct mmu_notifier_ops {
 	/*
 	 * invalidate_range_start() and invalidate_range_end() must be
 	 * paired and are called only when the mmap_sem and/or the
-	 * locks protecting the reverse maps are held. The subsystem
-	 * must guarantee that no additional references are taken to
-	 * the pages in the range established between the call to
-	 * invalidate_range_start() and the matching call to
-	 * invalidate_range_end().
+	 * locks protecting the reverse maps are held.
+	 * invalidate_range_free_pages() is called between the two
+	 * functions every time when the VM has unmapped pages that are
+	 * about to be freed.
+	 * The subsystem must guarantee that no additional references
+	 * are taken to the pages in the range established between the
+	 * call to invalidate_range_start() and the matching call to
+	 * invalidate_range_end(). If this guarantee can not be given
+	 * by the subsystem it has to make sure that additional
+	 * references are dropped again in the
+	 * invalidate_range_free_pages() notifier.
 	 *
 	 * Invalidation of multiple concurrent ranges may be
 	 * optionally permitted by the driver. Either way the
@@ -109,6 +115,9 @@ struct mmu_notifier_ops {
 	 * invalidate_range_start() is called when all pages in the
 	 * range are still mapped and have at least a refcount of one.
 	 *
+	 * invalidate_range_free_pages() is called when a bunch of pages
+	 * are unmapped but not yet freed by the VM.
+	 *
 	 * invalidate_range_end() is called when all pages in the
 	 * range have been unmapped and the pages have been freed by
 	 * the VM.
@@ -137,6 +146,8 @@ struct mmu_notifier_ops {
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
 				       unsigned long start, unsigned long end);
+	void (*invalidate_range_free_pages)(struct mmu_notifier *mn,
+					    struct mm_struct *mm);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
 				     unsigned long start, unsigned long end);
@@ -181,6 +192,7 @@ extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
+extern void __mmu_notifier_invalidate_range_free_pages(struct mm_struct *mm);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 
@@ -227,6 +239,12 @@ static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 		__mmu_notifier_invalidate_range_start(mm, start, end);
 }
 
+static inline void mmu_notifier_invalidate_range_free_pages(struct mm_struct *mm)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_free_pages(mm);
+}
+
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
@@ -354,6 +372,10 @@ static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 {
 }
 
+static inline void mmu_notifier_invalidate_range_free_pages(struct mm_struct *mm)
+{
+}
+
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 8d032de..ec6b11b 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -168,6 +168,19 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 	rcu_read_unlock();
 }
 
+void __mmu_notifier_invalidate_range_free_pages(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->invalidate_range_free_pages)
+			mn->ops->invalidate_range_free_pages(mn, mm);
+	}
+	rcu_read_unlock();
+}
+
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
