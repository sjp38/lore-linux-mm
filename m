Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9E9316B0062
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 18:18:04 -0500 (EST)
Date: Thu, 12 Nov 2009 23:17:59 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 4/6] ksm: singly-linked rmap_list
In-Reply-To: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911122317042.4050@sister.anvils>
References: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Free up a pointer in struct rmap_item, by making the mm_slot's rmap_list
a singly-linked list: we always traverse that list sequentially, and we
don't even lose any prefetches (but should consider adding a few later).
Name it rmap_list throughout.

Do we need to free up that pointer?  Not immediately, and in the end, we
could continue to avoid it with a union; but having done the conversion,
let's keep it this way, since there's no downside, and maybe we'll want
more in future (struct rmap_item is a cache-friendly 32 bytes on 32-bit
and 64 bytes on 64-bit, so we shall want to avoid expanding it).

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |   56 ++++++++++++++++++++++++-----------------------------
 1 file changed, 26 insertions(+), 30 deletions(-)

--- ksm3/mm/ksm.c	2009-11-12 15:28:47.000000000 +0000
+++ ksm4/mm/ksm.c	2009-11-12 15:28:54.000000000 +0000
@@ -79,13 +79,13 @@
  * struct mm_slot - ksm information per mm that is being scanned
  * @link: link to the mm_slots hash list
  * @mm_list: link into the mm_slots list, rooted in ksm_mm_head
- * @rmap_list: head for this mm_slot's list of rmap_items
+ * @rmap_list: head for this mm_slot's singly-linked list of rmap_items
  * @mm: the mm that this information is valid for
  */
 struct mm_slot {
 	struct hlist_node link;
 	struct list_head mm_list;
-	struct list_head rmap_list;
+	struct rmap_item *rmap_list;
 	struct mm_struct *mm;
 };
 
