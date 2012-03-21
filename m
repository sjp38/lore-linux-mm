Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 452C76B007E
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:56:25 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:56:24 -0700 (PDT)
Subject: [PATCH 02/16] mm: use vm_flags_t for vma flags
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:56:21 +0400
Message-ID: <20120321065621.13852.36786.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

* switch type of vma->vm_flags and mm->def_flags to vm_flags_t
* introduce new constant "VM_NONE", as equivalent of zero vm_flags state
* spread vm_flags_t in the generic mm code
* fix dangerous type-casts (like int exec = vma->vm_flags & VM_EXEC)
* convert BDI_CAP_*_MAP consistency checks into BUILD_BUG_ON()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
---
 drivers/char/mem.c          |    2 +-
 fs/binfmt_elf.c             |    2 +-
 fs/exec.c                   |    2 +-
 include/linux/backing-dev.h |    7 -------
 include/linux/huge_mm.h     |    4 ++--
 include/linux/ksm.h         |    8 ++++----
 include/linux/mm.h          |   23 +++++++++++++----------
 include/linux/mm_types.h    |    4 ++--
 include/linux/mman.h        |    4 ++--
 include/linux/rmap.h        |    8 ++++----
 kernel/events/core.c        |    4 ++--
 kernel/fork.c               |    2 +-
 kernel/sys.c                |    4 ++--
 mm/backing-dev.c            |    4 ++++
 mm/huge_memory.c            |    2 +-
 mm/ksm.c                    |    4 ++--
 mm/madvise.c                |    2 +-
 mm/memory.c                 |    4 ++--
 mm/mlock.c                  |    2 +-
 mm/mmap.c                   |   36 ++++++++++++++++++------------------
 mm/mprotect.c               |    9 +++++----
 mm/mremap.c                 |    2 +-
 mm/rmap.c                   |   16 +++++++---------
 mm/vmscan.c                 |    4 ++--
 24 files changed, 79 insertions(+), 80 deletions(-)

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index d6e9d08..60a6e34 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -280,7 +280,7 @@ static unsigned long get_unmapped_area_mem(struct file *file,
 /* can't do an in-place private mapping if there's no MMU */
 static inline int private_mapping_ok(struct vm_area_struct *vma)
 {
-	return vma->vm_flags & VM_MAYSHARE;
+	return (vma->vm_flags & VM_MAYSHARE) != VM_NONE;
 }
 #else
 #define get_unmapped_area_mem	NULL
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 2be0d74..dce9c93 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -572,7 +572,7 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long reloc_func_desc __maybe_unused = 0;
 	int executable_stack = EXSTACK_DEFAULT;
-	unsigned long def_flags = 0;
+	vm_flags_t def_flags = VM_NONE;
 	struct {
 		struct elfhdr elf_ex;
 		struct elfhdr interp_elf_ex;
diff --git a/fs/exec.c b/fs/exec.c
index 4b142c5..c01aac5 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -660,7 +660,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = bprm->vma;
 	struct vm_area_struct *prev = NULL;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 	unsigned long stack_base;
 	unsigned long stack_size;
 	unsigned long stack_expand;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index b1038bd..1fc0249 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -260,13 +260,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_NO_ACCT_AND_WRITEBACK \
 	(BDI_CAP_NO_WRITEBACK | BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_ACCT_WB)
 
-#if defined(VM_MAYREAD) && \
-	(BDI_CAP_READ_MAP != VM_MAYREAD || \
-	 BDI_CAP_WRITE_MAP != VM_MAYWRITE || \
-	 BDI_CAP_EXEC_MAP != VM_MAYEXEC)
-#error please change backing_dev_info::capabilities flags
-#endif
-
 extern struct backing_dev_info default_backing_dev_info;
 extern struct backing_dev_info noop_backing_dev_info;
 
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index f56cacb..7343ed1 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -108,7 +108,7 @@ extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
-			    unsigned long *vm_flags, int advice);
+			    vm_flags_t *vm_flags, int advice);
 extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
@@ -177,7 +177,7 @@ static inline int split_huge_page(struct page *page)
 	do { } while (0)
 #define compound_trans_head(page) compound_head(page)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
-				   unsigned long *vm_flags, int advice)
+				   vm_flags_t *vm_flags, int advice)
 {
 	BUG();
 	return 0;
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 3319a69..5de0c3d 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -21,7 +21,7 @@ struct page *ksm_does_need_to_copy(struct page *page,
 
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags);
+		unsigned long end, int advice, vm_flags_t *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
 void __ksm_exit(struct mm_struct *mm);
 
@@ -84,7 +84,7 @@ static inline int ksm_might_need_to_copy(struct page *page,
 }
 
 int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+			struct mem_cgroup *memcg, vm_flags_t *vm_flags);
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
 int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		  struct vm_area_struct *, unsigned long, void *), void *arg);
