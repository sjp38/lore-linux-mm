Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37F1C28029E
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:25:02 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id j6so12167003pgp.21
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:25:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t62si5024281pfa.49.2018.01.17.12.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:54 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 65/99] dax: Fix sparse warning
Date: Wed, 17 Jan 2018 12:21:29 -0800
Message-Id: <20180117202203.19756-66-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

sparse doesn't know that follow_pte_pmd() conditionally acquires the ptl,
because it's in a separate compilation unit.  Move follow_pte_pmd() to
mm.h where sparse can see it.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm.h | 15 ++++++++++++++-
 mm/memory.c        | 16 +---------------
 2 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fe1ee4313add..9c384c486edf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1314,7 +1314,7 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
-int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 			     unsigned long *start, unsigned long *end,
 			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
@@ -1324,6 +1324,19 @@ int follow_phys(struct vm_area_struct *vma, unsigned long address,
 int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 			void *buf, int len, int write);
 
+static inline int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+			     unsigned long *start, unsigned long *end,
+			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
+{
+	int res;
+
+	/* (void) is needed to make gcc happy */
+	(void) __cond_lock(*ptlp,
+			   !(res = __follow_pte_pmd(mm, address, start, end,
+						    ptepp, pmdpp, ptlp)));
+	return res;
+}
+
 static inline void unmap_shared_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen)
 {
diff --git a/mm/memory.c b/mm/memory.c
index ca5674cbaff2..66184601ac03 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4201,7 +4201,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
 
-static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 			    unsigned long *start, unsigned long *end,
 			    pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
 {
@@ -4278,20 +4278,6 @@ static inline int follow_pte(struct mm_struct *mm, unsigned long address,
 	return res;
 }
 
-int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
-			     unsigned long *start, unsigned long *end,
-			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
-{
-	int res;
-
-	/* (void) is needed to make gcc happy */
-	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte_pmd(mm, address, start, end,
-						    ptepp, pmdpp, ptlp)));
-	return res;
-}
-EXPORT_SYMBOL(follow_pte_pmd);
-
 /**
  * follow_pfn - look up PFN at a user virtual address
  * @vma: memory mapping
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
