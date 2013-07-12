Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 02FA36B0034
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 22:34:32 -0400 (EDT)
Received: by mail-qa0-f73.google.com with SMTP id hu14so20603qab.4
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 19:34:32 -0700 (PDT)
From: Colin Cross <ccross@android.com>
Subject: [PATCH 2/2] mm: add a field to store names for private anonymous memory
Date: Thu, 11 Jul 2013 19:34:22 -0700
Message-Id: <1373596462-27115-2-git-send-email-ccross@android.com>
In-Reply-To: <1373596462-27115-1-git-send-email-ccross@android.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Colin Cross <ccross@android.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

Userspace processes often have multiple allocators that each do
anonymous mmaps to get memory.  When examining memory usage of
individual processes or systems as a whole, it is useful to be
able to break down the various heaps that were allocated by
each layer and examine their size, RSS, and physical memory
usage.

This patch adds a user pointer to the shared union in
vm_area_struct that points to a null terminated string inside
the user process containing a name for the vma.  vmas that
point to the same address will be merged, but vmas that
point to equivalent strings at different addresses will
not be merged.

Userspace can set the name for a region of memory by calling
prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, start, len, (unsigned long)name);
Setting the name to NULL clears it.

The names of named anonymous vmas are shown in /proc/pid/maps
as [anon:<name>] and in /proc/pid/smaps in a new "Name" field
that is only present for named vmas.  If the userspace pointer
is no longer valid all or part of the name will be replaced
with "<fault>".

The idea to store a userspace pointer to reduce the complexity
within mm (at the expense of the complexity of reading
/proc/pid/mem) came from Dave Hansen.  This results in no
runtime overhead in the mm subsystem other than comparing
the anon_name pointers when considering vma merging.  The pointer
is stored in a union with fieds that are only used on file-backed
mappings, so it does not increase memory usage.

Signed-off-by: Colin Cross <ccross@android.com>
---
 Documentation/filesystems/proc.txt |  6 ++++
 fs/proc/task_mmu.c                 | 62 ++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h                 |  5 ++-
 include/linux/mm_types.h           | 15 +++++++++
 include/uapi/linux/prctl.h         |  3 ++
 kernel/sys.c                       | 24 +++++++++++++++
 mm/madvise.c                       | 56 +++++++++++++++++++++++++++++++---
 mm/mempolicy.c                     |  2 +-
 mm/mlock.c                         |  3 +-
 mm/mmap.c                          | 44 ++++++++++++++++-----------
 mm/mprotect.c                      |  3 +-
 11 files changed, 197 insertions(+), 26 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index fd8d0d5..e0eb9d2 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -369,6 +369,8 @@ is not associated with a file:
  [stack:1001]             = the stack of the thread with tid 1001
  [vdso]                   = the "virtual dynamic shared object",
                             the kernel system call handler
+ [anon:<name>]            = an anonymous mapping that has been
+                            named by userspace
 
  or if empty, the mapping is anonymous.
 
@@ -419,6 +421,7 @@ KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 Locked:              374 kB
 VmFlags: rd ex mr mw me de
+Name:           name from userspace
 
 the first of these lines shows the same information as is displayed for the
 mapping in /proc/PID/maps.  The remaining lines show the size of the mapping
@@ -469,6 +472,9 @@ Note that there is no guarantee that every flag and associated mnemonic will
 be present in all further kernel releases. Things get changed, the flags may
 be vanished or the reverse -- new added.
 
+The "Name" field will only be present on a mapping that has been named by
+userspace, and will show the name passed in by userspace.
+
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3e636d8..de76be4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -90,6 +90,56 @@ static void pad_len_spaces(struct seq_file *m, int len)
 	seq_printf(m, "%*c", len, ' ');
 }
 
