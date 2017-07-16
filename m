Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5759A6B04AB
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 19:00:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e199so150301196pfh.7
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 16:00:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x5si11693999pgb.583.2017.07.16.16.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 16:00:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/8] x86/mm: Rename tasksize_32bit/64bit to task_size_32bit/64bit
Date: Mon, 17 Jul 2017 01:59:50 +0300
Message-Id: <20170716225954.74185-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
References: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Rename these helpers to be consistent with spelling of TASK_SIZE and
related constants.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/elf.h   |  4 ++--
 arch/x86/kernel/sys_x86_64.c |  2 +-
 arch/x86/mm/hugetlbpage.c    |  2 +-
 arch/x86/mm/mmap.c           | 10 +++++-----
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 1c18d83d3f09..c7090ef1388e 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -304,8 +304,8 @@ static inline int mmap_is_ia32(void)
 		test_thread_flag(TIF_ADDR32));
 }
 
-extern unsigned long tasksize_32bit(void);
-extern unsigned long tasksize_64bit(void);
+extern unsigned long task_size_32bit(void);
+extern unsigned long task_size_64bit(void);
 extern unsigned long get_mmap_base(int is_legacy);
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 213ddf3e937d..89bd0d6460e1 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -120,7 +120,7 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 	}
 
 	*begin	= get_mmap_base(1);
-	*end	= in_compat_syscall() ? tasksize_32bit() : tasksize_64bit();
+	*end	= in_compat_syscall() ? task_size_32bit() : task_size_64bit();
 }
 
 unsigned long
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 2824607df108..868f02cf58ce 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -86,7 +86,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 	info.length = len;
 	info.low_limit = get_mmap_base(1);
 	info.high_limit = in_compat_syscall() ?
-		tasksize_32bit() : tasksize_64bit();
+		task_size_32bit() : task_size_64bit();
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	return vm_unmapped_area(&info);
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 229d04a83f85..d2586913c8d0 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -37,12 +37,12 @@ struct va_alignment __read_mostly va_align = {
 	.flags = -1,
 };
 
-unsigned long tasksize_32bit(void)
+unsigned long task_size_32bit(void)
 {
 	return IA32_PAGE_OFFSET;
 }
 
-unsigned long tasksize_64bit(void)
+unsigned long task_size_64bit(void)
 {
 	return TASK_SIZE_MAX;
 }
@@ -52,7 +52,7 @@ static unsigned long stack_maxrandom_size(unsigned long task_size)
 	unsigned long max = 0;
 	if ((current->flags & PF_RANDOMIZE) &&
 		!(current->personality & ADDR_NO_RANDOMIZE)) {
-		max = (-1UL) & __STACK_RND_MASK(task_size == tasksize_32bit());
+		max = (-1UL) & __STACK_RND_MASK(task_size == task_size_32bit());
 		max <<= PAGE_SHIFT;
 	}
 
@@ -142,7 +142,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 
 	arch_pick_mmap_base(&mm->mmap_base, &mm->mmap_legacy_base,
-			arch_rnd(mmap64_rnd_bits), tasksize_64bit());
+			arch_rnd(mmap64_rnd_bits), task_size_64bit());
 
 #ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
 	/*
@@ -152,7 +152,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	 * mmap_base, the compat syscall uses mmap_compat_base.
 	 */
 	arch_pick_mmap_base(&mm->mmap_compat_base, &mm->mmap_compat_legacy_base,
-			arch_rnd(mmap32_rnd_bits), tasksize_32bit());
+			arch_rnd(mmap32_rnd_bits), task_size_32bit());
 #endif
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
