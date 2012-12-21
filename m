Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D5FDD6B0070
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 13:59:37 -0500 (EST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm/huge_memory: use new hashtable implementation
Date: Fri, 21 Dec 2012 13:59:00 -0500
Message-Id: <1356116342-2121-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Sasha Levin <sasha.levin@oracle.com>

Switch hugemem to use the new hashtable implementation. This reduces the
amount of generic unrelated code in the hugemem.

This also removes the dymanic allocation of the hash table. The upside is that
we save a pointer dereference when accessing the hashtable, but we lose 8KB
if CONFIG_TRANSPARENT_HUGEPAGE is enabled but the processor doesn't
support hugepages.

This patch depends on d9b482c ("hashtable: introduce a small and naive
hashtable") which was merged in v3.6.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
Changes in v2:
 - Addressed comments by David Rientjes.

 mm/huge_memory.c | 54 +++++++++---------------------------------------------
 1 file changed, 9 insertions(+), 45 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9e894ed..f62654c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -20,6 +20,7 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
+#include <linux/hashtable.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -62,12 +63,11 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
 static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 
 static int khugepaged(void *none);
-static int mm_slots_hash_init(void);
 static int khugepaged_slab_init(void);
-static void khugepaged_slab_free(void);
 
-#define MM_SLOTS_HASH_HEADS 1024
-static struct hlist_head *mm_slots_hash __read_mostly;
+#define MM_SLOTS_HASH_BITS 10
+static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
+
 static struct kmem_cache *mm_slot_cache __read_mostly;
 
 /**
@@ -634,12 +634,6 @@ static int __init hugepage_init(void)
 	if (err)
 		goto out;
 
-	err = mm_slots_hash_init();
-	if (err) {
-		khugepaged_slab_free();
-		goto out;
-	}
-
 	register_shrinker(&huge_zero_page_shrinker);
 
 	/*
@@ -1893,12 +1887,6 @@ static int __init khugepaged_slab_init(void)
 	return 0;
 }
 
-static void __init khugepaged_slab_free(void)
-{
-	kmem_cache_destroy(mm_slot_cache);
-	mm_slot_cache = NULL;
-}
-
 static inline struct mm_slot *alloc_mm_slot(void)
 {
 	if (!mm_slot_cache)	/* initialization failed */
@@ -1911,47 +1899,23 @@ static inline void free_mm_slot(struct mm_slot *mm_slot)
 	kmem_cache_free(mm_slot_cache, mm_slot);
 }
 
-static int __init mm_slots_hash_init(void)
-{
-	mm_slots_hash = kzalloc(MM_SLOTS_HASH_HEADS * sizeof(struct hlist_head),
-				GFP_KERNEL);
-	if (!mm_slots_hash)
-		return -ENOMEM;
-	return 0;
-}
-
-#if 0
-static void __init mm_slots_hash_free(void)
-{
-	kfree(mm_slots_hash);
-	mm_slots_hash = NULL;
-}
-#endif
-
 static struct mm_slot *get_mm_slot(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
-	struct hlist_head *bucket;
 	struct hlist_node *node;
 
-	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
-				% MM_SLOTS_HASH_HEADS];
-	hlist_for_each_entry(mm_slot, node, bucket, hash) {
+	hash_for_each_possible(mm_slots_hash, mm_slot, node, hash, (unsigned long) mm)
 		if (mm == mm_slot->mm)
 			return mm_slot;
-	}
+
 	return NULL;
 }
 
 static void insert_to_mm_slots_hash(struct mm_struct *mm,
 				    struct mm_slot *mm_slot)
 {
-	struct hlist_head *bucket;
-
-	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
-				% MM_SLOTS_HASH_HEADS];
 	mm_slot->mm = mm;
-	hlist_add_head(&mm_slot->hash, bucket);
+	hash_add(mm_slots_hash, &mm_slot->hash, (long)mm);
 }
 
 static inline int khugepaged_test_exit(struct mm_struct *mm)
@@ -2020,7 +1984,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 	spin_lock(&khugepaged_mm_lock);
 	mm_slot = get_mm_slot(mm);
 	if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
-		hlist_del(&mm_slot->hash);
+		hash_del(&mm_slot->hash);
 		list_del(&mm_slot->mm_node);
 		free = 1;
 	}
@@ -2469,7 +2433,7 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 
 	if (khugepaged_test_exit(mm)) {
 		/* free mm_slot */
-		hlist_del(&mm_slot->hash);
+		hash_del(&mm_slot->hash);
 		list_del(&mm_slot->mm_node);
 
 		/*
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
