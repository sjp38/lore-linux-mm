Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F346A6B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 13:58:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c7so11845502pfd.12
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 10:58:31 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 31si10703492plh.326.2017.06.06.10.58.30
        for <linux-mm@kvack.org>;
        Tue, 06 Jun 2017 10:58:31 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered against prior accesses
Date: Tue,  6 Jun 2017 18:58:35 +0100
Message-Id: <1496771916-28203-3-git-send-email-will.deacon@arm.com>
In-Reply-To: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com, Will Deacon <will.deacon@arm.com>

page_ref_freeze and page_ref_unfreeze are designed to be used as a pair,
wrapping a critical section where struct pages can be modified without
having to worry about consistency for a concurrent fast-GUP.

Whilst page_ref_freeze has full barrier semantics due to its use of
atomic_cmpxchg, page_ref_unfreeze is implemented using atomic_set, which
doesn't provide any barrier semantics and allows the operation to be
reordered with respect to page modifications in the critical section.

This patch ensures that page_ref_unfreeze is ordered after any critical
section updates, by invoking smp_mb__before_atomic() prior to the
atomic_set.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Acked-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 include/linux/page_ref.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index 610e13271918..74d32d7905cb 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -174,6 +174,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
 	VM_BUG_ON_PAGE(page_count(page) != 0, page);
 	VM_BUG_ON(count == 0);
 
+	smp_mb__before_atomic();
 	atomic_set(&page->_refcount, count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_unfreeze))
 		__page_ref_unfreeze(page, count);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
