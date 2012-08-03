Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B14066B0068
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:23:17 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so397078bkc.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 07:23:17 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC v2 3/7] mm,ksm: use new hashtable implementation
Date: Fri,  3 Aug 2012 16:23:04 +0200
Message-Id: <1344003788-1417-4-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Switch ksm to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the ksm module.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/ksm.c |   29 +++++++++--------------------
 1 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 47c8853..72d062a 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -33,7 +33,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/swap.h>
 #include <linux/ksm.h>
-#include <linux/hash.h>
+#include <linux/hashtable.h>
 #include <linux/freezer.h>
 #include <linux/oom.h>
 
@@ -157,8 +157,8 @@ static struct rb_root root_stable_tree = RB_ROOT;
 static struct rb_root root_unstable_tree = RB_ROOT;
 
 #define MM_SLOTS_HASH_SHIFT 10
-#define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
-static struct hlist_head mm_slots_hash[MM_SLOTS_HASH_HEADS];
+#define mm_hash_cmp(slot, key) ((slot)->mm == (key))
+DEFINE_STATIC_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_SHIFT);
 
 static struct mm_slot ksm_mm_head = {
 	.mm_list = LIST_HEAD_INIT(ksm_mm_head.mm_list),
@@ -275,26 +275,15 @@ static inline void free_mm_slot(struct mm_slot *mm_slot)
 
 static struct mm_slot *get_mm_slot(struct mm_struct *mm)
 {
-	struct mm_slot *mm_slot;
-	struct hlist_head *bucket;
-	struct hlist_node *node;
-
-	bucket = &mm_slots_hash[hash_ptr(mm, MM_SLOTS_HASH_SHIFT)];
-	hlist_for_each_entry(mm_slot, node, bucket, link) {
-		if (mm == mm_slot->mm)
-			return mm_slot;
-	}
-	return NULL;
+	return hash_get(&mm_slots_hash, mm, struct mm_slot,
+				link, mm_hash_cmp);
 }
 
 static void insert_to_mm_slots_hash(struct mm_struct *mm,
 				    struct mm_slot *mm_slot)
 {
-	struct hlist_head *bucket;
-
-	bucket = &mm_slots_hash[hash_ptr(mm, MM_SLOTS_HASH_SHIFT)];
 	mm_slot->mm = mm;
-	hlist_add_head(&mm_slot->link, bucket);
+	hash_add(&mm_slots_hash, &mm_slot->link, (long)mm);
 }
 
 static inline int in_stable_tree(struct rmap_item *rmap_item)
@@ -647,7 +636,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
 						struct mm_slot, mm_list);
 		if (ksm_test_exit(mm)) {
-			hlist_del(&mm_slot->link);
+			hash_del(&mm_slot->link);
 			list_del(&mm_slot->mm_list);
 			spin_unlock(&ksm_mmlist_lock);
 
@@ -1385,7 +1374,7 @@ next_mm:
 		 * or when all VM_MERGEABLE areas have been unmapped (and
 		 * mmap_sem then protects against race with MADV_MERGEABLE).
 		 */
-		hlist_del(&slot->link);
+		hash_del(&slot->link);
 		list_del(&slot->mm_list);
 		spin_unlock(&ksm_mmlist_lock);
 
@@ -1548,7 +1537,7 @@ void __ksm_exit(struct mm_struct *mm)
 	mm_slot = get_mm_slot(mm);
 	if (mm_slot && ksm_scan.mm_slot != mm_slot) {
 		if (!mm_slot->rmap_list) {
-			hlist_del(&mm_slot->link);
+			hash_del(&mm_slot->link);
 			list_del(&mm_slot->mm_list);
 			easy_to_free = 1;
 		} else {
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
