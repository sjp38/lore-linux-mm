Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id B29D06B0075
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:57 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so25641671igb.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p4si3012492icb.94.2015.04.14.13.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 13:56:46 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 10/11] mm: debug: kill VM_BUG_ON_MM
Date: Tue, 14 Apr 2015 16:56:32 -0400
Message-Id: <1429044993-1677-11-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

Just use VM_BUG() instead.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mmdebug.h |    8 --------
 kernel/fork.c           |    2 +-
 mm/gup.c                |    2 +-
 mm/huge_memory.c        |    2 +-
 mm/mmap.c               |    2 +-
 mm/pagewalk.c           |    2 +-
 6 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 5106ab5..b810800 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -20,13 +20,6 @@ char *format_mm(const struct mm_struct *mm, char *buf, char *end);
 		}							\
 	} while (0)
 #define VM_BUG_ON(cond) VM_BUG(cond, "%s\n", __stringify(cond))
-#define VM_BUG_ON_MM(cond, mm)						\
-	do {								\
-		if (unlikely(cond)) {					\
-			pr_emerg("%pZm", mm);				\
-			BUG();						\
-		}							\
-	} while (0)
 #define VM_WARN_ON(cond) WARN_ON(cond)
 #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
@@ -41,7 +34,6 @@ static char *format_mm(const struct mm_struct *mm, char *buf, char *end)
 }
 #define VM_BUG(cond, fmt...) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
-#define VM_BUG_ON_MM(cond, mm) VM_BUG_ON(cond)
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
diff --git a/kernel/fork.c b/kernel/fork.c
index 18c44fb..36a7c36 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -645,7 +645,7 @@ static void check_mm(struct mm_struct *mm)
 				mm_nr_pmds(mm));
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
-	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
+	VM_BUG(mm->pmd_huge_pte, "%pZm", mm);
 #endif
 }
 
diff --git a/mm/gup.c b/mm/gup.c
index 0b851ac..57cc2de 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -848,7 +848,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG(start < vma->vm_start, "%pZv", vma);
 	VM_BUG(end > vma->vm_end, "%pZv", vma);
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+	VM_BUG(!rwsem_is_locked(&mm->mmap_sem), "%pZm", mm);
 
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
 	/*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d4b20cd..cda190f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2072,7 +2072,7 @@ int __khugepaged_enter(struct mm_struct *mm)
 		return -ENOMEM;
 
 	/* __khugepaged_exit() must not run from under us */
-	VM_BUG_ON_MM(khugepaged_test_exit(mm), mm);
+	VM_BUG(khugepaged_test_exit(mm), "%pZm", mm);
 	if (unlikely(test_and_set_bit(MMF_VM_HUGEPAGE, &mm->flags))) {
 		free_mm_slot(mm_slot);
 		return 0;
diff --git a/mm/mmap.c b/mm/mmap.c
index f2db320..311a795 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -464,7 +464,7 @@ static void validate_mm(struct mm_struct *mm)
 			pr_emerg("map_count %d rb %d\n", mm->map_count, i);
 		bug = 1;
 	}
-	VM_BUG_ON_MM(bug, mm);
+	VM_BUG(bug, "%pZm", mm);
 }
 #else
 #define validate_mm_rb(root, ignore) do { } while (0)
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 29f2f8b..952cddc 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -249,7 +249,7 @@ int walk_page_range(unsigned long start, unsigned long end,
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
+	VM_BUG(!rwsem_is_locked(&walk->mm->mmap_sem), "%pZm", walk->mm);
 
 	vma = find_vma(walk->mm, start);
 	do {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
