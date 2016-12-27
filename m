Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 279E56B0273
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:53 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so776892261pgi.2
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:53 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id r7si44810019ple.282.2016.12.26.17.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Date: Tue, 27 Dec 2016 04:54:13 +0300
Message-Id: <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

This patch introduces new rlimit resource to manage maximum virtual
address available to userspace to map.

On x86, 5-level paging enables 56-bit userspace virtual address space.
Not all user space is ready to handle wide addresses. It's known that
at least some JIT compilers use high bit in pointers to encode their
information. It collides with valid pointers with 5-level paging and
leads to crashes.

The patch aims to address this compatibility issue.

MM would use min(RLIMIT_VADDR, TASK_SIZE) as upper limit of virtual
address available to map by userspace.

The default hard limit will be RLIM_INFINITY, which basically means that
TASK_SIZE limits available address space.

The soft limit will also be RLIM_INFINITY everywhere, but the machine
with 5-level paging enabled. In this case, soft limit would be
(1UL << 47) - PAGE_SIZE. Ita??s current x86-64 TASK_SIZE_MAX with 4-level
paging which known to be safe

New rlimit resource would follow usual semantics with regards to
inheritance: preserved on fork(2) and exec(2). This has potential to
break application if limits set too wide or too narrow, but this is not
uncommon for other resources (consider RLIMIT_DATA or RLIMIT_AS).

As with other resources you can set the limit lower than current usage.
It would affect only future virtual address space allocations.

Use-cases for new rlimit:

  - Bumping the soft limit to RLIM_INFINITY, allows current process all
    its children to use addresses above 47-bits.

  - Bumping the soft limit to RLIM_INFINITY after fork(2), but before
    exec(2) allows the child to use addresses above 47-bits.

  - Lowering the hard limit to 47-bits would prevent current process all
    its children to use addresses above 47-bits, unless a process has
    CAP_SYS_RESOURCES.

  - Ita??s also can be handy to lower hard or soft limit to arbitrary
    address. User-mode emulation in QEMU may lower the limit to 32-bit
    to emulate 32-bit machine on 64-bit host.

TODO:
  - port to non-x86;

Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: linux-api@vger.kernel.org
---
 arch/x86/include/asm/elf.h          |  2 +-
 arch/x86/include/asm/processor.h    | 17 ++++++++++++-----
 arch/x86/kernel/sys_x86_64.c        |  6 +++---
 arch/x86/mm/hugetlbpage.c           |  8 ++++----
 arch/x86/mm/mmap.c                  |  4 ++--
 fs/binfmt_aout.c                    |  2 --
 fs/binfmt_elf.c                     | 10 +++++-----
 fs/hugetlbfs/inode.c                |  6 +++---
 fs/proc/base.c                      |  1 +
 include/asm-generic/resource.h      |  4 ++++
 include/linux/sched.h               |  5 +++++
 include/uapi/asm-generic/resource.h |  3 ++-
 kernel/events/uprobes.c             |  5 +++--
 kernel/sys.c                        |  6 +++---
 mm/mmap.c                           | 20 +++++++++++---------
 mm/mremap.c                         |  3 ++-
 mm/nommu.c                          |  2 +-
 mm/shmem.c                          |  8 ++++----
 18 files changed, 66 insertions(+), 46 deletions(-)

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
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index eaf100508c36..e02917126859 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -770,8 +770,8 @@ static inline void spin_lock_prefetch(const void *x)
  */
 #define TASK_SIZE		PAGE_OFFSET
 #define TASK_SIZE_MAX		TASK_SIZE
-#define STACK_TOP		TASK_SIZE
-#define STACK_TOP_MAX		STACK_TOP
+#define STACK_TOP		mmap_max_addr()
+#define STACK_TOP_MAX		TASK_SIZE
 
 #define INIT_THREAD  {							  \
 	.sp0			= TOP_OF_INIT_STACK,			  \
@@ -809,7 +809,14 @@ static inline void spin_lock_prefetch(const void *x)
  * particular problem by preventing anything from being mapped
  * at the maximum canonical address.
  */
-#define TASK_SIZE_MAX	((1UL << 47) - PAGE_SIZE)
+#define TASK_SIZE_MAX	((1UL << __VIRTUAL_MASK_SHIFT) - PAGE_SIZE)
+
+/*
+ * Default limit on maximum virtual address. This is required for
+ * compatibility with applications that assumes 47-bit VA.
+ * The limit be overrided with setrlimit(2).
+ */
+#define USER_VADDR_LIM	((1UL << 47) - PAGE_SIZE)
 
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
@@ -822,7 +829,7 @@ static inline void spin_lock_prefetch(const void *x)
 #define TASK_SIZE_OF(child)	((test_tsk_thread_flag(child, TIF_ADDR32)) ? \
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 
-#define STACK_TOP		TASK_SIZE
+#define STACK_TOP		mmap_max_addr()
 #define STACK_TOP_MAX		TASK_SIZE_MAX
 
 #define INIT_THREAD  {						\
