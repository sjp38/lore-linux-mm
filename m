Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id D67B76B006E
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 08:12:16 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so106549769wic.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 05:12:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb7si17708501wid.20.2015.04.28.05.12.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 05:12:11 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 2/3] mm: allow munmap related functions to understand gfp_mask
Date: Tue, 28 Apr 2015 14:11:50 +0200
Message-Id: <1430223111-14817-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1430223111-14817-1-git-send-email-mhocko@suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

__split_vma path requires to allocate a memory. Later patch in the
series will require to change standard GFP_KERNEL allocation to use
__GFP_NOFAIL. In order to do that all the allocation paths down this
path should understand gfp requirements of the caller.

This involves vma_dup_policy and vma_adjust which have _gfp variant now
and anon_vma_clone got just a new parameter because it doesn't have
many callers.

The patch doesn't have any runtime effects but it makes the code
slightly larger:
   text    data     bss     dec     hex filename
 511480   74147   44440  630067   99d33 mm/built-in.o.before
 511560   74147   44440  630147   99d83 mm/built-in.o.after

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/mempolicy.h | 17 ++++++++++++++---
 include/linux/mm.h        | 10 ++++++++--
 include/linux/rmap.h      |  2 +-
 mm/mempolicy.c            |  9 +++++----
 mm/mmap.c                 | 43 +++++++++++++++++++++++++------------------
 mm/nommu.c                | 24 ++++++++++++++++++------
 mm/rmap.c                 |  7 ++++---
 7 files changed, 75 insertions(+), 37 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 3d385c81c153..a42585c09d4e 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -82,11 +82,12 @@ static inline void mpol_cond_put(struct mempolicy *pol)
 		__mpol_put(pol);
 }
 
-extern struct mempolicy *__mpol_dup(struct mempolicy *pol);
+extern struct mempolicy *mpol_dup_gfp(struct mempolicy *pol,
+		gfp_t gfp_mask);
 static inline struct mempolicy *mpol_dup(struct mempolicy *pol)
 {
 	if (pol)
-		pol = __mpol_dup(pol);
+		pol = mpol_dup_gfp(pol, GFP_KERNEL);
 	return pol;
 }
 
@@ -125,7 +126,12 @@ struct shared_policy {
 	spinlock_t lock;
 };
 
-int vma_dup_policy(struct vm_area_struct *src, struct vm_area_struct *dst);
+int vma_dup_policy_gfp(struct vm_area_struct *src,
+		struct vm_area_struct *dst, gfp_t gfp_mask);
+static inline int
+vma_dup_policy(struct vm_area_struct *src, struct vm_area_struct *dst) {
+	return vma_dup_policy_gfp(src, dst, GFP_KERNEL);
+}
 void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol);
 int mpol_set_shared_policy(struct shared_policy *info,
 				struct vm_area_struct *vma,
@@ -235,6 +241,11 @@ vma_dup_policy(struct vm_area_struct *src, struct vm_area_struct *dst)
 {
 	return 0;
 }
+static inline int
+vma_dup_policy_gfp(struct vm_area_struct *src,
+		struct vm_area_struct *dst, gfp_t gfp_mask) {
+	return 0;
+}
 
 static inline void numa_policy_init(void)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5d20fba62081..723032a2273f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1752,8 +1752,14 @@ void anon_vma_interval_tree_verify(struct anon_vma_chain *node);
 
 /* mmap.c */
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
-extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
-	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
+extern int vma_adjust_gfp(struct vm_area_struct *vma, unsigned long start,
+	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
+	gfp_t gfp_mask);
+static inline int
+vma_adjust(struct vm_area_struct *vma, unsigned long start,
+	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert) {
+	return vma_adjust_gfp(vma, start, end, pgoff, insert, GFP_KERNEL);
+}
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bf36b6e644c4..23d210b84431 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -147,7 +147,7 @@ static inline void anon_vma_unlock_read(struct anon_vma *anon_vma)
 void anon_vma_init(void);	/* create anon_vma_cachep */
 int  anon_vma_prepare(struct vm_area_struct *);
 void unlink_anon_vmas(struct vm_area_struct *);
-int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
+int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *, gfp_t);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 
 static inline void anon_vma_merge(struct vm_area_struct *vma,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ede26291d4aa..9002d0a15d74 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2060,9 +2060,10 @@ retry_cpuset:
 }
 EXPORT_SYMBOL(alloc_pages_current);
 
