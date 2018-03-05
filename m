Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30F1E6B0025
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:30 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so1898727pfo.23
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:30 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 2-v6si9571007ple.387.2018.03.05.08.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:28 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 09/22] mm, rmap: Add arch-specific field into anon_vma
Date: Mon,  5 Mar 2018 19:25:57 +0300
Message-Id: <20180305162610.37510-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

MKTME enabling requires a way to find out which encryption KeyID has to
be used to access the page. There's not enough space in struct page to
store this information.

As a way out we can store it in anon_vma for the page: all pages in the
same anon_vma tree will be encrypted with the same KeyID.

This patch adds arch-specific field into anon_vma. For x86 it will be
used to store KeyID.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  6 ++++++
 mm/rmap.c            | 15 ++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 988d176472df..54c7ea330827 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -12,6 +12,10 @@
 #include <linux/memcontrol.h>
 #include <linux/highmem.h>
 
+#ifndef arch_anon_vma
+struct arch_anon_vma {};
+#endif
+
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
  * an anonymous page pointing to this anon_vma needs to be unmapped:
@@ -59,6 +63,8 @@ struct anon_vma {
 
 	/* Interval tree of private "related" vmas */
 	struct rb_root_cached rb_root;
+
+	struct arch_anon_vma arch_anon_vma;
 };
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index 47db27f8049e..c0470a69a4c9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -74,7 +74,14 @@
 static struct kmem_cache *anon_vma_cachep;
 static struct kmem_cache *anon_vma_chain_cachep;
 
-static inline struct anon_vma *anon_vma_alloc(void)
+#ifndef arch_anon_vma_init
+static inline void arch_anon_vma_init(struct anon_vma *anon_vma,
+		struct vm_area_struct *vma)
+{
+}
+#endif
+
+static inline struct anon_vma *anon_vma_alloc(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma;
 
@@ -88,6 +95,8 @@ static inline struct anon_vma *anon_vma_alloc(void)
 		 * from fork, the root will be reset to the parents anon_vma.
 		 */
 		anon_vma->root = anon_vma;
+
+		arch_anon_vma_init(anon_vma, vma);
 	}
 
 	return anon_vma;
@@ -186,7 +195,7 @@ int __anon_vma_prepare(struct vm_area_struct *vma)
 	anon_vma = find_mergeable_anon_vma(vma);
 	allocated = NULL;
 	if (!anon_vma) {
-		anon_vma = anon_vma_alloc();
+		anon_vma = anon_vma_alloc(vma);
 		if (unlikely(!anon_vma))
 			goto out_enomem_free_avc;
 		allocated = anon_vma;
@@ -337,7 +346,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 		return 0;
 
 	/* Then add our own anon_vma. */
-	anon_vma = anon_vma_alloc();
+	anon_vma = anon_vma_alloc(vma);
 	if (!anon_vma)
 		goto out_error;
 	avc = anon_vma_chain_alloc(GFP_KERNEL);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
