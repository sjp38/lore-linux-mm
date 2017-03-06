Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id F054F6B03CA
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 09:21:24 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f103so158992800ioi.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 06:21:24 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0131.outbound.protection.outlook.com. [104.47.2.131])
        by mx.google.com with ESMTPS id 70si8500204ioo.245.2017.03.06.06.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 06:21:23 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv6 3/5] x86/mm: introduce mmap_compat_base for 32-bit mmap()
Date: Mon, 6 Mar 2017 17:17:19 +0300
Message-ID: <20170306141721.9188-4-dsafonov@virtuozzo.com>
In-Reply-To: <20170306141721.9188-1-dsafonov@virtuozzo.com>
References: <20170306141721.9188-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

mmap() uses base address, from which it starts to look for a free space
for allocation. At this moment there is one mm->mmap_base, which is
calculated during exec(). The address depends on task's size, set rlimit
for stack, ASLR randomization. As task size and number of random bits
differ between 64 and 32 bit applications, calculated mmap_base will
be valid only for the same bitness.
That means e.g., that calculated mmap_base for ELF64 lies upper than
4Gb, which results in bug that 32-bit mmap() syscall will start to
search for a free address over 32-bit address space and returns only
lower 4-bytes of allocated mapping.
As 64-bit applications can do 32-bit syscalls and vice-versa, we need
to correctly chose mmap_base address for syscalls of different bitness.
For this purpose introduce mmap_compat_base and mmap_compat_legacy_base,
use them accordingly in top-down and bottom-up allocations in 32-bit
syscalls, use existed bases mmap_base and mmap_legacy_base for 64-bit
syscalls.
That means that each application on x86_64 will have now two bases
(or four if count legacy bases also) which are calculated on application
exec(). I guess we can relax the calculation of bases until first mmap()
call, but don't think it's worth.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/Kconfig                 |  7 +++++++
 arch/x86/Kconfig             |  1 +
 arch/x86/include/asm/elf.h   |  3 +++
 arch/x86/kernel/sys_x86_64.c | 23 +++++++++++++++++++----
 arch/x86/mm/mmap.c           | 41 ++++++++++++++++++++++++++++-------------
 include/linux/mm_types.h     |  5 +++++
 6 files changed, 63 insertions(+), 17 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index cd211a14a88f..c4d6833aacd9 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -700,6 +700,13 @@ config ARCH_MMAP_RND_COMPAT_BITS
 	  This value can be changed after boot using the
 	  /proc/sys/vm/mmap_rnd_compat_bits tunable
 
+config HAVE_ARCH_COMPAT_MMAP_BASES
+	bool
+	help
+	  This allows 64bit applications to invoke 32-bit mmap() syscall
+	  and vice-versa 32-bit applications to call 64-bit mmap().
+	  Required for applications doing different bitness syscalls.
+
 config HAVE_COPY_THREAD_TLS
 	bool
 	help
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cc98d5a294ee..2bab9d093b51 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -106,6 +106,7 @@ config X86
 	select HAVE_ARCH_KMEMCHECK
 	select HAVE_ARCH_MMAP_RND_BITS		if MMU
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
+	select HAVE_ARCH_COMPAT_MMAP_BASES	if MMU && COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index b908141cf0c4..ac5be5ba8527 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -303,6 +303,9 @@ static inline int mmap_is_ia32(void)
 		test_thread_flag(TIF_ADDR32));
 }
 
+extern unsigned long tasksize_32bit(void);
+extern unsigned long tasksize_64bit(void);
+
 #ifdef CONFIG_X86_32
 
 #define __STACK_RND_MASK(is32bit) (0x7ff)
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 50215a4b9347..c54817baabc7 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -17,6 +17,8 @@
 #include <linux/uaccess.h>
 #include <linux/elf.h>
 
+#include <asm/elf.h>
+#include <asm/compat.h>
 #include <asm/ia32.h>
 #include <asm/syscalls.h>
 
@@ -98,6 +100,18 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 	return error;
 }
 
