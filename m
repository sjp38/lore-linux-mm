Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E3CEA6B00B4
	for <linux-mm@kvack.org>; Mon,  4 May 2009 18:24:57 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Date: Tue,  5 May 2009 01:25:32 +0300
Message-Id: <1241475935-21162-4-git-send-email-ieidus@redhat.com>
In-Reply-To: <1241475935-21162-3-git-send-email-ieidus@redhat.com>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

This patch change the KSM_REMOVE_MEMORY_REGION ioctl to be specific per
memory region (instead of flushing all the registred memory regions inside
the file descriptor like it happen now)

The previoes api was:
user register memory regions using KSM_REGISTER_MEMORY_REGION inside the fd,
and then when he wanted to remove just one memory region, he had to remove them
all using KSM_REMOVE_MEMORY_REGION.

This patch change this beahivor by chaning the KSM_REMOVE_MEMORY_REGION
ioctl to recive another paramter that it is the begining of the virtual
address that is wanted to be removed.

(user can still remove all the memory regions all at once, by just closing
the file descriptor)

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |   45 ++++++++++++++++++++++++++-------------------
 1 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 982dfff..6e8b24b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -543,48 +543,55 @@ out:
 	return ret;
 }
 
-static void remove_mm_from_hash_and_tree(struct mm_struct *mm)
+static void remove_slot_from_hash_and_tree(struct ksm_mem_slot *slot)
 {
-	struct ksm_mem_slot *slot;
 	int pages_count;
 
-	list_for_each_entry(slot, &slots, link)
-		if (slot->mm == mm)
-			break;
-	BUG_ON(!slot);
-
 	root_unstable_tree = RB_ROOT;
 	for (pages_count = 0; pages_count < slot->npages; ++pages_count)
-		remove_page_from_tree(mm, slot->addr +
+		remove_page_from_tree(slot->mm, slot->addr +
 				      pages_count * PAGE_SIZE);
 	/* Called under slots_lock */
 	list_del(&slot->link);
 }
 
-static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma)
+static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma,
+					      unsigned long addr)
 {
+	int ret = -EFAULT;
 	struct ksm_mem_slot *slot, *node;
 
 	down_write(&slots_lock);
 	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
-		remove_mm_from_hash_and_tree(slot->mm);
-		mmput(slot->mm);
-		list_del(&slot->sma_link);
-		kfree(slot);
-		ksm_sma->nregions--;
+		if (addr == slot->addr) {
+			remove_slot_from_hash_and_tree(slot);
+			mmput(slot->mm);
+			list_del(&slot->sma_link);
+			kfree(slot);
+			ksm_sma->nregions--;
+			ret = 0;
+		}
 	}
 	up_write(&slots_lock);
-	return 0;
+	return ret;
 }
 
 static int ksm_sma_release(struct inode *inode, struct file *filp)
 {
+	struct ksm_mem_slot *slot, *node;
 	struct ksm_sma *ksm_sma = filp->private_data;
-	int r;
 
-	r = ksm_sma_ioctl_remove_memory_region(ksm_sma);
+	down_write(&slots_lock);
+	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
+		remove_slot_from_hash_and_tree(slot);
+		mmput(slot->mm);
+		list_del(&slot->sma_link);
+		kfree(slot);
+	}
+	up_write(&slots_lock);
+
 	kfree(ksm_sma);
-	return r;
+	return 0;
 }
 
 static long ksm_sma_ioctl(struct file *filp,
@@ -607,7 +614,7 @@ static long ksm_sma_ioctl(struct file *filp,
 		break;
 	}
 	case KSM_REMOVE_MEMORY_REGION:
-		r = ksm_sma_ioctl_remove_memory_region(sma);
+		r = ksm_sma_ioctl_remove_memory_region(sma, arg);
 		break;
 	}
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
