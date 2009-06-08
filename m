Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 43A826B0055
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 11:23:42 -0400 (EDT)
Date: Mon, 8 Jun 2009 17:35:36 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH mmotm] ksm: stop scan skipping pages
In-Reply-To: <Pine.LNX.4.64.0906081555360.22943@sister.anvils>
Message-ID: <Pine.LNX.4.64.0906081733390.7729@sister.anvils>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
 <Pine.LNX.4.64.0906081555360.22943@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KSM can be slow to identify all mergeable pages.  There's an off-by-one
in how ksm_scan_start() proceeds (see how it does a scan_get_next_index
at the head of its loop, but also on leaving its loop), which causes it
to skip over a page occasionally.  Fix that.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |   46 +++++++++++++++++++---------------------------
 1 file changed, 19 insertions(+), 27 deletions(-)

--- mmotm/mm/ksm.c	2009-06-08 13:14:36.000000000 +0100
+++ fixed/mm/ksm.c	2009-06-08 13:18:30.000000000 +0100
@@ -1331,30 +1331,26 @@ out:
 /* return -EAGAIN - no slots registered, nothing to be done */
 static int scan_get_next_index(struct ksm_scan *ksm_scan)
 {
-	struct ksm_mem_slot *slot;
+	struct list_head *next;
 
 	if (list_empty(&slots))
 		return -EAGAIN;
 
-	slot = ksm_scan->slot_index;
-
 	/* Are there pages left in this slot to scan? */
-	if ((slot->npages - ksm_scan->page_index - 1) > 0) {
-		ksm_scan->page_index++;
+	ksm_scan->page_index++;
+	if (ksm_scan->page_index < ksm_scan->slot_index->npages)
 		return 0;
-	}
 
-	list_for_each_entry_from(slot, &slots, link) {
-		if (slot == ksm_scan->slot_index)
-			continue;
-		ksm_scan->page_index = 0;
-		ksm_scan->slot_index = slot;
+	ksm_scan->page_index = 0;
+	next = ksm_scan->slot_index->link.next;
+	if (next != &slots) {
+		ksm_scan->slot_index =
+			list_entry(next, struct ksm_mem_slot, link);
 		return 0;
 	}
 
 	/* look like we finished scanning the whole memory, starting again */
 	root_unstable_tree = RB_ROOT;
-	ksm_scan->page_index = 0;
 	ksm_scan->slot_index = list_first_entry(&slots,
 						struct ksm_mem_slot, link);
 	return 0;
@@ -1366,21 +1362,22 @@ static int scan_get_next_index(struct ks
  * pointed to was released so we have to call this function every time after
  * taking the slots_lock
  */
-static void scan_update_old_index(struct ksm_scan *ksm_scan)
+static int scan_update_old_index(struct ksm_scan *ksm_scan)
 {
 	struct ksm_mem_slot *slot;
 
 	if (list_empty(&slots))
-		return;
+		return -EAGAIN;
 
 	list_for_each_entry(slot, &slots, link) {
 		if (ksm_scan->slot_index == slot)
-			return;
+			return 0;
 	}
 
 	ksm_scan->slot_index = list_first_entry(&slots,
 						struct ksm_mem_slot, link);
 	ksm_scan->page_index = 0;
+	return 0;
 }
 
 /**
@@ -1399,20 +1396,14 @@ static int ksm_scan_start(struct ksm_sca
 	struct ksm_mem_slot *slot;
 	struct page *page[1];
 	int val;
-	int ret = 0;
+	int ret;
 
 	down_read(&slots_lock);
+	ret = scan_update_old_index(ksm_scan);
 
-	scan_update_old_index(ksm_scan);
-
-	while (scan_npages > 0) {
-		ret = scan_get_next_index(ksm_scan);
-		if (ret)
-			goto out;
-
-		slot = ksm_scan->slot_index;
-
+	while (scan_npages && !ret) {
 		cond_resched();
+		slot = ksm_scan->slot_index;
 
 		/*
 		 * If the page is swapped out or in swap cache, we don't want to
@@ -1433,10 +1424,11 @@ static int ksm_scan_start(struct ksm_sca
 		} else {
 			up_read(&slot->mm->mmap_sem);
 		}
+
+		ret = scan_get_next_index(ksm_scan);
 		scan_npages--;
 	}
-	scan_get_next_index(ksm_scan);
-out:
+
 	up_read(&slots_lock);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
