Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 20A916B00B6
	for <linux-mm@kvack.org>; Mon,  4 May 2009 18:24:59 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 2/6] ksm: dont allow overlap memory addresses registrations.
Date: Tue,  5 May 2009 01:25:31 +0300
Message-Id: <1241475935-21162-3-git-send-email-ieidus@redhat.com>
In-Reply-To: <1241475935-21162-2-git-send-email-ieidus@redhat.com>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

subjects say it all.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index d58db6b..982dfff 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -451,21 +451,71 @@ static void remove_page_from_tree(struct mm_struct *mm,
 	remove_rmap_item_from_tree(rmap_item);
 }
 
+static inline int is_intersecting_address(unsigned long addr,
+					  unsigned long begin,
+					  unsigned long end)
+{
+	if (addr >= begin && addr < end)
+		return 1;
+	return 0;
+}
+
+/*
+ * is_overlap_mem - check if there is overlapping with memory that was already
+ * registred.
+ *
+ * note - this function must to be called under slots_lock
+ */
+static int is_overlap_mem(struct ksm_memory_region *mem)
+{
+	struct ksm_mem_slot *slot;
+
+	list_for_each_entry(slot, &slots, link) {
+		unsigned long mem_end;
+		unsigned long slot_end;
+
+		cond_resched();
+
+		if (current->mm != slot->mm)
+			continue;
+
+		mem_end = mem->addr + (unsigned long)mem->npages * PAGE_SIZE;
+		slot_end = slot->addr + (unsigned long)slot->npages * PAGE_SIZE;
+
+		if (is_intersecting_address(mem->addr, slot->addr, slot_end) ||
+		    is_intersecting_address(mem_end - 1, slot->addr, slot_end))
+			return 1;
+		if (is_intersecting_address(slot->addr, mem->addr, mem_end) ||
+		    is_intersecting_address(slot_end - 1, mem->addr, mem_end))
+			return 1;
+	}
+
+	return 0;
+}
+
 static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
 						struct ksm_memory_region *mem)
 {
 	struct ksm_mem_slot *slot;
 	int ret = -EPERM;
 
+	if (!mem->npages)
+		goto out;
+
+	down_write(&slots_lock);
+
 	if ((ksm_sma->nregions + 1) > regions_per_fd) {
 		ret = -EBUSY;
-		goto out;
+		goto out_unlock;
 	}
 
+	if (is_overlap_mem(mem))
+		goto out_unlock;
+
 	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
 	if (!slot) {
 		ret = -ENOMEM;
-		goto out;
+		goto out_unlock;
 	}
 
 	/*
@@ -478,8 +528,6 @@ static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
 	slot->addr = mem->addr;
 	slot->npages = mem->npages;
 
-	down_write(&slots_lock);
-
 	list_add_tail(&slot->link, &slots);
 	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
 	ksm_sma->nregions++;
@@ -489,6 +537,8 @@ static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
 
 out_free:
 	kfree(slot);
+out_unlock:
+	up_write(&slots_lock);
 out:
 	return ret;
 }
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
