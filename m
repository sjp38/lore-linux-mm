Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1CA8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 21:45:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id u20so22228356pfa.1
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 18:45:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g187si717597pfc.43.2018.12.27.18.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 18:45:19 -0800 (PST)
Date: Thu, 27 Dec 2018 18:45:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: bug report: hugetlbfs: use i_mmap_rwsem for more pmd sharing,
 synchronization
Message-Id: <20181227184518.4c689fcdca88325b841dfc71@linux-foundation.org>
In-Reply-To: <29441ca1-82f1-2e4b-13f6-ad4fe9ed4d0f@oracle.com>
References: <5c8be807-03cd-991d-c79b-3c10a4d6d67b@canonical.com>
	<29441ca1-82f1-2e4b-13f6-ad4fe9ed4d0f@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Colin Ian King <colin.king@canonical.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Stephen Rothwell <sfr@canb.auug.org.au>, stable@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 27 Dec 2018 11:24:31 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> On 12/27/18 3:44 AM, Colin Ian King wrote:
> > Hi,
> > 
> > Static analysis with CoverityScan on linux-next detected a potential
> > null pointer dereference with the following commit:
> > 
> > From d8a1051ed4ba55679ef24e838a1942c9c40f0a14 Mon Sep 17 00:00:00 2001
> > From: Mike Kravetz <mike.kravetz@oracle.com>
> > Date: Sat, 22 Dec 2018 10:55:57 +1100
> > Subject: [PATCH] hugetlbfs: use i_mmap_rwsem for more pmd sharing
> > 
> > The earlier check implies that "mapping" may be a null pointer:
> > 
> > var_compare_op: Comparing mapping to null implies that mapping might be
> > null.
> > 
> > 1008        if (!(flags & MF_MUST_KILL) && !PageDirty(hpage) && mapping &&
> > 1009            mapping_cap_writeback_dirty(mapping)) {
> > 
> > ..however later "mapper" is dereferenced when it may be potentially null:
> > 
> > 1034                /*
> > 1035                 * For hugetlb pages, try_to_unmap could potentially
> > call
> > 1036                 * huge_pmd_unshare.  Because of this, take semaphore in
> > 1037                 * write mode here and set TTU_RMAP_LOCKED to
> > indicate we
> > 1038                 * have taken the lock at this higer level.
> > 1039                 */
> >     CID 1476097 (#1 of 1): Dereference after null check (FORWARD_NULL)
> > 
> > var_deref_model: Passing null pointer mapping to
> > i_mmap_lock_write, which dereferences it.
> > 
> > 1040                i_mmap_lock_write(mapping);
> > 1041                unmap_success = try_to_unmap(hpage,
> > ttu|TTU_RMAP_LOCKED);
> > 1042                i_mmap_unlock_write(mapping);
> > 
> 
> Thanks for the report.
> 
> The 'good news' is that mapping can not be null in the code path above.
> The reasons are:
> - The page is locked upon entry to the routine
> - Earlier in the routine there is the check:
> 	if (!page_mapped(hpage))
> 		return true;
>   For huge pages (which are processed in the else clause above), page_mapped
>   implies page->mapping != null.
> 
> However, the routine hwpoison_user_mappings handles all page types.  The
> page_mapped check is actually there to check for pages in the swap cache.
> It is just coincidence that it also implies mapping != null for huge pages.
> 
> It would be better to make an explicit check for mapping != null before
> calling i_mmap_lock_write/try_to_unmap.  In this way, unrelated changes to
> code above will not potentially lead to the possibility of mapping == null.
> 
> I'm not sure what is the best way to handle this.  Below is an updated version
> of the patch sent to Andrew.  I can also provide a simple patch to the patch
> if that is easier.
> 

Below is the delta.  Please check it.  It seems to do more than the
above implies.

Also, I have notes here that 

hugetlbfs-use-i_mmap_rwsem-for-more-pmd-sharing-synchronization.patch
and
hugetlbfs-use-i_mmap_rwsem-to-fix-page-fault-truncate-race.patch

have additional updates pending.  Due to emails such as

http://lkml.kernel.org/r/849f5202-2200-265f-7769-8363053e8373@oracle.com
http://lkml.kernel.org/r/732c0b7d-5a4e-97a8-9677-30f3520893cb@oracle.com
http://lkml.kernel.org/r/6b91dd42-b903-1f6c-729a-bd9f51273986@oracle.com

What's the status, please?


From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: hugetlbfs-use-i_mmap_rwsem-for-more-pmd-sharing-synchronization-fix

It would be better to make an explicit check for mapping != null before
calling i_mmap_lock_write/try_to_unmap.  In this way, unrelated changes to
code above will not potentially lead to the possibility of mapping ==
null.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---


--- a/mm/hugetlb.c~hugetlbfs-use-i_mmap_rwsem-for-more-pmd-sharing-synchronization-fix
+++ a/mm/hugetlb.c
@@ -3250,6 +3250,14 @@ int copy_hugetlb_page_range(struct mm_st
 		mmu_notifier_range_init(&range, src, vma->vm_start,
 					vma->vm_end, MMU_NOTIFY_CLEAR);
 		mmu_notifier_invalidate_range_start(&range);
+	} else {
+		/*
+		 * For shared mappings i_mmap_rwsem must be held to call
+		 * huge_pte_alloc, otherwise the returned ptep could go
+		 * away if part of a shared pmd and another thread calls
+		 * huge_pmd_unshare.
+		 */
+		i_mmap_lock_read(mapping);
 	}
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
@@ -3259,18 +3267,8 @@ int copy_hugetlb_page_range(struct mm_st
 		if (!src_pte)
 			continue;
 
-		/*
-		 * i_mmap_rwsem must be held to call huge_pte_alloc.
-		 * Continue to hold until finished  with dst_pte, otherwise
-		 * it could go away if part of a shared pmd.
-		 *
-		 * Technically, i_mmap_rwsem is only needed in the non-cow
-		 * case as cow mappings are not shared.
-		 */
-		i_mmap_lock_read(mapping);
 		dst_pte = huge_pte_alloc(dst, addr, sz);
 		if (!dst_pte) {
-			i_mmap_unlock_read(mapping);
 			ret = -ENOMEM;
 			break;
 		}
@@ -3285,10 +3283,8 @@ int copy_hugetlb_page_range(struct mm_st
 		 * after taking the lock below.
 		 */
 		dst_entry = huge_ptep_get(dst_pte);
-		if ((dst_pte == src_pte) || !huge_pte_none(dst_entry)) {
-			i_mmap_unlock_read(mapping);
+		if ((dst_pte == src_pte) || !huge_pte_none(dst_entry))
 			continue;
-		}
 
 		dst_ptl = huge_pte_lock(h, dst, dst_pte);
 		src_ptl = huge_pte_lockptr(h, src, src_pte);
@@ -3337,12 +3333,12 @@ int copy_hugetlb_page_range(struct mm_st
 		}
 		spin_unlock(src_ptl);
 		spin_unlock(dst_ptl);
-
-		i_mmap_unlock_read(mapping);
 	}
 
 	if (cow)
 		mmu_notifier_invalidate_range_end(&range);
+	else
+		i_mmap_unlock_read(mapping);
 
 	return ret;
 }
--- a/mm/memory-failure.c~hugetlbfs-use-i_mmap_rwsem-for-more-pmd-sharing-synchronization-fix
+++ a/mm/memory-failure.c
@@ -966,7 +966,7 @@ static bool hwpoison_user_mappings(struc
 	enum ttu_flags ttu = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
-	bool unmap_success;
+	bool unmap_success = true;
 	int kill = 1, forcekill;
 	struct page *hpage = *hpagep;
 	bool mlocked = PageMlocked(hpage);
@@ -1030,7 +1030,7 @@ static bool hwpoison_user_mappings(struc
 
 	if (!PageHuge(hpage)) {
 		unmap_success = try_to_unmap(hpage, ttu);
-	} else {
+	} else if (mapping) {
 		/*
 		 * For hugetlb pages, try_to_unmap could potentially call
 		 * huge_pmd_unshare.  Because of this, take semaphore in
--- a/mm/rmap.c~hugetlbfs-use-i_mmap_rwsem-for-more-pmd-sharing-synchronization-fix
+++ a/mm/rmap.c
@@ -25,6 +25,7 @@
  *     page->flags PG_locked (lock_page)
  *       hugetlbfs_i_mmap_rwsem_key (in huge_pmd_share)
  *         mapping->i_mmap_rwsem
+ *           hugetlb_fault_mutex (hugetlbfs specific page fault mutex)
  *           anon_vma->rwsem
  *             mm->page_table_lock or pte_lock
  *               zone_lru_lock (in mark_page_accessed, isolate_lru_page)
_
