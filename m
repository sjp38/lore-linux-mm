Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07A956B0011
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:29 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 101-v6so8310933ple.19
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:29 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k4-v6si9469678pls.277.2018.03.05.08.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 13/22] mm, rmap: Free encrypted pages once mapcount drops to zero
Date: Mon,  5 Mar 2018 19:26:01 +0300
Message-Id: <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Freeing encrypted pages may require special treatment such as flush
cache to avoid aliasing.

Anonymous pages cannot be mapped back once the last mapcount is gone.
That's a good place to add hook to free encrypted page. At later point
we may not have valid anon_vma around to get KeyID.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |  1 +
 mm/rmap.c          | 34 ++++++++++++++++++++++++++++++++--
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7a4285f09c99..7ab5e39e3195 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1981,6 +1981,7 @@ extern void mem_init_print_info(const char *str);
 extern void reserve_bootmem_region(phys_addr_t start, phys_addr_t end);
 
 extern void prep_encrypt_page(struct page *page, gfp_t gfp, unsigned int order);
+extern void free_encrypt_page(struct page *page, int keyid, unsigned int order);
 
 /* Free the reserved page into the buddy system, so it gets managed. */
 static inline void __free_reserved_page(struct page *page)
diff --git a/mm/rmap.c b/mm/rmap.c
index c0470a69a4c9..4bff992fc106 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -81,6 +81,21 @@ static inline void arch_anon_vma_init(struct anon_vma *anon_vma,
 }
 #endif
 
+#ifndef anon_vma_encrypted
+static inline bool anon_vma_encrypted(struct anon_vma *anon_vma)
+{
+	return false;
+}
+#endif
+
+#ifndef anon_vma_keyid
+static inline int anon_vma_keyid(struct anon_vma *anon_vma)
+{
+	BUILD_BUG();
+	return 0;
+}
+#endif
+
 static inline struct anon_vma *anon_vma_alloc(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma;
@@ -1258,6 +1273,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 
 static void page_remove_anon_compound_rmap(struct page *page)
 {
+	struct anon_vma *anon_vma;
 	int i, nr;
 
 	if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
@@ -1292,6 +1308,12 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
 		deferred_split_huge_page(page);
 	}
+
+	anon_vma = page_anon_vma(page);
+	if (anon_vma_encrypted(anon_vma)) {
+		int keyid = anon_vma_keyid(anon_vma);
+		free_encrypt_page(page, keyid, compound_order(page));
+	}
 }
 
 /**
@@ -1303,6 +1325,9 @@ static void page_remove_anon_compound_rmap(struct page *page)
  */
 void page_remove_rmap(struct page *page, bool compound)
 {
+	struct page *head;
+	struct anon_vma *anon_vma;
+
 	if (!PageAnon(page))
 		return page_remove_file_rmap(page, compound);
 
@@ -1323,8 +1348,13 @@ void page_remove_rmap(struct page *page, bool compound)
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 
-	if (PageTransCompound(page))
-		deferred_split_huge_page(compound_head(page));
+	head = compound_head(page);
+	if (PageTransHuge(head))
+		deferred_split_huge_page(head);
+
+	anon_vma = page_anon_vma(head);
+	if (anon_vma_encrypted(anon_vma))
+		free_encrypt_page(page, anon_vma_keyid(anon_vma), 0);
 
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
