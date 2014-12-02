Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 021FB6B0071
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:38:11 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so12807978pac.8
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:38:10 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id n7si18199330pdj.247.2014.12.02.00.38.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:38:06 -0800 (PST)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id sB28c0qU026757
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 17:38:02 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 4/8] mm/hugetlb: fix getting refcount 0 page in
 hugetlb_fault()
Date: Tue, 2 Dec 2014 08:26:39 +0000
Message-ID: <1417508759-10848-5-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1417508759-10848-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1417508759-10848-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

When running the test which causes the race as shown in the previous patch,
we can hit the BUG "get_page() on refcount 0 page" in hugetlb_fault().

This race happens when pte turns into migration entry just after the first
check of is_hugetlb_entry_migration() in hugetlb_fault() passed with false.
To fix this, we need to check pte_present() again after huge_ptep_get().

This patch also reorders taking ptl and doing pte_page(), because pte_page(=
)
should be done in ptl. Due to this reordering, we need use trylock_page()
in page !=3D pagecache_page case to respect locking order.

Fixes: 66aebce747ea ("hugetlb: fix race condition in hugetlb_fault()")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.2+]
---
ChangeLog v5:
- add comment to justify calling wait_on_page_locked without taking refcoun=
t
- remove stale comment about lock order

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
- use trylock_page in page !=3D pagecache_page case
- fixed target stable version
---
 mm/hugetlb.c | 52 ++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 36 insertions(+), 16 deletions(-)

diff --git mmotm-2014-11-26-15-45.orig/mm/hugetlb.c mmotm-2014-11-26-15-45/=
mm/hugetlb.c
index adafced1aa17..dfc1527e8f4e 100644
--- mmotm-2014-11-26-15-45.orig/mm/hugetlb.c
+++ mmotm-2014-11-26-15-45/mm/hugetlb.c
@@ -3134,6 +3134,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_are=
a_struct *vma,
 	struct page *pagecache_page =3D NULL;
 	struct hstate *h =3D hstate_vma(vma);
 	struct address_space *mapping;
+	int need_wait_lock =3D 0;
=20
 	address &=3D huge_page_mask(h);
=20
@@ -3172,6 +3173,16 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_ar=
ea_struct *vma,
 	ret =3D 0;
=20
 	/*
+	 * entry could be a migration/hwpoison entry at this point, so this
+	 * check prevents the kernel from going below assuming that we have
+	 * a active hugepage in pagecache. This goto expects the 2nd page fault,
+	 * and is_hugetlb_entry_(migration|hwpoisoned) check will properly
+	 * handle it.
+	 */
+	if (!pte_present(entry))
+		goto out_mutex;
+
+	/*
 	 * If we are going to COW the mapping later, we examine the pending
 	 * reservations for this page now. This will ensure that any
 	 * allocations necessary to record that reservation occur outside the
@@ -3190,30 +3201,31 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_a=
rea_struct *vma,
 								vma, address);
 	}
=20
+	ptl =3D huge_pte_lock(h, mm, ptep);
+
+	/* Check for a racing update before calling hugetlb_cow */
+	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
+		goto out_ptl;
+
 	/*
 	 * hugetlb_cow() requires page locks of pte_page(entry) and
 	 * pagecache_page, so here we need take the former one
 	 * when page !=3D pagecache_page or !pagecache_page.
-	 * Note that locking order is always pagecache_page -> page,
-	 * so no worry about deadlock.
 	 */
 	page =3D pte_page(entry);
-	get_page(page);
 	if (page !=3D pagecache_page)
-		lock_page(page);
-
-	ptl =3D huge_pte_lockptr(h, mm, ptep);
-	spin_lock(ptl);
-	/* Check for a racing update before calling hugetlb_cow */
-	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
-		goto out_ptl;
+		if (!trylock_page(page)) {
+			need_wait_lock =3D 1;
+			goto out_ptl;
+		}
=20
+	get_page(page);
=20
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!huge_pte_write(entry)) {
 			ret =3D hugetlb_cow(mm, vma, address, ptep, entry,
 					pagecache_page, ptl);
-			goto out_ptl;
+			goto out_put_page;
 		}
 		entry =3D huge_pte_mkdirty(entry);
 	}
@@ -3221,7 +3233,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_ar=
ea_struct *vma,
 	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
 						flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, address, ptep);
-
+out_put_page:
+	if (page !=3D pagecache_page)
+		unlock_page(page);
+	put_page(page);
 out_ptl:
 	spin_unlock(ptl);
=20
@@ -3229,12 +3244,17 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_a=
rea_struct *vma,
 		unlock_page(pagecache_page);
 		put_page(pagecache_page);
 	}
-	if (page !=3D pagecache_page)
-		unlock_page(page);
-	put_page(page);
-
 out_mutex:
 	mutex_unlock(&htlb_fault_mutex_table[hash]);
+	/*
+	 * Generally it's safe to hold refcount during waiting page lock. But
+	 * here we just wait to defer the next page fault to avoid busy loop and
+	 * the page is not used after unlocked before returning from the current
+	 * page fault. So we are safe from accessing freed page, even if we wait
+	 * here without taking refcount.
+	 */
+	if (need_wait_lock)
+		wait_on_page_locked(page);
 	return ret;
 }
=20
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
