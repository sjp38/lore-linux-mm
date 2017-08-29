Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0E3280395
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:55:16 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g13so14751578qta.6
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:55:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v26si2329015qtf.150.2017.08.29.16.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:55:15 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 09/13] misc/mic/scif: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 19:54:43 -0400
Message-Id: <20170829235447.10050-10-jglisse@redhat.com>
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Sudeep Dutt <sudeep.dutt@intel.com>
Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/misc/mic/scif/scif_dma.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/misc/mic/scif/scif_dma.c b/drivers/misc/mic/scif/scif_dma.c
index 64d5760d069a..63d6246d6dff 100644
--- a/drivers/misc/mic/scif/scif_dma.c
+++ b/drivers/misc/mic/scif/scif_dma.c
@@ -200,16 +200,6 @@ static void scif_mmu_notifier_release(struct mmu_notifier *mn,
 	schedule_work(&scif_info.misc_work);
 }
 
-static void scif_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
-					      struct mm_struct *mm,
-					      unsigned long address)
-{
-	struct scif_mmu_notif	*mmn;
-
-	mmn = container_of(mn, struct scif_mmu_notif, ep_mmu_notifier);
-	scif_rma_destroy_tcw(mmn, address, PAGE_SIZE);
-}
-
 static void scif_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						     struct mm_struct *mm,
 						     unsigned long start,
@@ -235,7 +225,6 @@ static void scif_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
 static const struct mmu_notifier_ops scif_mmu_notifier_ops = {
 	.release = scif_mmu_notifier_release,
 	.clear_flush_young = NULL,
-	.invalidate_page = scif_mmu_notifier_invalidate_page,
 	.invalidate_range_start = scif_mmu_notifier_invalidate_range_start,
 	.invalidate_range_end = scif_mmu_notifier_invalidate_range_end};
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
