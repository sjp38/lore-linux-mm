Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDA76B0253
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:35:58 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q128so69994408qkd.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:35:58 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g67si3817159qkf.319.2016.12.16.10.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:35:57 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 02/14] sparc64: add new fields to mmu context for shared context support
Date: Fri, 16 Dec 2016 10:35:25 -0800
Message-Id: <1481913337-9331-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Add new fields to the mm_context structure to support shared context.
Instead of a simple context ID, add a pointer to a structure with a
reference count.  This is needed as multiple tasks will share the
context ID.

Pages using the shared context ID will reside in a separate TSB.  So
changes are made to increase the number of TSBs as well.  Note that
only support for context sharing of huge pages is provided.  Therefore,
no base page size shared context TSB.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/include/asm/mmu_64.h         | 36 +++++++++++++++++++++++++++++----
 arch/sparc/include/asm/mmu_context_64.h |  8 ++++----
 2 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/arch/sparc/include/asm/mmu_64.h b/arch/sparc/include/asm/mmu_64.h
index f7de0db..edf8663 100644
--- a/arch/sparc/include/asm/mmu_64.h
+++ b/arch/sparc/include/asm/mmu_64.h
@@ -57,6 +57,13 @@
 	 (!(((__ctx.sparc64_ctx_val) ^ tlb_context_cache) & CTX_VERSION_MASK))
 #define CTX_HWBITS(__ctx)	((__ctx.sparc64_ctx_val) & CTX_HW_MASK)
 #define CTX_NRBITS(__ctx)	((__ctx.sparc64_ctx_val) & CTX_NR_MASK)
+#define	SHARED_CTX_VALID(__ctx)	(__ctx.shared_ctx && \
+	 (!(((__ctx.shared_ctx->shared_ctx_val) ^ tlb_context_cache) & \
+	   CTX_VERSION_MASK)))
+#define	SHARED_CTX_HWBITS(__ctx)	\
+	 ((__ctx.shared_ctx->shared_ctx_val) & CTX_HW_MASK)
+#define	SHARED_CTX_NRBITS(__ctx)	\
+	 ((__ctx.shared_ctx->shared_ctx_val) & CTX_NR_MASK)
 
 #ifndef __ASSEMBLY__
 
@@ -80,24 +87,45 @@ struct tsb_config {
 	unsigned long		tsb_map_pte;
 };
 
-#define MM_TSB_BASE	0
+#if defined(CONFIG_SHARED_MMU_CTX)
+struct shared_mmu_ctx {
+	atomic_t	refcount;
+	unsigned long	shared_ctx_val;
+};
+
+#define MM_TSB_HUGE_SHARED	0
+#define MM_TSB_BASE		1
+#define MM_TSB_HUGE		2
+#define MM_NUM_TSBS		3
+#else
 
+#define MM_TSB_BASE		0
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
-#define MM_TSB_HUGE	1
-#define MM_NUM_TSBS	2
+#define MM_TSB_HUGE		1
+#define MM_TSB_HUGE_SHARED	1	/* Simplifies conditions in code */
+#define MM_NUM_TSBS		2
 #else
-#define MM_NUM_TSBS	1
+#define MM_NUM_TSBS		1
+#endif
 #endif
 
 typedef struct {
 	spinlock_t		lock;
 	unsigned long		sparc64_ctx_val;
+#if defined(CONFIG_SHARED_MMU_CTX)
+	struct shared_mmu_ctx	*shared_ctx;
+	unsigned long		shared_hugetlb_pte_count;
+#endif
 	unsigned long		hugetlb_pte_count;
 	unsigned long		thp_pte_count;
 	struct tsb_config	tsb_block[MM_NUM_TSBS];
 	struct hv_tsb_descr	tsb_descr[MM_NUM_TSBS];
 } mm_context_t;
 
+#define	mm_shared_ctx_val(mm)					\
+	((mm)->context.shared_ctx ?				\
+	 (mm)->context.shared_ctx->shared_ctx_val : 0UL)
+
 #endif /* !__ASSEMBLY__ */
 
 #define TSB_CONFIG_TSB		0x00
diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
index b84be67..d031799 100644
--- a/arch/sparc/include/asm/mmu_context_64.h
+++ b/arch/sparc/include/asm/mmu_context_64.h
@@ -35,15 +35,15 @@ void __tsb_context_switch(unsigned long pgd_pa,
 static inline void tsb_context_switch(struct mm_struct *mm)
 {
 	__tsb_context_switch(__pa(mm->pgd),
-			     &mm->context.tsb_block[0],
+			     &mm->context.tsb_block[MM_TSB_BASE],
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
-			     (mm->context.tsb_block[1].tsb ?
-			      &mm->context.tsb_block[1] :
+			     (mm->context.tsb_block[MM_TSB_HUGE].tsb ?
+			      &mm->context.tsb_block[MM_TSB_HUGE] :
 			      NULL)
 #else
 			     NULL
 #endif
-			     , __pa(&mm->context.tsb_descr[0]));
+			     , __pa(&mm->context.tsb_descr[MM_TSB_BASE]));
 }
 
 void tsb_grow(struct mm_struct *mm,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