+static void seq_print_vma_name(struct seq_file *m, struct vm_area_struct *vma)
+{
+	const char __user *name = vma_get_anon_name(vma);
+	struct mm_struct *mm = vma->vm_mm;
+
+	unsigned long page_start_vaddr;
+	unsigned long page_offset;
+	unsigned long num_pages;
+	unsigned long max_len = NAME_MAX;
+	int i;
+
+	page_start_vaddr = (unsigned long)name & PAGE_MASK;
+	page_offset = (unsigned long)name - page_start_vaddr;
+	num_pages = DIV_ROUND_UP(page_offset + max_len, PAGE_SIZE);
+
+	seq_puts(m, "[anon:");
+
+	for (i = 0; i < num_pages; i++) {
+		int len;
+		int write_len;
+		const char *kaddr;
+		long pages_pinned;
+		struct page *page;
+
+		pages_pinned = get_user_pages(current, mm, page_start_vaddr,
+				1, 0, 0, &page, NULL);
+		if (pages_pinned < 1) {
+			seq_puts(m, "<fault>]");
+			return;
+		}
+
+		kaddr = (const char *)kmap(page);
+		len = min(max_len, PAGE_SIZE - page_offset);
+		write_len = strnlen(kaddr + page_offset, len);
+		seq_write(m, kaddr + page_offset, write_len);
+		kunmap(page);
+		put_page(page);
+
+		/* if strnlen hit a null terminator then we're done */
+		if (write_len != len)
+			break;
+
+		max_len -= len;
+		page_offset = 0;
+		page_start_vaddr += PAGE_SIZE;
+	}
+
+	seq_putc(m, ']');
+}
+
 #ifdef CONFIG_NUMA
 /*
  * These functions are for numa_maps but called in generic **maps seq_file
@@ -335,6 +385,12 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 				pad_len_spaces(m, len);
 				seq_printf(m, "[stack:%d]", tid);
 			}
+			goto done;
+		}
+
+		if (vma_get_anon_name(vma)) {
+			pad_len_spaces(m, len);
+			seq_print_vma_name(m, vma);
 		}
 	}
 
@@ -634,6 +690,12 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
 	show_smap_vma_flags(m, vma);
 
+	if (vma_get_anon_name(vma)) {
+		seq_puts(m, "Name:           ");
+		seq_print_vma_name(m, vma);
+		seq_putc(m, '\n');
+	}
+
 	if (m->count < m->size)  /* vma is copied successfully */
 		m->version = (vma != get_gate_vma(task->mm))
 			? vma->vm_start : 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bd5679d..60038ea 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1486,7 +1486,7 @@ extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
-	struct mempolicy *);
+	struct mempolicy *, const char __user *);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int split_vma(struct mm_struct *,
 	struct vm_area_struct *, unsigned long addr, int new_below);
@@ -1829,5 +1829,8 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+int madvise_set_anon_name(unsigned long start, unsigned long len_in,
+				unsigned long name_addr);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..875ba48 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -255,6 +255,10 @@ struct vm_area_struct {
 	 * For areas with an address space and backing store,
 	 * linkage into the address_space->i_mmap interval tree, or
 	 * linkage of vma in the address_space->i_mmap_nonlinear list.
+	 *
+	 * For private anonymous mappings, a pointer to a null terminated string
+	 * in the user process containing the name given to the vma, or NULL
+	 * if unnamed.
 	 */
 	union {
 		struct {
@@ -262,6 +266,7 @@ struct vm_area_struct {
 			unsigned long rb_subtree_last;
 		} linear;
 		struct list_head nonlinear;
+		const char __user *anon_name;
 	} shared;
 
 	/*
@@ -456,4 +461,14 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 	return mm->cpu_vm_mask_var;
 }
 
+
+/* Return the name for an anonymous mapping or NULL for a file-backed mapping */
+static inline const char __user *vma_get_anon_name(struct vm_area_struct *vma)
+{
+	if (vma->vm_file)
+		return NULL;
+
+	return vma->shared.anon_name;
+}
+
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index 289760f..063bf75 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -149,4 +149,7 @@
 
 #define PR_GET_TID_ADDRESS	40
 
+#define PR_SET_VMA		41
+# define PR_SET_VMA_ANON_NAME		0
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/sys.c b/kernel/sys.c
index 2bbd9a7..401852f 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2099,6 +2099,27 @@ static int prctl_get_tid_address(struct task_struct *me, int __user **tid_addr)
 }
 #endif
 
+static int prctl_set_vma(unsigned long opt, unsigned long addr,
+		unsigned long len, unsigned long arg)
+{
+	struct mm_struct *mm = current->mm;
+	int error;
+
+	down_write(&mm->mmap_sem);
+
+	switch (opt) {
+	case PR_SET_VMA_ANON_NAME:
+		error = madvise_set_anon_name(addr, len, arg);
+		break;
+	default:
+		error = -EINVAL;
+	}
+
+	up_write(&mm->mmap_sem);
+
+	return error;
+}
+
 SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -2262,6 +2283,9 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		if (arg2 || arg3 || arg4 || arg5)
 			return -EINVAL;
 		return current->no_new_privs ? 1 : 0;
+	case PR_SET_VMA:
+		error = prctl_set_vma(arg2, arg3, arg4, arg5);
+		break;
 	default:
 		error = -EINVAL;
 		break;
diff --git a/mm/madvise.c b/mm/madvise.c
index b8820fd..b2f8738 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -44,20 +44,23 @@ static int madvise_need_mmap_write(int behavior)
  */
 static int madvise_update_vma(struct vm_area_struct *vma,
 		     struct vm_area_struct **prev, unsigned long start,
-		     unsigned long end, unsigned long new_flags)
+		     unsigned long end, unsigned long new_flags,
+		     const char __user *new_anon_name)
 {
 	struct mm_struct * mm = vma->vm_mm;
 	pgoff_t pgoff;
 	int error;
 
-	if (new_flags == vma->vm_flags) {
+	if (new_flags == vma->vm_flags &&
+			new_anon_name == vma_get_anon_name(vma)) {
 		*prev = vma;
 		return 0;
 	}
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
-				vma->vm_file, pgoff, vma_policy(vma));
+				vma->vm_file, pgoff, vma_policy(vma),
+				new_anon_name);
 	if (*prev) {
 		vma = *prev;
 		goto success;
@@ -82,10 +85,30 @@ success:
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
 	vma->vm_flags = new_flags;
+	if (!vma->vm_file)
+		vma->shared.anon_name = new_anon_name;
 
 	return 0;
 }
 
