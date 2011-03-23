Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BE5B48D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:47:29 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 resend 05/12] mm: arch: rename in_gate_area_no_task to in_gate_area_no_mm
Date: Wed, 23 Mar 2011 10:43:54 -0400
Message-Id: <1300891441-16280-6-git-send-email-wilsons@start.ca>
In-Reply-To: <1300891441-16280-1-git-send-email-wilsons@start.ca>
References: <1300891441-16280-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

Now that gate vma's are referenced with respect to a particular mm and not a
particular task it only makes sense to propagate the change to this predicate as
well.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: Michel Lespinasse <walken@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/powerpc/kernel/vdso.c         |    2 +-
 arch/s390/kernel/vdso.c            |    2 +-
 arch/sh/kernel/vsyscall/vsyscall.c |    2 +-
 arch/x86/mm/init_64.c              |    8 ++++----
 arch/x86/vdso/vdso32-setup.c       |    2 +-
 include/linux/mm.h                 |    6 +++---
 kernel/kallsyms.c                  |    4 ++--
 mm/memory.c                        |    2 +-
 mm/nommu.c                         |    2 +-
 9 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 467aa9e..142ab10 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -820,7 +820,7 @@ static int __init vdso_init(void)
 }
 arch_initcall(vdso_init);
 
-int in_gate_area_no_task(unsigned long addr)
+int in_gate_area_no_mm(unsigned long addr)
 {
 	return 0;
 }
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 9006e96..d73630b 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -337,7 +337,7 @@ static int __init vdso_init(void)
 }
 arch_initcall(vdso_init);
 
-int in_gate_area_no_task(unsigned long addr)
+int in_gate_area_no_mm(unsigned long addr)
 {
 	return 0;
 }
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index 62c36a8..1d6d51a 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -104,7 +104,7 @@ int in_gate_area(struct mm_struct *mm, unsigned long address)
 	return 0;
 }
 
-int in_gate_area_no_task(unsigned long address)
+int in_gate_area_no_mm(unsigned long address)
 {
 	return 0;
 }
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 4deb881..560113c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -890,11 +890,11 @@ int in_gate_area(struct mm_struct *mm, unsigned long addr)
 }
 
 /*
- * Use this when you have no reliable task/vma, typically from interrupt
- * context. It is less reliable than using the task's vma and may give
- * false positives:
+ * Use this when you have no reliable mm, typically from interrupt
+ * context. It is less reliable than using a task's mm and may give
+ * false positives.
  */
-int in_gate_area_no_task(unsigned long addr)
+int in_gate_area_no_mm(unsigned long addr)
 {
 	return (addr >= VSYSCALL_START) && (addr < VSYSCALL_END);
 }
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index f849bb2..468d591 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -435,7 +435,7 @@ int in_gate_area(struct mm_struct *mm, unsigned long addr)
 	return vma && addr >= vma->vm_start && addr < vma->vm_end;
 }
 
-int in_gate_area_no_task(unsigned long addr)
+int in_gate_area_no_mm(unsigned long addr)
 {
 	return 0;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c700bbb..694512d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1570,11 +1570,11 @@ static inline bool kernel_page_present(struct page *page) { return true; }
 
 extern struct vm_area_struct *get_gate_vma(struct mm_struct *mm);
 #ifdef	__HAVE_ARCH_GATE_AREA
-int in_gate_area_no_task(unsigned long addr);
+int in_gate_area_no_mm(unsigned long addr);
 int in_gate_area(struct mm_struct *mm, unsigned long addr);
 #else
-int in_gate_area_no_task(unsigned long addr);
-#define in_gate_area(mm, addr) ({(void)mm; in_gate_area_no_task(addr);})
+int in_gate_area_no_mm(unsigned long addr);
+#define in_gate_area(mm, addr) ({(void)mm; in_gate_area_no_mm(addr);})
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
 int drop_caches_sysctl_handler(struct ctl_table *, int,
diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
index 6f6d091..b9d0fd1 100644
--- a/kernel/kallsyms.c
+++ b/kernel/kallsyms.c
@@ -64,14 +64,14 @@ static inline int is_kernel_text(unsigned long addr)
 	if ((addr >= (unsigned long)_stext && addr <= (unsigned long)_etext) ||
 	    arch_is_kernel_text(addr))
 		return 1;
-	return in_gate_area_no_task(addr);
+	return in_gate_area_no_mm(addr);
 }
 
 static inline int is_kernel(unsigned long addr)
 {
 	if (addr >= (unsigned long)_stext && addr <= (unsigned long)_end)
 		return 1;
-	return in_gate_area_no_task(addr);
+	return in_gate_area_no_mm(addr);
 }
 
 static int is_ksym_addr(unsigned long addr)
diff --git a/mm/memory.c b/mm/memory.c
index d1347ac..3863e86 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3448,7 +3448,7 @@ struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 #endif
 }
 
-int in_gate_area_no_task(unsigned long addr)
+int in_gate_area_no_mm(unsigned long addr)
 {
 #ifdef AT_SYSINFO_EHDR
 	if ((addr >= FIXADDR_USER_START) && (addr < FIXADDR_USER_END))
diff --git a/mm/nommu.c b/mm/nommu.c
index f59e142..e629143 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1963,7 +1963,7 @@ error:
 	return -ENOMEM;
 }
 
-int in_gate_area_no_task(unsigned long addr)
+int in_gate_area_no_mm(unsigned long addr)
 {
 	return 0;
 }
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
