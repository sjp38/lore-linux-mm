Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 364876B038C
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 05:49:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c193so79363502pfb.7
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 02:49:30 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m24si2290284pfa.104.2017.02.20.02.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 02:49:29 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 2/5] mm: convert anon_vma.refcount from atomic_t to refcount_t
Date: Mon, 20 Feb 2017 12:49:11 +0200
Message-Id: <1487587754-10610-3-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
References: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>, Hans Liljestrand <ishkamiel@gmail.com>, Kees Cook <keescook@chromium.org>, David Windsor <dwindsor@gmail.com>

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
index 8774791..3321c86 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -77,7 +77,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
 
 	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
 	if (anon_vma) {
-		atomic_set(&anon_vma->refcount, 1);
+		refcount_set(&anon_vma->refcount, 1);
 		anon_vma->degree = 1;	/* Reference for first vma */
 		anon_vma->parent = anon_vma;
 		/*
@@ -92,7 +92,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
 
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
-	VM_BUG_ON(atomic_read(&anon_vma->refcount));
+	VM_BUG_ON(refcount_read(&anon_vma->refcount));
 
 	/*
 	 * Synchronize against page_lock_anon_vma_read() such that
@@ -421,7 +421,7 @@ static void anon_vma_ctor(void *data)
 	struct anon_vma *anon_vma = data;
 
 	init_rwsem(&anon_vma->rwsem);
-	atomic_set(&anon_vma->refcount, 0);
+	refcount_set(&anon_vma->refcount, 0);
 	anon_vma->rb_root = RB_ROOT;
 }
 
@@ -470,7 +470,7 @@ struct anon_vma *page_get_anon_vma(struct page *page)
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
+	if (!refcount_inc_not_zero(&anon_vma->refcount)) {
 		anon_vma = NULL;
 		goto out;
 	}
@@ -529,7 +529,7 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	}
 
 	/* trylock failed, we got to sleep */
-	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
+	if (!refcount_inc_not_zero(&anon_vma->refcount)) {
 		anon_vma = NULL;
 		goto out;
 	}
@@ -544,7 +544,7 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	rcu_read_unlock();
 	anon_vma_lock_read(anon_vma);
 
-	if (atomic_dec_and_test(&anon_vma->refcount)) {
+	if (refcount_dec_and_test(&anon_vma->refcount)) {
 		/*
 		 * Oops, we held the last refcount, release the lock
 		 * and bail -- can't simply use put_anon_vma() because
@@ -1577,7 +1577,7 @@ void __put_anon_vma(struct anon_vma *anon_vma)
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
