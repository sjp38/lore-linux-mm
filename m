Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 450676B0260
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 07:04:55 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id j82so371136142oih.6
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 04:04:55 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40109.outbound.protection.outlook.com. [40.107.4.109])
        by mx.google.com with ESMTPS id r188si5335530oib.142.2017.01.30.04.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 04:04:54 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv4 2/5] x86/mm: introduce mmap{,_legacy}_base
Date: Mon, 30 Jan 2017 15:04:29 +0300
Message-ID: <20170130120432.6716-3-dsafonov@virtuozzo.com>
In-Reply-To: <20170130120432.6716-1-dsafonov@virtuozzo.com>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

In the following patch they will be used to compute:
- mmap{,_legacy}_base for 64-bit mmap()
- mmap_compat{,_legacy}_base for 32-bit mmap()

This patch makes it possible to calculate mmap bases for any specified
task_size, which is needed to correctly choose the base address for mmap
in 32-bit syscalls and 64-bit syscalls.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/asm/elf.h       |  4 +++-
 arch/x86/include/asm/processor.h |  3 ++-
 arch/x86/mm/mmap.c               | 32 ++++++++++++++++++++------------
 3 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index e7f155c3045e..120b4f3d8a6a 100644
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
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 1be64da0384e..52086e65b422 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -862,7 +862,8 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define _TASK_UNMAPPED_BASE(task_size)	(PAGE_ALIGN(task_size / 3))
+#define TASK_UNMAPPED_BASE	_TASK_UNMAPPED_BASE(TASK_SIZE)
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 42063e787717..98be520fd270 100644
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
@@ -88,16 +90,22 @@ unsigned long arch_mmap_rnd(void)
 	return arch_native_rnd();
 }
 
-static unsigned long mmap_base(unsigned long rnd)
+static unsigned long mmap_base(unsigned long rnd, unsigned long task_size)
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
+static unsigned long mmap_legacy_base(unsigned long rnd,
+		unsigned long task_size)
+{
+	return _TASK_UNMAPPED_BASE(task_size) + rnd;
 }
 
 /*
@@ -111,13 +119,13 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
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