@@ -108,7 +108,7 @@ static inline int PageKsm(struct page *page)
 
 #ifdef CONFIG_MMU
 static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, vm_flags_t *vm_flags)
 {
 	return 0;
 }
@@ -120,7 +120,7 @@ static inline int ksm_might_need_to_copy(struct page *page,
 }
 
 static inline int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags)
+			struct mem_cgroup *memcg, vm_flags_t *vm_flags)
 {
 	return 0;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 69915a2..96f335c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -73,6 +73,9 @@ extern unsigned int kobjsize(const void *objp);
 /*
  * vm_flags in vm_area_struct, see mm_types.h.
  */
+
+#define VM_NONE		0x00000000
+
 #define VM_READ		0x00000001	/* currently active flags */
 #define VM_WRITE	0x00000002
 #define VM_EXEC		0x00000004
@@ -143,8 +146,8 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_READHINTMASK			(VM_SEQ_READ | VM_RAND_READ)
 #define VM_ClearReadHint(v)		(v)->vm_flags &= ~VM_READHINTMASK
 #define VM_NormalReadHint(v)		(!((v)->vm_flags & VM_READHINTMASK))
-#define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
-#define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
+#define VM_SequentialReadHint(v)	(!!((v)->vm_flags & VM_SEQ_READ))
+#define VM_RandomReadHint(v)		(!!((v)->vm_flags & VM_RAND_READ))
 
 /*
  * Special vmas that are non-mergable, non-mlock()able.
@@ -1059,7 +1062,7 @@ extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long flags, unsigned long new_addr);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
-			  unsigned long end, unsigned long newflags);
+			  unsigned long end, vm_flags_t newflags);
 
 /*
  * doesn't attempt to fault and will return short.
@@ -1371,7 +1374,7 @@ extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
-	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
+	vm_flags_t vm_flags, struct anon_vma *, struct file *, pgoff_t,
 	struct mempolicy *);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int split_vma(struct mm_struct *,
@@ -1396,7 +1399,7 @@ extern struct file *get_mm_exe_file(struct mm_struct *mm);
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
-				   unsigned long flags, struct page **pages);
+				   vm_flags_t vm_flags, struct page **pages);
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
@@ -1467,7 +1470,7 @@ extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
 /* CONFIG_STACK_GROWSUP still needs to to grow downwards at some places */
 extern int expand_downwards(struct vm_area_struct *vma,
 		unsigned long address);
-#if VM_GROWSUP
+#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
 extern int expand_upwards(struct vm_area_struct *vma, unsigned long address);
 #else
   #define expand_upwards(vma, address) do { } while (0)
@@ -1507,9 +1510,9 @@ static inline struct vm_area_struct *find_exact_vma(struct mm_struct *mm,
 }
 
 #ifdef CONFIG_MMU
-pgprot_t vm_get_page_prot(unsigned long vm_flags);
+pgprot_t vm_get_page_prot(vm_flags_t vm_flags);
 #else
-static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
+static inline pgprot_t vm_get_page_prot(vm_flags_t vm_flags)
 {
 	return __pgprot(0);
 }
@@ -1543,10 +1546,10 @@ extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
 #ifdef CONFIG_PROC_FS
-void vm_stat_account(struct mm_struct *, unsigned long, struct file *, long);
+void vm_stat_account(struct mm_struct *, vm_flags_t, struct file *, long);
 #else
 static inline void vm_stat_account(struct mm_struct *mm,
-			unsigned long flags, struct file *file, long pages)
+			vm_flags_t vm_flags, struct file *file, long pages)
 {
 }
 #endif /* CONFIG_PROC_FS */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3aeb8f6..d57e764 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -212,7 +212,7 @@ struct vm_area_struct {
 	struct vm_area_struct *vm_next, *vm_prev;
 
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
-	unsigned long vm_flags;		/* Flags, see mm.h. */
+	vm_flags_t vm_flags;		/* Flags, see mm.h. */
 
 	struct rb_node vm_rb;
 
