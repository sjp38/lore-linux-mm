Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF7656B03C1
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:18:07 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y68so2372337qka.2
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:18:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n9si694995qte.3.2017.08.31.14.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 14:18:07 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 10/13] sgi-gru: update to new mmu_notifier semantic
Date: Thu, 31 Aug 2017 17:17:35 -0400
Message-Id: <20170831211738.17922-11-jglisse@redhat.com>
In-Reply-To: <20170831211738.17922-1-jglisse@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/misc/sgi-gru/grutlbpurge.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index e936d43895d2..9918eda0e05f 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -247,17 +247,6 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, start, end);
 }
 
-static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
-				unsigned long address)
-{
-	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
-						 ms_notifier);
-
-	STAT(mmu_invalidate_page);
-	gru_flush_tlb_range(gms, address, PAGE_SIZE);
-	gru_dbg(grudev, "gms %p, address 0x%lx\n", gms, address);
-}
-
 static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
@@ -269,7 +258,6 @@ static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
 
 
 static const struct mmu_notifier_ops gru_mmuops = {
-	.invalidate_page	= gru_invalidate_page,
 	.invalidate_range_start	= gru_invalidate_range_start,
 	.invalidate_range_end	= gru_invalidate_range_end,
 	.release		= gru_release,
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
