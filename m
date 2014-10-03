Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0A16B006E
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 14:22:32 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id hq12so1056216vcb.9
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:22:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id dy1si4786751vdb.107.2014.10.03.11.22.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 11:22:31 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 08/17] mm: madvise MADV_USERFAULT
Date: Fri,  3 Oct 2014 19:07:58 +0200
Message-Id: <1412356087-16115-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

MADV_USERFAULT is a new madvise flag that will set VM_USERFAULT in the
vma flags. Whenever VM_USERFAULT is set in an anonymous vma, if
userland touches a still unmapped virtual address, a sigbus signal is
sent instead of allocating a new page. The sigbus signal handler will
then resolve the page fault in userland by calling the
remap_anon_pages syscall.

This functionality is needed to reliably implement postcopy live
migration in KVM (without having to use a special chardevice that
would disable all advanced Linux VM features, like swapping, KSM, THP,
automatic NUMA balancing, etc...).

MADV_USERFAULT could also be used to offload parts of anonymous memory
regions to remote nodes or to implement network distributed shared
memory.

Here I enlarged the vm_flags to 64bit as we run out of bits (noop on
64bit kernels). An alternative is to find some combination of flags
that are mutually exclusive if set.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/alpha/include/uapi/asm/mman.h     |  3 ++
 arch/mips/include/uapi/asm/mman.h      |  3 ++
 arch/parisc/include/uapi/asm/mman.h    |  3 ++
 arch/xtensa/include/uapi/asm/mman.h    |  3 ++
 fs/proc/task_mmu.c                     |  1 +
 include/linux/mm.h                     |  1 +
 include/uapi/asm-generic/mman-common.h |  3 ++
 mm/huge_memory.c                       | 60 +++++++++++++++++++++-------------
 mm/madvise.c                           | 17 ++++++++++
 mm/memory.c                            | 13 ++++++++
 10 files changed, 85 insertions(+), 22 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 0086b47..a10313c 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -60,6 +60,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
 
+#define MADV_USERFAULT	18		/* Trigger user faults if not mapped */
+#define MADV_NOUSERFAULT 19		/* Don't trigger user faults */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index cfcb876..d9d11a4 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -84,6 +84,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
 
+#define MADV_USERFAULT	18		/* Trigger user faults if not mapped */
+#define MADV_NOUSERFAULT 19		/* Don't trigger user faults */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 294d251..7bc7b7b 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -66,6 +66,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	70		/* Clear the MADV_NODUMP flag */
 
+#define MADV_USERFAULT	71		/* Trigger user faults if not mapped */
+#define MADV_NOUSERFAULT 72		/* Don't trigger user faults */
+
 /* compatibility flags */
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 00eed67..5448d88 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -90,6 +90,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
 
+#define MADV_USERFAULT	18		/* Trigger user faults if not mapped */
+#define MADV_NOUSERFAULT 19		/* Don't trigger user faults */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ee1c3a2..6033cb8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -568,6 +568,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_HUGEPAGE)]	= "hg",
 		[ilog2(VM_NOHUGEPAGE)]	= "nh",
 		[ilog2(VM_MERGEABLE)]	= "mg",
+		[ilog2(VM_USERFAULT)]	= "uf",
 	};
 	size_t i;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8900ba9..bf3df07 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -139,6 +139,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
+#define VM_USERFAULT	0x100000000ULL	/* Trigger user faults if not mapped */
 
 #if defined(CONFIG_X86)
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index ddc3b36..dbf1e70 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -52,6 +52,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_DONTDUMP flag */
 
+#define MADV_USERFAULT	18		/* Trigger user faults if not mapped */
+#define MADV_NOUSERFAULT 19		/* Don't trigger user faults */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e913a19..b402d60 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -721,12 +721,16 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
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
 
