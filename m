Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96EE54405E1
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:14:10 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e4so60672725pfg.4
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:14:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e11si10355979pgp.351.2017.02.17.06.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 06:14:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Date: Fri, 17 Feb 2017 17:13:28 +0300
Message-Id: <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-api@vger.kernel.org

This patch introduces two new prctl(2) handles to manage maximum virtual
address available to userspace to map.

On x86, 5-level paging enables 56-bit userspace virtual address space.
Not all user space is ready to handle wide addresses. It's known that
at least some JIT compilers use higher bits in pointers to encode their
information. It collides with valid pointers with 5-level paging and
leads to crashes.

The patch aims to address this compatibility issue.

MM would use the address as upper limit of virtual address available to
map by userspace, instead of TASK_SIZE.

The limit will be equal to TASK_SIZE everywhere, but the machine
with 5-level paging enabled. In this case, the default limit would be
(1UL << 47) - PAGE_SIZE. Ita??s current x86-64 TASK_SIZE_MAX with 4-level
paging which known to be safe.

Changing the limit would affect only future virtual address space
allocations. Currently existing VMAs are intact.

MPX can't at the moment handle addresses above 47-bits, so we refuse to
increase the limit above 47-bits. We also refuse to enable MPX if the
limit is already above 47-bits or if there is a VMA above the 47-bit
boundary.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-api@vger.kernel.org
---
 arch/x86/include/asm/elf.h         |  2 +-
 arch/x86/include/asm/mmu.h         |  2 ++
 arch/x86/include/asm/mmu_context.h |  1 +
 arch/x86/include/asm/processor.h   | 25 ++++++++++++++++++++-----
 arch/x86/kernel/process.c          | 18 ++++++++++++++++++
 arch/x86/kernel/sys_x86_64.c       |  6 +++---
 arch/x86/mm/hugetlbpage.c          |  8 ++++----
 arch/x86/mm/mmap.c                 |  4 ++--
 arch/x86/mm/mpx.c                  | 17 ++++++++++++++++-
 fs/binfmt_aout.c                   |  2 --
 fs/binfmt_elf.c                    | 10 +++++-----
 fs/hugetlbfs/inode.c               |  6 +++---
 include/linux/sched.h              |  8 ++++++++
 include/uapi/linux/prctl.h         |  3 +++
 kernel/events/uprobes.c            |  5 +++--
 kernel/sys.c                       | 23 ++++++++++++++++++++---
 mm/mmap.c                          | 20 +++++++++++---------
 mm/mremap.c                        |  3 ++-
 mm/nommu.c                         |  2 +-
 mm/shmem.c                         |  8 ++++----
 20 files changed, 127 insertions(+), 46 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index e7f155c3045e..5ce6f2b2b105 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -250,7 +250,7 @@ extern int force_personality32;
    the loader.  We need to make sure that it is out of the way of the program
    that it will "exec", and that there is sufficient room for the brk.  */
 
-#define ELF_ET_DYN_BASE		(TASK_SIZE / 3 * 2)
+#define ELF_ET_DYN_BASE		(mmap_max_addr() / 3 * 2)
 
 /* This yields a mask that user programs can use to figure out what
    instruction set this CPU supports.  This could be done in user space,
diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index f9813b6d8b80..174dc3b60165 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -35,6 +35,8 @@ typedef struct {
 	/* address of the bounds directory */
 	void __user *bd_addr;
 #endif
+	/* maximum virtual address the process can create VMA at */
+	unsigned long max_vaddr;
 } mm_context_t;
 
 #ifdef CONFIG_SMP
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 306c7e12af55..50bdfd6ab866 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -117,6 +117,7 @@ static inline int init_new_context(struct task_struct *tsk,
 	}
 	#endif
 	init_new_context_ldt(tsk, mm);
+	mm->context.max_vaddr = MAX_VADDR_DEFAULT;
 
 	return 0;
 }
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index e6cfe7ba2d65..173f9a6b3b6b 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -789,8 +789,9 @@ static inline void spin_lock_prefetch(const void *x)
  */
 #define TASK_SIZE		PAGE_OFFSET
 #define TASK_SIZE_MAX		TASK_SIZE
