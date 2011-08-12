Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 174186B00EE
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 06:30:04 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so2213303bkb.14
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 03:29:58 -0700 (PDT)
Date: Fri, 12 Aug 2011 14:29:54 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFC] x86, mm: start mmap allocation for libs from low addresses
Message-ID: <20110812102954.GA3496@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: kernel-hardening@lists.openwall.com, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch changes mmap base address allocator logic to incline to
allocate addresses from the first 16 Mbs of address space.  These
addresses start from zero byte (0x00AABBCC).  Using such addresses
breaks ret2libc exploits abusing string buffer overflows.  As library
addresses contain zero byte, addresses of library functions may not
present in the string, which is used to overflow the buffer.  As a
result, it makes it impossible to change the return address on the stack
to the address of some library function (e.g. system(3)).

The logic is applied to 32 bit tasks, both for 32 bit kernels and for 32
bit tasks running on 64 bit kernels.  64 bit tasks already have zero
bytes in addresses of library functions.  Other architectures may reuse
the logic.

The first Mb is excluded from the range because of the compatibility with
programs like Wine and Dosemu.

If the sum of libraries sizes plus executable size doesn't exceed 15 Mb,
the only pages out of ASCII-protected range are VDSO and vsyscall.
However, they don't provide enough material for obtaining arbitrary code
execution and are not dangerous without using other executable pages.

If 16 Mbs are over, we fallback to the old allocation algorithm.

Without the patch:

$ ldd /bin/ls
	linux-gate.so.1 =>  (0xf779c000)
        librt.so.1 => /lib/librt.so.1 (0xb7fcf000)
        libtermcap.so.2 => /lib/libtermcap.so.2 (0xb7fca000)
        libc.so.6 => /lib/libc.so.6 (0xb7eae000)
        libpthread.so.0 => /lib/libpthread.so.0 (0xb7e5b000)
        /lib/ld-linux.so.2 (0xb7fe6000)

With the patch:

$ ldd /bin/ls
	linux-gate.so.1 =>  (0xf772a000)
	librt.so.1 => /lib/librt.so.1 (0x0014a000)
	libtermcap.so.2 => /lib/libtermcap.so.2 (0x0015e000)
	libc.so.6 => /lib/libc.so.6 (0x00162000)
	libpthread.so.0 => /lib/libpthread.so.0 (0x00283000)
	/lib/ld-linux.so.2 (0x00131000)

The same logic was used in -ow patch for 2.0-2.4 kernels and in
exec-shield for 2.6.x kernels.  Parts of the code were taken from RHEL6
version of exec-shield.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
--
 arch/x86/mm/mmap.c       |    5 +++
 include/linux/mm_types.h |    4 +++
 include/linux/sched.h    |    3 ++
 mm/mmap.c                |   66 ++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 73 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 1dab519..0c82a94 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -131,6 +131,11 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	} else {
 		mm->mmap_base = mmap_base();
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
+		if (mmap_is_ia32()) {
+			mm->get_unmapped_exec_area =
+				arch_get_unmapped_exec_area;
+			mm->lib_mmap_base = 0x00110000 + mmap_rnd();
+		}
 		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 027935c..5f2dca9 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -225,9 +225,13 @@ struct mm_struct {
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
+	unsigned long (*get_unmapped_exec_area) (struct file *filp,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags);
 	void (*unmap_area) (struct mm_struct *mm, unsigned long addr);
 #endif
 	unsigned long mmap_base;		/* base of mmap area */
+	unsigned long lib_mmap_base;		/* base of mmap libraries area (includes zero symbol) */
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
 	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f024c63..8feaba9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -394,6 +394,9 @@ arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 			  unsigned long flags);
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
+extern unsigned long
+arch_get_unmapped_exec_area(struct file *, unsigned long,
+		unsigned long, unsigned long, unsigned long);
 #else
 static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
 #endif
diff --git a/mm/mmap.c b/mm/mmap.c
index d49736f..489510c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -50,6 +50,10 @@ static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
 
+static unsigned long
+get_unmapped_area_prot(struct file *file, unsigned long addr, unsigned long len,
+		unsigned long pgoff, unsigned long flags, bool exec);
+
 /*
  * WARNING: the debugging will use recursive algorithms so never enable this
  * unless you know what you are doing.
@@ -989,7 +993,8 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	/* Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
 	 */
-	addr = get_unmapped_area(file, addr, len, pgoff, flags);
+	addr = get_unmapped_area_prot(file, addr, len, pgoff, flags,
+			prot & PROT_EXEC);
 	if (addr & ~PAGE_MASK)
 		return addr;
 
@@ -1528,6 +1533,46 @@ bottomup:
 }
 #endif
 
+unsigned long
+arch_get_unmapped_exec_area(struct file *filp, unsigned long addr0,
+		unsigned long len, unsigned long pgoff, unsigned long flags)
+{
+	unsigned long addr = addr0;
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+
+	if (len > TASK_SIZE)
+		return -ENOMEM;
+
+	if (flags & MAP_FIXED)
+		return addr;
+
+	/* We ALWAYS start from the beginning as base addresses
+	 * with zero high bits is a valued resource */
+	addr = max_t(unsigned long, mm->lib_mmap_base, mmap_min_addr);
+
+	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+		/* At this point:  (!vma || addr < vma->vm_end). */
+		if (TASK_SIZE - len < addr)
+			return -ENOMEM;
+
+		/* We don't want to touch brk of not DYNAMIC elf binaries */
+		if (mm->brk && addr > mm->brk)
+			goto failed;
+
+		if (!vma || addr + len <= vma->vm_start)
+			return addr;
+
+		addr = vma->vm_end;
+		/* If 0x01000000 is touched, the algo gives up */
+		if (addr >= 0x01000000)
+			goto failed;
+	}
+
+failed:
+	return current->mm->get_unmapped_area(filp, addr0, len, pgoff, flags);
+}
+
 void arch_unmap_area_topdown(struct mm_struct *mm, unsigned long addr)
 {
 	/*
@@ -1541,9 +1586,9 @@ void arch_unmap_area_topdown(struct mm_struct *mm, unsigned long addr)
 		mm->free_area_cache = mm->mmap_base;
 }
 
-unsigned long
-get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
-		unsigned long pgoff, unsigned long flags)
+static unsigned long
+get_unmapped_area_prot(struct file *file, unsigned long addr, unsigned long len,
+		unsigned long pgoff, unsigned long flags, bool exec)
 {
 	unsigned long (*get_area)(struct file *, unsigned long,
 				  unsigned long, unsigned long, unsigned long);
@@ -1556,7 +1601,11 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
-	get_area = current->mm->get_unmapped_area;
+	if (exec && current->mm->get_unmapped_exec_area)
+		get_area = current->mm->get_unmapped_exec_area;
+	else
+		get_area = current->mm->get_unmapped_area;
+
 	if (file && file->f_op && file->f_op->get_unmapped_area)
 		get_area = file->f_op->get_unmapped_area;
 	addr = get_area(file, addr, len, pgoff, flags);
@@ -1571,6 +1620,13 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 	return arch_rebalance_pgtables(addr, len);
 }
 
+unsigned long
+get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
+		unsigned long pgoff, unsigned long flags)
+{
+	return get_unmapped_area_prot(file, addr, len, pgoff, flags, false);
+}
+
 EXPORT_SYMBOL(get_unmapped_area);
 
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