@@ -93,7 +93,7 @@ struct mm_slot {
  * struct ksm_scan - cursor for scanning
  * @mm_slot: the current mm_slot we are scanning
  * @address: the next address inside that to be scanned
- * @rmap_item: the current rmap that we are scanning inside the rmap_list
+ * @rmap_list: link to the next rmap to be scanned in the rmap_list
  * @seqnr: count of completed full scans (needed when removing unstable node)
  *
  * There is only the one ksm_scan instance of this cursor structure.
@@ -101,13 +101,14 @@ struct mm_slot {
 struct ksm_scan {
 	struct mm_slot *mm_slot;
 	unsigned long address;
-	struct rmap_item *rmap_item;
+	struct rmap_item **rmap_list;
 	unsigned long seqnr;
 };
 
 /**
  * struct rmap_item - reverse mapping item for virtual addresses
- * @link: link into mm_slot's rmap_list (rmap_list is per mm)
+ * @rmap_list: next rmap_item in mm_slot's singly-linked rmap_list
+ * @filler: unused space we're making available in this patch
  * @mm: the memory structure this rmap_item is pointing into
  * @address: the virtual address this rmap_item tracks (+ flags in low bits)
  * @oldchecksum: previous checksum of the page at that virtual address
@@ -116,7 +117,8 @@ struct ksm_scan {
  * @prev: previous rmap_item hanging off the same node of the stable tree
  */
 struct rmap_item {
-	struct list_head link;
+	struct rmap_item *rmap_list;
+	unsigned long filler;
 	struct mm_struct *mm;
 	unsigned long address;		/* + low bits used for flags below */
 	union {
@@ -275,7 +277,6 @@ static void insert_to_mm_slots_hash(stru
 	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
 				% MM_SLOTS_HASH_HEADS];
 	mm_slot->mm = mm;
-	INIT_LIST_HEAD(&mm_slot->rmap_list);
 	hlist_add_head(&mm_slot->link, bucket);
 }
 
@@ -479,15 +480,12 @@ static void remove_rmap_item_from_tree(s
 }
 
 static void remove_trailing_rmap_items(struct mm_slot *mm_slot,
-				       struct list_head *cur)
+				       struct rmap_item **rmap_list)
 {
-	struct rmap_item *rmap_item;
-
-	while (cur != &mm_slot->rmap_list) {
-		rmap_item = list_entry(cur, struct rmap_item, link);
-		cur = cur->next;
+	while (*rmap_list) {
+		struct rmap_item *rmap_item = *rmap_list;
+		*rmap_list = rmap_item->rmap_list;
 		remove_rmap_item_from_tree(rmap_item);
-		list_del(&rmap_item->link);
 		free_rmap_item(rmap_item);
 	}
 }
@@ -553,7 +551,7 @@ static int unmerge_and_remove_all_rmap_i
 				goto error;
 		}
 
-		remove_trailing_rmap_items(mm_slot, mm_slot->rmap_list.next);
+		remove_trailing_rmap_items(mm_slot, &mm_slot->rmap_list);
 
 		spin_lock(&ksm_mmlist_lock);
 		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
@@ -1141,20 +1139,19 @@ static void cmp_and_merge_page(struct pa
 }
 
 static struct rmap_item *get_next_rmap_item(struct mm_slot *mm_slot,
-					    struct list_head *cur,
+					    struct rmap_item **rmap_list,
 					    unsigned long addr)
 {
 	struct rmap_item *rmap_item;
 
-	while (cur != &mm_slot->rmap_list) {
-		rmap_item = list_entry(cur, struct rmap_item, link);
+	while (*rmap_list) {
+		rmap_item = *rmap_list;
 		if ((rmap_item->address & PAGE_MASK) == addr)
 			return rmap_item;
 		if (rmap_item->address > addr)
 			break;
-		cur = cur->next;
+		*rmap_list = rmap_item->rmap_list;
 		remove_rmap_item_from_tree(rmap_item);
-		list_del(&rmap_item->link);
 		free_rmap_item(rmap_item);
 	}
 
@@ -1163,7 +1160,8 @@ static struct rmap_item *get_next_rmap_i
 		/* It has already been zeroed */
 		rmap_item->mm = mm_slot->mm;
 		rmap_item->address = addr;
-		list_add_tail(&rmap_item->link, cur);
+		rmap_item->rmap_list = *rmap_list;
+		*rmap_list = rmap_item;
 	}
 	return rmap_item;
 }
@@ -1188,8 +1186,7 @@ static struct rmap_item *scan_get_next_r
 		spin_unlock(&ksm_mmlist_lock);
 next_mm:
 		ksm_scan.address = 0;
-		ksm_scan.rmap_item = list_entry(&slot->rmap_list,
-						struct rmap_item, link);
+		ksm_scan.rmap_list = &slot->rmap_list;
 	}
 
 	mm = slot->mm;
@@ -1215,10 +1212,10 @@ next_mm:
 				flush_anon_page(vma, *page, ksm_scan.address);
 				flush_dcache_page(*page);
 				rmap_item = get_next_rmap_item(slot,
-					ksm_scan.rmap_item->link.next,
-					ksm_scan.address);
+					ksm_scan.rmap_list, ksm_scan.address);
 				if (rmap_item) {
-					ksm_scan.rmap_item = rmap_item;
+					ksm_scan.rmap_list =
+							&rmap_item->rmap_list;
 					ksm_scan.address += PAGE_SIZE;
 				} else
 					put_page(*page);
@@ -1234,14 +1231,13 @@ next_mm:
 
 	if (ksm_test_exit(mm)) {
 		ksm_scan.address = 0;
-		ksm_scan.rmap_item = list_entry(&slot->rmap_list,
-						struct rmap_item, link);
+		ksm_scan.rmap_list = &slot->rmap_list;
 	}
 	/*
 	 * Nuke all the rmap_items that are above this current rmap:
 	 * because there were no VM_MERGEABLE vmas with such addresses.
 	 */
-	remove_trailing_rmap_items(slot, ksm_scan.rmap_item->link.next);
+	remove_trailing_rmap_items(slot, ksm_scan.rmap_list);
 
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = list_entry(slot->mm_list.next,
@@ -1423,7 +1419,7 @@ void __ksm_exit(struct mm_struct *mm)
 	spin_lock(&ksm_mmlist_lock);
 	mm_slot = get_mm_slot(mm);
 	if (mm_slot && ksm_scan.mm_slot != mm_slot) {
-		if (list_empty(&mm_slot->rmap_list)) {
+		if (!mm_slot->rmap_list) {
 			hlist_del(&mm_slot->link);
 			list_del(&mm_slot->mm_list);
 			easy_to_free = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
