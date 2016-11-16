Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBB626B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 02:40:14 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so17364659wms.7
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 23:40:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u124si6120311wmb.125.2016.11.15.23.40.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 23:40:13 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, rmap: handle anon_vma_prepare() common case inline
Date: Wed, 16 Nov 2016 08:40:05 +0100
Message-Id: <20161116074005.22768-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>

The anon_vma_prepare() function is mostly a large "if (unlikely(...))" block,
as the expected common case is that an anon_vma already exists. We could turn
the condition around and return 0, but it also makes sense to do it inline and
avoid a call for the common case.

Bloat-o-meter naturally shows that inlining the check has some code size costs:

add/remove: 1/1 grow/shrink: 4/0 up/down: 475/-373 (102)
function                                     old     new   delta
__anon_vma_prepare                             -     359    +359
handle_mm_fault                             2744    2796     +52
hugetlb_cow                                 1146    1170     +24
hugetlb_fault                               2123    2145     +22
wp_page_copy                                1469    1487     +18
anon_vma_prepare                             373       -    -373

Checking the asm however confirms that the hot paths now avoid a call, which
is now moved away.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/rmap.h | 10 ++++++-
 mm/rmap.c            | 73 ++++++++++++++++++++++++++--------------------------
 2 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b46bb5620a76..850da50c574e 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -137,11 +137,19 @@ static inline void anon_vma_unlock_read(struct anon_vma *anon_vma)
  * anon_vma helper functions.
  */
 void anon_vma_init(void);	/* create anon_vma_cachep */
-int  anon_vma_prepare(struct vm_area_struct *);
+int  __anon_vma_prepare(struct vm_area_struct *);
 void unlink_anon_vmas(struct vm_area_struct *);
 int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 
+static inline int anon_vma_prepare(struct vm_area_struct * vma)
+{
+	if (likely(vma->anon_vma))
+		return 0;
+
+	return __anon_vma_prepare(vma);
+}
+
 static inline void anon_vma_merge(struct vm_area_struct *vma,
 				  struct vm_area_struct *next)
 {
diff --git a/mm/rmap.c b/mm/rmap.c
index 1ef36404e7b2..91619fd70939 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -141,14 +141,15 @@ static void anon_vma_chain_link(struct vm_area_struct *vma,
 }
 
 /**
- * anon_vma_prepare - attach an anon_vma to a memory region
+ * __anon_vma_prepare - attach an anon_vma to a memory region
  * @vma: the memory region in question
  *
  * This makes sure the memory mapping described by 'vma' has
  * an 'anon_vma' attached to it, so that we can associate the
  * anonymous pages mapped into it with that anon_vma.
  *
- * The common case will be that we already have one, but if
+ * The common case will be that we already have one, which
+ * is handled inline by anon_vma_prepare(). But if
  * not we either need to find an adjacent mapping that we
  * can re-use the anon_vma from (very common when the only
  * reason for splitting a vma has been mprotect()), or we
@@ -167,48 +168,46 @@ static void anon_vma_chain_link(struct vm_area_struct *vma,
  *
  * This must be called with the mmap_sem held for reading.
  */
-int anon_vma_prepare(struct vm_area_struct *vma)
+int __anon_vma_prepare(struct vm_area_struct *vma)
 {
-	struct anon_vma *anon_vma = vma->anon_vma;
+	struct mm_struct *mm = vma->vm_mm;
+	struct anon_vma *anon_vma, *allocated;
 	struct anon_vma_chain *avc;
 
 	might_sleep();
-	if (unlikely(!anon_vma)) {
-		struct mm_struct *mm = vma->vm_mm;
-		struct anon_vma *allocated;
 
-		avc = anon_vma_chain_alloc(GFP_KERNEL);
-		if (!avc)
-			goto out_enomem;
+	avc = anon_vma_chain_alloc(GFP_KERNEL);
+	if (!avc)
+		goto out_enomem;
 
-		anon_vma = find_mergeable_anon_vma(vma);
-		allocated = NULL;
-		if (!anon_vma) {
-			anon_vma = anon_vma_alloc();
-			if (unlikely(!anon_vma))
-				goto out_enomem_free_avc;
-			allocated = anon_vma;
-		}
-
-		anon_vma_lock_write(anon_vma);
-		/* page_table_lock to protect against threads */
-		spin_lock(&mm->page_table_lock);
-		if (likely(!vma->anon_vma)) {
-			vma->anon_vma = anon_vma;
-			anon_vma_chain_link(vma, avc, anon_vma);
-			/* vma reference or self-parent link for new root */
-			anon_vma->degree++;
-			allocated = NULL;
-			avc = NULL;
-		}
-		spin_unlock(&mm->page_table_lock);
-		anon_vma_unlock_write(anon_vma);
-
-		if (unlikely(allocated))
-			put_anon_vma(allocated);
-		if (unlikely(avc))
-			anon_vma_chain_free(avc);
+	anon_vma = find_mergeable_anon_vma(vma);
+	allocated = NULL;
+	if (!anon_vma) {
+		anon_vma = anon_vma_alloc();
+		if (unlikely(!anon_vma))
+			goto out_enomem_free_avc;
+		allocated = anon_vma;
 	}
+
+	anon_vma_lock_write(anon_vma);
+	/* page_table_lock to protect against threads */
+	spin_lock(&mm->page_table_lock);
+	if (likely(!vma->anon_vma)) {
+		vma->anon_vma = anon_vma;
+		anon_vma_chain_link(vma, avc, anon_vma);
+		/* vma reference or self-parent link for new root */
+		anon_vma->degree++;
+		allocated = NULL;
+		avc = NULL;
+	}
+	spin_unlock(&mm->page_table_lock);
+	anon_vma_unlock_write(anon_vma);
+
+	if (unlikely(allocated))
+		put_anon_vma(allocated);
+	if (unlikely(avc))
+		anon_vma_chain_free(avc);
+
 	return 0;
 
  out_enomem_free_avc:
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
