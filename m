Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D458C280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:55:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c76so14313186qkj.11
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:55:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 93si4378385qkp.10.2017.08.29.16.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:55:13 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 07/13] iommu/amd: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 19:54:41 -0400
Message-Id: <20170829235447.10050-8-jglisse@redhat.com>
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, iommu@lists.linux-foundation.org, Joerg Roedel <jroedel@suse.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>
Cc: iommu@lists.linux-foundation.org
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/iommu/amd_iommu_v2.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 6629c472eafd..dccf5b76eff2 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -391,13 +391,6 @@ static int mn_clear_flush_young(struct mmu_notifier *mn,
 	return 0;
 }
 
-static void mn_invalidate_page(struct mmu_notifier *mn,
-			       struct mm_struct *mm,
-			       unsigned long address)
-{
-	__mn_flush_page(mn, address);
-}
-
 static void mn_invalidate_range(struct mmu_notifier *mn,
 				struct mm_struct *mm,
 				unsigned long start, unsigned long end)
@@ -436,7 +429,6 @@ static void mn_release(struct mmu_notifier *mn, struct mm_struct *mm)
 static const struct mmu_notifier_ops iommu_mn = {
 	.release		= mn_release,
 	.clear_flush_young      = mn_clear_flush_young,
-	.invalidate_page        = mn_invalidate_page,
 	.invalidate_range       = mn_invalidate_range,
 };
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
