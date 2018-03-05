Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83B016B0011
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:28 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so1898687pfo.23
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:28 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id v77si4239219pfa.108.2018.03.05.08.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 11/22] mm: Use __GFP_ENCRYPT for pages in encrypted VMAs
Date: Mon,  5 Mar 2018 19:25:59 +0300
Message-Id: <20180305162610.37510-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Change page allocation path to pass __GFP_ENCRYPT on allocation pages
for encrypted VMAs.

There are two different path where __GFP_ENCRYPT has to be set. One for
kernel compiled with CONFIG_NUMA enabled and the second for kernel
without NUMA support.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/gfp.h | 17 +++++++++++------
 include/linux/mm.h  |  7 +++++++
 mm/mempolicy.c      |  3 +++
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 43a93ca11c3c..c2e6f99a7fc6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -506,21 +506,26 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
 			int node, bool hugepage);
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
-	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
-	alloc_pages(gfp_mask, order)
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
-	alloc_pages(gfp_mask, order)
+
+static inline struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
+			struct vm_area_struct *vma, unsigned long addr,
+			int node, bool hugepage)
+{
+	if (vma_is_encrypted(vma))
+		gfp_mask |= __GFP_ENCRYPT;
+	return alloc_pages(gfp_mask, order);
+}
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id(), false)
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
+#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
+	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6791eccdb740..bc7b32d0189b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1479,6 +1479,13 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
 	return !vma->vm_ops;
 }
 
+#ifndef vma_is_encrypted
+static inline bool vma_is_encrypted(struct vm_area_struct *vma)
+{
+	return false;
+}
+#endif
+
 #ifdef CONFIG_SHMEM
 /*
  * The vma_is_shmem is not inline because it is used only by slow
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d879f1d8a44a..da989273de40 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1977,6 +1977,9 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	int preferred_nid;
 	nodemask_t *nmask;
 
+	if (vma_is_encrypted(vma))
+		gfp |= __GFP_ENCRYPT;
+
 	pol = get_vma_policy(vma, addr);
 
 	if (pol->mode == MPOL_INTERLEAVE) {
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