@@ -328,7 +328,7 @@ struct mm_struct {
 	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
 	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
 	unsigned long reserved_vm;	/* VM_RESERVED|VM_IO pages */
-	unsigned long def_flags;
+	vm_flags_t def_flags;
 	unsigned long nr_ptes;		/* Page table pages */
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 8b74e9b..3b11ea2 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -69,7 +69,7 @@ static inline int arch_validate_prot(unsigned long prot)
 /*
  * Combine the mmap "prot" argument into "vm_flags" used internally.
  */
-static inline unsigned long
+static inline vm_flags_t
 calc_vm_prot_bits(unsigned long prot)
 {
 	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
@@ -81,7 +81,7 @@ calc_vm_prot_bits(unsigned long prot)
 /*
  * Combine the mmap "flags" argument into "vm_flags" used internally.
  */
-static inline unsigned long
+static inline vm_flags_t
 calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 1cdd62a..cb460be 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -158,9 +158,9 @@ static inline void page_dup_rmap(struct page *page)
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+			struct mem_cgroup *memcg, vm_flags_t *vm_flags);
 int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
+	unsigned long address, unsigned int *mapcount, vm_flags_t *vm_flags);
 
 enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
@@ -237,9 +237,9 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *memcg,
-				  unsigned long *vm_flags)
+				  vm_flags_t *vm_flags)
 {
-	*vm_flags = 0;
+	*vm_flags = VM_NONE;
 	return 0;
 }
 
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 4b50357..73b1063 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -4559,7 +4559,7 @@ got_name:
 		if (cpuctx->active_pmu != pmu)
 			goto next;
 		perf_event_mmap_ctx(&cpuctx->ctx, mmap_event,
-					vma->vm_flags & VM_EXEC);
+					(vma->vm_flags & VM_EXEC) != VM_NONE);
 
 		ctxn = pmu->task_ctx_nr;
 		if (ctxn < 0)
@@ -4568,7 +4568,7 @@ got_name:
 		ctx = rcu_dereference(current->perf_event_ctxp[ctxn]);
 		if (ctx) {
 			perf_event_mmap_ctx(ctx, mmap_event,
-					vma->vm_flags & VM_EXEC);
+					(vma->vm_flags & VM_EXEC) != VM_NONE);
 		}
 next:
 		put_cpu_ptr(pmu->pmu_cpu_context);
diff --git a/kernel/fork.c b/kernel/fork.c
index 48675fb..f14cde8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -504,7 +504,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm_init_owner(mm, p);
 
 	if (likely(!mm_alloc_pgd(mm))) {
-		mm->def_flags = 0;
+		mm->def_flags = VM_NONE;
 		mmu_notifier_mm_init(mm);
 		return mm;
 	}
