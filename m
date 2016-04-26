Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 521856B0266
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so11521713lfc.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:53 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n9si29818223wjv.201.2016.04.26.05.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:39 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id e201so4193497wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 10/18] vdso: make arch_setup_additional_pages wait for mmap_sem for write killable
Date: Tue, 26 Apr 2016 14:56:17 +0200
Message-Id: <1461675385-5934-11-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

most architectures are relying on mmap_sem for write in their
arch_setup_additional_pages. If the waiting task gets killed by the oom
killer it would block oom_reaper from asynchronous address space reclaim
and reduce the chances of timely OOM resolving. Wait for the lock in
the killable mode and return with EINTR if the task got killed while
waiting.

Cc: linux-arch@vger.kernel.org
Acked-by: Andy Lutomirski <luto@amacapital.net> # for the x86 vdso
Acked-by: Vlastimil Babka <vbabka@suse.cz>
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
index a647d6642f3e..4a803c5a1ff7 100644
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
index 64fc030be0f2..9fefb005812a 100644
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
index b3cf81333a54..ab220ac9b3b9 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -163,7 +163,8 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
