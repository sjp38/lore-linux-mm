Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6009A6B0260
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:36:42 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so249646400pfb.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:36:42 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00117.outbound.protection.outlook.com. [40.107.0.117])
        by mx.google.com with ESMTPS id b69si894209pli.199.2017.01.16.04.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 04:36:41 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 2/5] x86/mm: introduce mmap_{,legacy}_base
Date: Mon, 16 Jan 2017 15:33:07 +0300
Message-ID: <20170116123310.22697-3-dsafonov@virtuozzo.com>
In-Reply-To: <20170116123310.22697-1-dsafonov@virtuozzo.com>
References: <20170116123310.22697-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

In the following patch they will be used to compute:
- mmap_base in compat sys_mmap() in native 64-bit binary
and vice-versa
- mmap_base for native sys_mmap() in compat x32/ia32-bit binary.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/asm/elf.h       |  9 +++++++--
 arch/x86/include/asm/processor.h |  2 +-
 arch/x86/mm/hugetlbpage.c        |  2 +-
 arch/x86/mm/mmap.c               | 31 +++++++++++++++++++------------
 4 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index ee1a87782b2c..9655a8390da4 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -286,6 +286,7 @@ do {									\
 
 #ifdef CONFIG_X86_32
 
+#define STACK_RND_MASK_MODE(native) (0x7ff)
 #define STACK_RND_MASK (0x7ff)
 
 #define ARCH_DLINFO		ARCH_DLINFO_IA32
@@ -295,7 +296,8 @@ do {									\
 #else /* CONFIG_X86_32 */
 
 /* 1GB for 64bit, 8MB for 32bit */
-#define STACK_RND_MASK (test_thread_flag(TIF_ADDR32) ? 0x7ff : 0x3fffff)
+#define STACK_RND_MASK_MODE(native) ((native) ? 0x3fffff : 0x7ff)
+#define STACK_RND_MASK STACK_RND_MASK_MODE(!test_thread_flag(TIF_ADDR32))
 
 #define ARCH_DLINFO							\
 do {									\
@@ -320,7 +322,7 @@ if (test_thread_flag(TIF_X32))						\
 else									\
 	ARCH_DLINFO_IA32
 
-#define COMPAT_ELF_ET_DYN_BASE	(TASK_UNMAPPED_BASE + 0x1000000)
+#define COMPAT_ELF_ET_DYN_BASE	(TASK_UNMAPPED_BASE(TASK_SIZE) + 0x1000000)
 
 #endif /* !CONFIG_X86_32 */
 
@@ -353,6 +355,9 @@ static inline int mmap_is_ia32(void)
 extern unsigned long arch_compat_rnd(void);
 #endif
 extern unsigned long arch_native_rnd(void);
+extern unsigned long mmap_base(unsigned long rnd, unsigned long task_size);
+extern unsigned long mmap_legacy_base(unsigned long rnd,
+					unsigned long task_size);
 
 /* Do not change the values. See get_align_mask() */
 enum align_flags {
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index eaf100508c36..2bf5787fac37 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -844,7 +844,7 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define TASK_UNMAPPED_BASE(task_size)	(PAGE_ALIGN(task_size / 3))
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 2ae8584b44c7..62dfa3fa3ee0 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -113,7 +113,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = TASK_UNMAPPED_BASE(TASK_SIZE);
 		info.high_limit = TASK_SIZE;
 		addr = vm_unmapped_area(&info);
 	}
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 0b2007b08194..b64362270165 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -35,12 +35,14 @@ struct va_alignment __read_mostly va_align = {
 	.flags = -1,
 };
 
-static unsigned long stack_maxrandom_size(void)
+static unsigned long stack_maxrandom_size(unsigned long task_size)
 {
 	unsigned long max = 0;
 	if ((current->flags & PF_RANDOMIZE) &&
 		!(current->personality & ADDR_NO_RANDOMIZE)) {
-		max = ((-1UL) & STACK_RND_MASK) << PAGE_SHIFT;
+		max = (-1UL);
+		max &= STACK_RND_MASK_MODE(task_size == TASK_SIZE_MAX);
+		max <<= PAGE_SHIFT;
 	}
 
 	return max;
@@ -51,8 +53,8 @@ static unsigned long stack_maxrandom_size(void)
  *
  * Leave an at least ~128 MB hole with possible stack randomization.
  */
-#define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
-#define MAX_GAP (TASK_SIZE/6*5)
+#define MIN_GAP(task_size) (128*1024*1024UL + stack_maxrandom_size(task_size))
+#define MAX_GAP(task_size) (task_size/6*5)
 
 static int mmap_is_legacy(void)
 {
@@ -88,16 +90,21 @@ unsigned long arch_mmap_rnd(void)
 	return arch_native_rnd();
 }
 
-static unsigned long mmap_base(unsigned long rnd)
+unsigned long mmap_base(unsigned long rnd, unsigned long task_size)
 {
 	unsigned long gap = rlimit(RLIMIT_STACK);
 
-	if (gap < MIN_GAP)
-		gap = MIN_GAP;
-	else if (gap > MAX_GAP)
-		gap = MAX_GAP;
+	if (gap < MIN_GAP(task_size))
+		gap = MIN_GAP(task_size);
+	else if (gap > MAX_GAP(task_size))
+		gap = MAX_GAP(task_size);
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(task_size - gap - rnd);
+}
+
+unsigned long mmap_legacy_base(unsigned long rnd, unsigned long task_size)
+{
+	return TASK_UNMAPPED_BASE(task_size) + rnd;
 }
 
 /*
@@ -111,13 +118,13 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
