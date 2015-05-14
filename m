Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 546FA6B00A2
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:32:07 -0400 (EDT)
Received: by wguv19 with SMTP id v19so20875252wgu.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:32:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q20si4654865wiv.60.2015.05.14.10.31.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:48 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 07/23] userfaultfd: call handle_userfault() for userfaultfd_missing() faults
Date: Thu, 14 May 2015 19:31:04 +0200
Message-Id: <1431624680-20153-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

This is where the page faults must be modified to call
handle_userfault() if userfaultfd_missing() is true (so if the
vma->vm_flags had VM_UFFD_MISSING set).

handle_userfault() then takes care of blocking the page fault and
delivering it to userland.

The fault flags must also be passed as parameter so the "read|write"
kind of fault can be passed to userland.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 69 ++++++++++++++++++++++++++++++++++++++------------------
 mm/memory.c      | 16 +++++++++++++
 2 files changed, 63 insertions(+), 22 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cb8904c..c221be3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -23,6 +23,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/userfaultfd_k.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -717,7 +718,8 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long haddr, pmd_t *pmd,
-					struct page *page, gfp_t gfp)
+					struct page *page, gfp_t gfp,
+					unsigned int flags)
 {
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
@@ -725,12 +727,16 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
-	if (mem_cgroup_try_charge(page, mm, gfp, &memcg))
-		return VM_FAULT_OOM;
+	if (mem_cgroup_try_charge(page, mm, gfp, &memcg)) {
+		put_page(page);
+		count_vm_event(THP_FAULT_FALLBACK);
+		return VM_FAULT_FALLBACK;
+	}
 
 	pgtable = pte_alloc_one(mm, haddr);
 	if (unlikely(!pgtable)) {
 		mem_cgroup_cancel_charge(page, memcg);
+		put_page(page);
 		return VM_FAULT_OOM;
 	}
 
@@ -750,6 +756,21 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pte_free(mm, pgtable);
 	} else {
 		pmd_t entry;
+
+		/* Deliver the page fault to userland */
+		if (userfaultfd_missing(vma)) {
+			int ret;
+
+			spin_unlock(ptl);
+			mem_cgroup_cancel_charge(page, memcg);
+			put_page(page);
+			pte_free(mm, pgtable);
+			ret = handle_userfault(vma, haddr, flags,
+					       VM_UFFD_MISSING);
+			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
+			return ret;
+		}
+
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		page_add_new_anon_rmap(page, vma, haddr);
@@ -760,6 +781,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		atomic_long_inc(&mm->nr_ptes);
 		spin_unlock(ptl);
+		count_vm_event(THP_FAULT_ALLOC);
 	}
 
 	return 0;
@@ -771,19 +793,16 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
 }
 
 /* Caller must hold page table lock. */
-static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
+static void set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
 		struct page *zero_page)
 {
 	pmd_t entry;
-	if (!pmd_none(*pmd))
-		return false;
 	entry = mk_pmd(zero_page, vma->vm_page_prot);
 	entry = pmd_mkhuge(entry);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
 	atomic_long_inc(&mm->nr_ptes);
-	return true;
 }
 
 int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -806,6 +825,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pgtable_t pgtable;
 		struct page *zero_page;
 		bool set;
+		int ret;
 		pgtable = pte_alloc_one(mm, haddr);
 		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
@@ -816,14 +836,28 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_FALLBACK;
 		}
 		ptl = pmd_lock(mm, pmd);
-		set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
-				zero_page);
-		spin_unlock(ptl);
+		ret = 0;
+		set = false;
+		if (pmd_none(*pmd)) {
+			if (userfaultfd_missing(vma)) {
+				spin_unlock(ptl);
+				ret = handle_userfault(vma, haddr, flags,
+						       VM_UFFD_MISSING);
+				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
+			} else {
+				set_huge_zero_page(pgtable, mm, vma,
+						   haddr, pmd,
+						   zero_page);
+				spin_unlock(ptl);
+				set = true;
+			}
+		} else
+			spin_unlock(ptl);
 		if (!set) {
 			pte_free(mm, pgtable);
 			put_huge_zero_page();
 		}
-		return 0;
+		return ret;
 	}
 	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
 	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
@@ -831,14 +865,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page, gfp))) {
-		put_page(page);
-		count_vm_event(THP_FAULT_FALLBACK);
-		return VM_FAULT_FALLBACK;
-	}
-
-	count_vm_event(THP_FAULT_ALLOC);
-	return 0;
+	return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page, gfp, flags);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
@@ -873,16 +900,14 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 */
 	if (is_huge_zero_pmd(pmd)) {
 		struct page *zero_page;
-		bool set;
 		/*
 		 * get_huge_zero_page() will never allocate a new page here,
 		 * since we already have a zero page to copy. It just takes a
 		 * reference.
 		 */
 		zero_page = get_huge_zero_page();
-		set = set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd,
+		set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd,
 				zero_page);
-		BUG_ON(!set); /* unexpected !pmd_none(dst_pmd) */
 		ret = 0;
 		goto out_unlock;
 	}
diff --git a/mm/memory.c b/mm/memory.c
index be9f075..790e6f7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -61,6 +61,7 @@
 #include <linux/string.h>
 #include <linux/dma-debug.h>
 #include <linux/debugfs.h>
+#include <linux/userfaultfd_k.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -2680,6 +2681,12 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto unlock;
+		/* Deliver the page fault to userland, check inside PT lock */
+		if (userfaultfd_missing(vma)) {
+			pte_unmap_unlock(page_table, ptl);
+			return handle_userfault(vma, address, flags,
+						VM_UFFD_MISSING);
+		}
 		goto setpte;
 	}
 
@@ -2707,6 +2714,15 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pte_none(*page_table))
 		goto release;
 
+	/* Deliver the page fault to userland, check inside PT lock */
+	if (userfaultfd_missing(vma)) {
+		pte_unmap_unlock(page_table, ptl);
+		mem_cgroup_cancel_charge(page, memcg);
+		page_cache_release(page);
+		return handle_userfault(vma, address, flags,
+					VM_UFFD_MISSING);
+	}
+
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
 	mem_cgroup_commit_charge(page, memcg, false);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
