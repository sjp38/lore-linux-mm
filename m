Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 25ED76B0075
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 14:47:20 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id c11so459580qad.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 11:47:19 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v8 05/16] mm/huge_memory: use new hashtable implementation
Date: Tue, 30 Oct 2012 14:46:01 -0400
Message-Id: <1351622772-16400-5-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch hugemem to use the new hashtable implementation. This reduces the
amount of generic unrelated code in the hugemem.

This also removes the dymanic allocation of the hash table. The size of the table is
constant so there's no point in paying the price of an extra dereference when accessing
it.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/huge_memory.c | 53 ++++++++++++-----------------------------------------
 1 file changed, 12 insertions(+), 41 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3c14a96..4b32238 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -19,6 +19,7 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
+#include <linux/hashtable.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"
@@ -59,12 +60,12 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
 static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 
 static int khugepaged(void *none);
-static int mm_slots_hash_init(void);
 static int khugepaged_slab_init(void);
 static void khugepaged_slab_free(void);
 
-#define MM_SLOTS_HASH_HEADS 1024
-static struct hlist_head *mm_slots_hash __read_mostly;
+#define MM_SLOTS_HASH_BITS 10
+static DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
+
 static struct kmem_cache *mm_slot_cache __read_mostly;
 
 /**
@@ -545,12 +546,6 @@ static int __init hugepage_init(void)
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
@@ -1694,47 +1689,23 @@ static inline void free_mm_slot(struct mm_slot *mm_slot)
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
+	struct mm_slot *slot;
 	struct hlist_node *node;
 
-	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
-				% MM_SLOTS_HASH_HEADS];
-	hlist_for_each_entry(mm_slot, node, bucket, hash) {
-		if (mm == mm_slot->mm)
-			return mm_slot;
-	}
+	hash_for_each_possible(mm_slots_hash, slot, node, hash, (unsigned long) mm)
+		if (slot->mm == mm)
+			return slot;
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
@@ -1803,7 +1774,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 	spin_lock(&khugepaged_mm_lock);
 	mm_slot = get_mm_slot(mm);
 	if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
-		hlist_del(&mm_slot->hash);
+		hash_del(&mm_slot->hash);
 		list_del(&mm_slot->mm_node);
 		free = 1;
 	}
@@ -2252,7 +2223,7 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 
 	if (khugepaged_test_exit(mm)) {
 		/* free mm_slot */
-		hlist_del(&mm_slot->hash);
+		hash_del(&mm_slot->hash);
 		list_del(&mm_slot->mm_node);
 
 		/*
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
