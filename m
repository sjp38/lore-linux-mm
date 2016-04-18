Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79BD56B025F
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 09:44:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so328663727pfe.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 06:44:59 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0101.outbound.protection.outlook.com. [157.56.112.101])
        by mx.google.com with ESMTPS id i10si3684448paz.90.2016.04.18.06.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 06:44:58 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv5 2/3] x86/vdso: add mremap hook to vm_special_mapping
Date: Mon, 18 Apr 2016 16:43:44 +0300
Message-ID: <1460987025-30360-2-git-send-email-dsafonov@virtuozzo.com>
In-Reply-To: <1460987025-30360-1-git-send-email-dsafonov@virtuozzo.com>
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460987025-30360-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: luto@amacapital.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>

Add possibility for userspace 32-bit applications to move
vdso mapping. Previously, when userspace app called
mremap for vdso, in return path it would land on previous
address of vdso page, resulting in segmentation violation.
Now it lands fine and returns to userspace with remapped vdso.
This will also fix context.vdso pointer for 64-bit, which does not
affect the user of vdso after mremap by now, but this may change.

As suggested by Andy, return EINVAL for mremap that splits vdso image.

Renamed and moved text_mapping structure declaration inside
map_vdso, as it used only there and now it complement
vvar_mapping variable.

There is still problem for remapping vdso in glibc applications:
linker relocates addresses for syscalls on vdso page, so
you need to relink with the new addresses. Or the next syscall
through glibc may fail:
  Program received signal SIGSEGV, Segmentation fault.
  #0  0xf7fd9b80 in __kernel_vsyscall ()
  #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
v5: as Andy suggested, add a check that new_vma->vm_mm and current->mm are
    the same, also check not only in_ia32_syscall() but image == &vdso_image_32
v4: drop __maybe_unused & use image from mm->context instead vdso_image_32
v3: as Andy suggested, return EINVAL in case of splitting vdso blob on mremap;
    used is_ia32_task instead of ifdefs 
v2: added __maybe_unused for pt_regs in vdso_mremap

 arch/x86/entry/vdso/vma.c | 39 ++++++++++++++++++++++++++++++++++-----
 include/linux/mm_types.h  |  3 +++
 mm/mmap.c                 | 10 ++++++++++
 3 files changed, 47 insertions(+), 5 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 10f704584922..ba133a9ab4f5 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -12,6 +12,7 @@
 #include <linux/random.h>
 #include <linux/elf.h>
 #include <linux/cpu.h>
+#include <linux/ptrace.h>
 #include <asm/pvclock.h>
 #include <asm/vgtod.h>
 #include <asm/proto.h>
@@ -98,10 +99,32 @@ static int vdso_fault(const struct vm_special_mapping *sm,
 	return 0;
 }
 
-static const struct vm_special_mapping text_mapping = {
-	.name = "[vdso]",
-	.fault = vdso_fault,
-};
+static int vdso_mremap(const struct vm_special_mapping *sm,
+		      struct vm_area_struct *new_vma)
+{
+	unsigned long new_size = new_vma->vm_end - new_vma->vm_start;
+	const struct vdso_image *image = current->mm->context.vdso_image;
+
+	if (image->size != new_size)
+		return -EINVAL;
+
+	if (current->mm != new_vma->vm_mm)
+		return -EFAULT;
+
+	if (in_ia32_syscall() && image == &vdso_image_32) {
+		struct pt_regs *regs = current_pt_regs();
+		unsigned long vdso_land = image->sym_int80_landing_pad;
+		unsigned long old_land_addr = vdso_land +
+			(unsigned long)current->mm->context.vdso;
+
+		/* Fixing userspace landing - look at do_fast_syscall_32 */
+		if (regs->ip == old_land_addr)
+			regs->ip = new_vma->vm_start + vdso_land;
+	}
+	current->mm->context.vdso = (void __user *)new_vma->vm_start;
+
+	return 0;
+}
 
 static int vvar_fault(const struct vm_special_mapping *sm,
 		      struct vm_area_struct *vma, struct vm_fault *vmf)
@@ -162,6 +185,12 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	struct vm_area_struct *vma;
 	unsigned long addr, text_start;
 	int ret = 0;
+
+	static const struct vm_special_mapping vdso_mapping = {
+		.name = "[vdso]",
+		.fault = vdso_fault,
+		.mremap = vdso_mremap,
+	};
 	static const struct vm_special_mapping vvar_mapping = {
 		.name = "[vvar]",
 		.fault = vvar_fault,
@@ -195,7 +224,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 				       image->size,
 				       VM_READ|VM_EXEC|
 				       VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				       &text_mapping);
+				       &vdso_mapping);
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c2d75b4fa86c..4d16ab9287af 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -586,6 +586,9 @@ struct vm_special_mapping {
 	int (*fault)(const struct vm_special_mapping *sm,
 		     struct vm_area_struct *vma,
 		     struct vm_fault *vmf);
+
+	int (*mremap)(const struct vm_special_mapping *sm,
+		     struct vm_area_struct *new_vma);
 };
 
 enum tlb_flush_reason {
diff --git a/mm/mmap.c b/mm/mmap.c
index bd2e1a533bc1..ba71658dd1a1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2930,9 +2930,19 @@ static const char *special_mapping_name(struct vm_area_struct *vma)
 	return ((struct vm_special_mapping *)vma->vm_private_data)->name;
 }
 
+static int special_mapping_mremap(struct vm_area_struct *new_vma)
+{
+	struct vm_special_mapping *sm = new_vma->vm_private_data;
+
+	if (sm->mremap)
+		return sm->mremap(sm, new_vma);
+	return 0;
+}
+
 static const struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
 	.fault = special_mapping_fault,
+	.mremap = special_mapping_mremap,
 	.name = special_mapping_name,
 };
 
-- 
2.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