diff --git a/kernel/sys.c b/kernel/sys.c
index ef7e275..3080842 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1703,8 +1703,8 @@ SYSCALL_DEFINE1(umask, int, mask)
 
 #ifdef CONFIG_CHECKPOINT_RESTORE
 static bool vma_flags_mismatch(struct vm_area_struct *vma,
-			       unsigned long required,
-			       unsigned long banned)
+			       vm_flags_t required,
+			       vm_flags_t banned)
 {
 	return (vma->vm_flags & required) != required ||
 		(vma->vm_flags & banned);
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index dd8e2aa..1380e07 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -758,6 +758,10 @@ int bdi_setup_and_register(struct backing_dev_info *bdi, char *name,
 	char tmp[32];
 	int err;
 
+	BUILD_BUG_ON(BDI_CAP_READ_MAP != VM_MAYREAD);
+	BUILD_BUG_ON(BDI_CAP_WRITE_MAP != VM_MAYWRITE);
+	BUILD_BUG_ON(BDI_CAP_EXEC_MAP != VM_MAYEXEC);
+
 	bdi->name = name;
 	bdi->capabilities = cap;
 	err = bdi_init(bdi);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f0e5306..813138d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1486,7 +1486,7 @@ out:
 		   VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
-		     unsigned long *vm_flags, int advice)
+		     vm_flags_t *vm_flags, int advice)
 {
 	switch (advice) {
 	case MADV_HUGEPAGE:
diff --git a/mm/ksm.c b/mm/ksm.c
index f23a24d..963ee37 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1446,7 +1446,7 @@ static int ksm_scan_thread(void *nothing)
 }
 
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, vm_flags_t *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
@@ -1581,7 +1581,7 @@ struct page *ksm_does_need_to_copy(struct page *page,
 }
 
 int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
-			unsigned long *vm_flags)
+			vm_flags_t *vm_flags)
 {
 	struct stable_node *stable_node;
 	struct rmap_item *rmap_item;
diff --git a/mm/madvise.c b/mm/madvise.c
index f5ab745..7a67ea5 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -43,7 +43,7 @@ static long madvise_behavior(struct vm_area_struct * vma,
 	struct mm_struct * mm = vma->vm_mm;
 	int error = 0;
 	pgoff_t pgoff;
-	unsigned long new_flags = vma->vm_flags;
+	vm_flags_t new_flags = vma->vm_flags;
 
 	switch (behavior) {
 	case MADV_NORMAL:
diff --git a/mm/memory.c b/mm/memory.c
index 4c09ecb..b1c7c98 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -845,7 +845,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
 		unsigned long addr, int *rss)
 {
-	unsigned long vm_flags = vma->vm_flags;
+	vm_flags_t vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
 	struct page *page;
 
@@ -1635,7 +1635,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     int *nonblocking)
 {
 	int i;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 
 	if (nr_pages <= 0)
 		return 0;
diff --git a/mm/mlock.c b/mm/mlock.c
index ef726e8..c555e7d 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -524,7 +524,7 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 static int do_mlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
-	unsigned int def_flags = 0;
+	vm_flags_t def_flags = VM_NONE;
 
 	if (flags & MCL_FUTURE)
 		def_flags = VM_LOCKED;
diff --git a/mm/mmap.c b/mm/mmap.c
index ae12bb8..0b6e869 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -77,7 +77,7 @@ pgprot_t protection_map[16] = {
 	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
 };
 
-pgprot_t vm_get_page_prot(unsigned long vm_flags)
+pgprot_t vm_get_page_prot(vm_flags_t vm_flags)
 {
 	return __pgprot(pgprot_val(protection_map[vm_flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
@@ -658,7 +658,7 @@ again:			remove_next = 1 + (end > next->vm_end);
  * per-vma resources, so we don't attempt to merge those.
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
-			struct file *file, unsigned long vm_flags)
+			struct file *file, vm_flags_t vm_flags)
 {
 	/* VM_CAN_NONLINEAR may get set later by f_op->mmap() */
 	if ((vma->vm_flags ^ vm_flags) & ~VM_CAN_NONLINEAR)
@@ -696,7 +696,7 @@ static inline int is_mergeable_anon_vma(struct anon_vma *anon_vma1,
  * wrap, nor mmaps which cover the final page at index -1UL.
  */
 static int
-can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
+can_vma_merge_before(struct vm_area_struct *vma, vm_flags_t vm_flags,
 	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags) &&
@@ -715,7 +715,7 @@ can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
  * anon_vmas, nor if same anon_vma is assigned but offsets incompatible.
  */
 static int
-can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
+can_vma_merge_after(struct vm_area_struct *vma, vm_flags_t vm_flags,
 	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags) &&
@@ -759,7 +759,7 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
  */
 struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,
-			unsigned long end, unsigned long vm_flags,
+			unsigned long end, vm_flags_t vm_flags,
 		     	struct anon_vma *anon_vma, struct file *file,
 			pgoff_t pgoff, struct mempolicy *policy)
 {
@@ -928,19 +928,19 @@ none:
 }
 
 #ifdef CONFIG_PROC_FS
-void vm_stat_account(struct mm_struct *mm, unsigned long flags,
-						struct file *file, long pages)
+void vm_stat_account(struct mm_struct *mm, vm_flags_t vm_flags,
+		     struct file *file, long pages)
 {
-	const unsigned long stack_flags
+	const vm_flags_t stack_flags
 		= VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
 
 	if (file) {
 		mm->shared_vm += pages;
-		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
+		if ((vm_flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
 			mm->exec_vm += pages;
-	} else if (flags & stack_flags)
+	} else if (vm_flags & stack_flags)
 		mm->stack_vm += pages;
-	if (flags & (VM_RESERVED|VM_IO))
+	if (vm_flags & (VM_RESERVED|VM_IO))
 		mm->reserved_vm += pages;
 }
 #endif /* CONFIG_PROC_FS */
@@ -2156,7 +2156,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 {
 	struct mm_struct * mm = current->mm;
 	struct vm_area_struct * vma, * prev;
-	unsigned long flags;
+	vm_flags_t vm_flags;
 	struct rb_node ** rb_link, * rb_parent;
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
 	int error;
@@ -2169,7 +2169,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 	if (error)
 		return error;
 
-	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
+	vm_flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
 
 	error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
 	if (error & ~PAGE_MASK)
@@ -2216,7 +2216,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 		return -ENOMEM;
 
 	/* Can we just expand an old private anonymous mapping? */
-	vma = vma_merge(mm, prev, addr, addr + len, flags,
+	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
 					NULL, NULL, pgoff, NULL);
 	if (vma)
 		goto out;
@@ -2235,13 +2235,13 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
 	vma->vm_pgoff = pgoff;
-	vma->vm_flags = flags;
-	vma->vm_page_prot = vm_get_page_prot(flags);
+	vma->vm_flags = vm_flags;
+	vma->vm_page_prot = vm_get_page_prot(vm_flags);
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 out:
 	perf_event_mmap(vma);
 	mm->total_vm += len >> PAGE_SHIFT;
-	if (flags & VM_LOCKED) {
+	if (vm_flags & VM_LOCKED) {
 		if (!mlock_vma_pages_range(vma, addr, addr + len))
 			mm->locked_vm += (len >> PAGE_SHIFT);
 	}
@@ -2489,7 +2489,7 @@ static const struct vm_operations_struct special_mapping_vmops = {
  */
 int install_special_mapping(struct mm_struct *mm,
 			    unsigned long addr, unsigned long len,
-			    unsigned long vm_flags, struct page **pages)
+			    vm_flags_t vm_flags, struct page **pages)
 {
 	int ret;
 	struct vm_area_struct *vma;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a409926..0faa389 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -143,10 +143,10 @@ static void change_protection(struct vm_area_struct *vma,
 
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
-	unsigned long start, unsigned long end, unsigned long newflags)
+	unsigned long start, unsigned long end, vm_flags_t newflags)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long oldflags = vma->vm_flags;
+	vm_flags_t oldflags = vma->vm_flags;
 	long nrpages = (end - start) >> PAGE_SHIFT;
 	unsigned long charged = 0;
 	pgoff_t pgoff;
@@ -232,7 +232,8 @@ fail:
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	unsigned long vm_flags, nstart, end, tmp, reqprot;
+	unsigned long nstart, end, tmp, reqprot;
+	vm_flags_t vm_flags;
 	struct vm_area_struct *vma, *prev;
 	int error = -EINVAL;
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
@@ -289,7 +290,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		prev = vma;
 
 	for (nstart = start ; ; ) {
-		unsigned long newflags;
+		vm_flags_t newflags;
 
 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
diff --git a/mm/mremap.c b/mm/mremap.c
index db8d983..c94d1db 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -186,7 +186,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
-	unsigned long vm_flags = vma->vm_flags;
+	vm_flags_t vm_flags = vma->vm_flags;
 	unsigned long new_pgoff;
 	unsigned long moved_len;
 	unsigned long excess = 0;
diff --git a/mm/rmap.c b/mm/rmap.c
index 36d01a2..88ccaec 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -691,7 +691,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
  */
 int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+			vm_flags_t *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int referenced = 0;
@@ -770,7 +770,7 @@ out:
 
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
+				vm_flags_t *vm_flags)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -819,7 +819,7 @@ static int page_referenced_anon(struct page *page,
  */
 static int page_referenced_file(struct page *page,
 				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
+				vm_flags_t *vm_flags)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -885,12 +885,12 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *memcg,
-		    unsigned long *vm_flags)
+		    vm_flags_t *vm_flags)
 {
 	int referenced = 0;
 	int we_locked = 0;
 
-	*vm_flags = 0;
+	*vm_flags = VM_NONE;
 	if (page_mapped(page) && page_rmapping(page)) {
 		if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
 			we_locked = trylock_page(page);
@@ -1415,7 +1415,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	 * keep the sem while scanning the cluster for mlocking pages.
 	 */
 	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
-		locked_vma = (vma->vm_flags & VM_LOCKED);
+		locked_vma = (vma->vm_flags & VM_LOCKED) != VM_NONE;
 		if (!locked_vma)
 			up_read(&vma->vm_mm->mmap_sem); /* don't need it */
 	}
@@ -1466,9 +1466,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 bool is_vma_temporary_stack(struct vm_area_struct *vma)
 {
-	int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);
-
-	if (!maybe_stack)
+	if ((vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP)) == VM_NONE)
 		return false;
 
 	if ((vma->vm_flags & VM_STACK_INCOMPLETE_SETUP) ==
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 57d8ef6..9d3441d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -705,7 +705,7 @@ static enum page_references page_check_references(struct page *page,
 						  struct scan_control *sc)
 {
 	int referenced_ptes, referenced_page;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 
 	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
 	referenced_page = TestClearPageReferenced(page);
@@ -1678,7 +1678,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 {
 	unsigned long nr_taken;
 	unsigned long nr_scanned;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
