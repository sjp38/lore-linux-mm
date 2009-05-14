Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3AEFD6B0152
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:31:16 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 2/4] mmlist: share mmlist with ksm.
Date: Thu, 14 May 2009 03:30:46 +0300
Message-Id: <1242261048-4487-3-git-send-email-ieidus@redhat.com>
In-Reply-To: <1242261048-4487-2-git-send-email-ieidus@redhat.com>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
 <1242261048-4487-2-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, linux-mm@kvack.org, riel@redhat.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

This change the logic of drain_mmlist() so the mmlist will be able to be
shared with ksm.

Right now mmlist is used to track the mm structs that their pages had swapped
and it is used by swapoff, this patch change it so that in addition to holding
the mm structs that their pages had been swapped, it will hold the mm structs
that have vm areas that are VM_MERGEABLE.

The tradeoff is little bit more work when swapoff is running, but probably
better than adding another pointer into mm_struct and increase its size.

This patch add mmlist_mask that have 2 bits that are able to be set:
MMLIST_SWAP and MMLIST_KSM, this mmlist_mask control the beahivor of the
drain_mmlist() so it drain the mmlist when ksm use it.

Implemantion note: if program called madvise for MADV_SHAREABLE, and then
                   this vma will go away the mm_struct will be still kept
                   inside the mmlist untill the procsess exit.

Another intersting point is the code inside rmap.c:
	if (list_empty(&mm->mmlist)) {
		spin_lock(&mmlist_lock);
		if (list_empty(&mm->mmlist))
			list_add(&mm->mmlist, &init_mm.mmlist);
		spin_unlock(&mmlist_lock);
	}

I and Andrea have disscussed about this function and we are not sure if it cant
race with drain_mmlist when swapoff is run while swapping happen.

Is it safe?, if it is safe it is safe for this patch, if it isnt then this patch
isnt safe as well.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/linux/swap.h |    4 ++++
 mm/madvise.c         |    8 ++++++++
 mm/rmap.c            |    8 ++++++++
 mm/swapfile.c        |    9 +++++++--
 4 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 62d8143..3919dc3 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -295,6 +295,10 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
 
 /* linux/mm/swapfile.c */
+#define MMLIST_SWAP (1 << 0)
+#define MMLIST_KSM  (1 << 1)
+extern int mmlist_mask;
+
 extern long nr_swap_pages;
 extern long total_swap_pages;
 extern void si_swapinfo(struct sysinfo *);
diff --git a/mm/madvise.c b/mm/madvise.c
index bd215ce..40a0036 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -11,6 +11,7 @@
 #include <linux/mempolicy.h>
 #include <linux/hugetlb.h>
 #include <linux/sched.h>
+#include <linux/swap.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -237,6 +238,13 @@ static long madvise_shareable(struct vm_area_struct *vma,
 		if (!ret) {
 			mm = vma->vm_mm;
 			set_bit(MMF_VM_MERGEABLE, &mm->flags);
+
+			spin_lock(&mmlist_lock);
+			if (unlikely(list_empty(&mm->mmlist)))
+				list_add(&mm->mmlist, &init_mm.mmlist);
+			if (unlikely(!(mmlist_mask & MMLIST_KSM)))
+				mmlist_mask |= MMLIST_KSM;
+			spin_unlock(&mmlist_lock);
 		}
 
 		return ret;
diff --git a/mm/rmap.c b/mm/rmap.c
index 95c55ea..71f378a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -951,7 +951,15 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				spin_lock(&mmlist_lock);
 				if (list_empty(&mm->mmlist))
 					list_add(&mm->mmlist, &init_mm.mmlist);
+				if (unlikely(!(mmlist_mask & MMLIST_SWAP)))
+					mmlist_mask |= MMLIST_SWAP;
 				spin_unlock(&mmlist_lock);
+			} else {
+				if (unlikely(!(mmlist_mask & MMLIST_SWAP))) {
+					spin_lock(&mmlist_lock);
+					mmlist_mask |= MMLIST_SWAP;
+					spin_unlock(&mmlist_lock);
+				}
 			}
 			dec_mm_counter(mm, anon_rss);
 		} else if (PAGE_MIGRATION) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 312fafe..dadaa15 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -42,6 +42,8 @@ long total_swap_pages;
 static int swap_overflow;
 static int least_priority;
 
+int mmlist_mask = 0;
+
 static const char Bad_file[] = "Bad swap file entry ";
 static const char Unused_file[] = "Unused swap file entry ";
 static const char Bad_offset[] = "Bad swap offset entry ";
@@ -1149,8 +1151,11 @@ static void drain_mmlist(void)
 		if (swap_info[i].inuse_pages)
 			return;
 	spin_lock(&mmlist_lock);
-	list_for_each_safe(p, next, &init_mm.mmlist)
-		list_del_init(p);
+	mmlist_mask &= ~MMLIST_SWAP;
+	if (!mmlist_mask) {
+		list_for_each_safe(p, next, &init_mm.mmlist)
+			list_del_init(p);
+	}
 	spin_unlock(&mmlist_lock);
 }
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