-#define STACK_TOP		TASK_SIZE
-#define STACK_TOP_MAX		STACK_TOP
+#define MAX_VADDR_DEFAULT	TASK_SIZE
+#define STACK_TOP		mmap_max_addr()
+#define STACK_TOP_MAX		TASK_SIZE
 
 #define INIT_THREAD  {							  \
 	.sp0			= TOP_OF_INIT_STACK,			  \
@@ -828,7 +829,14 @@ static inline void spin_lock_prefetch(const void *x)
  * particular problem by preventing anything from being mapped
  * at the maximum canonical address.
  */
-#define TASK_SIZE_MAX	((1UL << 47) - PAGE_SIZE)
+#define TASK_SIZE_MAX	((1UL << __VIRTUAL_MASK_SHIFT) - PAGE_SIZE)
+
+/*
+ * Default maximum virtual address. This is required for
+ * compatibility with applications that assumes 47-bit VA.
+ * The limit can be changed with prctl(PR_SET_MAX_VADDR).
+ */
+#define MAX_VADDR_DEFAULT	((1UL << 47) - PAGE_SIZE)
 
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
@@ -841,7 +849,7 @@ static inline void spin_lock_prefetch(const void *x)
 #define TASK_SIZE_OF(child)	((test_tsk_thread_flag(child, TIF_ADDR32)) ? \
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 
-#define STACK_TOP		TASK_SIZE
+#define STACK_TOP		mmap_max_addr()
 #define STACK_TOP_MAX		TASK_SIZE_MAX
 
 #define INIT_THREAD  {						\
@@ -863,7 +871,7 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(mmap_max_addr() / 3))
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
@@ -892,6 +900,13 @@ static inline int mpx_disable_management(void)
 }
 #endif /* CONFIG_X86_INTEL_MPX */
 
+extern unsigned long set_max_vaddr(unsigned long addr);
+
+#define SET_MAX_VADDR(addr)	set_max_vaddr(addr)
+#define GET_MAX_VADDR()		READ_ONCE(current->mm->context.max_vaddr)
+
+#define mmap_max_addr() min(TASK_SIZE, GET_MAX_VADDR())
+
 extern u16 amd_get_nb_id(int cpu);
 extern u32 amd_get_nodes_per_socket(void);
 
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index b615a1113f58..ddc5af35f146 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -32,6 +32,7 @@
 #include <asm/mce.h>
 #include <asm/vm86.h>
 #include <asm/switch_to.h>
+#include <asm/mpx.h>
 
 /*
  * per-CPU TSS segments. Threads are completely 'soft' on Linux,
@@ -536,3 +537,20 @@ unsigned long get_wchan(struct task_struct *p)
 	put_task_stack(p);
 	return ret;
 }
+
+unsigned long set_max_vaddr(unsigned long addr)
+{
+	down_write(&current->mm->mmap_sem);
+	if (addr > TASK_SIZE_MAX)
+		goto out;
+	/*
+	 * MPX cannot handle addresses above 47-bits. Refuse to increase
+	 * max_vaddr above the limit if MPX is enabled.
+	 */
+	if (addr > MAX_VADDR_DEFAULT && kernel_managing_mpx_tables(current->mm))
+		goto out;
+	current->mm->context.max_vaddr = addr;
+out:
+	up_write(&current->mm->mmap_sem);
+	return 0;
+}
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index a55ed63b9f91..e31f5b0c5468 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -115,7 +115,7 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 		}
 	} else {
 		*begin = current->mm->mmap_legacy_base;
-		*end = TASK_SIZE;
+		*end = mmap_max_addr();
 	}
 }
 
@@ -168,7 +168,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	struct vm_unmapped_area_info info;
 
 	/* requested length too big for entire address space */
