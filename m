Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1358F6B0035
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 12:18:19 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so5962029wib.4
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 09:18:17 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTP id k1si20674212wib.73.2014.07.29.09.18.15
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 09:18:16 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 1/3] mmu_notifier: Add mmu_notifier_invalidate_range()
Date: Tue, 29 Jul 2014 18:18:11 +0200
Message-Id: <1406650693-23315-2-git-send-email-joro@8bytes.org>
In-Reply-To: <1406650693-23315-1-git-send-email-joro@8bytes.org>
References: <1406650693-23315-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

From: Joerg Roedel <jroedel@suse.de>

This notifier closes two important gaps with the current
invalidate_range_start()/end() notifiers. The _start() part
is called when all pages are still mapped while the _end()
notifier is called when all pages are potentially unmapped
and already freed.

This does not allow to manage external (non-CPU) hardware
TLBs with MMU-notifiers because there is no way to prevent
that hardware will establish new TLB entries between the
calls of these two functions. But this is a requirement to
the subsytem that implements these existing notifiers.

To allow managing external TLBs the MMU-notifiers need to
catch the moment when pages are unmapped but not yet freed.
This new notifier catches that moment and notifies the
interested subsytem when pages that were unmapped are about
to be freed. The new notifier will be called between
invalidate_range_start()/end() to catch the moment when
pages are unmapped but not yet freed.

For non-CPU TLBs it is also necessary to know when
page-table pages are freed. This is the second gap in
current mmu_notifiers. At those events the new notifier will
also be called, without calling invalidate_range_start() and
invalidate_range_end() around it.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 include/linux/mmu_notifier.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca874..1bac99c 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -235,6 +235,11 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 		__mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
+static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+}
+
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 	mm->mmu_notifier_mm = NULL;
@@ -326,6 +331,11 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 {
 }
 
+static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+}
+
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