@@ -844,7 +851,7 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(mmap_max_addr() / 3))
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
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
index 29a02daf08a9..1f8034aed298 100644
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
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 8e7e61b28f31..b91247cd171d 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -594,6 +594,7 @@ static const struct limit_names lnames[RLIM_NLIMITS] = {
 	[RLIMIT_NICE] = {"Max nice priority", NULL},
 	[RLIMIT_RTPRIO] = {"Max realtime priority", NULL},
 	[RLIMIT_RTTIME] = {"Max realtime timeout", "us"},
+	[RLIMIT_VADDR] = {"Max virtual address", NULL},
 };
 
 /* Display limits for a process */
diff --git a/include/asm-generic/resource.h b/include/asm-generic/resource.h
index 5e752b959054..d24c978103e5 100644
--- a/include/asm-generic/resource.h
+++ b/include/asm-generic/resource.h
@@ -3,6 +3,9 @@
 
 #include <uapi/asm-generic/resource.h>
 
+#ifndef USER_VADDR_LIM
+#define USER_VADDR_LIM RLIM_INFINITY
+#endif
 
 /*
  * boot-time rlimit defaults for the init task:
@@ -25,6 +28,7 @@
 	[RLIMIT_NICE]		= { 0, 0 },				\
 	[RLIMIT_RTPRIO]		= { 0, 0 },				\
 	[RLIMIT_RTTIME]		= {  RLIM_INFINITY,  RLIM_INFINITY },	\
+	[RLIMIT_VADDR]		= { USER_VADDR_LIM,  RLIM_INFINITY },   \
 }
 
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4d1905245c7a..f0f23afe0838 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3661,4 +3661,9 @@ void cpufreq_add_update_util_hook(int cpu, struct update_util_data *data,
 void cpufreq_remove_update_util_hook(int cpu);
 #endif /* CONFIG_CPU_FREQ */
 
+static inline unsigned long mmap_max_addr(void)
+{
+	return min(TASK_SIZE, rlimit(RLIMIT_VADDR));
+}
+
 #endif
diff --git a/include/uapi/asm-generic/resource.h b/include/uapi/asm-generic/resource.h
index c6d10af50123..7843ed0ed7a7 100644
--- a/include/uapi/asm-generic/resource.h
+++ b/include/uapi/asm-generic/resource.h
@@ -45,7 +45,8 @@
 					   0-39 for nice level 19 .. -20 */
 #define RLIMIT_RTPRIO		14	/* maximum realtime priority */
 #define RLIMIT_RTTIME		15	/* timeout for RT tasks in us */
-#define RLIM_NLIMITS		16
+#define RLIMIT_VADDR		16	/* maximum virtual address */
+#define RLIM_NLIMITS		17
 
 /*
  * SuS says limits have to be unsigned.
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
index 842914ef7de4..a5ee7f23beda 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1718,7 +1718,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
  */
 static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 {
-	unsigned long mmap_max_addr = TASK_SIZE;
+	unsigned long max_addr = mmap_max_addr();
 	struct mm_struct *mm = current->mm;
 	int error = -EINVAL, i;
 
@@ -1743,7 +1743,7 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
 	for (i = 0; i < ARRAY_SIZE(offsets); i++) {
 		u64 val = *(u64 *)((char *)prctl_map + offsets[i]);
 
-		if ((unsigned long)val >= mmap_max_addr ||
+		if ((unsigned long)val >= max_addr ||
 		    (unsigned long)val < mmap_min_addr)
 			goto out;
 	}
@@ -1949,7 +1949,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	if (opt == PR_SET_MM_AUXV)
 		return prctl_set_auxv(mm, addr, arg4);
 
-	if (addr >= TASK_SIZE || addr < mmap_min_addr)
+	if (addr >= mmap_max_addr() || addr < mmap_min_addr)
 		return -EINVAL;
 
 	error = -EINVAL;
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
index bb53285a1d99..3c9be716083f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1976,7 +1976,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 	unsigned long inflated_addr;
 	unsigned long inflated_offset;
 
-	if (len > TASK_SIZE)
+	if (len > mmap_max_addr())
 		return -ENOMEM;
 
 	get_area = current->mm->get_unmapped_area;
@@ -1988,7 +1988,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 		return addr;
 	if (addr & ~PAGE_MASK)
 		return addr;
-	if (addr > TASK_SIZE - len)
+	if (addr > mmap_max_addr() - len)
 		return addr;
 
 	if (shmem_huge == SHMEM_HUGE_DENY)
@@ -2031,7 +2031,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 		return addr;
 
 	inflated_len = len + HPAGE_PMD_SIZE - PAGE_SIZE;
-	if (inflated_len > TASK_SIZE)
+	if (inflated_len > mmap_max_addr())
 		return addr;
 	if (inflated_len < len)
 		return addr;
@@ -2047,7 +2047,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
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
