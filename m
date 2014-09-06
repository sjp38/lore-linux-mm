Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7FD6B0038
	for <linux-mm@kvack.org>; Sat,  6 Sep 2014 15:39:41 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id h18so741184igc.16
        for <linux-mm@kvack.org>; Sat, 06 Sep 2014 12:39:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k6si6607126ici.82.2014.09.06.12.39.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Sep 2014 12:39:40 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 3/3] mm: use VM_BUG_ON_MM where possible
Date: Sat,  6 Sep 2014 15:38:46 -0400
Message-Id: <1410032326-4380-3-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1410032326-4380-1-git-send-email-sasha.levin@oracle.com>
References: <1410032326-4380-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

Dump the contents of the relevant struct_mm when we hit the
bug condition.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 kernel/fork.c    |    3 +--
 kernel/sys.c     |    2 +-
 mm/huge_memory.c |    2 +-
 mm/mlock.c       |    2 +-
 mm/mmap.c        |    7 ++++---
 mm/pagewalk.c    |    2 +-
 6 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 0cf9cdb..7953519 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -601,9 +601,8 @@ static void check_mm(struct mm_struct *mm)
 			printk(KERN_ALERT "BUG: Bad rss-counter state "
 					  "mm:%p idx:%d val:%ld\n", mm, i, x);
 	}
-
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
-	VM_BUG_ON(mm->pmd_huge_pte);
+	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
 #endif
 }
 
diff --git a/kernel/sys.c b/kernel/sys.c
index b59294d..037fd76 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1642,7 +1642,7 @@ static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
 	struct inode *inode;
 	int err;
 
-	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
 	exe = fdget(fd);
 	if (!exe.file)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d81f8ba..ba5dc2f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2045,7 +2045,7 @@ int __khugepaged_enter(struct mm_struct *mm)
 		return -ENOMEM;
 
 	/* __khugepaged_exit() must not run from under us */
-	VM_BUG_ON(khugepaged_test_exit(mm));
+	VM_BUG_ON_MM(khugepaged_test_exit(mm), mm);
 	if (unlikely(test_and_set_bit(MMF_VM_HUGEPAGE, &mm->flags))) {
 		free_mm_slot(mm_slot);
 		return 0;
diff --git a/mm/mlock.c b/mm/mlock.c
index d5d09d0..03aa851 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -235,7 +235,7 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG_ON_VMA(start < vma->vm_start, vma);
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
-	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
 	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
 	/*
diff --git a/mm/mmap.c b/mm/mmap.c
index 9351482..d2f1a0a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -408,8 +408,9 @@ static void validate_mm_rb(struct rb_root *root, struct vm_area_struct *ignore)
 	for (nd = rb_first(root); nd; nd = rb_next(nd)) {
 		struct vm_area_struct *vma;
 		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
-		BUG_ON(vma != ignore &&
-		       vma->rb_subtree_gap != vma_compute_subtree_gap(vma));
+		VM_BUG_ON_VMA(vma != ignore &&
+			vma->rb_subtree_gap != vma_compute_subtree_gap(vma),
+			vma);
 	}
 }
 
@@ -443,7 +444,7 @@ static void validate_mm(struct mm_struct *mm)
 		pr_info("map_count %d rb %d\n", mm->map_count, i);
 		bug = 1;
 	}
-	BUG_ON(bug);
+	VM_BUG_ON_MM(bug, mm);
 }
 #else
 #define validate_mm_rb(root, ignore) do { } while (0)
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 2beeabf..ad83195 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -177,7 +177,7 @@ int walk_page_range(unsigned long addr, unsigned long end,
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
+	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
 
 	pgd = pgd_offset(walk->mm, addr);
 	do {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
