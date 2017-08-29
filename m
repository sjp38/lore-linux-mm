Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C85A280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:55:15 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id l65so14374468qkc.1
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:55:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s5si3987065qta.415.2017.08.29.16.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:55:14 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 08/13] iommu/intel: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 19:54:42 -0400
Message-Id: <20170829235447.10050-9-jglisse@redhat.com>
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, David Woodhouse <dwmw2@infradead.org>, iommu@lists.linux-foundation.org, Joerg Roedel <jroedel@suse.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: iommu@lists.linux-foundation.org
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/iommu/intel-svm.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index f167c0d84ebf..f620dccec8ee 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -223,14 +223,6 @@ static void intel_change_pte(struct mmu_notifier *mn, struct mm_struct *mm,
 	intel_flush_svm_range(svm, address, 1, 1, 0);
 }
 
-static void intel_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
-				  unsigned long address)
-{
-	struct intel_svm *svm = container_of(mn, struct intel_svm, notifier);
-
-	intel_flush_svm_range(svm, address, 1, 1, 0);
-}
-
 /* Pages have been freed at this point */
 static void intel_invalidate_range(struct mmu_notifier *mn,
 				   struct mm_struct *mm,
@@ -285,7 +277,6 @@ static void intel_mm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 static const struct mmu_notifier_ops intel_mmuops = {
 	.release = intel_mm_release,
 	.change_pte = intel_change_pte,
-	.invalidate_page = intel_invalidate_page,
 	.invalidate_range = intel_invalidate_range,
 };
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