+static int madvise_vma_anon_name(struct vm_area_struct *vma,
+		     struct vm_area_struct **prev,
+		     unsigned long start, unsigned long end,
+		     unsigned long name_addr)
+{
+	int error;
+
+	/* Only anonymous mappings can be named */
+	if (vma->vm_file)
+		return -EINVAL;
+
+	error = madvise_update_vma(vma, prev, start, end, vma->vm_flags,
+			(const char __user *)name_addr);
+	if (error == -ENOMEM)
+		error = -EAGAIN;
+	return error;
+}
+
 #ifdef CONFIG_SWAP
 static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 	unsigned long end, struct mm_walk *walk)
@@ -352,7 +375,8 @@ static int madvise_vma_behavior(struct vm_area_struct *vma,
 		break;
 	}
 
-	error = madvise_update_vma(vma, prev, start, end, new_flags);
+	error = madvise_update_vma(vma, prev, start, end, new_flags,
+				vma_get_anon_name(vma));
 
 out:
 	if (error == -ENOMEM)
@@ -488,6 +512,30 @@ int madvise_walk_vmas(unsigned long start, unsigned long end,
 	return unmapped_error;
 }
 
+int madvise_set_anon_name(unsigned long start, unsigned long len_in,
+		unsigned long name_addr)
+{
+	unsigned long end;
+	unsigned long len;
+
+	if (start & ~PAGE_MASK)
+		return -EINVAL;
+	len = (len_in + ~PAGE_MASK) & PAGE_MASK;
+
+	/* Check to see whether len was rounded up from small -ve to zero */
+	if (len_in && !len)
+		return -EINVAL;
+
+	end = start + len;
+	if (end < start)
+		return -EINVAL;
+
+	if (end == start)
+		return 0;
+
+	return madvise_walk_vmas(start, end, name_addr, madvise_vma_anon_name);
+}
+
 /*
  * The madvise(2) system call.
  *
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7431001..11db490 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -728,7 +728,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			((vmstart - vma->vm_start) >> PAGE_SHIFT);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
 				  vma->anon_vma, vma->vm_file, pgoff,
-				  new_pol);
+				  new_pol, vma->vm_name);
 		if (prev) {
 			vma = prev;
 			next = vma->vm_next;
diff --git a/mm/mlock.c b/mm/mlock.c
index 79b7cf7..33861c7 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -287,7 +287,8 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
-			  vma->vm_file, pgoff, vma_policy(vma));
+			  vma->vm_file, pgoff, vma_policy(vma),
+			  vma_get_anon_name(vma));
 	if (*prev) {
 		vma = *prev;
 		goto success;
diff --git a/mm/mmap.c b/mm/mmap.c
index f681e18..25abb88 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -893,7 +893,8 @@ again:			remove_next = 1 + (end > next->vm_end);
  * per-vma resources, so we don't attempt to merge those.
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
-			struct file *file, unsigned long vm_flags)
+			struct file *file, unsigned long vm_flags,
+			const char __user *anon_name)
 {
 	if (vma->vm_flags ^ vm_flags)
 		return 0;
@@ -901,6 +902,8 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 		return 0;
 	if (vma->vm_ops && vma->vm_ops->close)
 		return 0;
+	if (vma_get_anon_name(vma) != anon_name)
+		return 0;
 	return 1;
 }
 
@@ -931,9 +934,10 @@ static inline int is_mergeable_anon_vma(struct anon_vma *anon_vma1,
  */
 static int
 can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
