Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0E26B0039
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:50:58 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id va2so1648259obc.11
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 18:50:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n6si21639278oed.93.2014.09.29.18.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 18:50:56 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 4/5] mm: poison vm_area_struct
Date: Mon, 29 Sep 2014 21:47:18 -0400
Message-Id: <1412041639-23617-5-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de, Sasha Levin <sasha.levin@oracle.com>

Add poisoning to vm_area_struct to catch corruption at either the beginning or
the end of the struct.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 fs/exec.c                |  5 +++++
 include/linux/mm_types.h |  6 ++++++
 include/linux/mmdebug.h  |  6 ++++++
 kernel/fork.c            |  2 ++
 mm/debug.c               | 11 +++++++++--
 mm/mmap.c                | 19 ++++++++++++++++++-
 mm/nommu.c               |  7 +++++++
 mm/vmacache.c            |  3 +++
 8 files changed, 56 insertions(+), 3 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 7302b75..6cdd652 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -257,6 +257,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 		return -ENOMEM;
 
 	down_write(&mm->mmap_sem);
+#ifdef CONFIG_DEBUG_VM_POISON
+	vma->poison_start = MM_POISON_BEGIN;
+	vma->poison_end = MM_POISON_END;
+#endif
 	vma->vm_mm = mm;
 
 	/*
@@ -283,6 +287,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 err:
 	up_write(&mm->mmap_sem);
 	bprm->vma = NULL;
+	VM_CHECK_POISON_VMA(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 	return err;
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 0b0d324..4e2cf93 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -245,6 +245,9 @@ struct vm_region {
  * library, the executable area etc).
  */
 struct vm_area_struct {
+#ifdef CONFIG_DEBUG_VM_POISON
+	u32 poison_start;
+#endif
 	/* The first cache line has the info for VMA tree walking. */
 
 	unsigned long vm_start;		/* Our start address within vm_mm. */
@@ -308,6 +311,9 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+#ifdef CONFIG_DEBUG_VM_POISON
+	u32 poison_end;
+#endif
 };
 
 struct core_thread {
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 339e40f..75bc69d 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -45,6 +45,11 @@ void dump_mm(const struct mm_struct *mm);
 		VM_BUG_ON_MM((mm)->poison_start != MM_POISON_BEGIN, (mm));\
 		VM_BUG_ON_MM((mm)->poison_end != MM_POISON_END, (mm));	\
 	} while (0)
+#define VM_CHECK_POISON_VMA(vma)					\
+	do {                                                            \
+		VM_BUG_ON_VMA((vma)->poison_start != MM_POISON_BEGIN, (vma));\
+		VM_BUG_ON_VMA((vma)->poison_end != MM_POISON_END, (vma));\
+	} while (0)
 #endif
 #else
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
@@ -55,6 +60,7 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
 #define VM_CHECK_POISON_MM(mm) do { } while(0)
+#define VM_CHECK_POISON_VMA(vma) do { } while(0)
 #endif
 
 #ifdef CONFIG_DEBUG_VIRTUAL
diff --git a/kernel/fork.c b/kernel/fork.c
index 26bedfa..c3ae913 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -415,6 +415,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (!tmp)
 			goto fail_nomem;
+		VM_CHECK_POISON_VMA(mpnt);
 		*tmp = *mpnt;
 		INIT_LIST_HEAD(&tmp->anon_vma_chain);
 		retval = vma_dup_policy(mpnt, tmp);
@@ -489,6 +490,7 @@ out:
 fail_nomem_anon_vma_fork:
 	mpol_put(vma_policy(tmp));
 fail_nomem_policy:
+	VM_CHECK_POISON_VMA(tmp);
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
 	retval = -ENOMEM;
