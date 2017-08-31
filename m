Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1869B6B03A1
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:17:59 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t13so2247057qtc.7
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:17:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c186si6457qkg.140.2017.08.31.14.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 14:17:58 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 06/13] IB/hfi1: update to new mmu_notifier semantic
Date: Thu, 31 Aug 2017 17:17:31 -0400
Message-Id: <20170831211738.17922-7-jglisse@redhat.com>
In-Reply-To: <20170831211738.17922-1-jglisse@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-rdma@vger.kernel.org, Dean Luick <dean.luick@intel.com>, Ira Weiny <ira.weiny@intel.com>, Doug Ledford <dledford@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: linux-rdma@vger.kernel.org
Cc: Dean Luick <dean.luick@intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/infiniband/hw/hfi1/mmu_rb.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/mmu_rb.c b/drivers/infiniband/hw/hfi1/mmu_rb.c
index ccbf52c8ff6f..e4b56a0dd6d0 100644
--- a/drivers/infiniband/hw/hfi1/mmu_rb.c
+++ b/drivers/infiniband/hw/hfi1/mmu_rb.c
@@ -67,8 +67,6 @@ struct mmu_rb_handler {
 
 static unsigned long mmu_node_start(struct mmu_rb_node *);
 static unsigned long mmu_node_last(struct mmu_rb_node *);
-static inline void mmu_notifier_page(struct mmu_notifier *, struct mm_struct *,
-				     unsigned long);
 static inline void mmu_notifier_range_start(struct mmu_notifier *,
 					    struct mm_struct *,
 					    unsigned long, unsigned long);
@@ -82,7 +80,6 @@ static void do_remove(struct mmu_rb_handler *handler,
 static void handle_remove(struct work_struct *work);
 
 static const struct mmu_notifier_ops mn_opts = {
-	.invalidate_page = mmu_notifier_page,
 	.invalidate_range_start = mmu_notifier_range_start,
 };
 
@@ -285,12 +282,6 @@ void hfi1_mmu_rb_remove(struct mmu_rb_handler *handler,
 	handler->ops->remove(handler->ops_arg, node);
 }
 
-static inline void mmu_notifier_page(struct mmu_notifier *mn,
-				     struct mm_struct *mm, unsigned long addr)
-{
-	mmu_notifier_mem_invalidate(mn, mm, addr, addr + PAGE_SIZE);
-}
-
 static inline void mmu_notifier_range_start(struct mmu_notifier *mn,
 					    struct mm_struct *mm,
 					    unsigned long start,
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
