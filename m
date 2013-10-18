Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id BB8BF6B014A
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 09:07:39 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fa1so4441259pad.23
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 06:07:39 -0700 (PDT)
Received: from psmtp.com ([74.125.245.135])
        by mx.google.com with SMTP id io7si563769pbc.329.2013.10.18.06.07.38
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 06:07:38 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id c11so3659704wgh.26
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 06:07:36 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH 1/2] thp: Introduce arch_(un)block_thp_split
Date: Fri, 18 Oct 2013 14:07:12 +0100
Message-Id: <1382101634-4723-2-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1382101634-4723-1-git-send-email-steve.capper@linaro.org>
References: <1382101634-4723-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, Zi Shen Lim <zishen.lim@linaro.org>, patches@linaro.org, linaro-kernel@lists.linaro.org, Steve Capper <steve.capper@linaro.org>

In kernel/futex.c an assumption is made in the THP tail pinning code
that disabling the irqs is sufficient to block the THP splitting code
from completing.

Architectures such as ARM do hardware TLB broadcasts so disabling the
irqs will not prevent a THP split from completing.

This patch introduces: arch_block_thp_split and arch_unblock_thp_split,
and provides stock implementations that observe the original irq enable
and disable behaviour.

One can then define these macros themselves to implement architecture
specific behaviour.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 include/linux/huge_mm.h | 16 ++++++++++++++++
 kernel/futex.c          |  6 +++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 3935428..35fb742 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -177,6 +177,14 @@ static inline struct page *compound_trans_head(struct page *page)
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
+#ifndef arch_block_thp_split
+#define arch_block_thp_split(mm)	local_irq_disable()
+#endif
+
+#ifndef arch_unblock_thp_split
+#define arch_unblock_thp_split(mm)	local_irq_enable()
+#endif
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -227,6 +235,14 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
 	return 0;
 }
 
+#ifndef arch_block_thp_split
+#define arch_block_thp_split(mm)	do { } while (0)
+#endif
+
+#ifndef arch_unblock_thp_split
+#define arch_unblock_thp_split(mm)	do { } while (0)
+#endif
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/kernel/futex.c b/kernel/futex.c
index c3a1a55..e016ff2 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -287,7 +287,7 @@ again:
 	if (unlikely(PageTail(page))) {
 		put_page(page);
 		/* serialize against __split_huge_page_splitting() */
-		local_irq_disable();
+		arch_block_thp_split(mm);
 		if (likely(__get_user_pages_fast(address, 1, 1, &page) == 1)) {
 			page_head = compound_head(page);
 			/*
@@ -304,9 +304,9 @@ again:
 				get_page(page_head);
 				put_page(page);
 			}
-			local_irq_enable();
+			arch_unblock_thp_split(mm);
 		} else {
-			local_irq_enable();
+			arch_unblock_thp_split(mm);
 			goto again;
 		}
 	}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
