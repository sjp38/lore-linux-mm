Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 7824B6B006E
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:23:22 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so397078bkc.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 07:23:21 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC v2 5/7] mm/huge_memory: use new hashtable implementation
Date: Fri,  3 Aug 2012 16:23:06 +0200
Message-Id: <1344003788-1417-6-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Switch hugemem to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the hugemem.

This also removes the dymanic allocation of the hash table. The size of the table is
constant so there's no point in paying the price of an extra dereference when accessing
it.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/huge_memory.c |   56 ++++++++++-------------------------------------------
 1 files changed, 11 insertions(+), 45 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 57c4b93..7b2cad5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -17,6 +17,7 @@
 #include <linux/khugepaged.h>
 #include <linux/freezer.h>
 #include <linux/mman.h>
+#include <linux/hashtable.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"
@@ -57,12 +58,13 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
 static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 
 static int khugepaged(void *none);
-static int mm_slots_hash_init(void);
 static int khugepaged_slab_init(void);
 static void khugepaged_slab_free(void);
 
-#define MM_SLOTS_HASH_HEADS 1024
-static struct hlist_head *mm_slots_hash __read_mostly;
+#define MM_SLOTS_HASH_BITS 10
+#define MM_SLOTS_HASH_CMP(mm_slot, obj) ((mm_slot)->mm == (obj))
+DEFINE_STATIC_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
+
 static struct kmem_cache *mm_slot_cache __read_mostly;
 
 /**
@@ -140,7 +142,7 @@ static int start_khugepaged(void)
 	int err = 0;
 	if (khugepaged_enabled()) {
 		int wakeup;
-		if (unlikely(!mm_slot_cache || !mm_slots_hash)) {
+		if (unlikely(!mm_slot_cache)) {
 			err = -ENOMEM;
 			goto out;
 		}
@@ -554,12 +556,6 @@ static int __init hugepage_init(void)
 	if (err)
 		goto out;
 
-	err = mm_slots_hash_init();
-	if (err) {
-		khugepaged_slab_free();
-		goto out;
-	}
-
 	/*
 	 * By default disable transparent hugepages on smaller systems,
 	 * where the extra memory used could hurt more than TLB overhead
@@ -1562,47 +1558,17 @@ static inline void free_mm_slot(struct mm_slot *mm_slot)
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
-	struct mm_slot *mm_slot;
-	struct hlist_head *bucket;
-	struct hlist_node *node;
-
-	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
-				% MM_SLOTS_HASH_HEADS];
-	hlist_for_each_entry(mm_slot, node, bucket, hash) {
-		if (mm == mm_slot->mm)
-			return mm_slot;
-	}
-	return NULL;
+	return hash_get(&mm_slots_hash, mm, struct mm_slot,
+		hash, MM_SLOTS_HASH_CMP); 
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
+	hash_add(&mm_slots_hash, &mm_slot->hash, (long)mm);
 }
 
 static inline int khugepaged_test_exit(struct mm_struct *mm)
@@ -1675,7 +1641,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 	spin_lock(&khugepaged_mm_lock);
 	mm_slot = get_mm_slot(mm);
 	if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
-		hlist_del(&mm_slot->hash);
+		hash_del(&mm_slot->hash);
 		list_del(&mm_slot->mm_node);
 		free = 1;
 	}
@@ -2089,7 +2055,7 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 
 	if (khugepaged_test_exit(mm)) {
 		/* free mm_slot */
-		hlist_del(&mm_slot->hash);
+		hash_del(&mm_slot->hash);
 		list_del(&mm_slot->mm_node);
 
 		/*
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
