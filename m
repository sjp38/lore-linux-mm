Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 762026B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 10:58:48 -0400 (EDT)
Received: by bkbzt12 with SMTP id zt12so348695bkb.14
        for <linux-mm@kvack.org>; Wed, 07 Sep 2011 07:58:41 -0700 (PDT)
Date: Wed, 7 Sep 2011 18:58:26 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFCv2] x86, mm: start mmap allocation for libs from low addresses
Message-ID: <20110907145826.GA16378@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: kernel-hardening@lists.openwall.com, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch changes mmap base address allocator logic to incline to
allocate addresses for executable pages from the first 16 MBs of address
space.  These addresses start from zero byte (0x00AABBCC).  Using such
addresses breaks ret2libc exploits abusing string buffer overflows (or
makes such attacks harder and/or less reliable).

As x86 architecture is little-endian, this zero byte is the last byte of
the address.  So it's possible to e.g. overwrite a return address on the
stack with the malformed address.  However, now it's impossible to
additionally provide function arguments, which are located after the
function address on the stack.  The attacker's best bet may be to find
an entry point not at function boundary that sets registers and then
proceeds with or branches to the desired library code.  The easiest way
to set registers and branch would be a function epilogue.  Then it may
be similarly difficult to reliably pass register values and a further
address to branch to, because the desired values for these will also
tend to contain NULs - e.g., the address of "/bin/sh" in libc or a zero
value for root's uid.  A possible bypass is via multiple overflows - if
the overflow may be triggered more than once before the vulnerable
function returns, then multiple NULs may be written, exactly one per
overflow.  But this is hopefully relatively rare.

To fully utilize the protection, the executable image should be
randomized (sysctl kernel.randomize_va_space > 0 and the executable is
compiled as PIE) and the sum of libraries sizes plus executable size
shouldn't exceed 16 MBs.  In this case the only pages out of
ASCII-protected range are VDSO and vsyscall pages.  However, they don't
provide enough material for obtaining arbitrary code execution and are
not dangerous without using other executable pages.

The logic is applied to x86 32 bit tasks, both for 32 bit kernels and
for 32 bit tasks running on 64 bit kernels.  64 bit tasks already have
zero bytes in addresses of library functions.  Other architectures
(non-x86) may reuse the logic too.

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
	librt.so.1 => /lib/librt.so.1 (0x0004a000)
	libtermcap.so.2 => /lib/libtermcap.so.2 (0x0005e000)
	libc.so.6 => /lib/libc.so.6 (0x00062000)
	libpthread.so.0 => /lib/libpthread.so.0 (0x00183000)
	/lib/ld-linux.so.2 (0x00121000)


If CONFIG_VM86=y, the first 1 MB + 64 KBs are excluded from the potential
range for mmap allocations as it might be used by vm86 code.  If
CONFIG_VM86=n, the allocation begins from 128 KBs to protect against
userspace NULL pointer dereferences (or from mmap_min_addr if it is
bigger than 128 KBs).  Regardless of CONFIG_VM86 the base address is
randomized with the same entropy size as mm->mmap_base.

If 16 MBs are over, we fallback to the old allocation algorithm.
But, hopefully, programs which need such protection (network daemons,
programs working with untrusted data, etc.) are small enough to utilize
the protection.

The same logic was used in -ow patch for 2.0-2.4 kernels and in
exec-shield for 2.6.x kernels.  Code parts were taken from exec-shield
from RHEL6.


v2 - Added comments, adjusted patch description.
   - s/arch_get_unmapped_exec_area/get_unmapped_exec_area/
   - Don't reserve the first 1 MB + 64 KBs if CONFIG_VM86=n.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
--
 arch/x86/mm/mmap.c       |   23 ++++++++++++
 include/linux/mm_types.h |    4 ++
 include/linux/sched.h    |    3 ++
 mm/mmap.c                |   87 +++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 112 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 1dab519..0bbbb3d 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -118,6 +118,25 @@ static unsigned long mmap_legacy_base(void)
 		return TASK_UNMAPPED_BASE + mmap_rnd();
 }
 