-int vma_dup_policy(struct vm_area_struct *src, struct vm_area_struct *dst)
+int vma_dup_policy_gfp(struct vm_area_struct *src, struct vm_area_struct *dst,
+		gfp_t gfp_mask)
 {
-	struct mempolicy *pol = mpol_dup(vma_policy(src));
+	struct mempolicy *pol = mpol_dup_gfp(vma_policy(src), gfp_mask);
 
 	if (IS_ERR(pol))
 		return PTR_ERR(pol);
@@ -2082,9 +2083,9 @@ int vma_dup_policy(struct vm_area_struct *src, struct vm_area_struct *dst)
  */
 
 /* Slow path of a mempolicy duplicate */
-struct mempolicy *__mpol_dup(struct mempolicy *old)
+struct mempolicy *mpol_dup_gfp(struct mempolicy *old, gfp_t gfp_mask)
 {
-	struct mempolicy *new = kmem_cache_alloc(policy_cache, GFP_KERNEL);
+	struct mempolicy *new = kmem_cache_alloc(policy_cache, gfp_mask);
 
 	if (!new)
 		return ERR_PTR(-ENOMEM);
diff --git a/mm/mmap.c b/mm/mmap.c
index bb50cacc3ea5..4882008dac83 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -719,8 +719,9 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
  * are necessary.  The "insert" vma (if any) is to be inserted
  * before we drop the necessary locks.
  */
-int vma_adjust(struct vm_area_struct *vma, unsigned long start,
-	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
+int vma_adjust_gfp(struct vm_area_struct *vma, unsigned long start,
+	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
+	gfp_t gfp_mask)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *next = vma->vm_next;
@@ -773,7 +774,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 			int error;
 
 			importer->anon_vma = exporter->anon_vma;
-			error = anon_vma_clone(importer, exporter);
+			error = anon_vma_clone(importer, exporter, gfp_mask);
 			if (error)
 				return error;
 		}
@@ -2435,11 +2436,11 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 /*
- * __split_vma() bypasses sysctl_max_map_count checking.  We use this on the
+ * __split_vma_gfp() bypasses sysctl_max_map_count checking.  We use this on the
  * munmap path where it doesn't make sense to fail.
  */
-static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
-	      unsigned long addr, int new_below)
+static int __split_vma_gfp(struct mm_struct *mm, struct vm_area_struct *vma,
+	      unsigned long addr, int new_below, gfp_t gfp_mask)
 {
 	struct vm_area_struct *new;
 	int err = -ENOMEM;
@@ -2448,7 +2449,7 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 					~(huge_page_mask(hstate_vma(vma)))))
 		return -EINVAL;
 
-	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+	new = kmem_cache_alloc(vm_area_cachep, gfp_mask);
 	if (!new)
 		goto out_err;
 
@@ -2464,11 +2465,11 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 		new->vm_pgoff += ((addr - vma->vm_start) >> PAGE_SHIFT);
 	}
 
-	err = vma_dup_policy(vma, new);
+	err = vma_dup_policy_gfp(vma, new, gfp_mask);
 	if (err)
 		goto out_free_vma;
 
-	err = anon_vma_clone(new, vma);
+	err = anon_vma_clone(new, vma, gfp_mask);
 	if (err)
 		goto out_free_mpol;
 
@@ -2479,10 +2480,10 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 		new->vm_ops->open(new);
 
 	if (new_below)
-		err = vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
-			((addr - new->vm_start) >> PAGE_SHIFT), new);
+		err = vma_adjust_gfp(vma, addr, vma->vm_end, vma->vm_pgoff +
+			((addr - new->vm_start) >> PAGE_SHIFT), new, gfp_mask);
 	else
-		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
+		err = vma_adjust_gfp(vma, vma->vm_start, addr, vma->vm_pgoff, new, gfp_mask);
 
 	/* Success. */
 	if (!err)
@@ -2512,7 +2513,7 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (mm->map_count >= sysctl_max_map_count)
 		return -ENOMEM;
 
-	return __split_vma(mm, vma, addr, new_below);
+	return __split_vma_gfp(mm, vma, addr, new_below, GFP_KERNEL);
 }
 
 /* Munmap is split into 2 main parts -- this part which finds
@@ -2520,7 +2521,8 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * work.  This now handles partial unmappings.
  * Jeremy Fitzhardinge <jeremy@goop.org>
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+static int __do_munmap_gfp(struct mm_struct *mm, unsigned long start, size_t len,
+		gfp_t gfp_mask)
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
@@ -2562,7 +2564,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
 			return -ENOMEM;
 
-		error = __split_vma(mm, vma, start, 0);
+		error = __split_vma_gfp(mm, vma, start, 0, gfp_mask);
 		if (error)
 			return error;
 		prev = vma;
@@ -2571,7 +2573,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	/* Does it split the last one? */
 	last = find_vma(mm, end);
 	if (last && end > last->vm_start) {
-		int error = __split_vma(mm, last, end, 1);
+		int error = __split_vma_gfp(mm, last, end, 1, gfp_mask);
 		if (error)
 			return error;
 	}
