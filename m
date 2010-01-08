Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 735B16B0062
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 17:05:38 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/6] NOMMU: Don't need get_unmapped_area() for NOMMU
Date: Fri, 08 Jan 2010 22:05:33 +0000
Message-ID: <20100108220533.23489.99121.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: viro@ZenIV.linux.org.uk, vapier@gentoo.org, lethal@linux-sh.org
Cc: dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

get_unmapped_area() is unnecessary for NOMMU as no-one calls it.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/mm_types.h |    2 ++
 include/linux/sched.h    |    7 +++++--
 mm/nommu.c               |   21 ---------------------
 mm/util.c                |    2 +-
 4 files changed, 8 insertions(+), 24 deletions(-)


diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 80cfa78..36f9627 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -205,10 +205,12 @@ struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
+#ifdef CONFIG_MMU
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
 	void (*unmap_area) (struct mm_struct *mm, unsigned long addr);
+#endif
 	unsigned long mmap_base;		/* base of mmap area */
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8d4991b..08a2523 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -377,6 +377,8 @@ extern int sysctl_max_map_count;
 
 #include <linux/aio.h>
 
+#ifdef CONFIG_MMU
+extern void arch_pick_mmap_layout(struct mm_struct *mm);
 extern unsigned long
 arch_get_unmapped_area(struct file *, unsigned long, unsigned long,
 		       unsigned long, unsigned long);
@@ -386,6 +388,9 @@ arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 			  unsigned long flags);
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
+#else
+extern void arch_pick_mmap_layout(struct mm_struct *mm) {}
+#endif
 
 #if USE_SPLIT_PTLOCKS
 /*
@@ -2491,8 +2496,6 @@ static inline void set_task_cpu(struct task_struct *p, unsigned int cpu)
 
 #endif /* CONFIG_SMP */
 
-extern void arch_pick_mmap_layout(struct mm_struct *mm);
-
 #ifdef CONFIG_TRACING
 extern void
 __trace_special(void *__tr, void *__data,
diff --git a/mm/nommu.c b/mm/nommu.c
index d6dd656..32be0cf 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1761,27 +1761,6 @@ void unmap_mapping_range(struct address_space *mapping,
 EXPORT_SYMBOL(unmap_mapping_range);
 
 /*
- * ask for an unmapped area at which to create a mapping on a file
- */
-unsigned long get_unmapped_area(struct file *file, unsigned long addr,
-				unsigned long len, unsigned long pgoff,
-				unsigned long flags)
-{
-	unsigned long (*get_area)(struct file *, unsigned long, unsigned long,
-				  unsigned long, unsigned long);
-
-	get_area = current->mm->get_unmapped_area;
-	if (file && file->f_op && file->f_op->get_unmapped_area)
-		get_area = file->f_op->get_unmapped_area;
-
-	if (!get_area)
-		return -ENOSYS;
-
-	return get_area(file, addr, len, pgoff, flags);
-}
-EXPORT_SYMBOL(get_unmapped_area);
-
-/*
  * Check that a process has enough memory to allocate a new virtual
  * mapping. 0 means there is enough memory for the allocation to
  * succeed and -ENOMEM implies there is not.
diff --git a/mm/util.c b/mm/util.c
index 7c35ad9..834db7b 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -220,7 +220,7 @@ char *strndup_user(const char __user *s, long n)
 }
 EXPORT_SYMBOL(strndup_user);
 
-#ifndef HAVE_ARCH_PICK_MMAP_LAYOUT
+#if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
 void arch_pick_mmap_layout(struct mm_struct *mm)
 {
 	mm->mmap_base = TASK_UNMAPPED_BASE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
