Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 495D06B0055
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:18 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so1689490pbc.1
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:17 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1673013pdj.22
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:15 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 07/14] vrange: Purge volatile pages when memory is tight
Date: Wed,  2 Oct 2013 17:51:36 -0700
Message-Id: <1380761503-14509-8-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch adds purging logic of volatile pages into direct
reclaim path so that if vrange pages is selected as victim by VM,
they could be discarded rather than swapping out.

Direct purging doesn't consider volatile page's age because it
would be better to free the page rather than swapping out
another working set pages. This makes sense because userspace
specifies "please remove free these pages when memory is tight"
via the vrange syscall.

This however is an in-kernel behavior and the purging logic
could later change. Applications should not assume anything
about the volatile page purging order, much as they shouldn't
assume anything about the page swapout order.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/rmap.h | 11 +++++++----
 mm/ksm.c             |  2 +-
 mm/rmap.c            | 28 ++++++++++++++++++++--------
 mm/vmscan.c          | 17 +++++++++++++++--
 4 files changed, 43 insertions(+), 15 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 6dacb93..f38185d 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -181,10 +181,11 @@ static inline void page_dup_rmap(struct page *page)
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+int page_referenced(struct page *, int is_locked, struct mem_cgroup *memcg,
+				unsigned long *vm_flags, int *is_vrange);
 int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
+			unsigned long address, unsigned int *mapcount,
+			unsigned long *vm_flags, int *is_vrange);
 
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
@@ -249,9 +250,11 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *memcg,
-				  unsigned long *vm_flags)
+				  unsigned long *vm_flags,
+				  int *is_vrange)
 {
 	*vm_flags = 0;
+	*is_vrange = 0;
 	return 0;
 }
 
diff --git a/mm/ksm.c b/mm/ksm.c
index b6afe0c..debc20c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1932,7 +1932,7 @@ again:
 				continue;
 
 			referenced += page_referenced_one(page, vma,
-				rmap_item->address, &mapcount, vm_flags);
+				rmap_item->address, &mapcount, vm_flags, NULL);
 			if (!search_new_forks || !mapcount)
 				break;
 		}
diff --git a/mm/rmap.c b/mm/rmap.c
index b2e29ac..f929f22 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -57,6 +57,7 @@
 #include <linux/migrate.h>
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
+#include <linux/vrange.h>
 
 #include <asm/tlbflush.h>
 
@@ -662,7 +663,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
  */
 int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+			unsigned long *vm_flags, int *is_vrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int referenced = 0;
@@ -724,6 +725,11 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 				referenced++;
 		}
 		pte_unmap_unlock(pte, ptl);
+		if (is_vrange && vrange_addr_volatile(vma, address)) {
+			*is_vrange = 1;
+			*mapcount = 0; /* break ealry from loop */
+			goto out;
+		}
 	}
 
 	(*mapcount)--;
@@ -736,7 +742,7 @@ out:
 
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags, int *is_vrange)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -761,7 +767,8 @@ static int page_referenced_anon(struct page *page,
 		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 			continue;
 		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
+						  &mapcount, vm_flags,
+						  is_vrange);
 		if (!mapcount)
 			break;
 	}
@@ -785,7 +792,7 @@ static int page_referenced_anon(struct page *page,
  */
 static int page_referenced_file(struct page *page,
 				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags, int *is_vrange)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -826,7 +833,8 @@ static int page_referenced_file(struct page *page,
 		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 			continue;
 		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
+						  &mapcount, vm_flags,
+						  is_vrange);
 		if (!mapcount)
 			break;
 	}
@@ -841,6 +849,7 @@ static int page_referenced_file(struct page *page,
  * @is_locked: caller holds lock on the page
  * @memcg: target memory cgroup
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @is_vrange: Is @page in vrange?
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
@@ -848,7 +857,8 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *memcg,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags,
+		    int *is_vrange)
 {
 	int referenced = 0;
 	int we_locked = 0;
@@ -867,10 +877,12 @@ int page_referenced(struct page *page,
 								vm_flags);
 		else if (PageAnon(page))
 			referenced += page_referenced_anon(page, memcg,
-								vm_flags);
+								vm_flags,
+								is_vrange);
 		else if (page->mapping)
 			referenced += page_referenced_file(page, memcg,
-								vm_flags);
+								vm_flags,
+								is_vrange);
 		if (we_locked)
 			unlock_page(page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2cff0d4..ab377b6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -43,6 +43,7 @@
 #include <linux/sysctl.h>
 #include <linux/oom.h>
 #include <linux/prefetch.h>
+#include <linux/vrange.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -610,17 +611,19 @@ enum page_references {
 	PAGEREF_RECLAIM,
 	PAGEREF_RECLAIM_CLEAN,
 	PAGEREF_KEEP,
+	PAGEREF_DISCARD,
 	PAGEREF_ACTIVATE,
 };
 
 static enum page_references page_check_references(struct page *page,
 						  struct scan_control *sc)
 {
+	int is_vrange = 0;
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
 
 	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
-					  &vm_flags);
+					  &vm_flags, &is_vrange);
 	referenced_page = TestClearPageReferenced(page);
 
 	/*
@@ -630,6 +633,13 @@ static enum page_references page_check_references(struct page *page,
 	if (vm_flags & VM_LOCKED)
 		return PAGEREF_RECLAIM;
 
+	/*
+	 * If volatile page is reached on LRU's tail, we discard the
+	 * page without considering recycle the page.
+	 */
+	if (is_vrange)
+		return PAGEREF_DISCARD;
+
 	if (referenced_ptes) {
 		if (PageSwapBacked(page))
 			return PAGEREF_ACTIVATE;
@@ -859,6 +869,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto activate_locked;
 		case PAGEREF_KEEP:
 			goto keep_locked;
+		case PAGEREF_DISCARD:
+			if (may_enter_fs && !discard_vpage(page))
+				goto free_it;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
 			; /* try to reclaim the page below */
@@ -1614,7 +1627,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		}
 
 		if (page_referenced(page, 0, sc->target_mem_cgroup,
-				    &vm_flags)) {
+				    &vm_flags, NULL)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
