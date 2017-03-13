Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 129BF6B0397
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:14:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n11so15928218wma.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:14:41 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 04/13] mm: Add mm_struct argument to 'get_unmapped_area' and 'vm_unmapped_area'
Date: Mon, 13 Mar 2017 15:14:06 -0700
Message-Id: <20170313221415.9375-5-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

Add the mm_struct that for which an unmapped area should be found as
explicit argument to the 'get_unmapped_area' function. Previously, the
function simply search for an unmapped area in the memory map of the
 current task. However, with the introduction of first class virtual
address spaces, it is necessary that get_unmapped_area also can look for
unmapped area in memory maps other than the one of the current task.

Changing the signature of the generic 'get_unmapped_area' function also
requires that all the 'arch_get_unmapped_area' functions as well as the
'vm_unmapped_area' function with its dependents have to take the memory
map that they should work on as additional argument. Simply using the one
of the current task, as these functions did before, is not correct anymore
and leads to incorrect results.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
---
 arch/alpha/kernel/osf_sys.c                  | 19 ++++++------
 arch/arc/mm/mmap.c                           |  8 ++---
 arch/arm/kernel/process.c                    |  2 +-
 arch/arm/mm/mmap.c                           | 19 ++++++------
 arch/arm64/kernel/vdso.c                     |  2 +-
 arch/blackfin/include/asm/pgtable.h          |  3 +-
 arch/blackfin/kernel/sys_bfin.c              |  5 ++--
 arch/frv/mm/elf-fdpic.c                      | 11 +++----
 arch/hexagon/kernel/vdso.c                   |  2 +-
 arch/ia64/kernel/perfmon.c                   |  3 +-
 arch/ia64/kernel/sys_ia64.c                  |  6 ++--
 arch/ia64/mm/hugetlbpage.c                   |  7 +++--
 arch/metag/mm/hugetlbpage.c                  | 11 +++----
 arch/mips/kernel/vdso.c                      |  2 +-
 arch/mips/mm/mmap.c                          | 27 +++++++++--------
 arch/parisc/kernel/sys_parisc.c              | 19 ++++++------
 arch/parisc/mm/hugetlbpage.c                 |  7 +++--
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  6 ++--
 arch/powerpc/include/asm/page_64.h           |  3 +-
 arch/powerpc/kernel/vdso.c                   |  2 +-
 arch/powerpc/mm/hugetlbpage-radix.c          |  9 +++---
 arch/powerpc/mm/hugetlbpage.c                |  9 +++---
 arch/powerpc/mm/mmap.c                       | 17 +++++------
 arch/powerpc/mm/slice.c                      | 25 ++++++++--------
 arch/s390/kernel/vdso.c                      |  3 +-
 arch/s390/mm/mmap.c                          | 42 +++++++++++++-------------
 arch/sh/kernel/vsyscall/vsyscall.c           |  2 +-
 arch/sh/mm/mmap.c                            | 19 ++++++------
 arch/sparc/include/asm/pgtable_64.h          |  4 +--
 arch/sparc/kernel/sys_sparc_32.c             |  6 ++--
 arch/sparc/kernel/sys_sparc_64.c             | 31 +++++++++++---------
 arch/sparc/mm/hugetlbpage.c                  | 26 ++++++++--------
 arch/tile/kernel/vdso.c                      |  2 +-
 arch/tile/mm/hugetlbpage.c                   | 26 ++++++++--------
 arch/x86/entry/vdso/vma.c                    |  2 +-
 arch/x86/kernel/sys_x86_64.c                 | 19 ++++++------
 arch/x86/mm/hugetlbpage.c                    | 26 ++++++++--------
 arch/xtensa/kernel/syscall.c                 |  7 +++--
 drivers/char/mem.c                           | 15 ++++++----
 drivers/dax/dax.c                            | 10 +++----
 drivers/media/usb/uvc/uvc_v4l2.c             |  6 ++--
 drivers/media/v4l2-core/v4l2-dev.c           |  8 ++---
 drivers/media/v4l2-core/videobuf2-v4l2.c     |  5 ++--
 drivers/mtd/mtdchar.c                        |  3 +-
 drivers/usb/gadget/function/uvc_v4l2.c       |  3 +-
 fs/hugetlbfs/inode.c                         |  8 ++---
 fs/proc/inode.c                              | 10 +++----
 fs/ramfs/file-mmu.c                          |  5 ++--
 fs/ramfs/file-nommu.c                        | 10 ++++---
 fs/romfs/mmap-nommu.c                        |  3 +-
 include/linux/fs.h                           |  2 +-
 include/linux/huge_mm.h                      |  6 ++--
 include/linux/hugetlb.h                      |  5 ++--
 include/linux/mm.h                           | 16 ++++++----
 include/linux/mm_types.h                     |  7 +++--
 include/linux/sched.h                        | 10 +++----
 include/linux/shmem_fs.h                     |  5 ++--
 include/media/v4l2-dev.h                     |  3 +-
 include/media/videobuf2-v4l2.h               |  5 ++--
 ipc/shm.c                                    | 10 +++----
 kernel/events/uprobes.c                      |  2 +-
 mm/huge_memory.c                             | 18 +++++++-----
 mm/mmap.c                                    | 44 ++++++++++++++--------------
 mm/mremap.c                                  | 11 +++----
 mm/nommu.c                                   | 10 ++++---
 mm/shmem.c                                   | 14 ++++-----
 sound/core/pcm_native.c                      |  3 +-
 67 files changed, 370 insertions(+), 326 deletions(-)

diff --git a/arch/alpha/kernel/osf_sys.c b/arch/alpha/kernel/osf_sys.c
index 54d8616644e2..281109bcdc5d 100644
--- a/arch/alpha/kernel/osf_sys.c
+++ b/arch/alpha/kernel/osf_sys.c
@@ -1308,8 +1308,8 @@ SYSCALL_DEFINE1(old_adjtimex, struct timex32 __user *, txc_p)
    generic version except that we know how to honor ADDR_LIMIT_32BIT.  */
 
 static unsigned long
