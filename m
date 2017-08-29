Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74974280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:11:47 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f15so13322582qtc.11
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:11:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r8si3753695qkl.216.2017.08.29.13.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 13:11:46 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 4/4] iommu/amd: update to new mmu_notifier_invalidate_page() semantic
Date: Tue, 29 Aug 2017 16:11:32 -0400
Message-Id: <20170829201132.9292-5-jglisse@redhat.com>
In-Reply-To: <20170829201132.9292-1-jglisse@redhat.com>
References: <20170829201132.9292-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

mmu_notifier_invalidate_page() is now be call from under the spinlock.
But we can now rely on invalidate_range() being call afterward.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bernhard Held <berny156@gmx.de>
Cc: Adam Borowski <kilobyte@angband.pl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: Wanpeng Li <kernellwp@gmail.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Mike Galbraith <efault@gmx.de>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: axie <axie@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
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