diff --git a/mm/debug.c b/mm/debug.c
index a1ebc5e..d53174e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -152,11 +152,18 @@ static const struct trace_print_flags vmaflags_names[] = {
 void dump_vma(const struct vm_area_struct *vma)
 {
 	pr_emerg("vma %p start %p end %p\n"
+#ifdef CONFIG_DEBUG_VM_POISON
+		"start poison: %s end poison: %s\n"
+#endif
 		"next %p prev %p mm %p\n"
 		"prot %lx anon_vma %p vm_ops %p\n"
 		"pgoff %lx file %p private_data %p\n",
-		vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
-		vma->vm_prev, vma->vm_mm,
+		vma, (void *)vma->vm_start, (void *)vma->vm_end,
+#ifdef CONFIG_DEBUG_VM_POISON
+		(vma->poison_start == MM_POISON_BEGIN) ? "valid" : "invalid",
+		(vma->poison_end == MM_POISON_END) ? "valid" : "invalid",
+#endif
+		vma->vm_next, vma->vm_prev, vma->vm_mm,
 		(unsigned long)pgprot_val(vma->vm_page_prot),
 		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
 		vma->vm_file, vma->vm_private_data);
diff --git a/mm/mmap.c b/mm/mmap.c
index 3240bbc..da5ffeb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -274,6 +274,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	struct vm_area_struct *next = vma->vm_next;
 
 	might_sleep();
+	VM_CHECK_POISON_VMA(vma);
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
@@ -900,6 +901,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 			anon_vma_merge(vma, next);
 		mm->map_count--;
 		mpol_put(vma_policy(next));
+		VM_CHECK_POISON_VMA(next);
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
@@ -1594,6 +1596,10 @@ munmap_back:
 		goto unacct_error;
 	}
 
+#ifdef CONFIG_DEBUG_VM_POISON
+	vma->poison_start = MM_POISON_BEGIN;
+	vma->poison_end = MM_POISON_END;
+#endif
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
@@ -1691,6 +1697,7 @@ allow_write_and_free_vma:
 	if (vm_flags & VM_DENYWRITE)
 		allow_write_access(file);
 free_vma:
+	VM_CHECK_POISON_VMA(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 unacct_error:
 	if (charged)
@@ -2454,7 +2461,7 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!new)
 		goto out_err;
-
+	VM_CHECK_POISON_VMA(vma);
 	/* most fields are the same, copy all, and then fixup */
 	*new = *vma;
 
@@ -2499,6 +2506,7 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  out_free_mpol:
 	mpol_put(vma_policy(new));
  out_free_vma:
+	VM_CHECK_POISON_VMA(new);
 	kmem_cache_free(vm_area_cachep, new);
  out_err:
 	return err;
@@ -2771,6 +2779,10 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 		return -ENOMEM;
 	}
 
+#ifdef CONFIG_DEBUG_VM_POISON
+	vma->poison_start = MM_POISON_BEGIN;
+	vma->poison_end = MM_POISON_END;
+#endif
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
@@ -2942,6 +2954,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		*need_rmap_locks = (new_vma->vm_pgoff <= vma->vm_pgoff);
 	} else {
 		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+		VM_CHECK_POISON_VMA(vma);
 		if (new_vma) {
 			*new_vma = *vma;
 			new_vma->vm_start = addr;
@@ -3058,6 +3071,10 @@ static struct vm_area_struct *__install_special_mapping(
 		return ERR_PTR(-ENOMEM);
 
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
+#ifdef CONFIG_DEBUG_VM_POISON
+	vma->poison_start = MM_POISON_BEGIN;
+	vma->poison_end = MM_POISON_END;
+#endif
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
diff --git a/mm/nommu.c b/mm/nommu.c
index bd10aa1..e81b656 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -820,6 +820,7 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 {
 	kenter("%p", vma);
+	VM_CHECK_POISON_VMA(vma);
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
@@ -1302,6 +1303,10 @@ unsigned long do_mmap_pgoff(struct file *file,
 	if (!vma)
 		goto error_getting_vma;
 
+#ifdef CONFIG_DEBUG_VM_POISON
+	vma->poison_start = MM_POISON_BEGIN;
+	vma->poison_end = MM_POISON_END;
+#endif
 	region->vm_usage = 1;
 	region->vm_flags = vm_flags;
 	region->vm_pgoff = pgoff;
@@ -1465,6 +1470,7 @@ error:
 	kmem_cache_free(vm_region_jar, region);
 	if (vma->vm_file)
 		fput(vma->vm_file);
+	VM_CHECK_POISON_VMA(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 	kleave(" = %d", ret);
 	return ret;
@@ -1571,6 +1577,7 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/* most fields are the same, copy all, and then fixup */
+	VM_CHECK_POISON_VMA(vma);
 	*new = *vma;
 	*region = *vma->vm_region;
 	new->vm_region = region;
diff --git a/mm/vmacache.c b/mm/vmacache.c
index d507caa..27760cf 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -59,6 +59,7 @@ static bool vmacache_valid_mm(struct mm_struct *mm)
 
 void vmacache_update(unsigned long addr, struct vm_area_struct *newvma)
 {
+	VM_CHECK_POISON_VMA(newvma);
 	if (vmacache_valid_mm(newvma->vm_mm))
 		current->vmacache[VMACACHE_HASH(addr)] = newvma;
 }
@@ -99,6 +100,7 @@ struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
 			continue;
 		if (WARN_ON_ONCE(vma->vm_mm != mm))
 			break;
+		VM_CHECK_POISON_VMA(vma);
 		if (vma->vm_start <= addr && vma->vm_end > addr) {
 			count_vm_vmacache_event(VMACACHE_FIND_HITS);
 			return vma;
@@ -123,6 +125,7 @@ struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
 	for (i = 0; i < VMACACHE_SIZE; i++) {
 		struct vm_area_struct *vma = current->vmacache[i];
 
+		VM_CHECK_POISON_VMA(vma);
 		if (vma && vma->vm_start == start && vma->vm_end == end) {
 			count_vm_vmacache_event(VMACACHE_FIND_HITS);
 			return vma;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
