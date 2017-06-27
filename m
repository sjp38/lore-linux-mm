Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96C506B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:49:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h81so23987985pfh.15
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:49:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u72si1788824pfk.160.2017.06.27.04.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 04:49:00 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 2/5] mm: convert anon_vma.refcount from atomic_t to refcount_t
Date: Tue, 27 Jun 2017 14:48:44 +0300
Message-Id: <1498564127-11097-3-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1498564127-11097-1-git-send-email-elena.reshetova@intel.com>
References: <1498564127-11097-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, keescook@chromium.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>, Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/linux/rmap.h |  7 ++++---
 mm/rmap.c            | 14 +++++++-------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 8c89e90..a8f4a97 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -10,6 +10,7 @@
 #include <linux/rwsem.h>
 #include <linux/memcontrol.h>
 #include <linux/highmem.h>
+#include <linux/refcount.h>
 
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
@@ -35,7 +36,7 @@ struct anon_vma {
 	 * the reference is responsible for clearing up the
 	 * anon_vma if they are the last user on release
 	 */
-	atomic_t refcount;
+	refcount_t refcount;
 
 	/*
 	 * Count of child anon_vmas and VMAs which points to this anon_vma.
@@ -102,14 +103,14 @@ enum ttu_flags {
 #ifdef CONFIG_MMU
 static inline void get_anon_vma(struct anon_vma *anon_vma)
 {
-	atomic_inc(&anon_vma->refcount);
+	refcount_inc(&anon_vma->refcount);
 }
 
 void __put_anon_vma(struct anon_vma *anon_vma);
 
 static inline void put_anon_vma(struct anon_vma *anon_vma)
 {
-	if (atomic_dec_and_test(&anon_vma->refcount))
+	if (refcount_dec_and_test(&anon_vma->refcount))
 		__put_anon_vma(anon_vma);
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index f683801..55d7f9e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -79,7 +79,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
 
 	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
 	if (anon_vma) {
-		atomic_set(&anon_vma->refcount, 1);
+		refcount_set(&anon_vma->refcount, 1);
 		anon_vma->degree = 1;	/* Reference for first vma */
 		anon_vma->parent = anon_vma;
 		/*
@@ -94,7 +94,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
 
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
-	VM_BUG_ON(atomic_read(&anon_vma->refcount));
+	VM_BUG_ON(refcount_read(&anon_vma->refcount));
 
 	/*
 	 * Synchronize against page_lock_anon_vma_read() such that
@@ -423,7 +423,7 @@ static void anon_vma_ctor(void *data)
 	struct anon_vma *anon_vma = data;
 
 	init_rwsem(&anon_vma->rwsem);
-	atomic_set(&anon_vma->refcount, 0);
+	refcount_set(&anon_vma->refcount, 0);
 	anon_vma->rb_root = RB_ROOT;
 }
 
@@ -472,7 +472,7 @@ struct anon_vma *page_get_anon_vma(struct page *page)
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
+	if (!refcount_inc_not_zero(&anon_vma->refcount)) {
 		anon_vma = NULL;
 		goto out;
 	}
@@ -531,7 +531,7 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	}
 
 	/* trylock failed, we got to sleep */
-	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
+	if (!refcount_inc_not_zero(&anon_vma->refcount)) {
 		anon_vma = NULL;
 		goto out;
 	}
@@ -546,7 +546,7 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	rcu_read_unlock();
 	anon_vma_lock_read(anon_vma);
 
-	if (atomic_dec_and_test(&anon_vma->refcount)) {
+	if (refcount_dec_and_test(&anon_vma->refcount)) {
 		/*
 		 * Oops, we held the last refcount, release the lock
 		 * and bail -- can't simply use put_anon_vma() because
@@ -1585,7 +1585,7 @@ void __put_anon_vma(struct anon_vma *anon_vma)
 	struct anon_vma *root = anon_vma->root;
 
 	anon_vma_free(anon_vma);
-	if (root != anon_vma && atomic_dec_and_test(&root->refcount))
+	if (root != anon_vma && refcount_dec_and_test(&root->refcount))
 		anon_vma_free(root);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