+static unsigned long get_mmap_base(int is_legacy)
+{
+	struct mm_struct *mm = current->mm;
+
+#ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
+	if (in_compat_syscall())
+		return is_legacy ? mm->mmap_compat_legacy_base
+				 : mm->mmap_compat_base;
+#endif
+	return is_legacy ? mm->mmap_legacy_base : mm->mmap_base;
+}
+
 static void find_start_end(unsigned long flags, unsigned long *begin,
 			   unsigned long *end)
 {
@@ -114,10 +128,11 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 		if (current->flags & PF_RANDOMIZE) {
 			*begin = randomize_page(*begin, 0x02000000);
 		}
-	} else {
-		*begin = current->mm->mmap_legacy_base;
-		*end = TASK_SIZE;
+		return;
 	}
+
+	*begin	= get_mmap_base(1);
+	*end	= in_compat_syscall() ? tasksize_32bit() : tasksize_64bit();
 }
 
 unsigned long
@@ -191,7 +206,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = mm->mmap_base;
+	info.high_limit = get_mmap_base(0);
 	info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	if (filp) {
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 1e9cb945dca1..84a0ffc550fe 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -36,11 +36,16 @@ struct va_alignment __read_mostly va_align = {
 	.flags = -1,
 };
 
-static inline unsigned long tasksize_32bit(void)
+unsigned long tasksize_32bit(void)
 {
 	return IA32_PAGE_OFFSET;
 }
 
+unsigned long tasksize_64bit(void)
+{
+	return TASK_SIZE_MAX;
+}
+
 static unsigned long stack_maxrandom_size(unsigned long task_size)
 {
 	unsigned long max = 0;
@@ -81,6 +86,8 @@ static unsigned long arch_rnd(unsigned int rndbits)
 
 unsigned long arch_mmap_rnd(void)
 {
+	if (!(current->flags & PF_RANDOMIZE))
+		return 0;
 	return arch_rnd(mmap_is_ia32() ? mmap32_rnd_bits : mmap64_rnd_bits);
 }
 
@@ -114,22 +121,30 @@ static unsigned long mmap_legacy_base(unsigned long rnd,
  * This function, called very early during the creation of a new
  * process VM image, sets up which VM layout function to use:
  */
-void arch_pick_mmap_layout(struct mm_struct *mm)
+static void arch_pick_mmap_base(unsigned long *base, unsigned long *legacy_base,
+		unsigned long random_factor, unsigned long task_size)
 {
-	unsigned long random_factor = 0UL;
-
-	if (current->flags & PF_RANDOMIZE)
-		random_factor = arch_mmap_rnd();
-
-	mm->mmap_legacy_base = mmap_legacy_base(random_factor, TASK_SIZE);
+	*legacy_base = mmap_legacy_base(random_factor, task_size);
+	if (mmap_is_legacy())
+		*base = *legacy_base;
+	else
+		*base = mmap_base(random_factor, task_size);
+}
 
-	if (mmap_is_legacy()) {
-		mm->mmap_base = mm->mmap_legacy_base;
+void arch_pick_mmap_layout(struct mm_struct *mm)
+{
+	if (mmap_is_legacy())
 		mm->get_unmapped_area = arch_get_unmapped_area;
-	} else {
-		mm->mmap_base = mmap_base(random_factor, TASK_SIZE);
+	else
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-	}
+
+	arch_pick_mmap_base(&mm->mmap_base, &mm->mmap_legacy_base,
+			arch_rnd(mmap64_rnd_bits), tasksize_64bit());
+
+#ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
+	arch_pick_mmap_base(&mm->mmap_compat_base, &mm->mmap_compat_legacy_base,
+			arch_rnd(mmap32_rnd_bits), tasksize_32bit());
+#endif
 }
 
 const char *arch_vma_name(struct vm_area_struct *vma)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f60f45fe226f..45cdb27791a3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -367,6 +367,11 @@ struct mm_struct {
 #endif
 	unsigned long mmap_base;		/* base of mmap area */
 	unsigned long mmap_legacy_base;         /* base of mmap area in bottom-up allocations */
+#ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
+	/* Base adresses for compatible mmap() */
+	unsigned long mmap_compat_base;
+	unsigned long mmap_compat_legacy_base;
+#endif
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long highest_vm_end;		/* highest vma end address */
 	pgd_t * pgd;
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
