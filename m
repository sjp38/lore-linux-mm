Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E38D06B039F
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:17:57 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u9so2245440qkl.7
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:17:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b85si6591217qkg.540.2017.08.31.14.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 14:17:57 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 05/13] IB/umem: update to new mmu_notifier semantic
Date: Thu, 31 Aug 2017 17:17:30 -0400
Message-Id: <20170831211738.17922-6-jglisse@redhat.com>
In-Reply-To: <20170831211738.17922-1-jglisse@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-rdma@vger.kernel.org, Artemy Kovalyov <artemyko@mellanox.com>, Doug Ledford <dledford@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Tested-by: Leon Romanovsky <leonro@mellanox.com>
Cc: linux-rdma@vger.kernel.org
Cc: Artemy Kovalyov <artemyko@mellanox.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/infiniband/core/umem_odp.c | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 8c4ec564e495..55e8f5ed8b3c 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -166,24 +166,6 @@ static int invalidate_page_trampoline(struct ib_umem *item, u64 start,
 	return 0;
 }
 
-static void ib_umem_notifier_invalidate_page(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
-					     unsigned long address)
-{
-	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
-
-	if (!context->invalidate_range)
-		return;
-
-	ib_ucontext_notifier_start_account(context);
-	down_read(&context->umem_rwsem);
-	rbt_ib_umem_for_each_in_range(&context->umem_tree, address,
-				      address + PAGE_SIZE,
-				      invalidate_page_trampoline, NULL);
-	up_read(&context->umem_rwsem);
-	ib_ucontext_notifier_end_account(context);
-}
-
 static int invalidate_range_start_trampoline(struct ib_umem *item, u64 start,
 					     u64 end, void *cookie)
 {
@@ -237,7 +219,6 @@ static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
 
 static const struct mmu_notifier_ops ib_umem_notifiers = {
 	.release                    = ib_umem_notifier_release,
-	.invalidate_page            = ib_umem_notifier_invalidate_page,
 	.invalidate_range_start     = ib_umem_notifier_invalidate_range_start,
 	.invalidate_range_end       = ib_umem_notifier_invalidate_range_end,
 };
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
