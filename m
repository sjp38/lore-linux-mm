Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 87B8F6B00A4
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:53:48 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id m20so3778325qcx.39
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 15:53:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j49si14007874qgd.15.2014.09.15.15.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 15:53:47 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 3/5] mm/hugetlb: fix getting refcount 0 page in hugetlb_fault()
Date: Mon, 15 Sep 2014 18:39:57 -0400
Message-Id: <1410820799-27278-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, stable@vger.kernel.org

When running the test which causes the race as shown in the previous patch,
we can hit the BUG "get_page() on refcount 0 page" in hugetlb_fault().

This race happens when pte turns into migration entry just after the first
check of is_hugetlb_entry_migration() in hugetlb_fault() passed with false.
To fix this, we need to check pte_present() again after huge_ptep_get().

This patch also reorders taking ptl and doing pte_page(), because pte_page()
should be done in ptl. Due to this reordering, we need use trylock_page()
in page != pagecache_page case to respect locking order.

Fixes: 66aebce747ea ("hugetlb: fix race condition in hugetlb_fault()")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.2+]
---
ChangeLog v4:
- move !pte_present(entry) (i.e. migration/hwpoison) check before
  taking page table lock
- call wait_on_page_locked() if trylock_page() returns false
- remove unused label out_unlock_page
- fix the order of put_page() and unlock_page() after out_put_page label
- move changelog under '---'

Hugh advised me for ver.3 that we can call migration_entry_wait_huge()
when the !pte_present(entry) check returns true to avoid busy faulting.
But it seems that in that case only one additional page fault happens
instead of busy faulting, because is_hugetlb_entry_migration() in the
second call of hugetlb_fault() should return true and then
migration_entry_wait_huge() is called. We could avoid this additional
page fault by adding another migration_entry_wait_huge(), but then
we should separate pte_present() check into is_hugetlb_entry_migration()
path and is_hugetlb_entry_hwpoisoned() path, which makes code complicated.
So let me take the simpler approach for sending stable tree.
And it's also advised that we can clean up is_hugetlb_entry_migration()
and is_hugetlb_entry_hwpoisoned() things. This will be done in another
work, and the above migration_entry_wait_huge problem will be revisited
there.

ChangeLog v3:
- doing pte_page() and taking refcount under page table lock
- check pte_present after taking ptl, which makes it unnecessary to use
  get_page_unless_zero()
- use trylock_page in page != pagecache_page case
- fixed target stable version
---
 mm/hugetlb.c | 42 ++++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git mmotm-2014-09-09-14-42.orig/mm/hugetlb.c mmotm-2014-09-09-14-42/mm/hugetlb.c
index 941832ee3d5a..52f001943169 100644
--- mmotm-2014-09-09-14-42.orig/mm/hugetlb.c
+++ mmotm-2014-09-09-14-42/mm/hugetlb.c
@@ -3128,6 +3128,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *pagecache_page = NULL;
 	struct hstate *h = hstate_vma(vma);
 	struct address_space *mapping;
+	int need_wait_lock = 0;
 
 	address &= huge_page_mask(h);
 
@@ -3164,6 +3165,15 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	ret = 0;
+	/*
+	 * entry could be a migration/hwpoison entry at this point, so this
+	 * check prevents the kernel from going below assuming that we have
+	 * a active hugepage in pagecache. This goto expects the 2nd page fault,
+	 * and is_hugetlb_entry_(migration|hwpoisoned) check will properly
+	 * handle it.
+	 */
+	if (!pte_present(entry))
+		goto out_mutex;
 
 	/*
 	 * If we are going to COW the mapping later, we examine the pending
@@ -3184,6 +3194,12 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 								vma, address);
 	}
 
+	ptl = huge_pte_lock(h, mm, ptep);
+
+	/* Check for a racing update before calling hugetlb_cow */
+	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
+		goto out_ptl;
+
 	/*
 	 * hugetlb_cow() requires page locks of pte_page(entry) and
 	 * pagecache_page, so here we need take the former one
@@ -3192,22 +3208,19 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * so no worry about deadlock.
 	 */
 	page = pte_page(entry);
-	get_page(page);
 	if (page != pagecache_page)
-		lock_page(page);
-
-	ptl = huge_pte_lockptr(h, mm, ptep);
-	spin_lock(ptl);
-	/* Check for a racing update before calling hugetlb_cow */
-	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
-		goto out_ptl;
+		if (!trylock_page(page)) {
+			need_wait_lock = 1;
+			goto out_ptl;
+		}
 
+	get_page(page);
 
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!huge_pte_write(entry)) {
 			ret = hugetlb_cow(mm, vma, address, ptep, entry,
 					pagecache_page, ptl);
-			goto out_ptl;
+			goto out_put_page;
 		}
 		entry = huge_pte_mkdirty(entry);
 	}
@@ -3215,7 +3228,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
 						flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, address, ptep);
-
+out_put_page:
+	if (page != pagecache_page)
+		unlock_page(page);
+	put_page(page);
 out_ptl:
 	spin_unlock(ptl);
 
@@ -3223,12 +3239,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unlock_page(pagecache_page);
 		put_page(pagecache_page);
 	}
-	if (page != pagecache_page)
-		unlock_page(page);
-	put_page(page);
-
 out_mutex:
 	mutex_unlock(&htlb_fault_mutex_table[hash]);
+	if (need_wait_lock)
+		wait_on_page_locked(page);
 	return ret;
 }
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
