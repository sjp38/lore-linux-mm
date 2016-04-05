Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 77C0B828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 18:00:28 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fe3so18721031pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 15:00:28 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id vx8si10201416pac.107.2016.04.05.15.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 15:00:27 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id zm5so18741896pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 15:00:27 -0700 (PDT)
Date: Tue, 5 Apr 2016 15:00:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 27/31] huge tmpfs recovery: tweak shmem_getpage_gfp to fill
 team
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051458520.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

shmem_recovery_swapin() took the trouble to arrange for pages to be
swapped in to their final destinations without needing page migration.
It's daft not to do the same for pages being newly instantiated (when
a huge page has been allocated after transient fragmentation, too late
to satisfy the initial fault).

Let SGP_TEAM convey the intended destination down to shmem_getpage_gfp().
And make sure that SGP_TEAM cannot instantiate pages beyond the last
huge page: although shmem_recovery_populate() has a PageTeam check
against truncation, that's insufficient, and only shmem_getpage_gfp()
knows what adjustments to make when we have allocated too far.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |   56 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 49 insertions(+), 7 deletions(-)

--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -464,6 +464,7 @@ static int shmem_populate_hugeteam(struc
 		/* Mark all pages dirty even when map is readonly, for now */
 		if (PageUptodate(head + i) && PageDirty(head + i))
 			continue;
+		page = NULL;
 		error = shmem_getpage_gfp(inode, index, &page, SGP_TEAM,
 					  gfp, vma->vm_mm, NULL);
 		if (error)
@@ -965,6 +966,7 @@ again:
 		    !account_head)
 			continue;
 
+		page = team;	/* used as hint if not yet instantiated */
 		error = shmem_getpage_gfp(recovery->inode, index, &page,
 					  SGP_TEAM, gfp, recovery->mm, NULL);
 		if (error)
@@ -2708,6 +2710,7 @@ static int shmem_replace_page(struct pag
 
 /*
  * shmem_getpage_gfp - find page in cache, or get from swap, or allocate
+ *                     (or use page indicated by shmem_recovery_populate)
  *
  * If we allocate a new one we do not mark it dirty. That's up to the
  * vm. If we swap it in we mark it dirty since we also free the swap
@@ -2727,14 +2730,20 @@ static int shmem_getpage_gfp(struct inod
 	struct mem_cgroup *memcg;
 	struct page *page;
 	swp_entry_t swap;
+	loff_t offset;
 	int error;
 	int once = 0;
-	int alloced = 0;
+	bool alloced = false;
+	bool exposed_swapbacked = false;
 	struct page *hugehint;
 	struct page *alloced_huge = NULL;
 
 	if (index > (MAX_LFS_FILESIZE >> PAGE_SHIFT))
 		return -EFBIG;
+
+	offset = (loff_t)index << PAGE_SHIFT;
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && sgp == SGP_TEAM)
+		offset &= ~((loff_t)HPAGE_PMD_SIZE-1);
 repeat:
 	swap.val = 0;
 	page = find_lock_entry(mapping, index);
@@ -2743,8 +2752,7 @@ repeat:
 		page = NULL;
 	}
 
-	if (sgp <= SGP_CACHE &&
-	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
+	if (sgp <= SGP_TEAM && offset >= i_size_read(inode)) {
 		error = -EINVAL;
 		goto unlock;
 	}
@@ -2863,8 +2871,34 @@ repeat:
 			percpu_counter_inc(&sbinfo->used_blocks);
 		}
 
-		/* Take huge hint from super, except for shmem_symlink() */
 		hugehint = NULL;
+		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+		    sgp == SGP_TEAM && *pagep) {
+			struct page *head;
+
+			if (!get_page_unless_zero(*pagep)) {
+				error = -ENOENT;
+				goto decused;
+			}
+			page = *pagep;
+			lock_page(page);
+			head = page - (index & (HPAGE_PMD_NR-1));
+			if (!PageTeam(head)) {
+				error = -ENOENT;
+				goto decused;
+			}
+			if (PageSwapBacked(page)) {
+				shr_stats(page_raced);
+				/* maybe already created; or swapin truncated */
+				error = page->mapping ? -EEXIST : -ENOENT;
+				goto decused;
+			}
+			SetPageSwapBacked(page);
+			exposed_swapbacked = true;
+			goto memcg;
+		}
+
+		/* Take huge hint from super, except for shmem_symlink() */
 		if (mapping->a_ops == &shmem_aops &&
 		    (shmem_huge == SHMEM_HUGE_FORCE ||
 		     (sbinfo->huge && shmem_huge != SHMEM_HUGE_DENY)))
@@ -2878,7 +2912,7 @@ repeat:
 		}
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
-
+memcg:
 		error = mem_cgroup_try_charge(page, charge_mm, gfp, &memcg,
 				false);
 		if (error)
@@ -2894,6 +2928,11 @@ repeat:
 			goto decused;
 		}
 		mem_cgroup_commit_charge(page, memcg, false, false);
+		if (exposed_swapbacked) {
+			shr_stats(page_created);
+			/* cannot clear swapbacked once sent to lru */
+			exposed_swapbacked = false;
+		}
 		lru_cache_add_anon(page);
 
 		spin_lock(&info->lock);
@@ -2937,8 +2976,7 @@ clear:
 	}
 
 	/* Perhaps the file has been truncated since we checked */
-	if (sgp <= SGP_CACHE &&
-	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
+	if (sgp <= SGP_TEAM && offset >= i_size_read(inode)) {
 		if (alloced && !PageTeam(page)) {
 			ClearPageDirty(page);
 			delete_from_page_cache(page);
@@ -2966,6 +3004,10 @@ failed:
 		error = -EEXIST;
 unlock:
 	if (page) {
+		if (exposed_swapbacked) {
+			ClearPageSwapBacked(page);
+			exposed_swapbacked = false;
+		}
 		unlock_page(page);
 		put_page(page);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