@@ -2605,6 +2607,11 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	return 0;
 }
 
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+{
+	return __do_munmap_gfp(mm, start, len, GFP_KERNEL);
+}
+
 int vm_munmap(unsigned long start, size_t len)
 {
 	int ret;
@@ -2943,10 +2950,10 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
 			new_vma->vm_pgoff = pgoff;
-			if (vma_dup_policy(vma, new_vma))
+			if (vma_dup_policy_gfp(vma, new_vma, GFP_KERNEL))
 				goto out_free_vma;
 			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
-			if (anon_vma_clone(new_vma, vma))
+			if (anon_vma_clone(new_vma, vma, GFP_KERNEL))
 				goto out_free_mempol;
 			if (new_vma->vm_file)
 				get_file(new_vma->vm_file);
diff --git a/mm/nommu.c b/mm/nommu.c
index 3fba2dc97c44..f1e7b41a2031 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1556,8 +1556,8 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
  * split a vma into two pieces at address 'addr', a new vma is allocated either
  * for the first part or the tail.
  */
-int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
-	      unsigned long addr, int new_below)
+static int __split_vma_gfp(struct mm_struct *mm, struct vm_area_struct *vma,
+	      unsigned long addr, int new_below, gfp_t gfp_mask)
 {
 	struct vm_area_struct *new;
 	struct vm_region *region;
@@ -1573,11 +1573,11 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (mm->map_count >= sysctl_max_map_count)
 		return -ENOMEM;
 
-	region = kmem_cache_alloc(vm_region_jar, GFP_KERNEL);
+	region = kmem_cache_alloc(vm_region_jar, gfp_mask);
 	if (!region)
 		return -ENOMEM;
 
-	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+	new = kmem_cache_alloc(vm_area_cachep, gfp_mask);
 	if (!new) {
 		kmem_cache_free(vm_region_jar, region);
 		return -ENOMEM;
@@ -1618,6 +1618,12 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
+int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
+	      unsigned long addr, int new_below)
+{
+	return __split_vma_gfp(mm, vma, addr, new_below, GFP_KERNEL);
+}
+
 /*
  * shrink a VMA by removing the specified chunk from either the beginning or
  * the end
@@ -1663,7 +1669,8 @@ static int shrink_vma(struct mm_struct *mm,
  * - under NOMMU conditions the chunk to be unmapped must be backed by a single
  *   VMA, though it need not cover the whole VMA
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+static int __do_munmap_gfp(struct mm_struct *mm, unsigned long start, size_t len
+		gfp_t gfp_mask)
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
@@ -1722,7 +1729,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 			return -EINVAL;
 		}
 		if (start != vma->vm_start && end != vma->vm_end) {
-			ret = split_vma(mm, vma, start, 1);
+			ret = __split_vma_gfp(mm, vma, start, 1, gfp_mask);
 			if (ret < 0) {
 				kleave(" = %d [split]", ret);
 				return ret;
@@ -1737,6 +1744,11 @@ erase_whole_vma:
 	kleave(" = 0");
 	return 0;
 }
+
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+{
+	return __do_munmap_gfp(mm, start, len, GFP_KERNEL);
+}
 EXPORT_SYMBOL(do_munmap);
 
 int vm_munmap(unsigned long addr, size_t len)
diff --git a/mm/rmap.c b/mm/rmap.c
index dad23a43e42c..e10101940031 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -249,7 +249,8 @@ static inline void unlock_anon_vma_root(struct anon_vma *root)
  * good chance of avoiding scanning the whole hierarchy when it searches where
  * page is mapped.
  */
-int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
+int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src,
+		gfp_t gfp_mask)
 {
 	struct anon_vma_chain *avc, *pavc;
 	struct anon_vma *root = NULL;
@@ -261,7 +262,7 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 		if (unlikely(!avc)) {
 			unlock_anon_vma_root(root);
 			root = NULL;
-			avc = anon_vma_chain_alloc(GFP_KERNEL);
+			avc = anon_vma_chain_alloc(gfp_mask);
 			if (!avc)
 				goto enomem_failure;
 		}
@@ -320,7 +321,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	 * First, attach the new VMA to the parent VMA's anon_vmas,
 	 * so rmap can find non-COWed pages in child processes.
 	 */
-	error = anon_vma_clone(vma, pvma);
+	error = anon_vma_clone(vma, pvma, GFP_KERNEL);
 	if (error)
 		return error;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
