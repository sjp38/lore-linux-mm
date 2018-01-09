Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE6B46B0260
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:23:22 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t65so11074487pfe.22
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:23:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14sor508044pgt.156.2018.01.09.12.23.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:23:20 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 1/3] exec: Pass stack rlimit into mm layout functions
Date: Tue,  9 Jan 2018 12:23:01 -0800
Message-Id: <1515529383-35695-2-git-send-email-keescook@chromium.org>
In-Reply-To: <1515529383-35695-1-git-send-email-keescook@chromium.org>
References: <1515529383-35695-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Rik van Riel <riel@redhat.com>, Laura Abbott <labbott@redhat.com>, Greg KH <greg@kroah.com>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Since it is possible that the stack rlimit can change externally during
exec (either via another thread calling setrlimit() or another process
calling prlimit()), provide a way to pass the rlimit down into the
per-architecture mm layout functions so that the rlimit can stay in the
bprm structure instead of sitting in the signal structure until exec is
finalized.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/mm/mmap.c               | 14 +++++++-------
 arch/arm64/mm/mmap.c             | 14 +++++++-------
 arch/mips/mm/mmap.c              | 14 +++++++-------
 arch/parisc/kernel/sys_parisc.c  | 16 +++++++++++-----
 arch/powerpc/mm/mmap.c           | 28 ++++++++++++++++------------
 arch/s390/mm/mmap.c              | 15 ++++++++-------
 arch/sparc/kernel/sys_sparc_64.c |  4 ++--
 arch/tile/mm/mmap.c              | 11 ++++++-----
 arch/x86/mm/mmap.c               | 18 +++++++++++-------
 fs/exec.c                        |  8 +++++++-
 include/linux/sched/mm.h         |  6 ++++--
 mm/util.c                        |  2 +-
 12 files changed, 87 insertions(+), 63 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index eb1de66517d5..f866870db749 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -21,20 +21,20 @@
 #define MIN_GAP (128*1024*1024UL)
 #define MAX_GAP ((TASK_SIZE)/6*5)
 
-static int mmap_is_legacy(void)
+static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
 	if (current->personality & ADDR_COMPAT_LAYOUT)
 		return 1;
 
-	if (rlimit(RLIMIT_STACK) == RLIM_INFINITY)
+	if (rlim_stack->rlim_cur == RLIM_INFINITY)
 		return 1;
 
 	return sysctl_legacy_va_layout;
 }
 
-static unsigned long mmap_base(unsigned long rnd)
+static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
-	unsigned long gap = rlimit(RLIMIT_STACK);
+	unsigned long gap = rlim_stack->rlim_cur;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
@@ -180,18 +180,18 @@ unsigned long arch_mmap_rnd(void)
 	return rnd << PAGE_SHIFT;
 }
 
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	unsigned long random_factor = 0UL;
 
 	if (current->flags & PF_RANDOMIZE)
 		random_factor = arch_mmap_rnd();
 
-	if (mmap_is_legacy()) {
+	if (mmap_is_legacy(rlim_stack)) {
 		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
-		mm->mmap_base = mmap_base(random_factor);
+		mm->mmap_base = mmap_base(random_factor, rlim_stack);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 	}
 }
diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index decccffb03ca..842c8a5fcd53 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -38,12 +38,12 @@
 #define MIN_GAP (SZ_128M)
 #define MAX_GAP	(STACK_TOP/6*5)
 
-static int mmap_is_legacy(void)
+static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
 	if (current->personality & ADDR_COMPAT_LAYOUT)
 		return 1;
 
-	if (rlimit(RLIMIT_STACK) == RLIM_INFINITY)
+	if (rlim_stack->rlim_cur == RLIM_INFINITY)
 		return 1;
 
 	return sysctl_legacy_va_layout;
@@ -62,9 +62,9 @@ unsigned long arch_mmap_rnd(void)
 	return rnd << PAGE_SHIFT;
 }
 
-static unsigned long mmap_base(unsigned long rnd)
+static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
-	unsigned long gap = rlimit(RLIMIT_STACK);
+	unsigned long gap = rlim_stack->rlim_cur;
 	unsigned long pad = (STACK_RND_MASK << PAGE_SHIFT) + stack_guard_gap;
 
 	/* Values close to RLIM_INFINITY can overflow. */
