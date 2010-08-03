Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ACA736008E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:23:20 -0400 (EDT)
Message-ID: <4C578D94.2020205@cn.fujitsu.com>
Date: Tue, 03 Aug 2010 11:31:32 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH resend] ksm:  cleanup for mm_slots_hash
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> I just talked with Izik and he agrees with patch! ;)

Avi Kivity <avi@redhat.com> wrote:
> Note, to get the patch merged your best bet is to copy linux-mm and
> Andrew Morton.

Subject: [PATCH resend] ksm: cleanup for mm_slots_hash

Use compile-allocated memory instead of dynamic allocated
memory for mm_slots_hash.

Use hash_ptr() instead divisions for bucket calculation.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
diff --git a/mm/ksm.c b/mm/ksm.c
index 6c3e99b..f69ff28 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -33,6 +33,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/swap.h>
 #include <linux/ksm.h>
+#include <linux/hash.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -153,8 +154,9 @@ struct rmap_item {
 static struct rb_root root_stable_tree = RB_ROOT;
 static struct rb_root root_unstable_tree = RB_ROOT;
 
-#define MM_SLOTS_HASH_HEADS 1024
-static struct hlist_head *mm_slots_hash;
+#define MM_SLOTS_HASH_SHIFT 10
+#define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
+static struct hlist_head mm_slots_hash[MM_SLOTS_HASH_HEADS];
 
 static struct mm_slot ksm_mm_head = {
 	.mm_list = LIST_HEAD_INIT(ksm_mm_head.mm_list),
@@ -269,28 +271,13 @@ static inline void free_mm_slot(struct mm_slot *mm_slot)
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
-static void __init mm_slots_hash_free(void)
-{
-	kfree(mm_slots_hash);
-}
-
 static struct mm_slot *get_mm_slot(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
 	struct hlist_head *bucket;
 	struct hlist_node *node;
 
-	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
-				% MM_SLOTS_HASH_HEADS];
+	bucket = &mm_slots_hash[hash_ptr(mm, MM_SLOTS_HASH_SHIFT)];
 	hlist_for_each_entry(mm_slot, node, bucket, link) {
 		if (mm == mm_slot->mm)
 			return mm_slot;
@@ -303,8 +290,7 @@ static void insert_to_mm_slots_hash(struct mm_struct *mm,
 {
 	struct hlist_head *bucket;
 
-	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
-				% MM_SLOTS_HASH_HEADS];
+	bucket = &mm_slots_hash[hash_ptr(mm, MM_SLOTS_HASH_SHIFT)];
 	mm_slot->mm = mm;
 	hlist_add_head(&mm_slot->link, bucket);
 }
@@ -1943,15 +1929,11 @@ static int __init ksm_init(void)
 	if (err)
 		goto out;
 
-	err = mm_slots_hash_init();
-	if (err)
-		goto out_free1;
-
 	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
 	if (IS_ERR(ksm_thread)) {
 		printk(KERN_ERR "ksm: creating kthread failed\n");
 		err = PTR_ERR(ksm_thread);
-		goto out_free2;
+		goto out_free;
 	}
 
 #ifdef CONFIG_SYSFS
@@ -1959,7 +1941,7 @@ static int __init ksm_init(void)
 	if (err) {
 		printk(KERN_ERR "ksm: register sysfs failed\n");
 		kthread_stop(ksm_thread);
-		goto out_free2;
+		goto out_free;
 	}
 #else
 	ksm_run = KSM_RUN_MERGE;	/* no way for user to start it */
@@ -1975,9 +1957,7 @@ static int __init ksm_init(void)
 #endif
 	return 0;
 
-out_free2:
-	mm_slots_hash_free();
-out_free1:
+out_free:
 	ksm_slab_free();
 out:
 	return err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
