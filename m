Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 216416B0083
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:19:28 -0500 (EST)
Received: by wibhm9 with SMTP id hm9so17061577wib.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:19:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jj2si15311654wid.42.2015.03.05.09.19.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:06 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 07/21] userfaultfd: call handle_userfault() for userfaultfd_missing() faults
Date: Thu,  5 Mar 2015 18:17:50 +0100
Message-Id: <1425575884-2574-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

This is where the page faults must be modified to call
handle_userfault() if userfaultfd_missing() is true (so if the
vma->vm_flags had VM_UFFD_MISSING set).

handle_userfault() then takes care of blocking the page fault and
delivering it to userland.

The fault flags must also be passed as parameter so the "read|write"
kind of fault can be passed to userland.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 68 ++++++++++++++++++++++++++++++++++++++------------------
 mm/memory.c      | 16 +++++++++++++
 2 files changed, 62 insertions(+), 22 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f0207cf..5374132 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -23,6 +23,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/userfaultfd_k.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -708,7 +709,7 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long haddr, pmd_t *pmd,
-					struct page *page)
+					struct page *page, unsigned int flags)
 {
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
@@ -716,12 +717,16 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
-	if (mem_cgroup_try_charge(page, mm, GFP_TRANSHUGE, &memcg))
-		return VM_FAULT_OOM;
+	if (mem_cgroup_try_charge(page, mm, GFP_TRANSHUGE, &memcg)) {
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
 
@@ -741,6 +746,21 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
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
@@ -751,6 +771,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		atomic_long_inc(&mm->nr_ptes);
 		spin_unlock(ptl);
+		count_vm_event(THP_FAULT_ALLOC);
 	}
 
 	return 0;
@@ -762,19 +783,16 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
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
@@ -797,6 +815,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pgtable_t pgtable;
 		struct page *zero_page;
 		bool set;
+		int ret;
 		pgtable = pte_alloc_one(mm, haddr);
 		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
@@ -807,14 +826,28 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -822,14 +855,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
-		put_page(page);
-		count_vm_event(THP_FAULT_FALLBACK);
-		return VM_FAULT_FALLBACK;
-	}
-
-	count_vm_event(THP_FAULT_ALLOC);
-	return 0;
+	return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page, flags);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
@@ -864,16 +890,14 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
index 8068893..0ae719c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -61,6 +61,7 @@
 #include <linux/string.h>
 #include <linux/dma-debug.h>
 #include <linux/debugfs.h>
+#include <linux/userfaultfd_k.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -2585,6 +2586,12 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
 
@@ -2612,6 +2619,15 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