@@ -83,7 +83,7 @@ static unsigned long mmap_base(unsigned long rnd)
  * This function, called very early during the creation of a new process VM
  * image, sets up which VM layout function to use:
  */
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	unsigned long random_factor = 0UL;
 
@@ -94,11 +94,11 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	 * Fall back to the standard layout if the personality bit is set, or
 	 * if the expected stack growth is unlimited:
 	 */
-	if (mmap_is_legacy()) {
+	if (mmap_is_legacy(rlim_stack)) {
 		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
-		mm->mmap_base = mmap_base(random_factor);
+		mm->mmap_base = mmap_base(random_factor, rlim_stack);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 	}
 }
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 33d3251ecd37..2f616ebeb7e0 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -24,20 +24,20 @@ EXPORT_SYMBOL(shm_align_mask);
 #define MIN_GAP (128*1024*1024UL)
 #define MAX_GAP ((TASK_SIZE)/6*5)
 
-static int mmap_is_legacy(void)
+static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
 	if (current->personality & ADDR_COMPAT_LAYOUT)
 		return 1;
 
-	if (rlimit(RLIMIT_STACK) == RLIM_INFINITY)
+	if (rlim_stack->rlim_cur == RLIM_INFINITY)
 		return 1;
 
 	return sysctl_legacy_va_layout;
 }
 
-static unsigned long mmap_base(unsigned long rnd)
+static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
-	unsigned long gap = rlimit(RLIMIT_STACK);
+	unsigned long gap = rlim_stack->rlim_cur;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
@@ -158,18 +158,18 @@ unsigned long arch_mmap_rnd(void)
 	return rnd << PAGE_SHIFT;
 }
 
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	unsigned long random_factor = 0UL;
 
 	if (current->flags & PF_RANDOMIZE)
 		random_factor = arch_mmap_rnd();
 
-	if (mmap_is_legacy()) {
+	if (mmap_is_legacy(rlim_stack)) {
 		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
-		mm->mmap_base = mmap_base(random_factor);
+		mm->mmap_base = mmap_base(random_factor, rlim_stack);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 	}
 }
diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index 378a754ca186..ff9289626d42 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -70,12 +70,18 @@ static inline unsigned long COLOR_ALIGN(unsigned long addr,
  * Top of mmap area (just below the process stack).
  */
 
-static unsigned long mmap_upper_limit(void)
+/*
+ * When called from arch_get_unmapped_area(), rlim_stack will be NULL,
+ * indicating that "current" should be used instead of a passed-in
+ * value from the exec bprm as done with arch_pick_mmap_layout().
+ */
+static unsigned long mmap_upper_limit(struct rlimit *rlim_stack)
 {
 	unsigned long stack_base;
 
 	/* Limit stack size - see setup_arg_pages() in fs/exec.c */
-	stack_base = rlimit_max(RLIMIT_STACK);
+	stack_base = rlim_stack ? rlim_stack->rlim_max
+				: rlimit_max(RLIMIT_STACK);
 	if (stack_base > STACK_SIZE_MAX)
 		stack_base = STACK_SIZE_MAX;
 
@@ -127,7 +133,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = mm->mmap_legacy_base;
-	info.high_limit = mmap_upper_limit();
+	info.high_limit = mmap_upper_limit(NULL);
 	info.align_mask = last_mmap ? (PAGE_MASK & (SHM_COLOUR - 1)) : 0;
 	info.align_offset = shared_align_offset(last_mmap, pgoff);
 	addr = vm_unmapped_area(&info);
@@ -250,10 +256,10 @@ static unsigned long mmap_legacy_base(void)
  * This function, called very early during the creation of a new
  * process VM image, sets up which VM layout function to use:
  */
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	mm->mmap_legacy_base = mmap_legacy_base();
-	mm->mmap_base = mmap_upper_limit();
+	mm->mmap_base = mmap_upper_limit(rlim_stack);
 
 	if (mmap_is_legacy()) {
 		mm->mmap_base = mm->mmap_legacy_base;
diff --git a/arch/powerpc/mm/mmap.c b/arch/powerpc/mm/mmap.c
index d503f344e476..b24ce40acd47 100644
--- a/arch/powerpc/mm/mmap.c
+++ b/arch/powerpc/mm/mmap.c
@@ -39,12 +39,12 @@
 #define MIN_GAP (128*1024*1024)
 #define MAX_GAP (TASK_SIZE/6*5)
 
-static inline int mmap_is_legacy(void)
+static inline int mmap_is_legacy(struct rlimit *rlim_stack)
 {
 	if (current->personality & ADDR_COMPAT_LAYOUT)
 		return 1;
 
-	if (rlimit(RLIMIT_STACK) == RLIM_INFINITY)
+	if (rlim_stack->rlim_cur == RLIM_INFINITY)
 		return 1;
 
 	return sysctl_legacy_va_layout;
@@ -76,9 +76,10 @@ static inline unsigned long stack_maxrandom_size(void)
 		return (1<<30);
 }
 
-static inline unsigned long mmap_base(unsigned long rnd)
+static inline unsigned long mmap_base(unsigned long rnd,
+				      struct rlimit *rlim_stack)
 {
-	unsigned long gap = rlimit(RLIMIT_STACK);
+	unsigned long gap = rlim_stack->rlim_cur;
 	unsigned long pad = stack_maxrandom_size() + stack_guard_gap;
 
 	/* Values close to RLIM_INFINITY can overflow. */
@@ -196,26 +197,28 @@ radix__arch_get_unmapped_area_topdown(struct file *filp,
 }
 
 static void radix__arch_pick_mmap_layout(struct mm_struct *mm,
-					unsigned long random_factor)
+					unsigned long random_factor,
+					struct rlimit *rlim_stack)
 {
-	if (mmap_is_legacy()) {
+	if (mmap_is_legacy(rlim_stack)) {
 		mm->mmap_base = TASK_UNMAPPED_BASE;
 		mm->get_unmapped_area = radix__arch_get_unmapped_area;
 	} else {
-		mm->mmap_base = mmap_base(random_factor);
+		mm->mmap_base = mmap_base(random_factor, rlim_stack);
 		mm->get_unmapped_area = radix__arch_get_unmapped_area_topdown;
 	}
 }
 #else
 /* dummy */
 extern void radix__arch_pick_mmap_layout(struct mm_struct *mm,
-					unsigned long random_factor);
+					unsigned long random_factor,
+					struct rlimit *rlim_stack);
 #endif
 /*
  * This function, called very early during the creation of a new
  * process VM image, sets up which VM layout function to use:
  */
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	unsigned long random_factor = 0UL;
 
@@ -223,16 +226,17 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 		random_factor = arch_mmap_rnd();
 
 	if (radix_enabled())
-		return radix__arch_pick_mmap_layout(mm, random_factor);
+		return radix__arch_pick_mmap_layout(mm, random_factor,
+						    rlim_stack);
 	/*
 	 * Fall back to the standard layout if the personality
 	 * bit is set, or if the expected stack growth is unlimited:
 	 */
-	if (mmap_is_legacy()) {
+	if (mmap_is_legacy(rlim_stack)) {
 		mm->mmap_base = TASK_UNMAPPED_BASE;
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
-		mm->mmap_base = mmap_base(random_factor);
+		mm->mmap_base = mmap_base(random_factor, rlim_stack);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 	}
 }
diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
index 831bdcf407bb..0a7627cdb34e 100644
--- a/arch/s390/mm/mmap.c
+++ b/arch/s390/mm/mmap.c
@@ -37,11 +37,11 @@ static unsigned long stack_maxrandom_size(void)
 #define MIN_GAP (32*1024*1024)
 #define MAX_GAP (STACK_TOP/6*5)
 
-static inline int mmap_is_legacy(void)
+static inline int mmap_is_legacy(struct rlimit *rlim_stack)
 {
 	if (current->personality & ADDR_COMPAT_LAYOUT)
 		return 1;
-	if (rlimit(RLIMIT_STACK) == RLIM_INFINITY)
+	if (rlim_stack->rlim_cur == RLIM_INFINITY)
 		return 1;
 	return sysctl_legacy_va_layout;
 }
@@ -56,9 +56,10 @@ static unsigned long mmap_base_legacy(unsigned long rnd)
 	return TASK_UNMAPPED_BASE + rnd;
 }
 
-static inline unsigned long mmap_base(unsigned long rnd)
+static inline unsigned long mmap_base(unsigned long rnd,
+				      struct rlimit *rlim_stack)
 {
-	unsigned long gap = rlimit(RLIMIT_STACK);
+	unsigned long gap = rlim_stack->rlim_cur;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
@@ -184,7 +185,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
  * This function, called very early during the creation of a new
  * process VM image, sets up which VM layout function to use:
  */
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	unsigned long random_factor = 0UL;
 
@@ -195,11 +196,11 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	 * Fall back to the standard layout if the personality
 	 * bit is set, or if the expected stack growth is unlimited:
 	 */
-	if (mmap_is_legacy()) {
+	if (mmap_is_legacy(rlim_stack)) {
 		mm->mmap_base = mmap_base_legacy(random_factor);
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
-		mm->mmap_base = mmap_base(random_factor);
+		mm->mmap_base = mmap_base(random_factor, rlim_stack);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 	}
 }
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index 55416db482ad..2f896fecd01f 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -276,7 +276,7 @@ static unsigned long mmap_rnd(void)
 	return rnd << PAGE_SHIFT;
 }
 
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	unsigned long random_factor = mmap_rnd();
 	unsigned long gap;
@@ -285,7 +285,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	 * Fall back to the standard layout if the personality
 	 * bit is set, or if the expected stack growth is unlimited:
 	 */
-	gap = rlimit(RLIMIT_STACK);
+	gap = rlim_stack->rlim_cur;
 	if (!test_thread_flag(TIF_32BIT) ||
 	    (current->personality & ADDR_COMPAT_LAYOUT) ||
 	    gap == RLIM_INFINITY ||
diff --git a/arch/tile/mm/mmap.c b/arch/tile/mm/mmap.c
index 8ab28167c44b..26366d694e0e 100644
--- a/arch/tile/mm/mmap.c
+++ b/arch/tile/mm/mmap.c
@@ -30,9 +30,10 @@
 #define MIN_GAP (128*1024*1024)
 #define MAX_GAP (TASK_SIZE/6*5)
 
-static inline unsigned long mmap_base(struct mm_struct *mm)
+static inline unsigned long mmap_base(struct mm_struct *mm,
+				      struct rlimit *rlim_stack)
 {
-	unsigned long gap = rlimit(RLIMIT_STACK);
+	unsigned long gap = rlim_stack->rlim_cur;
 	unsigned long random_factor = 0;
 
 	if (current->flags & PF_RANDOMIZE)
@@ -50,7 +51,7 @@ static inline unsigned long mmap_base(struct mm_struct *mm)
  * This function, called very early during the creation of a new
  * process VM image, sets up which VM layout function to use:
  */
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 #if !defined(__tilegx__)
 	int is_32bit = 1;
@@ -78,11 +79,11 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	 * Use standard layout if the expected stack growth is unlimited
 	 * or we are running native 64 bits.
 	 */
-	if (rlimit(RLIMIT_STACK) == RLIM_INFINITY) {
+	if (rlim_stack->rlim_cur == RLIM_INFINITY) {
 		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
-		mm->mmap_base = mmap_base(mm);
+		mm->mmap_base = mmap_base(mm, rlim_stack);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 	}
 }
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 155ecbac9e28..48c591251600 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -90,9 +90,10 @@ unsigned long arch_mmap_rnd(void)
 	return arch_rnd(mmap_is_ia32() ? mmap32_rnd_bits : mmap64_rnd_bits);
 }
 
-static unsigned long mmap_base(unsigned long rnd, unsigned long task_size)
+static unsigned long mmap_base(unsigned long rnd, unsigned long task_size,
+			       struct rlimit *rlim_stack)
 {
-	unsigned long gap = rlimit(RLIMIT_STACK);
+	unsigned long gap = rlim_stack->rlim_cur;
 	unsigned long pad = stack_maxrandom_size(task_size) + stack_guard_gap;
 	unsigned long gap_min, gap_max;
 
@@ -126,16 +127,17 @@ static unsigned long mmap_legacy_base(unsigned long rnd,
  * process VM image, sets up which VM layout function to use:
  */
 static void arch_pick_mmap_base(unsigned long *base, unsigned long *legacy_base,
-		unsigned long random_factor, unsigned long task_size)
+		unsigned long random_factor, unsigned long task_size,
+		struct rlimit *rlim_stack)
 {
 	*legacy_base = mmap_legacy_base(random_factor, task_size);
 	if (mmap_is_legacy())
 		*base = *legacy_base;
 	else
-		*base = mmap_base(random_factor, task_size);
+		*base = mmap_base(random_factor, task_size, rlim_stack);
 }
 
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	if (mmap_is_legacy())
 		mm->get_unmapped_area = arch_get_unmapped_area;
@@ -143,7 +145,8 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 
 	arch_pick_mmap_base(&mm->mmap_base, &mm->mmap_legacy_base,
-			arch_rnd(mmap64_rnd_bits), task_size_64bit(0));
+			arch_rnd(mmap64_rnd_bits), task_size_64bit(0),
+			rlim_stack);
 
 #ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
 	/*
@@ -153,7 +156,8 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	 * mmap_base, the compat syscall uses mmap_compat_base.
 	 */
 	arch_pick_mmap_base(&mm->mmap_compat_base, &mm->mmap_compat_legacy_base,
-			arch_rnd(mmap32_rnd_bits), task_size_32bit());
+			arch_rnd(mmap32_rnd_bits), task_size_32bit(),
+			rlim_stack);
 #endif
 }
 
diff --git a/fs/exec.c b/fs/exec.c
index 7eb8d21bcab9..7074913ad2e7 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1323,6 +1323,8 @@ EXPORT_SYMBOL(would_dump);
 
 void setup_new_exec(struct linux_binprm * bprm)
 {
+	struct rlimit rlim_stack;
+
 	/*
 	 * Once here, prepare_binrpm() will not be called any more, so
 	 * the final state of setuid/setgid/fscaps can be merged into the
@@ -1345,7 +1347,11 @@ void setup_new_exec(struct linux_binprm * bprm)
 			current->signal->rlim[RLIMIT_STACK].rlim_cur = _STK_LIM;
 	}
 
-	arch_pick_mmap_layout(current->mm);
+	task_lock(current->group_leader);
+	rlim_stack = current->signal->rlim[RLIMIT_STACK];
+	task_unlock(current->group_leader);
+
+	arch_pick_mmap_layout(current->mm, &rlim_stack);
 
 	current->sas_ss_sp = current->sas_ss_size = 0;
 
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 3d49b91b674d..f28240e2c7e5 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -112,7 +112,8 @@ static inline void mm_update_next_owner(struct mm_struct *mm)
 #endif /* CONFIG_MEMCG */
 
 #ifdef CONFIG_MMU
-extern void arch_pick_mmap_layout(struct mm_struct *mm);
+extern void arch_pick_mmap_layout(struct mm_struct *mm,
+				  struct rlimit *rlim_stack);
 extern unsigned long
 arch_get_unmapped_area(struct file *, unsigned long, unsigned long,
 		       unsigned long, unsigned long);
@@ -121,7 +122,8 @@ arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 			  unsigned long len, unsigned long pgoff,
 			  unsigned long flags);
 #else
-static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
+static inline void arch_pick_mmap_layout(struct mm_struct *mm,
+					 struct rlimit *rlim_stack) {}
 #endif
 
 static inline bool in_vfork(struct task_struct *tsk)
diff --git a/mm/util.c b/mm/util.c
index 34e57fae959d..07b53a3c24c8 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -265,7 +265,7 @@ int vma_is_stack_for_current(struct vm_area_struct *vma)
 }
 
 #if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
-void arch_pick_mmap_layout(struct mm_struct *mm)
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	mm->mmap_base = TASK_UNMAPPED_BASE;
 	mm->get_unmapped_area = arch_get_unmapped_area;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