@@ -746,6 +750,16 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pte_free(mm, pgtable);
 	} else {
 		pmd_t entry;
+
+		/* Deliver the page fault to userland */
+		if (vma->vm_flags & VM_USERFAULT) {
+			spin_unlock(ptl);
+			mem_cgroup_cancel_charge(page, memcg);
+			put_page(page);
+			pte_free(mm, pgtable);
+			return VM_FAULT_SIGBUS;
+		}
+
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		page_add_new_anon_rmap(page, vma, haddr);
@@ -756,6 +770,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		atomic_long_inc(&mm->nr_ptes);
 		spin_unlock(ptl);
+		count_vm_event(THP_FAULT_ALLOC);
 	}
 
 	return 0;
@@ -776,20 +791,17 @@ static inline struct page *alloc_hugepage_vma(int defrag,
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
 	entry = pmd_wrprotect(entry);
 	entry = pmd_mkhuge(entry);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
 	atomic_long_inc(&mm->nr_ptes);
-	return true;
 }
 
 int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -811,6 +823,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pgtable_t pgtable;
 		struct page *zero_page;
 		bool set;
+		int ret;
 		pgtable = pte_alloc_one(mm, haddr);
 		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
@@ -821,14 +834,24 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_FALLBACK;
 		}
 		ptl = pmd_lock(mm, pmd);
-		set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
-				zero_page);
+		ret = 0;
+		set = false;
+		if (pmd_none(*pmd)) {
+			if (vma->vm_flags & VM_USERFAULT)
+				ret = VM_FAULT_SIGBUS;
+			else {
+				set_huge_zero_page(pgtable, mm, vma,
+						   haddr, pmd,
+						   zero_page);
+				set = true;
+			}
+		}
 		spin_unlock(ptl);
 		if (!set) {
 			pte_free(mm, pgtable);
 			put_huge_zero_page();
 		}
-		return 0;
+		return ret;
 	}
 	page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
 			vma, haddr, numa_node_id(), 0);
@@ -836,14 +859,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
+	return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
@@ -878,16 +894,14 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
@@ -2148,7 +2162,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		if (pte_none(pteval)) {
-			if (++none <= khugepaged_max_ptes_none)
+			if (!(vma->vm_flags & VM_USERFAULT) &&
+			    ++none <= khugepaged_max_ptes_none)
 				continue;
 			else
 				goto out;
@@ -2569,7 +2584,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		if (pte_none(pteval)) {
-			if (++none <= khugepaged_max_ptes_none)
+			if (!(vma->vm_flags & VM_USERFAULT) &&
+			    ++none <= khugepaged_max_ptes_none)
 				continue;
 			else
 				goto out_unmap;
diff --git a/mm/madvise.c b/mm/madvise.c
index d5aee71..24620c0 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -93,6 +93,21 @@ static long madvise_behavior(struct vm_area_struct *vma,
 		if (error)
 			goto out;
 		break;
+	case MADV_USERFAULT:
+		if (vma->vm_ops) {
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags |= VM_USERFAULT;
+		break;
+	case MADV_NOUSERFAULT:
+		if (vma->vm_ops) {
+			WARN_ON(new_flags & VM_USERFAULT);
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags &= ~VM_USERFAULT;
+		break;
 	}
 
 	if (new_flags == vma->vm_flags) {
@@ -408,6 +423,8 @@ madvise_behavior_valid(int behavior)
 	case MADV_HUGEPAGE:
 	case MADV_NOHUGEPAGE:
 #endif
+	case MADV_USERFAULT:
+	case MADV_NOUSERFAULT:
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
 		return 1;
diff --git a/mm/memory.c b/mm/memory.c
index e229970..16e4c8a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2645,6 +2645,11 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto unlock;
+		/* Deliver the page fault to userland, check inside PT lock */
+		if (vma->vm_flags & VM_USERFAULT) {
+			pte_unmap_unlock(page_table, ptl);
+			return VM_FAULT_SIGBUS;
+		}
 		goto setpte;
 	}
 
@@ -2672,6 +2677,14 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pte_none(*page_table))
 		goto release;
 
+	/* Deliver the page fault to userland, check inside PT lock */
+	if (vma->vm_flags & VM_USERFAULT) {
+		pte_unmap_unlock(page_table, ptl);
+		mem_cgroup_cancel_charge(page, memcg);
+		page_cache_release(page);
+		return VM_FAULT_SIGBUS;
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