-arch_get_unmapped_area_1(unsigned long addr, unsigned long len,
-		         unsigned long limit)
+arch_get_unmapped_area_1(struct mm_struct *mm, unsigned long addr,
+			 unsigned long len, unsigned long limit)
 {
 	struct vm_unmapped_area_info info;
 
@@ -1319,13 +1319,13 @@ arch_get_unmapped_area_1(unsigned long addr, unsigned long len,
 	info.high_limit = limit;
 	info.align_mask = 0;
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 unsigned long
-arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		       unsigned long len, unsigned long pgoff,
-		       unsigned long flags)
+arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		       unsigned long addr, unsigned long len,
+		       unsigned long pgoff, unsigned long flags)
 {
 	unsigned long limit;
 
@@ -1352,19 +1352,20 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	   this feature should be incorporated into all ports?  */
 
 	if (addr) {
-		addr = arch_get_unmapped_area_1 (PAGE_ALIGN(addr), len, limit);
+		addr = arch_get_unmapped_area_1 (mm, PAGE_ALIGN(addr), len,
+						 limit);
 		if (addr != (unsigned long) -ENOMEM)
 			return addr;
 	}
 
 	/* Next, try allocating at TASK_UNMAPPED_BASE.  */
-	addr = arch_get_unmapped_area_1 (PAGE_ALIGN(TASK_UNMAPPED_BASE),
+	addr = arch_get_unmapped_area_1 (mm, PAGE_ALIGN(TASK_UNMAPPED_BASE),
 					 len, limit);
 	if (addr != (unsigned long) -ENOMEM)
 		return addr;
 
 	/* Finally, try allocating in low memory.  */
-	addr = arch_get_unmapped_area_1 (PAGE_SIZE, len, limit);
+	addr = arch_get_unmapped_area_1 (mm, PAGE_SIZE, len, limit);
 
 	return addr;
 }
diff --git a/arch/arc/mm/mmap.c b/arch/arc/mm/mmap.c
index 2e06d56e987b..2fa95d302b02 100644
--- a/arch/arc/mm/mmap.c
+++ b/arch/arc/mm/mmap.c
@@ -28,10 +28,10 @@
  * SHMLBA bytes.
  */
 unsigned long
-arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	int do_align = 0;
 	int aliasing = cache_is_vipt_aliasing();
@@ -74,5 +74,5 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.high_limit = TASK_SIZE;
 	info.align_mask = do_align ? (PAGE_MASK & (SHMLBA - 1)) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 91d2d5b01414..4c6f9595fdbe 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -426,7 +426,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 	hint = sigpage_addr(mm, npages);
-	addr = get_unmapped_area(NULL, hint, npages << PAGE_SHIFT, 0, 0);
+	addr = get_unmapped_area(mm, NULL, hint, npages << PAGE_SHIFT, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
 		ret = addr;
 		goto up_fail;
diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 66353caa35b9..48b49bfdd1d7 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -52,10 +52,10 @@ static unsigned long mmap_base(unsigned long rnd)
  * in the VIVT case, we optimise out the alignment rules.
  */
 unsigned long
-arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	int do_align = 0;
 	int aliasing = cache_is_vipt_aliasing();
@@ -99,16 +99,15 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.high_limit = TASK_SIZE;
 	info.align_mask = do_align ? (PAGE_MASK & (SHMLBA - 1)) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			const unsigned long len, const unsigned long pgoff,
-			const unsigned long flags)
+arch_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			const unsigned long addr0, const unsigned long len,
+			const unsigned long pgoff, const unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	int do_align = 0;
 	int aliasing = cache_is_vipt_aliasing();
@@ -150,7 +149,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.high_limit = mm->mmap_base;
 	info.align_mask = do_align ? (PAGE_MASK & (SHMLBA - 1)) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -163,7 +162,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		info.flags = 0;
 		info.low_limit = mm->mmap_base;
 		info.high_limit = TASK_SIZE;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index a2c2478e7d78..403e71456297 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -166,7 +166,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
-	vdso_base = get_unmapped_area(NULL, 0, vdso_mapping_len, 0, 0);
+	vdso_base = get_unmapped_area(mm, NULL, 0, vdso_mapping_len, 0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
 		ret = ERR_PTR(vdso_base);
 		goto up_fail;
diff --git a/arch/blackfin/include/asm/pgtable.h b/arch/blackfin/include/asm/pgtable.h
index c1ee3d6533fb..fe2c5d41d62a 100644
--- a/arch/blackfin/include/asm/pgtable.h
+++ b/arch/blackfin/include/asm/pgtable.h
@@ -92,7 +92,8 @@ extern char empty_zero_page[];
 #define	VMALLOC_END	0xffffffff
 
 /* provide a special get_unmapped_area for framebuffer mmaps of nommu */
-extern unsigned long get_fb_unmapped_area(struct file *filp, unsigned long,
+extern unsigned long get_fb_unmapped_area(struct mm_struct *mm,
+					  struct file *filp, unsigned long,
 					  unsigned long, unsigned long,
 					  unsigned long);
 #define HAVE_ARCH_FB_UNMAPPED_AREA
diff --git a/arch/blackfin/kernel/sys_bfin.c b/arch/blackfin/kernel/sys_bfin.c
index d998383cb956..65acfd2bc8d1 100644
--- a/arch/blackfin/kernel/sys_bfin.c
+++ b/arch/blackfin/kernel/sys_bfin.c
@@ -42,8 +42,9 @@ asmlinkage void *sys_dma_memcpy(void *dest, const void *src, size_t len)
 #if defined(CONFIG_FB) || defined(CONFIG_FB_MODULE)
 #include <linux/fb.h>
 #include <linux/export.h>
-unsigned long get_fb_unmapped_area(struct file *filp, unsigned long orig_addr,
-	unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long get_fb_unmapped_area(struct mm_struct *mm, struct file *filp,
+	unsigned long orig_addr, unsigned long len, unsigned long pgoff,
+	unsigned long flags)
 {
 	struct fb_info *info = filp->private_data;
 	return (unsigned long)info->screen_base;
diff --git a/arch/frv/mm/elf-fdpic.c b/arch/frv/mm/elf-fdpic.c
index 836f14707a62..c7158d8883e2 100644
--- a/arch/frv/mm/elf-fdpic.c
+++ b/arch/frv/mm/elf-fdpic.c
@@ -56,7 +56,8 @@ void elf_fdpic_arch_lay_out_mm(struct elf_fdpic_params *exec_params,
  * place non-fixed mmaps firstly in the bottom part of memory, working up, and then in the top part
  * of memory, working down
  */
-unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsigned long len,
+unsigned long arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+				     unsigned long addr, unsigned long len,
 				     unsigned long pgoff, unsigned long flags)
 {
 	struct vm_area_struct *vma;
@@ -72,7 +73,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	/* only honour a hint if we're not going to clobber something doing so */
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
-		vma = find_vma(current->mm, addr);
+		vma = find_vma(mm, addr);
 		if (TASK_SIZE - len >= addr &&
 		    (!vma || addr + len <= vma->vm_start))
 			goto success;
@@ -82,10 +83,10 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = (current->mm->start_stack - 0x00200000);
+	info.high_limit = (mm->start_stack - 0x00200000);
 	info.align_mask = 0;
 	info.align_offset = 0;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 	if (!(addr & ~PAGE_MASK))
 		goto success;
 	VM_BUG_ON(addr != -ENOMEM);
@@ -93,7 +94,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	/* search from just above the WorkRAM area to the top of memory */
 	info.low_limit = PAGE_ALIGN(0x80000000);
 	info.high_limit = TASK_SIZE;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 	if (!(addr & ~PAGE_MASK))
 		goto success;
 	VM_BUG_ON(addr != -ENOMEM);
diff --git a/arch/hexagon/kernel/vdso.c b/arch/hexagon/kernel/vdso.c
index 3ea968415539..1ec46d4dd0e6 100644
--- a/arch/hexagon/kernel/vdso.c
+++ b/arch/hexagon/kernel/vdso.c
@@ -71,7 +71,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	/* Try to get it loaded right near ld.so/glibc. */
 	vdso_base = STACK_TOP;
 
-	vdso_base = get_unmapped_area(NULL, vdso_base, PAGE_SIZE, 0, 0);
+	vdso_base = get_unmapped_area(mm, NULL, vdso_base, PAGE_SIZE, 0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
 		ret = vdso_base;
 		goto up_fail;
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 677a86826771..8a5cb50e698f 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2308,7 +2308,8 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 	down_write(&task->mm->mmap_sem);
 
 	/* find some free area in address space, must have mmap sem held */
-	vma->vm_start = get_unmapped_area(NULL, 0, size, 0, MAP_PRIVATE|MAP_ANONYMOUS);
+	vma->vm_start = get_unmapped_area(mm, NULL, 0, size, 0,
+					  MAP_PRIVATE|MAP_ANONYMOUS);
 	if (IS_ERR_VALUE(vma->vm_start)) {
 		DPRINT(("Cannot find unmapped area for size %ld\n", size));
 		up_write(&task->mm->mmap_sem);
diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
index a09c12230bc5..2f33e1c9d002 100644
--- a/arch/ia64/kernel/sys_ia64.c
+++ b/arch/ia64/kernel/sys_ia64.c
@@ -21,12 +21,12 @@
 #include <linux/uaccess.h>
 
 unsigned long
-arch_get_unmapped_area (struct file *filp, unsigned long addr, unsigned long len,
+arch_get_unmapped_area (struct mm_struct *mm, struct file *filp,
+			unsigned long addr, unsigned long len,
 			unsigned long pgoff, unsigned long flags)
 {
 	long map_shared = (flags & MAP_SHARED);
 	unsigned long align_mask = 0;
-	struct mm_struct *mm = current->mm;
 	struct vm_unmapped_area_info info;
 
 	if (len > RGN_MAP_LIMIT)
@@ -61,7 +61,7 @@ arch_get_unmapped_area (struct file *filp, unsigned long addr, unsigned long len
 	info.high_limit = TASK_SIZE;
 	info.align_mask = align_mask;
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 asmlinkage long
diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 85de86d36fdf..fd9ff12b37f4 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -134,8 +134,9 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 	free_pgd_range(tlb, addr, end, floor, ceiling);
 }
 
-unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
-		unsigned long pgoff, unsigned long flags)
+unsigned long hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
 	struct vm_unmapped_area_info info;
 
@@ -161,7 +162,7 @@ unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr, u
 	info.high_limit = HPAGE_REGION_BASE + RGN_MAP_LIMIT;
 	info.align_mask = PAGE_MASK & (HPAGE_SIZE - 1);
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 static int __init hugetlb_setup_sz(char *str)
diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index db1b7da91e4f..4bf5b3c1ae7e 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -179,7 +179,7 @@ hugetlb_get_unmapped_area_existing(unsigned long len)
 
 /* Do a full search to find an area without any nearby normal pages. */
 static unsigned long
-hugetlb_get_unmapped_area_new_pmd(unsigned long len)
+hugetlb_get_unmapped_area_new_pmd(struct mm_struct *mm, unsigned long len)
 {
 	struct vm_unmapped_area_info info;
 
@@ -189,12 +189,13 @@ hugetlb_get_unmapped_area_new_pmd(unsigned long len)
 	info.high_limit = TASK_SIZE;
 	info.align_mask = PAGE_MASK & HUGEPT_MASK;
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 unsigned long
-hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
 	struct hstate *h = hstate_file(file);
 
@@ -227,7 +228,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	 * Find an unmapped naturally aligned set of 4MB blocks that we can use
 	 * for huge pages.
 	 */
-	return hugetlb_get_unmapped_area_new_pmd(len);
+	return hugetlb_get_unmapped_area_new_pmd(mm, len);
 }
 
 #endif /*HAVE_ARCH_HUGETLB_UNMAPPED_AREA*/
diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index 9631b42908f3..05d87680a05a 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -129,7 +129,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	vvar_size = gic_size + PAGE_SIZE;
 	size = vvar_size + image->size;
 
-	base = get_unmapped_area(NULL, 0, size, 0, 0);
+	base = get_unmapped_area(mm, NULL, 0, size, 0, 0);
 	if (IS_ERR_VALUE(base)) {
 		ret = base;
 		goto out;
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index d08ea3ff0f53..86a8cb07a584 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -51,11 +51,11 @@ static unsigned long mmap_base(unsigned long rnd)
 
 enum mmap_allocation_direction {UP, DOWN};
 
-static unsigned long arch_get_unmapped_area_common(struct file *filp,
-	unsigned long addr0, unsigned long len, unsigned long pgoff,
-	unsigned long flags, enum mmap_allocation_direction dir)
+static unsigned long arch_get_unmapped_area_common(struct mm_struct *mm,
+	struct file *filp, unsigned long addr0, unsigned long len,
+	unsigned long pgoff, unsigned long flags,
+	enum mmap_allocation_direction dir)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long addr = addr0;
 	int do_color_align;
@@ -104,7 +104,7 @@ static unsigned long arch_get_unmapped_area_common(struct file *filp,
 		info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 		info.low_limit = PAGE_SIZE;
 		info.high_limit = mm->mmap_base;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 
 		if (!(addr & ~PAGE_MASK))
 			return addr;
@@ -120,13 +120,14 @@ static unsigned long arch_get_unmapped_area_common(struct file *filp,
 	info.flags = 0;
 	info.low_limit = mm->mmap_base;
 	info.high_limit = TASK_SIZE;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
-unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr0,
-	unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+	unsigned long addr0, unsigned long len, unsigned long pgoff,
+	unsigned long flags)
 {
-	return arch_get_unmapped_area_common(filp,
+	return arch_get_unmapped_area_common(mm, filp,
 			addr0, len, pgoff, flags, UP);
 }
 
@@ -134,11 +135,11 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr0,
  * There is no need to export this but sched.h declares the function as
  * extern so making it static here results in an error.
  */
-unsigned long arch_get_unmapped_area_topdown(struct file *filp,
-	unsigned long addr0, unsigned long len, unsigned long pgoff,
-	unsigned long flags)
+unsigned long arch_get_unmapped_area_topdown(struct mm_struct *mm,
+	struct file *filp, unsigned long addr0, unsigned long len,
+	unsigned long pgoff, unsigned long flags)
 {
-	return arch_get_unmapped_area_common(filp,
+	return arch_get_unmapped_area_common(mm, filp,
 			addr0, len, pgoff, flags, DOWN);
 }
 
diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index bf3294171230..68664e9a3317 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -84,10 +84,10 @@ static unsigned long mmap_upper_limit(void)
 }
 
 
-unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long task_size = TASK_SIZE;
 	int do_color_align, last_mmap;
@@ -127,7 +127,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.high_limit = mmap_upper_limit();
 	info.align_mask = last_mmap ? (PAGE_MASK & (SHM_COLOUR - 1)) : 0;
 	info.align_offset = shared_align_offset(last_mmap, pgoff);
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 found_addr:
 	if (do_color_align && !last_mmap && !(addr & ~PAGE_MASK))
@@ -137,12 +137,11 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
 }
 
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+arch_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			  const unsigned long addr0, const unsigned long len,
+			  const unsigned long pgoff, const unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	int do_color_align, last_mmap;
 	struct vm_unmapped_area_info info;
@@ -187,7 +186,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.high_limit = mm->mmap_base;
 	info.align_mask = last_mmap ? (PAGE_MASK & (SHM_COLOUR - 1)) : 0;
 	info.align_offset = shared_align_offset(last_mmap, pgoff);
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 	if (!(addr & ~PAGE_MASK))
 		goto found_addr;
 	VM_BUG_ON(addr != -ENOMEM);
@@ -198,7 +197,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	return arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
+	return arch_get_unmapped_area(mm, filp, addr0, len, pgoff, flags);
 
 found_addr:
 	if (do_color_align && !last_mmap && !(addr & ~PAGE_MASK))
diff --git a/arch/parisc/mm/hugetlbpage.c b/arch/parisc/mm/hugetlbpage.c
index 5d6eea925cf4..a0f93122e142 100644
--- a/arch/parisc/mm/hugetlbpage.c
+++ b/arch/parisc/mm/hugetlbpage.c
@@ -21,8 +21,9 @@
 
 
 unsigned long
-hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
 	struct hstate *h = hstate_file(file);
 
@@ -39,7 +40,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 		addr = ALIGN(addr, huge_page_size(h));
 
 	/* we need to make sure the colouring is OK */
-	return arch_get_unmapped_area(file, addr, len, pgoff, flags);
+	return arch_get_unmapped_area(mm, file, addr, len, pgoff, flags);
 }
 
 
diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index c62f14d0bec1..5ff88a3d946e 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -8,9 +8,9 @@
 void radix__flush_hugetlb_page(struct vm_area_struct *vma, unsigned long vmaddr);
 void radix__local_flush_hugetlb_page(struct vm_area_struct *vma, unsigned long vmaddr);
 extern unsigned long
-radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-				unsigned long len, unsigned long pgoff,
-				unsigned long flags);
+radix__hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags);
 
 static inline int hstate_get_psize(struct hstate *hstate)
 {
diff --git a/arch/powerpc/include/asm/page_64.h b/arch/powerpc/include/asm/page_64.h
index dd5f0712afa2..1ac2c5814d14 100644
--- a/arch/powerpc/include/asm/page_64.h
+++ b/arch/powerpc/include/asm/page_64.h
@@ -115,7 +115,8 @@ struct slice_mask {
 
 struct mm_struct;
 
-extern unsigned long slice_get_unmapped_area(unsigned long addr,
+extern unsigned long slice_get_unmapped_area(struct mm_struct *mm,
+					     unsigned long addr,
 					     unsigned long len,
 					     unsigned long flags,
 					     unsigned int psize,
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 4111d30badfa..3f7c4b334620 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -198,7 +198,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 */
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
-	vdso_base = get_unmapped_area(NULL, vdso_base,
+	vdso_base = get_unmapped_area(mm, NULL, vdso_base,
 				      (vdso_pages << PAGE_SHIFT) +
 				      ((VDSO_ALIGNMENT - 1) & PAGE_MASK),
 				      0, 0);
diff --git a/arch/powerpc/mm/hugetlbpage-radix.c b/arch/powerpc/mm/hugetlbpage-radix.c
index 35254a678456..86e99682033a 100644
--- a/arch/powerpc/mm/hugetlbpage-radix.c
+++ b/arch/powerpc/mm/hugetlbpage-radix.c
@@ -41,11 +41,10 @@ void radix__flush_hugetlb_tlb_range(struct vm_area_struct *vma, unsigned long st
  * ie, use topdown or not based on mmap_is_legacy check ?
  */
 unsigned long
-radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-				unsigned long len, unsigned long pgoff,
-				unsigned long flags)
+radix__hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
@@ -78,5 +77,5 @@ radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	info.high_limit = current->mm->mmap_base;
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 8c3389cbcd12..817bf97e59cc 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -698,17 +698,18 @@ int gup_huge_pd(hugepd_t hugepd, unsigned long addr, unsigned pdshift,
 }
 
 #ifdef CONFIG_PPC_MM_SLICES
-unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-					unsigned long len, unsigned long pgoff,
+unsigned long hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+					unsigned long addr, unsigned long len,
+					unsigned long pgoff,
 					unsigned long flags)
 {
 	struct hstate *hstate = hstate_file(file);
 	int mmu_psize = shift_to_mmu_psize(huge_page_shift(hstate));
 
 	if (radix_enabled())
-		return radix__hugetlb_get_unmapped_area(file, addr, len,
+		return radix__hugetlb_get_unmapped_area(mm, file, addr, len,
 						       pgoff, flags);
-	return slice_get_unmapped_area(addr, len, flags, mmu_psize, 1);
+	return slice_get_unmapped_area(mm, addr, len, flags, mmu_psize, 1);
 }
 #endif
 
diff --git a/arch/powerpc/mm/mmap.c b/arch/powerpc/mm/mmap.c
index 2f1e44362198..b05ad3e33c40 100644
--- a/arch/powerpc/mm/mmap.c
+++ b/arch/powerpc/mm/mmap.c
@@ -88,11 +88,10 @@ static inline unsigned long mmap_base(unsigned long rnd)
  * HAVE_ARCH_UNMAPPED_AREA
  */
 static unsigned long
-radix__arch_get_unmapped_area(struct file *filp, unsigned long addr,
-			     unsigned long len, unsigned long pgoff,
-			     unsigned long flags)
+radix__arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+			     unsigned long addr, unsigned long len,
+			     unsigned long pgoff, unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct vm_unmapped_area_info info;
 
@@ -115,18 +114,18 @@ radix__arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.low_limit = mm->mmap_base;
 	info.high_limit = TASK_SIZE;
 	info.align_mask = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 static unsigned long
-radix__arch_get_unmapped_area_topdown(struct file *filp,
+radix__arch_get_unmapped_area_topdown(struct mm_struct *mm,
+				     struct file *filp,
 				     const unsigned long addr0,
 				     const unsigned long len,
 				     const unsigned long pgoff,
 				     const unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 
@@ -151,7 +150,7 @@ radix__arch_get_unmapped_area_topdown(struct file *filp,
 	info.low_limit = max(PAGE_SIZE, mmap_min_addr);
 	info.high_limit = mm->mmap_base;
 	info.align_mask = 0;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -164,7 +163,7 @@ radix__arch_get_unmapped_area_topdown(struct file *filp,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
diff --git a/arch/powerpc/mm/slice.c b/arch/powerpc/mm/slice.c
index 2b27458902ee..ebcb47c62d47 100644
--- a/arch/powerpc/mm/slice.c
+++ b/arch/powerpc/mm/slice.c
@@ -296,7 +296,7 @@ static unsigned long slice_find_area_bottomup(struct mm_struct *mm,
 		}
 		info.high_limit = addr;
 
-		found = vm_unmapped_area(&info);
+		found = vm_unmapped_area(mm, &info);
 		if (!(found & ~PAGE_MASK))
 			return found;
 	}
@@ -339,7 +339,7 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 		}
 		info.low_limit = addr;
 
-		found = vm_unmapped_area(&info);
+		found = vm_unmapped_area(mm, &info);
 		if (!(found & ~PAGE_MASK))
 			return found;
 	}
@@ -380,9 +380,9 @@ static unsigned long slice_find_area(struct mm_struct *mm, unsigned long len,
 #define MMU_PAGE_BASE	MMU_PAGE_4K
 #endif
 
-unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
-				      unsigned long flags, unsigned int psize,
-				      int topdown)
+unsigned long slice_get_unmapped_area(struct mm_struct *mm, unsigned long addr,
+				      unsigned long len, unsigned long flags,
+				      unsigned int psize, int topdown)
 {
 	struct slice_mask mask = {0, 0};
 	struct slice_mask good_mask;
@@ -390,7 +390,6 @@ unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
 	struct slice_mask compat_mask = {0, 0};
 	int fixed = (flags & MAP_FIXED);
 	int pshift = max_t(int, mmu_psize_defs[psize].shift, PAGE_SHIFT);
-	struct mm_struct *mm = current->mm;
 	unsigned long newaddr;
 
 	/* Sanity checks */
@@ -544,24 +543,26 @@ unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
 }
 EXPORT_SYMBOL_GPL(slice_get_unmapped_area);
 
-unsigned long arch_get_unmapped_area(struct file *filp,
+unsigned long arch_get_unmapped_area(struct mm_struct *mm,
+				     struct file *filp,
 				     unsigned long addr,
 				     unsigned long len,
 				     unsigned long pgoff,
 				     unsigned long flags)
 {
-	return slice_get_unmapped_area(addr, len, flags,
-				       current->mm->context.user_psize, 0);
+	return slice_get_unmapped_area(mm, addr, len, flags,
+				       mm->context.user_psize, 0);
 }
 
-unsigned long arch_get_unmapped_area_topdown(struct file *filp,
+unsigned long arch_get_unmapped_area_topdown(struct mm_struct *mm,
+					     struct file *filp,
 					     const unsigned long addr0,
 					     const unsigned long len,
 					     const unsigned long pgoff,
 					     const unsigned long flags)
 {
-	return slice_get_unmapped_area(addr0, len, flags,
-				       current->mm->context.user_psize, 1);
+	return slice_get_unmapped_area(mm, addr0, len, flags,
+				       mm->context.user_psize, 1);
 }
 
 unsigned int get_slice_psize(struct mm_struct *mm, unsigned long addr)
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 5904abf6b1ae..2e8d5d6d7806 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -218,7 +218,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 */
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
-	vdso_base = get_unmapped_area(NULL, 0, vdso_pages << PAGE_SHIFT, 0, 0);
+	vdso_base = get_unmapped_area(mm, NULL, 0, vdso_pages << PAGE_SHIFT,
+				      0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
 		rc = vdso_base;
 		goto out_up;
diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
index eb9df2822da1..e9622a8bc740 100644
--- a/arch/s390/mm/mmap.c
+++ b/arch/s390/mm/mmap.c
@@ -81,10 +81,10 @@ static inline unsigned long mmap_base(unsigned long rnd)
 }
 
 unsigned long
-arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct vm_unmapped_area_info info;
 
@@ -111,16 +111,15 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	else
 		info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+arch_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			  const unsigned long addr0, const unsigned long len,
+			  const unsigned long pgoff, const unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 
@@ -149,7 +148,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	else
 		info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -162,7 +161,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
@@ -180,14 +179,14 @@ int s390_mmap_check(unsigned long addr, unsigned long len, unsigned long flags)
 }
 
 static unsigned long
-s390_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+s390_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	unsigned long area;
 	int rc;
 
-	area = arch_get_unmapped_area(filp, addr, len, pgoff, flags);
+	area = arch_get_unmapped_area(mm, filp, addr, len, pgoff, flags);
 	if (!(area & ~PAGE_MASK))
 		return area;
 	if (area == -ENOMEM && !is_compat_task() && TASK_SIZE < TASK_MAX_SIZE) {
@@ -195,21 +194,22 @@ s390_get_unmapped_area(struct file *filp, unsigned long addr,
 		rc = crst_table_upgrade(mm);
 		if (rc)
 			return (unsigned long) rc;
-		area = arch_get_unmapped_area(filp, addr, len, pgoff, flags);
+		area = arch_get_unmapped_area(mm, filp, addr, len, pgoff,
+					      flags);
 	}
 	return area;
 }
 
 static unsigned long
-s390_get_unmapped_area_topdown(struct file *filp, const unsigned long addr,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+s390_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			  const unsigned long addr, const unsigned long len,
+			  const unsigned long pgoff, const unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	unsigned long area;
 	int rc;
 
-	area = arch_get_unmapped_area_topdown(filp, addr, len, pgoff, flags);
+	area = arch_get_unmapped_area_topdown(mm, filp, addr, len, pgoff,
+					      flags);
 	if (!(area & ~PAGE_MASK))
 		return area;
 	if (area == -ENOMEM && !is_compat_task() && TASK_SIZE < TASK_MAX_SIZE) {
@@ -217,7 +217,7 @@ s390_get_unmapped_area_topdown(struct file *filp, const unsigned long addr,
 		rc = crst_table_upgrade(mm);
 		if (rc)
 			return (unsigned long) rc;
-		area = arch_get_unmapped_area_topdown(filp, addr, len,
+		area = arch_get_unmapped_area_topdown(mm, filp, addr, len,
 						      pgoff, flags);
 	}
 	return area;
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index cc0cc5b4ff18..81f68365b511 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -67,7 +67,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
-	addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
+	addr = get_unmapped_area(mm, NULL, 0, PAGE_SIZE, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
 		ret = addr;
 		goto up_fail;
diff --git a/arch/sh/mm/mmap.c b/arch/sh/mm/mmap.c
index 6777177807c2..ab873264c260 100644
--- a/arch/sh/mm/mmap.c
+++ b/arch/sh/mm/mmap.c
@@ -30,10 +30,10 @@ static inline unsigned long COLOUR_ALIGN(unsigned long addr,
 	return base + off;
 }
 
-unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
-	unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+	unsigned long addr, unsigned long len, unsigned long pgoff,
+	unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	int do_colour_align;
 	struct vm_unmapped_area_info info;
@@ -73,16 +73,15 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.high_limit = TASK_SIZE;
 	info.align_mask = do_colour_align ? (PAGE_MASK & shm_align_mask) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+arch_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			  const unsigned long addr0, const unsigned long len,
+			  const unsigned long pgoff, const unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	int do_colour_align;
 	struct vm_unmapped_area_info info;
@@ -123,7 +122,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.high_limit = mm->mmap_base;
 	info.align_mask = do_colour_align ? (PAGE_MASK & shm_align_mask) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -136,7 +135,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 314b66851348..e5e47115ba43 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -1013,8 +1013,8 @@ static inline int io_remap_pfn_range(struct vm_area_struct *vma,
 /* We provide a special get_unmapped_area for framebuffer mmaps to try and use
  * the largest alignment possible such that larget PTEs can be used.
  */
-unsigned long get_fb_unmapped_area(struct file *filp, unsigned long,
-				   unsigned long, unsigned long,
+unsigned long get_fb_unmapped_area(struct mm_struct *mm, struct file *filp,
+				   unsigned long, unsigned long, unsigned long,
 				   unsigned long);
 #define HAVE_ARCH_FB_UNMAPPED_AREA
 
diff --git a/arch/sparc/kernel/sys_sparc_32.c b/arch/sparc/kernel/sys_sparc_32.c
index fb7b185ee941..52319c194f96 100644
--- a/arch/sparc/kernel/sys_sparc_32.c
+++ b/arch/sparc/kernel/sys_sparc_32.c
@@ -36,7 +36,9 @@ asmlinkage unsigned long sys_getpagesize(void)
 	return PAGE_SIZE; /* Possibly older binaries want 8192 on sun4's? */
 }
 
-unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+				     unsigned long addr, unsigned long len,
+				     unsigned long pgoff, unsigned long flags)
 {
 	struct vm_unmapped_area_info info;
 
@@ -63,7 +65,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	info.align_mask = (flags & MAP_SHARED) ?
 		(PAGE_MASK & (SHMLBA - 1)) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 /*
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index 884c70331345..3e77c04700ef 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -83,9 +83,10 @@ static inline unsigned long COLOR_ALIGN(unsigned long addr,
 	return base + off;
 }
 
-unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+				     unsigned long addr, unsigned long len,
+				     unsigned long pgoff, unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct * vma;
 	unsigned long task_size = TASK_SIZE;
 	int do_color_align;
@@ -128,25 +129,24 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	info.high_limit = min(task_size, VA_EXCLUDE_START);
 	info.align_mask = do_color_align ? (PAGE_MASK & (SHMLBA - 1)) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	if ((addr & ~PAGE_MASK) && task_size > VA_EXCLUDE_END) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.low_limit = VA_EXCLUDE_END;
 		info.high_limit = task_size;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
 }
 
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+arch_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			  const unsigned long addr0, const unsigned long len,
+			  const unsigned long pgoff, const unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	unsigned long task_size = STACK_TOP32;
 	unsigned long addr = addr0;
 	int do_color_align;
@@ -191,7 +191,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.high_limit = mm->mmap_base;
 	info.align_mask = do_color_align ? (PAGE_MASK & (SHMLBA - 1)) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -204,20 +204,23 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = STACK_TOP32;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
 }
 
 /* Try to align mapping such that we align it as much as possible. */
-unsigned long get_fb_unmapped_area(struct file *filp, unsigned long orig_addr, unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long get_fb_unmapped_area(struct mm_sturc *mm, struct file *filp,
+				   unsigned long orig_addr, unsigned long len,
+				   unsigned long pgoff, unsigned long flags)
 {
 	unsigned long align_goal, addr = -ENOMEM;
-	unsigned long (*get_area)(struct file *, unsigned long,
-				  unsigned long, unsigned long, unsigned long);
+	unsigned long (*get_area)(struct mm_struct *, struct file *,
+				  unsigned long, unsigned long, unsigned long,
+				  unsigned long);
 
-	get_area = current->mm->get_unmapped_area;
+	get_area = mm->get_unmapped_area;
 
 	if (flags & MAP_FIXED) {
 		/* Ok, don't mess with it. */
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 988acc8b1b80..92841d9ddd59 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -22,7 +22,8 @@
  * definition we don't have to worry about any page coloring stuff
  */
 
-static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *filp,
+static unsigned long hugetlb_get_unmapped_area_bottomup(struct mm_struct *mm,
+							struct file *filp,
 							unsigned long addr,
 							unsigned long len,
 							unsigned long pgoff,
@@ -40,25 +41,26 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *filp,
 	info.high_limit = min(task_size, VA_EXCLUDE_START);
 	info.align_mask = PAGE_MASK & ~HPAGE_MASK;
 	info.align_offset = 0;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	if ((addr & ~PAGE_MASK) && task_size > VA_EXCLUDE_END) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.low_limit = VA_EXCLUDE_END;
 		info.high_limit = task_size;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
 }
 
 static unsigned long
-hugetlb_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
+hugetlb_get_unmapped_area_topdown(struct mm_struct *mm,
+				  struct file *filp,
+				  const unsigned long addr0,
 				  const unsigned long len,
 				  const unsigned long pgoff,
 				  const unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 
@@ -71,7 +73,7 @@ hugetlb_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.high_limit = mm->mmap_base;
 	info.align_mask = PAGE_MASK & ~HPAGE_MASK;
 	info.align_offset = 0;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -84,17 +86,17 @@ hugetlb_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = STACK_TOP32;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
 }
 
 unsigned long
-hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long task_size = TASK_SIZE;
 
@@ -120,10 +122,10 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 			return addr;
 	}
 	if (mm->get_unmapped_area == arch_get_unmapped_area)
-		return hugetlb_get_unmapped_area_bottomup(file, addr, len,
+		return hugetlb_get_unmapped_area_bottomup(mm, file, addr, len,
 				pgoff, flags);
 	else
-		return hugetlb_get_unmapped_area_topdown(file, addr, len,
+		return hugetlb_get_unmapped_area_topdown(mm, file, addr, len,
 				pgoff, flags);
 }
 
diff --git a/arch/tile/kernel/vdso.c b/arch/tile/kernel/vdso.c
index 5bc51d7dfdcb..74aa55aa11ec 100644
--- a/arch/tile/kernel/vdso.c
+++ b/arch/tile/kernel/vdso.c
@@ -150,7 +150,7 @@ int setup_vdso_pages(void)
 	if (pages == 0)
 		return 0;
 
-	vdso_base = get_unmapped_area(NULL, vdso_base,
+	vdso_base = get_unmapped_area(mm, NULL, vdso_base,
 				      (pages << PAGE_SHIFT) +
 				      ((VDSO_ALIGNMENT - 1) & PAGE_MASK),
 				      0, 0);
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 77ceaa343fce..24e8c99b5b3f 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -161,7 +161,8 @@ int pud_huge(pud_t pud)
 }
 
 #ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
-static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
+static unsigned long hugetlb_get_unmapped_area_bottomup(struct mm_struct *mm,
+		struct file *file,
 		unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
@@ -174,10 +175,11 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 	info.high_limit = TASK_SIZE;
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
-static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
+static unsigned long hugetlb_get_unmapped_area_topdown(struct mm_struct *mm,
+		struct file *file,
 		unsigned long addr0, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
@@ -188,10 +190,10 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = current->mm->mmap_base;
+	info.high_limit = mm->mmap_base;
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -204,17 +206,17 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
 }
 
-unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
 	struct hstate *h = hstate_file(file);
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 
 	if (len & ~huge_page_mask(h))
@@ -235,11 +237,11 @@ unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	if (current->mm->get_unmapped_area == arch_get_unmapped_area)
-		return hugetlb_get_unmapped_area_bottomup(file, addr, len,
+	if (mm->get_unmapped_area == arch_get_unmapped_area)
+		return hugetlb_get_unmapped_area_bottomup(mm, file, addr, len,
 				pgoff, flags);
 	else
-		return hugetlb_get_unmapped_area_topdown(file, addr, len,
+		return hugetlb_get_unmapped_area_topdown(mm, file, addr, len,
 				pgoff, flags);
 }
 #endif /* HAVE_ARCH_HUGETLB_UNMAPPED_AREA */
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 10820f6cefbf..8f728f3a1698 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -153,7 +153,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
-	addr = get_unmapped_area(NULL, addr,
+	addr = get_unmapped_area(mm, NULL, addr,
 				 image->size - image->sym_vvar_start, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
 		ret = addr;
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index a55ed63b9f91..bf9198998895 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -120,10 +120,10 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 }
 
 unsigned long
-arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct vm_unmapped_area_info info;
 	unsigned long begin, end;
@@ -154,16 +154,15 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		info.align_mask = get_align_mask();
 		info.align_offset += get_align_bits();
 	}
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+arch_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			  const unsigned long addr0, const unsigned long len,
+			  const unsigned long pgoff, const unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 
@@ -197,7 +196,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		info.align_mask = get_align_mask();
 		info.align_offset += get_align_bits();
 	}
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 	if (!(addr & ~PAGE_MASK))
 		return addr;
 	VM_BUG_ON(addr != -ENOMEM);
@@ -209,5 +208,5 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	return arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
+	return arch_get_unmapped_area(mm, filp, addr0, len, pgoff, flags);
 }
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 2ae8584b44c7..93f0dccd0fcd 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -72,7 +72,8 @@ int pud_huge(pud_t pud)
 #endif
 
 #ifdef CONFIG_HUGETLB_PAGE
-static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
+static unsigned long hugetlb_get_unmapped_area_bottomup(struct mm_struct *mm,
+		struct file *file,
 		unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
@@ -81,14 +82,15 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 
 	info.flags = 0;
 	info.length = len;
-	info.low_limit = current->mm->mmap_legacy_base;
+	info.low_limit = mm->mmap_legacy_base;
 	info.high_limit = TASK_SIZE;
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 
-static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
+static unsigned long hugetlb_get_unmapped_area_topdown(struct mm_struct *mm,
+		struct file *file,
 		unsigned long addr0, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
@@ -99,10 +101,10 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = current->mm->mmap_base;
+	info.high_limit = mm->mmap_base;
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -115,18 +117,18 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
 }
 
 unsigned long
-hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
 	struct hstate *h = hstate_file(file);
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 
 	if (len & ~huge_page_mask(h))
@@ -148,10 +150,10 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 			return addr;
 	}
 	if (mm->get_unmapped_area == arch_get_unmapped_area)
-		return hugetlb_get_unmapped_area_bottomup(file, addr, len,
+		return hugetlb_get_unmapped_area_bottomup(mm, file, addr, len,
 				pgoff, flags);
 	else
-		return hugetlb_get_unmapped_area_topdown(file, addr, len,
+		return hugetlb_get_unmapped_area_topdown(mm, file, addr, len,
 				pgoff, flags);
 }
 #endif /* CONFIG_HUGETLB_PAGE */
diff --git a/arch/xtensa/kernel/syscall.c b/arch/xtensa/kernel/syscall.c
index d3fd100dffc9..4a17828917df 100644
--- a/arch/xtensa/kernel/syscall.c
+++ b/arch/xtensa/kernel/syscall.c
@@ -58,8 +58,9 @@ asmlinkage long xtensa_fadvise64_64(int fd, int advice,
 }
 
 #ifdef CONFIG_MMU
-unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
 	struct vm_area_struct *vmm;
 
@@ -83,7 +84,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(mm, addr); ; vmm = vmm->vm_next) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 6d9cc2d39d22..4b6ac3f373df 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -273,7 +273,8 @@ static pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 #endif
 
 #ifndef CONFIG_MMU
-static unsigned long get_unmapped_area_mem(struct file *file,
+static unsigned long get_unmapped_area_mem(struct mm_struct *mm,
+					   struct file *file,
 					   unsigned long addr,
 					   unsigned long len,
 					   unsigned long pgoff,
@@ -662,9 +663,10 @@ static int mmap_zero(struct file *file, struct vm_area_struct *vma)
 	return 0;
 }
 
-static unsigned long get_unmapped_area_zero(struct file *file,
-				unsigned long addr, unsigned long len,
-				unsigned long pgoff, unsigned long flags)
+static unsigned long get_unmapped_area_zero(struct mm_struct *mm,
+				struct file *file, unsigned long addr,
+				unsigned long len, unsigned long pgoff,
+				unsigned long flags)
 {
 #ifdef CONFIG_MMU
 	if (flags & MAP_SHARED) {
@@ -674,11 +676,12 @@ static unsigned long get_unmapped_area_zero(struct file *file,
 		 * and pass NULL for file as in mmap.c's get_unmapped_area(),
 		 * so as not to confuse shmem with our handle on "/dev/zero".
 		 */
-		return shmem_get_unmapped_area(NULL, addr, len, pgoff, flags);
+		return shmem_get_unmapped_area(mm, NULL, addr, len, pgoff,
+					       flags);
 	}
 
 	/* Otherwise flags & MAP_PRIVATE: with no shmem object beneath it */
-	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+	return mm->get_unmapped_area(mm, file, addr, len, pgoff, flags);
 #else
 	return -ENOSYS;
 #endif
diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index ed758b74ddf0..ab60b8c05b7f 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -552,9 +552,9 @@ static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
 }
 
 /* return an unmapped area aligned to the dax region specified alignment */
-static unsigned long dax_get_unmapped_area(struct file *filp,
-		unsigned long addr, unsigned long len, unsigned long pgoff,
-		unsigned long flags)
+static unsigned long dax_get_unmapped_area(struct mm_struct *mm,
+		struct file *filp, unsigned long addr, unsigned long len,
+		unsigned long pgoff, unsigned long flags)
 {
 	unsigned long off, off_end, off_align, len_align, addr_align, align;
 	struct dax_dev *dax_dev = filp ? filp->private_data : NULL;
@@ -576,14 +576,14 @@ static unsigned long dax_get_unmapped_area(struct file *filp,
 	if ((off + len_align) < off)
 		goto out;
 
-	addr_align = current->mm->get_unmapped_area(filp, addr, len_align,
+	addr_align = mm->get_unmapped_area(mm, filp, addr, len_align,
 			pgoff, flags);
 	if (!IS_ERR_VALUE(addr_align)) {
 		addr_align += (off - addr_align) & (align - 1);
 		return addr_align;
 	}
  out:
-	return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
+	return mm->get_unmapped_area(mm, filp, addr, len, pgoff, flags);
 }
 
 static int dax_open(struct inode *inode, struct file *filp)
diff --git a/drivers/media/usb/uvc/uvc_v4l2.c b/drivers/media/usb/uvc/uvc_v4l2.c
index 3e7e283a44a8..2224c5ebb459 100644
--- a/drivers/media/usb/uvc/uvc_v4l2.c
+++ b/drivers/media/usb/uvc/uvc_v4l2.c
@@ -1434,9 +1434,9 @@ static unsigned int uvc_v4l2_poll(struct file *file, poll_table *wait)
 }
 
 #ifndef CONFIG_MMU
-static unsigned long uvc_v4l2_get_unmapped_area(struct file *file,
-		unsigned long addr, unsigned long len, unsigned long pgoff,
-		unsigned long flags)
+static unsigned long uvc_v4l2_get_unmapped_area(struct mm_struct *mm,
+		struct file *file, unsigned long addr, unsigned long len,
+		unsigned long pgoff, unsigned long flags)
 {
 	struct uvc_fh *handle = file->private_data;
 	struct uvc_streaming *stream = handle->stream;
diff --git a/drivers/media/v4l2-core/v4l2-dev.c b/drivers/media/v4l2-core/v4l2-dev.c
index fa2124cb31bd..f227ebc369f7 100644
--- a/drivers/media/v4l2-core/v4l2-dev.c
+++ b/drivers/media/v4l2-core/v4l2-dev.c
@@ -369,9 +369,9 @@ static long v4l2_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 #ifdef CONFIG_MMU
 #define v4l2_get_unmapped_area NULL
 #else
-static unsigned long v4l2_get_unmapped_area(struct file *filp,
-		unsigned long addr, unsigned long len, unsigned long pgoff,
-		unsigned long flags)
+static unsigned long v4l2_get_unmapped_area(struct mm_struct *mm,
+		struct file *filp, unsigned long addr, unsigned long len,
+		unsigned long pgoff, unsigned long flags)
 {
 	struct video_device *vdev = video_devdata(filp);
 	int ret;
@@ -380,7 +380,7 @@ static unsigned long v4l2_get_unmapped_area(struct file *filp,
 		return -ENOSYS;
 	if (!video_is_registered(vdev))
 		return -ENODEV;
-	ret = vdev->fops->get_unmapped_area(filp, addr, len, pgoff, flags);
+	ret = vdev->fops->get_unmapped_area(mm, filp, addr, len, pgoff, flags);
 	if (vdev->dev_debug & V4L2_DEV_DEBUG_FOP)
 		printk(KERN_DEBUG "%s: get_unmapped_area (%d)\n",
 			video_device_node_name(vdev), ret);
diff --git a/drivers/media/v4l2-core/videobuf2-v4l2.c b/drivers/media/v4l2-core/videobuf2-v4l2.c
index 3529849d2218..953417fb4914 100644
--- a/drivers/media/v4l2-core/videobuf2-v4l2.c
+++ b/drivers/media/v4l2-core/videobuf2-v4l2.c
@@ -932,8 +932,9 @@ unsigned int vb2_fop_poll(struct file *file, poll_table *wait)
 EXPORT_SYMBOL_GPL(vb2_fop_poll);
 
 #ifndef CONFIG_MMU
-unsigned long vb2_fop_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long vb2_fop_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
 	struct video_device *vdev = video_devdata(file);
 
diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
index ce5ccc573a9c..8774808c69e5 100644
--- a/drivers/mtd/mtdchar.c
+++ b/drivers/mtd/mtdchar.c
@@ -1156,7 +1156,8 @@ static long mtdchar_compat_ioctl(struct file *file, unsigned int cmd,
  *   mappings)
  */
 #ifndef CONFIG_MMU
-static unsigned long mtdchar_get_unmapped_area(struct file *file,
+static unsigned long mtdchar_get_unmapped_area(struct mm_struct *mm,
+					   struct file *file,
 					   unsigned long addr,
 					   unsigned long len,
 					   unsigned long pgoff,
diff --git a/drivers/usb/gadget/function/uvc_v4l2.c b/drivers/usb/gadget/function/uvc_v4l2.c
index 3e22b45687d3..96ad4de14dc7 100644
--- a/drivers/usb/gadget/function/uvc_v4l2.c
+++ b/drivers/usb/gadget/function/uvc_v4l2.c
@@ -343,7 +343,8 @@ uvc_v4l2_poll(struct file *file, poll_table *wait)
 }
 
 #ifndef CONFIG_MMU
-static unsigned long uvcg_v4l2_get_unmapped_area(struct file *file,
+static unsigned long uvcg_v4l2_get_unmapped_area(struct mm_struct *mm,
+		struct file *file,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags)
 {
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 54de77e78775..69037eb6a728 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -168,10 +168,10 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 #ifndef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 static unsigned long
-hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
@@ -201,7 +201,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	info.high_limit = TASK_SIZE;
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 #endif
 
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 842a5ff5b85c..cb2d5702bdce 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -291,9 +291,9 @@ static int proc_reg_mmap(struct file *file, struct vm_area_struct *vma)
 }
 
 static unsigned long
-proc_reg_get_unmapped_area(struct file *file, unsigned long orig_addr,
-			   unsigned long len, unsigned long pgoff,
-			   unsigned long flags)
+proc_reg_get_unmapped_area(struct mm_struct *mm, struct file *file,
+			   unsigned long orig_addr, unsigned long len,
+			   unsigned long pgoff, unsigned long flags)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 	unsigned long rv = -EIO;
@@ -304,11 +304,11 @@ proc_reg_get_unmapped_area(struct file *file, unsigned long orig_addr,
 		get_area = pde->proc_fops->get_unmapped_area;
 #ifdef CONFIG_MMU
 		if (!get_area)
-			get_area = current->mm->get_unmapped_area;
+			get_area = mm->get_unmapped_area;
 #endif
 
 		if (get_area)
-			rv = get_area(file, orig_addr, len, pgoff, flags);
+			rv = get_area(mm, file, orig_addr, len, pgoff, flags);
 		else
 			rv = orig_addr;
 		unuse_pde(pde);
diff --git a/fs/ramfs/file-mmu.c b/fs/ramfs/file-mmu.c
index 12af0490322f..a4584130234a 100644
--- a/fs/ramfs/file-mmu.c
+++ b/fs/ramfs/file-mmu.c
@@ -31,11 +31,12 @@
 
 #include "internal.h"
 
-static unsigned long ramfs_mmu_get_unmapped_area(struct file *file,
+static unsigned long ramfs_mmu_get_unmapped_area(struct mm_struct *mm,
+		struct file *file,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags)
 {
-	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+	return mm->get_unmapped_area(mm, file, addr, len, pgoff, flags);
 }
 
 const struct file_operations ramfs_file_operations = {
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 2ef7ce75c062..564ba84d61b6 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -27,7 +27,8 @@
 #include "internal.h"
 
 static int ramfs_nommu_setattr(struct dentry *, struct iattr *);
-static unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
+static unsigned long ramfs_nommu_get_unmapped_area(struct mm_struct *mm,
+						   struct file *file,
 						   unsigned long addr,
 						   unsigned long len,
 						   unsigned long pgoff,
@@ -202,9 +203,10 @@ static int ramfs_nommu_setattr(struct dentry *dentry, struct iattr *ia)
  *   - the pages to be mapped must exist
  *   - the pages be physically contiguous in sequence
  */
-static unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
-					    unsigned long addr, unsigned long len,
-					    unsigned long pgoff, unsigned long flags)
+static unsigned long ramfs_nommu_get_unmapped_area(struct mm_struct *mm,
+					struct file *file, unsigned long addr,
+					unsigned long len, unsigned long pgoff,
+					unsigned long flags)
 {
 	unsigned long maxpages, lpages, nr, loop, ret;
 	struct inode *inode = file_inode(file);
diff --git a/fs/romfs/mmap-nommu.c b/fs/romfs/mmap-nommu.c
index 1118a0dc6b45..0bfebcafb077 100644
--- a/fs/romfs/mmap-nommu.c
+++ b/fs/romfs/mmap-nommu.c
@@ -19,7 +19,8 @@
  *   mappings)
  * - attempts to map through to the underlying MTD device
  */
-static unsigned long romfs_get_unmapped_area(struct file *file,
+static unsigned long romfs_get_unmapped_area(struct mm_struct *mm,
+					     struct file *file,
 					     unsigned long addr,
 					     unsigned long len,
 					     unsigned long pgoff,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2ba074328894..45f8cf874ea1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1662,7 +1662,7 @@ struct file_operations {
 	int (*fasync) (int, struct file *, int);
 	int (*lock) (struct file *, int, struct file_lock *);
 	ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
-	unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
+	unsigned long (*get_unmapped_area)(struct mm_struct *, struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 	int (*check_flags)(int);
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 97e478d6b690..94a0e680b7d7 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -87,9 +87,9 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 extern unsigned long transparent_hugepage_flags;
 
-extern unsigned long thp_get_unmapped_area(struct file *filp,
-		unsigned long addr, unsigned long len, unsigned long pgoff,
-		unsigned long flags);
+extern unsigned long thp_get_unmapped_area(struct mm_struct *mm,
+		struct file *filp, unsigned long addr, unsigned long len,
+		unsigned long pgoff, unsigned long flags);
 
 extern void prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 48c76d612d40..72260cc252f2 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -287,8 +287,9 @@ hugetlb_file_setup(const char *name, size_t size, vm_flags_t acctflag,
 #endif /* !CONFIG_HUGETLBFS */
 
 #ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
-unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-					unsigned long len, unsigned long pgoff,
+unsigned long hugetlb_get_unmapped_area(struct mm_struct *mm, struct file *file,
+					unsigned long addr, unsigned long len,
+					unsigned long pgoff,
 					unsigned long flags);
 #endif /* HAVE_ARCH_HUGETLB_UNMAPPED_AREA */
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 71a90604d21f..1520da8f9c67 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2014,7 +2014,9 @@ extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
-extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
+extern unsigned long get_unmapped_area(struct mm_struct *, struct file *,
+				       unsigned long, unsigned long,
+				       unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct mm_struct *mm, struct file *file,
 				 unsigned long addr, unsigned long len,
@@ -2066,8 +2068,10 @@ struct vm_unmapped_area_info {
 	unsigned long align_offset;
 };
 
-extern unsigned long unmapped_area(struct vm_unmapped_area_info *info);
-extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info);
+extern unsigned long unmapped_area(struct mm_struct *mm,
+				   struct vm_unmapped_area_info *info);
+extern unsigned long unmapped_area_topdown(struct mm_struct *mm,
+					   struct vm_unmapped_area_info *info);
 
 /*
  * Search for an unmapped address range.
@@ -2079,12 +2083,12 @@ extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info);
  * - satisfies (begin_addr & align_mask) == (align_offset & align_mask)
  */
 static inline unsigned long
-vm_unmapped_area(struct vm_unmapped_area_info *info)
+vm_unmapped_area(struct mm_struct *mm, struct vm_unmapped_area_info *info)
 {
 	if (info->flags & VM_UNMAPPED_AREA_TOPDOWN)
-		return unmapped_area_topdown(info);
+		return unmapped_area_topdown(mm, info);
 	else
-		return unmapped_area(info);
+		return unmapped_area(mm, info);
 }
 
 /* truncate.c */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 808751d7b737..6aa03e88dcff 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -398,9 +398,10 @@ struct mm_struct {
 	struct rb_root mm_rb;
 	u32 vmacache_seqnum;                   /* per-thread vmacache */
 #ifdef CONFIG_MMU
-	unsigned long (*get_unmapped_area) (struct file *filp,
-				unsigned long addr, unsigned long len,
-				unsigned long pgoff, unsigned long flags);
+	unsigned long (*get_unmapped_area) (struct mm_struct *mm,
+				struct file *filp, unsigned long addr,
+				unsigned long len, unsigned long pgoff,
+				unsigned long flags);
 #endif
 	unsigned long mmap_base;		/* base of mmap area */
 	unsigned long mmap_legacy_base;         /* base of mmap area in bottom-up allocations */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ad3ec9ec61f7..42b9b93a50ac 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -476,12 +476,12 @@ struct user_namespace;
 #ifdef CONFIG_MMU
 extern void arch_pick_mmap_layout(struct mm_struct *mm);
 extern unsigned long
-arch_get_unmapped_area(struct file *, unsigned long, unsigned long,
-		       unsigned long, unsigned long);
+arch_get_unmapped_area(struct mm_struct *mm, struct file *, unsigned long,
+		       unsigned long, unsigned long, unsigned long);
 extern unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
-			  unsigned long len, unsigned long pgoff,
-			  unsigned long flags);
+arch_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			       unsigned long addr, unsigned long len,
+			       unsigned long pgoff, unsigned long flags);
 #else
 static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
 #endif
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index ff078e7043b6..37d27369bb42 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -54,8 +54,9 @@ extern struct file *shmem_file_setup(const char *name,
 extern struct file *shmem_kernel_file_setup(const char *name, loff_t size,
 					    unsigned long flags);
 extern int shmem_zero_setup(struct vm_area_struct *);
-extern unsigned long shmem_get_unmapped_area(struct file *, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags);
+extern unsigned long shmem_get_unmapped_area(struct mm_struct *, struct file *,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 extern bool shmem_mapping(struct address_space *mapping);
 extern void shmem_unlock_mapping(struct address_space *mapping);
diff --git a/include/media/v4l2-dev.h b/include/media/v4l2-dev.h
index e657614521e3..d7287a53f590 100644
--- a/include/media/v4l2-dev.h
+++ b/include/media/v4l2-dev.h
@@ -156,7 +156,8 @@ struct v4l2_file_operations {
 #ifdef CONFIG_COMPAT
 	long (*compat_ioctl32) (struct file *, unsigned int, unsigned long);
 #endif
-	unsigned long (*get_unmapped_area) (struct file *, unsigned long,
+	unsigned long (*get_unmapped_area) (struct mm_struct *mm,
+				struct file *filep, unsigned long,
 				unsigned long, unsigned long, unsigned long);
 	int (*mmap) (struct file *, struct vm_area_struct *);
 	int (*open) (struct file *);
diff --git a/include/media/videobuf2-v4l2.h b/include/media/videobuf2-v4l2.h
index 036127c54bbf..43f4d0a3b333 100644
--- a/include/media/videobuf2-v4l2.h
+++ b/include/media/videobuf2-v4l2.h
@@ -264,8 +264,9 @@ ssize_t vb2_fop_read(struct file *file, char __user *buf,
 		size_t count, loff_t *ppos);
 unsigned int vb2_fop_poll(struct file *file, poll_table *wait);
 #ifndef CONFIG_MMU
-unsigned long vb2_fop_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags);
+unsigned long vb2_fop_get_unmapped_area(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags);
 #endif
 
 /**
diff --git a/ipc/shm.c b/ipc/shm.c
index 64c21fb32ca9..2fd73cda4ec8 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -465,14 +465,14 @@ static long shm_fallocate(struct file *file, int mode, loff_t offset,
 	return sfd->file->f_op->fallocate(file, mode, offset, len);
 }
 
-static unsigned long shm_get_unmapped_area(struct file *file,
-	unsigned long addr, unsigned long len, unsigned long pgoff,
-	unsigned long flags)
+static unsigned long shm_get_unmapped_area(struct mm_struct *mm,
+	struct file *file, unsigned long addr, unsigned long len,
+	unsigned long pgoff, unsigned long flags)
 {
 	struct shm_file_data *sfd = shm_file_data(file);
 
-	return sfd->file->f_op->get_unmapped_area(sfd->file, addr, len,
-						pgoff, flags);
+	return sfd->file->f_op->get_unmapped_area(mm, sfd->file, addr, len,
+						  pgoff, flags);
 }
 
 static const struct file_operations shm_file_operations = {
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index d416f3baf392..ed95aae0f386 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1142,7 +1142,7 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 
 	if (!area->vaddr) {
 		/* Try to map as high as possible, this is only a hint. */
-		area->vaddr = get_unmapped_area(NULL, TASK_SIZE - PAGE_SIZE,
+		area->vaddr = get_unmapped_area(mm, NULL, TASK_SIZE - PAGE_SIZE,
 						PAGE_SIZE, 0, 0);
 		if (area->vaddr & ~PAGE_MASK) {
 			ret = area->vaddr;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5f3ad65c85de..d5b2604867e5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -499,8 +499,9 @@ void prep_transhuge_page(struct page *page)
 	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
 
-unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
-		loff_t off, unsigned long flags, unsigned long size)
+unsigned long __thp_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long len, loff_t off, unsigned long flags,
+		unsigned long size)
 {
 	unsigned long addr;
 	loff_t off_end = off + len;
@@ -514,8 +515,8 @@ unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
 	if (len_pad < len || (off + len_pad) < off)
 		return 0;
 
-	addr = current->mm->get_unmapped_area(filp, 0, len_pad,
-					      off >> PAGE_SHIFT, flags);
+	addr = mm->get_unmapped_area(mm, filp, 0, len_pad, off >> PAGE_SHIFT,
+				     flags);
 	if (IS_ERR_VALUE(addr))
 		return 0;
 
@@ -523,8 +524,9 @@ unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
 	return addr;
 }
 
-unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long thp_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
 	loff_t off = (loff_t)pgoff << PAGE_SHIFT;
 
@@ -533,12 +535,12 @@ unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
 	if (!IS_DAX(filp->f_mapping->host) || !IS_ENABLED(CONFIG_FS_DAX_PMD))
 		goto out;
 
-	addr = __thp_get_unmapped_area(filp, len, off, flags, PMD_SIZE);
+	addr = __thp_get_unmapped_area(mm, filp, len, off, flags, PMD_SIZE);
 	if (addr)
 		return addr;
 
  out:
-	return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
+	return mm->get_unmapped_area(mm, filp, addr, len, pgoff, flags);
 }
 EXPORT_SYMBOL_GPL(thp_get_unmapped_area);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index ea79bc4da5b7..8a73dc458e69 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1339,7 +1339,7 @@ unsigned long do_mmap(struct mm_struct *mm, struct file *file,
 	/* Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
 	 */
-	addr = get_unmapped_area(file, addr, len, pgoff, flags);
+	addr = get_unmapped_area(mm, file, addr, len, pgoff, flags);
 	if (offset_in_page(addr))
 		return addr;
 
@@ -1742,7 +1742,8 @@ unsigned long mmap_region(struct mm_struct *mm, struct file *file,
 	return error;
 }
 
-unsigned long unmapped_area(struct vm_unmapped_area_info *info)
+unsigned long unmapped_area(struct mm_struct *mm,
+			    struct vm_unmapped_area_info *info)
 {
 	/*
 	 * We implement the search by looking for an rbtree node that
@@ -1752,7 +1753,6 @@ unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 	 * - gap_end - gap_start >= length
 	 */
 
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long length, low_limit, high_limit, gap_start, gap_end;
 
@@ -1844,9 +1844,9 @@ unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 	return gap_start;
 }
 
-unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
+unsigned long unmapped_area_topdown(struct mm_struct *mm,
+				    struct vm_unmapped_area_info *info)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long length, low_limit, high_limit, gap_start, gap_end;
 
@@ -1955,10 +1955,10 @@ unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
  */
 #ifndef HAVE_ARCH_UNMAPPED_AREA
 unsigned long
-arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
+arch_get_unmapped_area(struct mm_struct *mm, struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct vm_unmapped_area_info info;
 
@@ -1981,7 +1981,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.low_limit = mm->mmap_base;
 	info.high_limit = TASK_SIZE;
 	info.align_mask = 0;
-	return vm_unmapped_area(&info);
+	return vm_unmapped_area(mm, &info);
 }
 #endif
 
@@ -1991,12 +1991,11 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
  */
 #ifndef HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+arch_get_unmapped_area_topdown(struct mm_struct *mm, struct file *filp,
+			  const unsigned long addr0, const unsigned long len,
+			  const unsigned long pgoff, const unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 
@@ -2021,7 +2020,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.low_limit = max(PAGE_SIZE, mmap_min_addr);
 	info.high_limit = mm->mmap_base;
 	info.align_mask = 0;
-	addr = vm_unmapped_area(&info);
+	addr = vm_unmapped_area(mm, &info);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
@@ -2034,7 +2033,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
-		addr = vm_unmapped_area(&info);
+		addr = vm_unmapped_area(mm, &info);
 	}
 
 	return addr;
@@ -2042,11 +2041,12 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 #endif
 
 unsigned long
-get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
-		unsigned long pgoff, unsigned long flags)
+get_unmapped_area(struct mm_struct *mm, struct file *file, unsigned long addr,
+		  unsigned long len, unsigned long pgoff, unsigned long flags)
 {
-	unsigned long (*get_area)(struct file *, unsigned long,
-				  unsigned long, unsigned long, unsigned long);
+	unsigned long (*get_area)(struct mm_struct *, struct file *,
+				  unsigned long, unsigned long, unsigned long,
+				  unsigned long);
 
 	unsigned long error = arch_mmap_check(addr, len, flags);
 	if (error)
@@ -2056,7 +2056,7 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
-	get_area = current->mm->get_unmapped_area;
+	get_area = mm->get_unmapped_area;
 	if (file) {
 		if (file->f_op->get_unmapped_area)
 			get_area = file->f_op->get_unmapped_area;
@@ -2070,7 +2070,7 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 		get_area = shmem_get_unmapped_area;
 	}
 
-	addr = get_area(file, addr, len, pgoff, flags);
+	addr = get_area(mm, file, addr, len, pgoff, flags);
 	if (IS_ERR_VALUE(addr))
 		return addr;
 
@@ -2819,7 +2819,7 @@ static int do_brk(unsigned long addr, unsigned long request)
 
 	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
 
-	error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
+	error = get_unmapped_area(mm, NULL, addr, len, 0, MAP_FIXED);
 	if (offset_in_page(error))
 		return error;
 
diff --git a/mm/mremap.c b/mm/mremap.c
index 30d7d2482eea..f085eed57bac 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -452,8 +452,9 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (vma->vm_flags & VM_MAYSHARE)
 		map_flags |= MAP_SHARED;
 
-	ret = get_unmapped_area(vma->vm_file, new_addr, new_len, vma->vm_pgoff +
-				((addr - vma->vm_start) >> PAGE_SHIFT),
+	ret = get_unmapped_area(mm, vma->vm_file, new_addr, new_len,
+				vma->vm_pgoff +
+					((addr - vma->vm_start) >> PAGE_SHIFT),
 				map_flags);
 	if (offset_in_page(ret))
 		goto out1;
@@ -475,8 +476,8 @@ static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
 		return 0;
 	if (vma->vm_next && vma->vm_next->vm_start < end) /* intersection */
 		return 0;
-	if (get_unmapped_area(NULL, vma->vm_start, end - vma->vm_start,
-			      0, MAP_FIXED) & ~PAGE_MASK)
+	if (get_unmapped_area(vma->vm_mm, NULL, vma->vm_start,
+			      end - vma->vm_start, 0, MAP_FIXED) & ~PAGE_MASK)
 		return 0;
 	return 1;
 }
@@ -583,7 +584,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		if (vma->vm_flags & VM_MAYSHARE)
 			map_flags |= MAP_SHARED;
 
-		new_addr = get_unmapped_area(vma->vm_file, 0, new_len,
+		new_addr = get_unmapped_area(mm, vma->vm_file, 0, new_len,
 					vma->vm_pgoff +
 					((addr - vma->vm_start) >> PAGE_SHIFT),
 					map_flags);
diff --git a/mm/nommu.c b/mm/nommu.c
index 54825d29f50b..5075a56b75ec 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1333,8 +1333,9 @@ unsigned long do_mmap(struct mm_struct *mm,
 		 *   tell us the location of a shared mapping
 		 */
 		if (capabilities & NOMMU_MAP_DIRECT) {
-			addr = file->f_op->get_unmapped_area(file, addr, len,
-							     pgoff, flags);
+			addr = file->f_op->get_unmapped_area(mm, file, addr,
+							     len, pgoff,
+							     flags);
 			if (IS_ERR_VALUE(addr)) {
 				ret = addr;
 				if (ret != -ENOSYS)
@@ -1782,8 +1783,9 @@ int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 }
 EXPORT_SYMBOL(remap_vmalloc_range);
 
-unsigned long arch_get_unmapped_area(struct file *file, unsigned long addr,
-	unsigned long len, unsigned long pgoff, unsigned long flags)
+unsigned long arch_get_unmapped_area(struct mm_struct *mm, struct file *file,
+	unsigned long addr, unsigned long len, unsigned long pgoff,
+	unsigned long flags)
 {
 	return -ENOMEM;
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index 3a7587a0314d..5e27727c05a8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1971,11 +1971,11 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return ret;
 }
 
-unsigned long shmem_get_unmapped_area(struct file *file,
+unsigned long shmem_get_unmapped_area(struct mm_struct *mm, struct file *file,
 				      unsigned long uaddr, unsigned long len,
 				      unsigned long pgoff, unsigned long flags)
 {
-	unsigned long (*get_area)(struct file *,
+	unsigned long (*get_area)(struct mm_struct *mm, struct file *,
 		unsigned long, unsigned long, unsigned long, unsigned long);
 	unsigned long addr;
 	unsigned long offset;
@@ -1986,8 +1986,8 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
-	get_area = current->mm->get_unmapped_area;
-	addr = get_area(file, uaddr, len, pgoff, flags);
+	get_area = mm->get_unmapped_area;
+	addr = get_area(mm, file, uaddr, len, pgoff, flags);
 
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
 		return addr;
@@ -2043,7 +2043,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 	if (inflated_len < len)
 		return addr;
 
-	inflated_addr = get_area(NULL, 0, inflated_len, 0, flags);
+	inflated_addr = get_area(mm, NULL, 0, inflated_len, 0, flags);
 	if (IS_ERR_VALUE(inflated_addr))
 		return addr;
 	if (inflated_addr & ~PAGE_MASK)
@@ -3971,11 +3971,11 @@ void shmem_unlock_mapping(struct address_space *mapping)
 }
 
 #ifdef CONFIG_MMU
-unsigned long shmem_get_unmapped_area(struct file *file,
+unsigned long shmem_get_unmapped_area(struct mm_struct *mm, struct file *file,
 				      unsigned long addr, unsigned long len,
 				      unsigned long pgoff, unsigned long flags)
 {
-	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+	return mm->get_unmapped_area(mm, file, addr, len, pgoff, flags);
 }
 #endif
 
diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
index 9d33c1e85c79..f3d2ee8ecf9f 100644
--- a/sound/core/pcm_native.c
+++ b/sound/core/pcm_native.c
@@ -3649,7 +3649,8 @@ static int snd_pcm_hw_params_old_user(struct snd_pcm_substream *substream,
 #endif /* CONFIG_SND_SUPPORT_OLD_API */
 
 #ifndef CONFIG_MMU
-static unsigned long snd_pcm_get_unmapped_area(struct file *file,
+static unsigned long snd_pcm_get_unmapped_area(struct mm_struct *mm,
+					       struct file *file,
 					       unsigned long addr,
 					       unsigned long len,
 					       unsigned long pgoff,
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
