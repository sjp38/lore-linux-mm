Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 036516B025E
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:00:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so364908152pfb.7
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:00:52 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20111.outbound.protection.outlook.com. [40.107.2.111])
        by mx.google.com with ESMTPS id c85si5460162pfk.224.2017.01.27.13.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 13:00:51 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 3/5] x86/mm: fix 32-bit mmap() for 64-bit ELF
Date: Sat, 28 Jan 2017 00:00:27 +0300
Message-ID: <20170127210029.31566-4-dsafonov@virtuozzo.com>
In-Reply-To: <20170127210029.31566-1-dsafonov@virtuozzo.com>
References: <20170127210029.31566-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

Fix 32-bit compat_sys_mmap() mapping VMA over 4Gb in 64-bit binaries
and 64-bit sys_mmap() mapping VMA only under 4Gb in 32-bit binaries.
Introduced new bases for compat syscalls in mm_struct:
mmap_compat_base and mmap_compat_legacy_base for top-down and
bottom-up allocations accordingly.
Taught arch_get_unmapped_area{,_topdown}() to use the new mmap_bases
in compat syscalls for high/low limits in vm_unmapped_area().

I discovered that bug on ZDTM tests for compat 32-bit C/R.
Working compat sys_mmap() in 64-bit binaries is really needed for that
purpose, as 32-bit applications are restored from 64-bit CRIU binary.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/Kconfig                 |  7 +++++++
 arch/x86/Kconfig             |  1 +
 arch/x86/kernel/sys_x86_64.c | 28 ++++++++++++++++++++++++----
 arch/x86/mm/mmap.c           | 27 ++++++++++++++++++++-------
 include/linux/mm_types.h     |  5 +++++
 5 files changed, 57 insertions(+), 11 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 99839c23d453..6bdca6d86855 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -671,6 +671,13 @@ config ARCH_MMAP_RND_COMPAT_BITS
 	  This value can be changed after boot using the
 	  /proc/sys/vm/mmap_rnd_compat_bits tunable
 
+config HAVE_ARCH_COMPAT_MMAP_BASES
+	bool
+	help
+	  If this is set, one program can do native and compatible syscall
+	  mmap() on architecture. Thus kernel has different bases to
+	  compute high and low virtual address limits for allocation.
+
 config HAVE_COPY_THREAD_TLS
 	bool
 	help
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e487493bbd47..b3acb836567a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -102,6 +102,7 @@ config X86
 	select HAVE_ARCH_KMEMCHECK
 	select HAVE_ARCH_MMAP_RND_BITS		if MMU
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
+	select HAVE_ARCH_COMPAT_MMAP_BASES	if MMU && COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index a55ed63b9f91..90be0839441d 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -16,6 +16,7 @@
 #include <linux/uaccess.h>
 #include <linux/elf.h>
 
+#include <asm/compat.h>
 #include <asm/ia32.h>
 #include <asm/syscalls.h>
 
@@ -113,10 +114,19 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 		if (current->flags & PF_RANDOMIZE) {
 			*begin = randomize_page(*begin, 0x02000000);
 		}
-	} else {
-		*begin = current->mm->mmap_legacy_base;
-		*end = TASK_SIZE;
+		return;
 	}
+
+#ifdef CONFIG_COMPAT
+	if (in_compat_syscall()) {
+		*begin = current->mm->mmap_compat_legacy_base;
+		*end = IA32_PAGE_OFFSET;
+		return;
+	}
+#endif
+
+	*begin = current->mm->mmap_legacy_base;
+	*end = TASK_SIZE_MAX;
 }
 
 unsigned long
@@ -157,6 +167,16 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	return vm_unmapped_area(&info);
 }
 
+static unsigned long find_top(void)
+{
+#ifdef CONFIG_COMPAT
+	if (in_compat_syscall())
+		return current->mm->mmap_compat_base;
+	else
+#endif
+		return current->mm->mmap_base;
+}
+
 unsigned long
 arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			  const unsigned long len, const unsigned long pgoff,
@@ -190,7 +210,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = mm->mmap_base;
+	info.high_limit = find_top();
 	info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	if (filp) {
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 98be520fd270..17b11ce07dcb 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -112,6 +112,16 @@ static unsigned long mmap_legacy_base(unsigned long rnd,
  * This function, called very early during the creation of a new
  * process VM image, sets up which VM layout function to use:
  */
+static void arch_pick_mmap_base(unsigned long *base, unsigned long *legacy_base,
+		unsigned long random_factor, unsigned long task_size)
+{
+	*legacy_base =  mmap_legacy_base(random_factor, task_size);
+	if (mmap_is_legacy())
+		*base = *legacy_base;
+	else
+		*base = mmap_base(random_factor, task_size);
+}
+
 void arch_pick_mmap_layout(struct mm_struct *mm)
 {
 	unsigned long random_factor = 0UL;
@@ -119,15 +129,18 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (current->flags & PF_RANDOMIZE)
 		random_factor = arch_mmap_rnd();
 
-	mm->mmap_legacy_base = mmap_legacy_base(random_factor, TASK_SIZE);
-
-	if (mmap_is_legacy()) {
-		mm->mmap_base = mm->mmap_legacy_base;
+	if (mmap_is_legacy())
 		mm->get_unmapped_area = arch_get_unmapped_area;
-	} else {
-		mm->mmap_base = mmap_base(random_factor, TASK_SIZE);
+	else
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-	}
+
+	arch_pick_mmap_base(&mm->mmap_base, &mm->mmap_legacy_base,
+			random_factor, TASK_SIZE_MAX);
+
+#ifdef CONFIG_COMPAT
+	arch_pick_mmap_base(&mm->mmap_compat_base, &mm->mmap_compat_legacy_base,
+			random_factor, IA32_PAGE_OFFSET);
+#endif
 }
 
 const char *arch_vma_name(struct vm_area_struct *vma)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 808751d7b737..48274a84cebe 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -404,6 +404,11 @@ struct mm_struct {
 #endif
 	unsigned long mmap_base;		/* base of mmap area */
 	unsigned long mmap_legacy_base;         /* base of mmap area in bottom-up allocations */
+#ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
+	/* Base addresses for compatible mmap() */
+	unsigned long mmap_compat_base;
+	unsigned long mmap_compat_legacy_base;
+#endif
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long highest_vm_end;		/* highest vma end address */
 	pgd_t * pgd;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
