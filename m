Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 4E9FF6B006C
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 18:06:00 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 3/7] Allow each architecture to specify the address range that can be used for this allocation.
Date: Mon, 18 Jun 2012 18:05:22 -0400
Message-Id: <1340057126-31143-4-git-send-email-riel@redhat.com>
In-Reply-To: <1340057126-31143-1-git-send-email-riel@redhat.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>

From: Rik van Riel <riel@surriel.com>

On x86-64, this is used to implement MMAP_32BIT semantics.

On PPC and IA64, allocations using certain page sizes need to be
restricted to certain virtual address ranges. This callback could
be used to implement such address restrictions with minimal hassle.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 arch/mips/mm/mmap.c               |    8 ++----
 arch/x86/include/asm/pgtable_64.h |    1 +
 arch/x86/kernel/sys_x86_64.c      |   11 ++++++---
 include/linux/sched.h             |    7 ++++++
 mm/mmap.c                         |   38 ++++++++++++++++++++++++++++++++++--
 5 files changed, 53 insertions(+), 12 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 302d779..3f8af17 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -61,8 +61,6 @@ static inline unsigned long COLOUR_ALIGN_DOWN(unsigned long addr,
 	((((addr) + shm_align_mask) & ~shm_align_mask) +	\
 	 (((pgoff) << PAGE_SHIFT) & shm_align_mask))
 
-enum mmap_allocation_direction {UP, DOWN};
-
 static unsigned long arch_get_unmapped_area_common(struct file *filp,
 	unsigned long addr0, unsigned long len, unsigned long pgoff,
 	unsigned long flags, enum mmap_allocation_direction dir)
@@ -107,7 +105,7 @@ static unsigned long arch_get_unmapped_area_common(struct file *filp,
 			return addr;
 	}
 
-	if (dir == UP) {
+	if (dir == ALLOC_UP) {
 		addr = mm->mmap_base;
 		if (do_color_align)
 			addr = COLOUR_ALIGN(addr, pgoff);
@@ -204,7 +202,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr0,
 	unsigned long len, unsigned long pgoff, unsigned long flags)
 {
 	return arch_get_unmapped_area_common(filp,
-			addr0, len, pgoff, flags, UP);
+			addr0, len, pgoff, flags, ALLOC_UP);
 }
 
 /*
@@ -216,7 +214,7 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
 	unsigned long flags)
 {
 	return arch_get_unmapped_area_common(filp,
-			addr0, len, pgoff, flags, DOWN);
+			addr0, len, pgoff, flags, ALLOC_DOWN);
 }
 
 void arch_pick_mmap_layout(struct mm_struct *mm)
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 975f709..8af36f6 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -169,6 +169,7 @@ extern void cleanup_highmap(void);
 
 #define HAVE_ARCH_UNMAPPED_AREA
 #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
+#define HAVE_ARCH_GET_ADDRESS_RANGE
 
 #define pgtable_cache_init()   do { } while (0)
 #define check_pgt_cache()      do { } while (0)
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index b4d3c39..2595a5e 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -95,8 +95,8 @@ out:
 	return error;
 }
 
-static void find_start_end(unsigned long flags, unsigned long *begin,
-			   unsigned long *end)
+void arch_get_address_range(unsigned long flags, unsigned long *begin,
+		unsigned long *end, enum mmap_allocation_direction direction)
 {
 	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT)) {
 		unsigned long new_begin;
@@ -114,9 +114,12 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 			if (new_begin)
 				*begin = new_begin;
 		}
-	} else {
+	} else if (direction == ALLOC_UP) {
 		*begin = TASK_UNMAPPED_BASE;
 		*end = TASK_SIZE;
+	} else /* direction == ALLOC_DOWN */ {
+		*begin = 0;
+		*end = current->mm->mmap_base;
 	}
 }
 
@@ -132,7 +135,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	if (flags & MAP_FIXED)
 		return addr;
 
-	find_start_end(flags, &begin, &end);
+	arch_get_address_range(flags, &begin, &end, ALLOC_UP);
 
 	if (len > end)
 		return -ENOMEM;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4059c0f..fc76318 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -388,7 +388,14 @@ extern int sysctl_max_map_count;
 #include <linux/aio.h>
 
 #ifdef CONFIG_MMU
+enum mmap_allocation_direction {
+	ALLOC_UP,
+	ALLOC_DOWN
+};
 extern void arch_pick_mmap_layout(struct mm_struct *mm);
+extern void
+arch_get_address_range(unsigned long flags, unsigned long *begin,
+		unsigned long *end, enum mmap_allocation_direction direction);
 extern unsigned long
 arch_get_unmapped_area(struct file *, unsigned long, unsigned long,
 		       unsigned long, unsigned long);
diff --git a/mm/mmap.c b/mm/mmap.c
index 40c848e..92cf0bf 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1465,6 +1465,20 @@ unacct_error:
 	return error;
 }
 
+#ifndef HAVE_ARCH_GET_ADDRESS_RANGE
+void arch_get_address_range(unsigned long flags, unsigned long *begin,
+		unsigned long *end, enum mmap_allocation_direction direction)
+{
+	if (direction == ALLOC_UP) {
+		*begin = TASK_UNMAPPED_BASE;
+		*end = TASK_SIZE;
+	} else /* direction == ALLOC_DOWN */ {
+		*begin = 0;
+		*end = current->mm->mmap_base;
+	}
+}
+#endif
+
 /* Get an address range which is currently unmapped.
  * For shmat() with addr=0.
  *
@@ -1499,7 +1513,9 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
 	struct rb_node *rb_node;
-	unsigned long lower_limit = TASK_UNMAPPED_BASE;
+	unsigned long lower_limit, upper_limit;
+
+	arch_get_address_range(flags, &lower_limit, &upper_limit, ALLOC_UP);
 
 	if (len > TASK_SIZE)
 		return -ENOMEM;
@@ -1546,6 +1562,13 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 			continue;
 		}
 
+		/* We have gone too far right, and can not go left. */
+		if (vma->vm_end + len > upper_limit) {
+			if (!addr)
+				return -ENOMEM;
+			goto found_addr;
+		}
+
 		if (!found_here && node_free_hole(rb_node->rb_right) >= len) {
 			/* Last known hole is to the right of this subtree. */
 			rb_node = rb_node->rb_right;
@@ -1625,7 +1648,9 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	struct rb_node *rb_node = NULL;
-	unsigned long upper_limit = mm->mmap_base;
+	unsigned long lower_limit, upper_limit;
+
+	arch_get_address_range(flags, &lower_limit, &upper_limit, ALLOC_DOWN);
 
 	/* requested length too big for entire address space */
 	if (len > TASK_SIZE)
@@ -1644,7 +1669,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	}
 
 	/* requested length too big; prevent integer underflow below */
-	if (len > upper_limit)
+	if (len > upper_limit - lower_limit)
 		return -ENOMEM;
 
 	/*
@@ -1681,6 +1706,13 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			}
 		}
 
+		/* We have gone too far left, and can not go right. */
+		if (vma->vm_start < lower_limit + len) {
+			if (!addr)
+				return -ENOMEM;
+			goto found_addr;
+		}
+
 		if (!found_here && node_free_hole(rb_node->rb_left) >= len) {
 			/* Last known hole is to the right of this subtree. */
 			rb_node = rb_node->rb_left;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
