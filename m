Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4FED6B03B6
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 13:40:25 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 203so38848390ith.3
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:40:25 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0106.outbound.protection.outlook.com. [104.47.2.106])
        by mx.google.com with ESMTPS id e196si3650532ita.89.2017.02.14.10.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Feb 2017 10:40:24 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv5 2/5] x86/mm: add task_size parameter to mmap_base()
Date: Tue, 14 Feb 2017 21:36:18 +0300
Message-ID: <20170214183621.2537-3-dsafonov@virtuozzo.com>
In-Reply-To: <20170214183621.2537-1-dsafonov@virtuozzo.com>
References: <20170214183621.2537-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>

To correctly handle 32-bit and 64-bit mmap() syscalls, we need different
mmap bases to start allocation from. So, introduce mmap_legacy_base()
helper and change mmap_base() to return base address according to
specified task size.
It'll prepare the mmap base computing code for splitting mmap_base
on two bases: for 64-bit syscall and for 32-bit syscalls.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/asm/elf.h       | 24 ++++++++++---------
 arch/x86/include/asm/processor.h |  4 +++-
 arch/x86/mm/mmap.c               | 50 +++++++++++++++++++++++++---------------
 3 files changed, 48 insertions(+), 30 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index e7f155c3045e..8aedc2a4d48c 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -284,8 +284,19 @@ do {									\
 	}								\
 } while (0)
 
+/*
+ * True on X86_32 or when emulating IA32 on X86_64
+ */
+static inline int mmap_is_ia32(void)
+{
+	return IS_ENABLED(CONFIG_X86_32) ||
+	       (IS_ENABLED(CONFIG_COMPAT) &&
+		test_thread_flag(TIF_ADDR32));
+}
+
 #ifdef CONFIG_X86_32
 
+#define __STACK_RND_MASK(is32bit) (0x7ff)
 #define STACK_RND_MASK (0x7ff)
 
 #define ARCH_DLINFO		ARCH_DLINFO_IA32
@@ -295,7 +306,8 @@ do {									\
 #else /* CONFIG_X86_32 */
 
 /* 1GB for 64bit, 8MB for 32bit */
-#define STACK_RND_MASK (test_thread_flag(TIF_ADDR32) ? 0x7ff : 0x3fffff)
+#define __STACK_RND_MASK(is32bit) ((is32bit) ? 0x7ff : 0x3fffff)
+#define STACK_RND_MASK __STACK_RND_MASK(mmap_is_ia32())
 
 #define ARCH_DLINFO							\
 do {									\
@@ -339,16 +351,6 @@ extern int compat_arch_setup_additional_pages(struct linux_binprm *bprm,
 					      int uses_interp);
 #define compat_arch_setup_additional_pages compat_arch_setup_additional_pages
 
-/*
- * True on X86_32 or when emulating IA32 on X86_64
- */
-static inline int mmap_is_ia32(void)
-{
-	return IS_ENABLED(CONFIG_X86_32) ||
-	       (IS_ENABLED(CONFIG_COMPAT) &&
-		test_thread_flag(TIF_ADDR32));
-}
-
 /* Do not change the values. See get_align_mask() */
 enum align_flags {
 	ALIGN_VA_32	= BIT(0),
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index e6cfe7ba2d65..491f5a05a133 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -787,6 +787,7 @@ static inline void spin_lock_prefetch(const void *x)
 /*
  * User space process size: 3GB (default).
  */
+#define IA32_PAGE_OFFSET	PAGE_OFFSET
 #define TASK_SIZE		PAGE_OFFSET
 #define TASK_SIZE_MAX		TASK_SIZE
 #define STACK_TOP		TASK_SIZE
@@ -863,7 +864,8 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define __TASK_UNMAPPED_BASE(task_size)	(PAGE_ALIGN(task_size / 3))
+#define TASK_UNMAPPED_BASE		__TASK_UNMAPPED_BASE(TASK_SIZE)
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 9f3ac019e51c..88ef0c1b0e51 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -35,25 +35,23 @@ struct va_alignment __read_mostly va_align = {
 	.flags = -1,
 };
 
-static unsigned long stack_maxrandom_size(void)
+static inline unsigned long tasksize_32bit(void)
+{
+	return IA32_PAGE_OFFSET;
+}
+
+static unsigned long stack_maxrandom_size(unsigned long task_size)
 {
 	unsigned long max = 0;
 	if ((current->flags & PF_RANDOMIZE) &&
 		!(current->personality & ADDR_NO_RANDOMIZE)) {
-		max = ((-1UL) & STACK_RND_MASK) << PAGE_SHIFT;
+		max = (-1UL) & __STACK_RND_MASK(task_size == tasksize_32bit());
+		max <<= PAGE_SHIFT;
 	}
 
 	return max;
 }
 
-/*
- * Top of mmap area (just below the process stack).
- *
- * Leave an at least ~128 MB hole with possible stack randomization.
- */
-#define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
-#define MAX_GAP (TASK_SIZE/6*5)
-
 #ifdef CONFIG_64BIT
 # define mmap32_rnd_bits  mmap_rnd_compat_bits
 # define mmap64_rnd_bits  mmap_rnd_bits
@@ -62,6 +60,8 @@ static unsigned long stack_maxrandom_size(void)
 # define mmap64_rnd_bits  mmap_rnd_bits
 #endif
 
+#define SIZE_128M    (128 * 1024 * 1024UL)
+
 static int mmap_is_legacy(void)
 {
 	if (current->personality & ADDR_COMPAT_LAYOUT)
@@ -83,16 +83,30 @@ unsigned long arch_mmap_rnd(void)
 	return arch_rnd(mmap_is_ia32() ? mmap32_rnd_bits : mmap64_rnd_bits);
 }
 
-static unsigned long mmap_base(unsigned long rnd)
+static unsigned long mmap_base(unsigned long rnd, unsigned long task_size)
 {
 	unsigned long gap = rlimit(RLIMIT_STACK);
+	unsigned long gap_min, gap_max;
+
+	/*
+	 * Top of mmap area (just below the process stack).
+	 * Leave an at least ~128 MB hole with possible stack randomization.
+	 */
+	gap_min = SIZE_128M + stack_maxrandom_size(task_size);
+	gap_max = (task_size / 6) * 5;
 
-	if (gap < MIN_GAP)
-		gap = MIN_GAP;
-	else if (gap > MAX_GAP)
-		gap = MAX_GAP;
+	if (gap < gap_min)
+		gap = gap_min;
+	else if (gap > gap_max)
+		gap = gap_max;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(task_size - gap - rnd);
+}
+
+static unsigned long mmap_legacy_base(unsigned long rnd,
+				      unsigned long task_size)
+{
+	return __TASK_UNMAPPED_BASE(task_size) + rnd;
 }
 
 /*
@@ -106,13 +120,13 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (current->flags & PF_RANDOMIZE)
 		random_factor = arch_mmap_rnd();
 
-	mm->mmap_legacy_base = TASK_UNMAPPED_BASE + random_factor;
+	mm->mmap_legacy_base = mmap_legacy_base(random_factor, TASK_SIZE);
 
 	if (mmap_is_legacy()) {
 		mm->mmap_base = mm->mmap_legacy_base;
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
-		mm->mmap_base = mmap_base(random_factor);
+		mm->mmap_base = mmap_base(random_factor, TASK_SIZE);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 	}
 }
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
