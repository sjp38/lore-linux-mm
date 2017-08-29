Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0E98280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:55:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u63so14404218qkb.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:55:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 21si3916764qtm.495.2017.08.29.16.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:55:08 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 03/13] powerpc/powernv: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 19:54:37 -0400
Message-Id: <20170829235447.10050-4-jglisse@redhat.com>
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linuxppc-dev@lists.ozlabs.org, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Alistair Popple <alistair@popple.id.au>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/powerpc/platforms/powernv/npu-dma.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/arch/powerpc/platforms/powernv/npu-dma.c b/arch/powerpc/platforms/powernv/npu-dma.c
index b5d960d6db3d..4c7b8591f737 100644
--- a/arch/powerpc/platforms/powernv/npu-dma.c
+++ b/arch/powerpc/platforms/powernv/npu-dma.c
@@ -614,15 +614,6 @@ static void pnv_npu2_mn_change_pte(struct mmu_notifier *mn,
 	mmio_invalidate(npu_context, 1, address, true);
 }
 
-static void pnv_npu2_mn_invalidate_page(struct mmu_notifier *mn,
-					struct mm_struct *mm,
-					unsigned long address)
-{
-	struct npu_context *npu_context = mn_to_npu_context(mn);
-
-	mmio_invalidate(npu_context, 1, address, true);
-}
-
 static void pnv_npu2_mn_invalidate_range(struct mmu_notifier *mn,
 					struct mm_struct *mm,
 					unsigned long start, unsigned long end)
@@ -640,7 +631,6 @@ static void pnv_npu2_mn_invalidate_range(struct mmu_notifier *mn,
 static const struct mmu_notifier_ops nv_nmmu_notifier_ops = {
 	.release = pnv_npu2_mn_release,
 	.change_pte = pnv_npu2_mn_change_pte,
-	.invalidate_page = pnv_npu2_mn_invalidate_page,
 	.invalidate_range = pnv_npu2_mn_invalidate_range,
 };
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
