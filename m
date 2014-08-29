Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id CE9EC6B0037
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 21:52:44 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id f12so1564946qad.32
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 18:52:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 20si8512105qgo.58.2014.08.28.18.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Aug 2014 18:52:44 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 3/6] mm/hugetlb: fix getting refcount 0 page in hugetlb_fault()
Date: Thu, 28 Aug 2014 21:38:57 -0400
Message-Id: <1409276340-7054-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

When running the test which causes the race as shown in the previous patch,
we can hit the BUG "get_page() on refcount 0 page" in hugetlb_fault().

This race happens when pte turns into migration entry just after the first
check of is_hugetlb_entry_migration() in hugetlb_fault() passed with false.
To fix this, we need to check pte_present() again with holding ptl.

This patch also reorders taking ptl and doing pte_page(), because pte_page()
should be done in ptl. Due to this reordering, we need use trylock_page()
in page != pagecache_page case to respect locking order.

ChangeLog v3:
- doing pte_page() and taking refcount under page table lock
- check pte_present after taking ptl, which makes it unnecessary to use
  get_page_unless_zero()
- use trylock_page in page != pagecache_page case
- fixed target stable version

Fixes: 66aebce747ea ("hugetlb: fix race condition in hugetlb_fault()")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.2+]
---
 mm/hugetlb.c | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git mmotm-2014-08-25-16-52.orig/mm/hugetlb.c mmotm-2014-08-25-16-52/mm/hugetlb.c
index c5345c5edb50..2aafe073cb06 100644
--- mmotm-2014-08-25-16-52.orig/mm/hugetlb.c
+++ mmotm-2014-08-25-16-52/mm/hugetlb.c
@@ -3184,6 +3184,15 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 								vma, address);
 	}
 
+	ptl = huge_pte_lock(h, mm, ptep);
+
+	/* Check for a racing update before calling hugetlb_cow */
+	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
+		goto out_ptl;
+
+	if (!pte_present(entry))
+		goto out_ptl;
+
 	/*
 	 * hugetlb_cow() requires page locks of pte_page(entry) and
 	 * pagecache_page, so here we need take the former one
@@ -3192,22 +3201,17 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
+		if (!trylock_page(page))
+			goto out_ptl;
 
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
@@ -3215,7 +3219,11 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
 						flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, address, ptep);
-
+out_put_page:
+	put_page(page);
+out_unlock_page:
+	if (page != pagecache_page)
+		unlock_page(page);
 out_ptl:
 	spin_unlock(ptl);
 
@@ -3223,10 +3231,6 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unlock_page(pagecache_page);
 		put_page(pagecache_page);
 	}
-	if (page != pagecache_page)
-		unlock_page(page);
-	put_page(page);
-
 out_mutex:
 	mutex_unlock(&htlb_fault_mutex_table[hash]);
 	return ret;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
