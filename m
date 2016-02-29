Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 679A16B025A
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:27 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id n186so49200401wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:27 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 10/18] vdso: make arch_setup_additional_pages wait for mmap_sem for write killable
Date: Mon, 29 Feb 2016 14:26:49 +0100
Message-Id: <1456752417-9626-11-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

most architectures are relying on mmap_sem for write in their
arch_setup_additional_pages. If the waiting task gets killed by the oom
killer it would block oom_reaper from asynchronous address space reclaim
and reduce the chances of timely OOM resolving. Wait for the lock in
the killable mode and return with EINTR if the task got killed while
waiting.

Cc: linux-arch@vger.kernel.org
Cc: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/arm/kernel/process.c          | 3 ++-
 arch/arm64/kernel/vdso.c           | 6 ++++--
 arch/hexagon/kernel/vdso.c         | 3 ++-
 arch/mips/kernel/vdso.c            | 3 ++-
 arch/powerpc/kernel/vdso.c         | 3 ++-
 arch/s390/kernel/vdso.c            | 3 ++-
 arch/sh/kernel/vsyscall/vsyscall.c | 4 +++-
 arch/x86/entry/vdso/vma.c          | 3 ++-
 arch/x86/um/vdso/vma.c             | 3 ++-
 9 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 4adfb46e3ee9..94cccae090fa 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -420,7 +420,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	npages = 1; /* for sigpage */
 	npages += vdso_total_pages;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 	hint = sigpage_addr(mm, npages);
 	addr = get_unmapped_area(NULL, hint, npages << PAGE_SHIFT, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index 97bc68f4c689..d7423dfb4a4a 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -95,7 +95,8 @@ int aarch32_setup_vectors_page(struct linux_binprm *bprm, int uses_interp)
 	};
 	void *ret;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 	current->mm->context.vdso = (void *)addr;
 
 	/* Map vectors page at the high address. */
@@ -163,7 +164,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	/* Be sure to map the data page */
 	vdso_mapping_len = vdso_text_len + PAGE_SIZE;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 	vdso_base = get_unmapped_area(NULL, 0, vdso_mapping_len, 0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
 		ret = ERR_PTR(vdso_base);
diff --git a/arch/hexagon/kernel/vdso.c b/arch/hexagon/kernel/vdso.c
index 0bf5a87e4d0a..3ea968415539 100644
--- a/arch/hexagon/kernel/vdso.c
+++ b/arch/hexagon/kernel/vdso.c
@@ -65,7 +65,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	unsigned long vdso_base;
 	struct mm_struct *mm = current->mm;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 
 	/* Try to get it loaded right near ld.so/glibc. */
 	vdso_base = STACK_TOP;
diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index 975e99759bab..54e1663ce639 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -104,7 +104,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	struct resource gic_res;
 	int ret;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 
 	/*
 	 * Determine total area size. This includes the VDSO data itself, the
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index def1b8b5e6c1..6767605ea8da 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -195,7 +195,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 * and end up putting it elsewhere.
 	 * Add enough to the size so that the result can be aligned.
 	 */
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 	vdso_base = get_unmapped_area(NULL, vdso_base,
 				      (vdso_pages << PAGE_SHIFT) +
 				      ((VDSO_ALIGNMENT - 1) & PAGE_MASK),
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 94495cac8be3..5904abf6b1ae 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -216,7 +216,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 * it at vdso_base which is the "natural" base for it, but we might
 	 * fail and end up putting it elsewhere.
 	 */
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 	vdso_base = get_unmapped_area(NULL, 0, vdso_pages << PAGE_SHIFT, 0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
 		rc = vdso_base;
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index ea2aa1393b87..cc0cc5b4ff18 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -64,7 +64,9 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	unsigned long addr;
 	int ret;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
 		ret = addr;
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 10f704584922..69d861f67c47 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -174,7 +174,8 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 		addr = 0;
 	}
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 
 	addr = get_unmapped_area(NULL, addr,
 				 image->size - image->sym_vvar_start, 0, 0);
diff --git a/arch/x86/um/vdso/vma.c b/arch/x86/um/vdso/vma.c
index 237c6831e095..6be22f991b59 100644
--- a/arch/x86/um/vdso/vma.c
+++ b/arch/x86/um/vdso/vma.c
@@ -61,7 +61,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (!vdso_enabled)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 
 	err = install_special_mapping(mm, um_vdso_addr, PAGE_SIZE,
 		VM_READ|VM_EXEC|
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