+	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff,
+	const char __user *anon_name)
 {
-	if (is_mergeable_vma(vma, file, vm_flags) &&
+	if (is_mergeable_vma(vma, file, vm_flags, anon_name) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		if (vma->vm_pgoff == vm_pgoff)
 			return 1;
@@ -950,9 +954,10 @@ can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
  */
 static int
 can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
+	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff,
+	const char __user *anon_name)
 {
-	if (is_mergeable_vma(vma, file, vm_flags) &&
+	if (is_mergeable_vma(vma, file, vm_flags, anon_name) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		pgoff_t vm_pglen;
 		vm_pglen = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
@@ -963,9 +968,9 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
 }
 
 /*
- * Given a mapping request (addr,end,vm_flags,file,pgoff), figure out
- * whether that can be merged with its predecessor or its successor.
- * Or both (it neatly fills a hole).
+ * Given a mapping request (addr,end,vm_flags,file,pgoff,anon_name),
+ * figure out whether that can be merged with its predecessor or its
+ * successor.  Or both (it neatly fills a hole).
  *
  * In most cases - when called for mmap, brk or mremap - [addr,end) is
  * certain not to be mapped by the time vma_merge is called; but when
@@ -995,7 +1000,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,
 			unsigned long end, unsigned long vm_flags,
 		     	struct anon_vma *anon_vma, struct file *file,
-			pgoff_t pgoff, struct mempolicy *policy)
+			pgoff_t pgoff, struct mempolicy *policy,
+			const char __user *anon_name)
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
@@ -1021,15 +1027,15 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	 */
 	if (prev && prev->vm_end == addr &&
   			mpol_equal(vma_policy(prev), policy) &&
-			can_vma_merge_after(prev, vm_flags,
-						anon_vma, file, pgoff)) {
+			can_vma_merge_after(prev, vm_flags, anon_vma,
+						file, pgoff, anon_name)) {
 		/*
 		 * OK, it can.  Can we now merge in the successor as well?
 		 */
 		if (next && end == next->vm_start &&
 				mpol_equal(policy, vma_policy(next)) &&
-				can_vma_merge_before(next, vm_flags,
-					anon_vma, file, pgoff+pglen) &&
+				can_vma_merge_before(next, vm_flags, anon_vma,
+						file, pgoff+pglen, anon_name) &&
 				is_mergeable_anon_vma(prev->anon_vma,
 						      next->anon_vma, NULL)) {
 							/* cases 1, 6 */
@@ -1049,8 +1055,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	 */
 	if (next && end == next->vm_start &&
  			mpol_equal(policy, vma_policy(next)) &&
-			can_vma_merge_before(next, vm_flags,
-					anon_vma, file, pgoff+pglen)) {
+			can_vma_merge_before(next, vm_flags, anon_vma,
+					file, pgoff+pglen, anon_name)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
 			err = vma_adjust(prev, prev->vm_start,
 				addr, prev->vm_pgoff, NULL);
@@ -1519,7 +1525,8 @@ munmap_back:
 	/*
 	 * Can we just expand an old mapping?
 	 */
-	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff, NULL);
+	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff,
+			NULL, NULL);
 	if (vma)
 		goto out;
 
@@ -2663,7 +2670,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 
 	/* Can we just expand an old private anonymous mapping? */
 	vma = vma_merge(mm, prev, addr, addr + len, flags,
-					NULL, NULL, pgoff, NULL);
+					NULL, NULL, pgoff, NULL, NULL);
 	if (vma)
 		goto out;
 
@@ -2821,7 +2828,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
 		return NULL;	/* should never get here */
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
+			vma_get_anon_name(vma));
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 94722a4..94d50b7 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -271,7 +271,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 */
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*pprev = vma_merge(mm, *pprev, start, end, newflags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
+			vma_get_anon_name(vma));
 	if (*pprev) {
 		vma = *pprev;
 		goto success;
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