-	if (len > TASK_SIZE)
+	if (len > mmap_max_addr())
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED)
@@ -182,7 +182,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
+		if (mmap_max_addr() - len >= addr &&
 				(!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 2ae8584b44c7..b55b04b82097 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -82,7 +82,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = current->mm->mmap_legacy_base;
-	info.high_limit = TASK_SIZE;
+	info.high_limit = mmap_max_addr();
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	return vm_unmapped_area(&info);
@@ -114,7 +114,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
-		info.high_limit = TASK_SIZE;
+		info.high_limit = mmap_max_addr();
 		addr = vm_unmapped_area(&info);
 	}
 
@@ -131,7 +131,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 
 	if (len & ~huge_page_mask(h))
 		return -EINVAL;
-	if (len > TASK_SIZE)
+	if (len > mmap_max_addr())
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED) {
@@ -143,7 +143,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	if (addr) {
 		addr = ALIGN(addr, huge_page_size(h));
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
+		if (mmap_max_addr() - len >= addr &&
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index d2dc0438d654..c22f0b802576 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -52,7 +52,7 @@ static unsigned long stack_maxrandom_size(void)
  * Leave an at least ~128 MB hole with possible stack randomization.
  */
 #define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
-#define MAX_GAP (TASK_SIZE/6*5)
+#define MAX_GAP (mmap_max_addr()/6*5)
 
 static int mmap_is_legacy(void)
 {
@@ -90,7 +90,7 @@ static unsigned long mmap_base(unsigned long rnd)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(mmap_max_addr() - gap - rnd);
 }
 
 /*
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index af59f808742f..c19707d3e104 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -354,10 +354,25 @@ int mpx_enable_management(void)
 	 */
 	bd_base = mpx_get_bounds_dir();
 	down_write(&mm->mmap_sem);
+
+	/*
+	 * MPX doesn't support addresses above 47-bits yes.
+	 * Make sure it's not allowed to map above the limit and nothing is
+	 * mapped there before enabling.
+	 */
+	if (mmap_max_addr() > MAX_VADDR_DEFAULT ||
+			find_vma(mm, MAX_VADDR_DEFAULT)) {
+		pr_warn_once("%s (%d): MPX cannot handle addresses "
+				"above 47-bits. Disabling.",
+				current->comm, current->pid);
+		ret = -ENXIO;
+		goto out;
+	}
+
 	mm->context.bd_addr = bd_base;
 	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
 		ret = -ENXIO;
-
+out:
 	up_write(&mm->mmap_sem);
 	return ret;
 }
diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index 2a59139f520b..7a7f6dba6b00 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -121,8 +121,6 @@ static struct linux_binfmt aout_format = {
 	.min_coredump	= PAGE_SIZE
 };
 
-#define BAD_ADDR(x)	((unsigned long)(x) >= TASK_SIZE)
-
 static int set_brk(unsigned long start, unsigned long end)
 {
 	start = PAGE_ALIGN(start);
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 422370293cfd..b5dbea735c6d 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -89,7 +89,7 @@ static struct linux_binfmt elf_format = {
 	.min_coredump	= ELF_EXEC_PAGESIZE,
 };
 
-#define BAD_ADDR(x) ((unsigned long)(x) >= TASK_SIZE)
+#define BAD_ADDR(x) ((unsigned long)(x) >= mmap_max_addr())
 
 static int set_brk(unsigned long start, unsigned long end)
 {
@@ -587,8 +587,8 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
 			k = load_addr + eppnt->p_vaddr;
 			if (BAD_ADDR(k) ||
 			    eppnt->p_filesz > eppnt->p_memsz ||
-			    eppnt->p_memsz > TASK_SIZE ||
-			    TASK_SIZE - eppnt->p_memsz < k) {
+			    eppnt->p_memsz > mmap_max_addr() ||
+			    mmap_max_addr() - eppnt->p_memsz < k) {
 				error = -ENOMEM;
 				goto out;
 			}
@@ -960,8 +960,8 @@ static int load_elf_binary(struct linux_binprm *bprm)
 		 * <= p_memsz so it is only necessary to check p_memsz.
 		 */
 		if (BAD_ADDR(k) || elf_ppnt->p_filesz > elf_ppnt->p_memsz ||
-		    elf_ppnt->p_memsz > TASK_SIZE ||
-		    TASK_SIZE - elf_ppnt->p_memsz < k) {
+		    elf_ppnt->p_memsz > mmap_max_addr() ||
+		    mmap_max_addr() - elf_ppnt->p_memsz < k) {
 			/* set_brk can never work. Avoid overflows. */
 			retval = -EINVAL;
 			goto out_free_dentry;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 54de77e78775..e132e93b85fb 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -178,7 +178,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 
 	if (len & ~huge_page_mask(h))
 		return -EINVAL;
-	if (len > TASK_SIZE)
+	if (len > mmap_max_addr())
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED) {
@@ -190,7 +190,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	if (addr) {
 		addr = ALIGN(addr, huge_page_size(h));
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
+		if (mmap_max_addr() - len >= addr &&
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
@@ -198,7 +198,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = TASK_UNMAPPED_BASE;
-	info.high_limit = TASK_SIZE;
+	info.high_limit = mmap_max_addr();
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	return vm_unmapped_area(&info);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ad3ec9ec61f7..bf47a62fde5d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3671,4 +3671,12 @@ void cpufreq_add_update_util_hook(int cpu, struct update_util_data *data,
 void cpufreq_remove_update_util_hook(int cpu);
 #endif /* CONFIG_CPU_FREQ */
 
+#ifndef mmap_max_addr
+#define mmap_max_addr mmap_max_addr
+static inline unsigned long mmap_max_addr(void)
+{
+	return TASK_SIZE;
+}
+#endif
+
 #endif
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759a9e40..e9478ccd4386 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,7 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+#define PR_SET_MAX_VADDR	48
+#define PR_GET_MAX_VADDR	49
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index d416f3baf392..651f571a1a79 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1142,8 +1142,9 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 
 	if (!area->vaddr) {
 		/* Try to map as high as possible, this is only a hint. */
-		area->vaddr = get_unmapped_area(NULL, TASK_SIZE - PAGE_SIZE,
-						PAGE_SIZE, 0, 0);
+		area->vaddr = get_unmapped_area(NULL,
+				mmap_max_addr() - PAGE_SIZE,
+				PAGE_SIZE, 0, 0);
 		if (area->vaddr & ~PAGE_MASK) {
 			ret = area->vaddr;
 			goto fail;
diff --git a/kernel/sys.c b/kernel/sys.c
index 842914ef7de4..366ba7be92a7 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -103,6 +103,12 @@
 #ifndef SET_FP_MODE
 # define SET_FP_MODE(a,b)	(-EINVAL)
 #endif
+#ifndef SET_MAX_VADDR
+# define SET_MAX_VADDR(a)	(-EINVAL)
+#endif
+#ifndef GET_MAX_VADDR
+# define GET_MAX_VADDR()	(-EINVAL)
+#endif
 
 /*
  * this is where the system-wide overflow UID and GID are defined, for
@@ -1718,7 +1724,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
  */
 static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 {
-	unsigned long mmap_max_addr = TASK_SIZE;
+	unsigned long max_addr = mmap_max_addr();
 	struct mm_struct *mm = current->mm;
 	int error = -EINVAL, i;
 
@@ -1743,7 +1749,7 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 	for (i = 0; i < ARRAY_SIZE(offsets); i++) {
 		u64 val = *(u64 *)((char *)prctl_map + offsets[i]);
 
-		if ((unsigned long)val >= mmap_max_addr ||
+		if ((unsigned long)val >= max_addr ||
 		    (unsigned long)val < mmap_min_addr)
 			goto out;
 	}
@@ -1949,7 +1955,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	if (opt == PR_SET_MM_AUXV)
 		return prctl_set_auxv(mm, addr, arg4);
 
-	if (addr >= TASK_SIZE || addr < mmap_min_addr)
+	if (addr >= mmap_max_addr() || addr < mmap_min_addr)
 		return -EINVAL;
 
 	error = -EINVAL;
@@ -2261,6 +2267,17 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_FP_MODE:
 		error = GET_FP_MODE(me);
 		break;
+	case PR_SET_MAX_VADDR:
+		if (arg3 || arg4 || arg5)
+			return -EINVAL;
+		error = SET_MAX_VADDR(arg2);
+		break;
+	case PR_GET_MAX_VADDR:
+		if (arg3 || arg4 || arg5)
+			return -EINVAL;
+		error = put_user(GET_MAX_VADDR(),
+				(unsigned long __user *) arg2);
+		break;
 	default:
 		error = -EINVAL;
 		break;
diff --git a/mm/mmap.c b/mm/mmap.c
index dc4291dcc99b..a3384f23359e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1966,7 +1966,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	struct vm_area_struct *vma;
 	struct vm_unmapped_area_info info;
 
-	if (len > TASK_SIZE - mmap_min_addr)
+	if (len > mmap_max_addr() - mmap_min_addr)
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED)
@@ -1975,15 +1975,16 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr && addr >= mmap_min_addr &&
-		    (!vma || addr + len <= vma->vm_start))
+		if (mmap_max_addr() - len >= addr &&
+				addr >= mmap_min_addr &&
+				(!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
 
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = mm->mmap_base;
-	info.high_limit = TASK_SIZE;
+	info.high_limit = mmap_max_addr();
 	info.align_mask = 0;
 	return vm_unmapped_area(&info);
 }
@@ -2005,7 +2006,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	struct vm_unmapped_area_info info;
 
 	/* requested length too big for entire address space */
-	if (len > TASK_SIZE - mmap_min_addr)
+	if (len > mmap_max_addr() - mmap_min_addr)
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED)
@@ -2015,7 +2016,8 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr && addr >= mmap_min_addr &&
+		if (mmap_max_addr() - len >= addr &&
+				addr >= mmap_min_addr &&
 				(!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
@@ -2037,7 +2039,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
-		info.high_limit = TASK_SIZE;
+		info.high_limit = mmap_max_addr();
 		addr = vm_unmapped_area(&info);
 	}
 
@@ -2057,7 +2059,7 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 		return error;
 
 	/* Careful about overflows.. */
-	if (len > TASK_SIZE)
+	if (len > mmap_max_addr())
 		return -ENOMEM;
 
 	get_area = current->mm->get_unmapped_area;
@@ -2078,7 +2080,7 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 	if (IS_ERR_VALUE(addr))
 		return addr;
 
-	if (addr > TASK_SIZE - len)
+	if (addr > mmap_max_addr() - len)
 		return -ENOMEM;
 	if (offset_in_page(addr))
 		return -EINVAL;
diff --git a/mm/mremap.c b/mm/mremap.c
index 2b3bfcd51c75..a8b4fba3dce6 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -433,7 +433,8 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (offset_in_page(new_addr))
 		goto out;
 
-	if (new_len > TASK_SIZE || new_addr > TASK_SIZE - new_len)
+	if (new_len > mmap_max_addr() ||
+			new_addr > mmap_max_addr() - new_len)
 		goto out;
 
 	/* Ensure the old/new locations do not overlap */
diff --git a/mm/nommu.c b/mm/nommu.c
index 24f9f5f39145..6043b8b82083 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -905,7 +905,7 @@ static int validate_mmap_request(struct file *file,
 
 	/* Careful about overflows.. */
 	rlen = PAGE_ALIGN(len);
-	if (!rlen || rlen > TASK_SIZE)
+	if (!rlen || rlen > mmap_max_addr())
 		return -ENOMEM;
 
 	/* offset overflow? */
diff --git a/mm/shmem.c b/mm/shmem.c
index 3a7587a0314d..54d1ebfb577d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1983,7 +1983,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 	unsigned long inflated_addr;
 	unsigned long inflated_offset;
 
-	if (len > TASK_SIZE)
+	if (len > mmap_max_addr())
 		return -ENOMEM;
 
 	get_area = current->mm->get_unmapped_area;
@@ -1995,7 +1995,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 		return addr;
 	if (addr & ~PAGE_MASK)
 		return addr;
-	if (addr > TASK_SIZE - len)
+	if (addr > mmap_max_addr() - len)
 		return addr;
 
 	if (shmem_huge == SHMEM_HUGE_DENY)
@@ -2038,7 +2038,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 		return addr;
 
 	inflated_len = len + HPAGE_PMD_SIZE - PAGE_SIZE;
-	if (inflated_len > TASK_SIZE)
+	if (inflated_len > mmap_max_addr())
 		return addr;
 	if (inflated_len < len)
 		return addr;
@@ -2054,7 +2054,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 	if (inflated_offset > offset)
 		inflated_addr += HPAGE_PMD_SIZE;
 
-	if (inflated_addr > TASK_SIZE - len)
+	if (inflated_addr > mmap_max_addr() - len)
 		return addr;
 	return inflated_addr;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