+#ifdef CONFIG_VM86
+/*
+ * Don't touch any memory that can be addressed by vm86 apps.
+ * Reserve the first 1 MB + 64 KBs.
+ */
+#define ASCII_ARMOR_MIN_ADDR 0x00110000
+#else
+/*
+ * No special users of low addresses.
+ * Reserve the first 128 KBs to detect NULL pointer dereferences.
+ */
+#define ASCII_ARMOR_MIN_ADDR 0x00020000
+#endif
+
+static unsigned long mmap_lib_base(void)
+{
+	return ASCII_ARMOR_MIN_ADDR + mmap_rnd();
+}
+
 /*
  * This function, called very early during the creation of a new
  * process VM image, sets up which VM layout function to use:
@@ -131,6 +150,10 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	} else {
 		mm->mmap_base = mmap_base();
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
+		if (mmap_is_ia32()) {
+			mm->get_unmapped_exec_area = get_unmapped_exec_area;
+			mm->lib_mmap_base = mmap_lib_base();
+		}
 		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 027935c..68fc216 100644
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
+	unsigned long lib_mmap_base;		/* base of mmap libraries area (for get_unmapped_exec_area()) */
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
 	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f024c63..ef9024f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -394,6 +394,9 @@ arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 			  unsigned long flags);
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
+extern unsigned long
+get_unmapped_exec_area(struct file *, unsigned long,
+		unsigned long, unsigned long, unsigned long);
 #else
 static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
 #endif
diff --git a/mm/mmap.c b/mm/mmap.c
index d49736f..cb81804 100644
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
 
@@ -1528,6 +1533,67 @@ bottomup:
 }
 #endif
 
+/* Addresses before this value contain at least one zero byte. */
+#define ASCII_ARMOR_MAX_ADDR 0x01000000
+
+/*
+ * This function finds the first unmapped region inside of
+ * [mm->lib_mmap_base; ASCII_ARMOR_MAX_ADDR) region.  Addresses from this
+ * region contain at least one zero byte, which complicates
+ * exploitation of C string buffer overflows (C strings cannot contain zero
+ * byte inside) in return to libc class of attacks.
+ *
+ * This allocator is bottom up allocator like arch_get_unmapped_area(), but
+ * it differs from the latter.  get_unmapped_exec_area() does its best to
+ * allocate as low address as possible.
+ */
+unsigned long
+get_unmapped_exec_area(struct file *filp, unsigned long addr0,
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
+	 * with zero high bits is a scarce and valuable resource */
+	addr = max_t(unsigned long, mm->lib_mmap_base, mmap_min_addr);
+
+	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+		/* At this point:  (!vma || addr < vma->vm_end). */
+		if (addr > TASK_SIZE - len)
+			return -ENOMEM;
+
+		/*
+		 * If kernel.randomize_va_space < 2, the executable is built as
+		 * non-PIE, and exec image base is lower than ASCII_ARMOR_MAX_ADDR,
+		 * it's possible to touch or overrun brk area in ASCII-armor
+		 * zone.  We don't want to reduce future brk growth, so we
+		 * fallback to the default allocator in this case.
+		 */
+		if (mm->brk && addr + len > mm->brk)
+			goto failed;
+
+		if (!vma || addr + len <= vma->vm_start)
+			return addr;
+
+		addr = vma->vm_end;
+
+		/* If ACSII-armor area is over, the algo gives up */
+		if (addr >= ASCII_ARMOR_MAX_ADDR)
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
@@ -1541,9 +1607,9 @@ void arch_unmap_area_topdown(struct mm_struct *mm, unsigned long addr)
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
@@ -1556,7 +1622,11 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
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
@@ -1571,6 +1641,13 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
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

-- 
Vasiliy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
