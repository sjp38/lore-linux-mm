Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A564828E1
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 07:37:01 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id at7so27574417obd.1
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 04:37:01 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0113.outbound.protection.outlook.com. [157.55.234.113])
        by mx.google.com with ESMTPS id h77si80265oib.276.2016.06.28.04.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Jun 2016 04:37:00 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv10 1/2] x86/vdso: add mremap hook to vm_special_mapping
Date: Tue, 28 Jun 2016 14:35:38 +0300
Message-ID: <20160628113539.13606-2-dsafonov@virtuozzo.com>
In-Reply-To: <20160628113539.13606-1-dsafonov@virtuozzo.com>
References: <20160628113539.13606-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, mingo@redhat.com, luto@kernel.org, linux-mm@kvack.org, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

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
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Acked-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vma.c | 47 ++++++++++++++++++++++++++++++++++++++++++-----
 include/linux/mm_types.h  |  3 +++
 mm/mmap.c                 | 10 ++++++++++
 3 files changed, 55 insertions(+), 5 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index ab220ac9b3b9..3329844e3c43 100644
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
@@ -97,10 +98,40 @@ static int vdso_fault(const struct vm_special_mapping *sm,
 	return 0;
 }
 
-static const struct vm_special_mapping text_mapping = {
-	.name = "[vdso]",
-	.fault = vdso_fault,
-};
+static void vdso_fix_landing(const struct vdso_image *image,
+		struct vm_area_struct *new_vma)
+{
+#if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
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
+#endif
+}
+
+static int vdso_mremap(const struct vm_special_mapping *sm,
+		struct vm_area_struct *new_vma)
+{
+	unsigned long new_size = new_vma->vm_end - new_vma->vm_start;
+	const struct vdso_image *image = current->mm->context.vdso_image;
+
+	if (image->size != new_size)
+		return -EINVAL;
+
+	if (WARN_ON_ONCE(current->mm != new_vma->vm_mm))
+		return -EFAULT;
+
+	vdso_fix_landing(image, new_vma);
+	current->mm->context.vdso = (void __user *)new_vma->vm_start;
+
+	return 0;
+}
 
 static int vvar_fault(const struct vm_special_mapping *sm,
 		      struct vm_area_struct *vma, struct vm_fault *vmf)
@@ -151,6 +182,12 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
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
@@ -185,7 +222,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 				       image->size,
 				       VM_READ|VM_EXEC|
 				       VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				       &text_mapping);
+				       &vdso_mapping);
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e093e1d3285b..79472b22d23f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -595,6 +595,9 @@ struct vm_special_mapping {
 	int (*fault)(const struct vm_special_mapping *sm,
 		     struct vm_area_struct *vma,
 		     struct vm_fault *vmf);
+
+	int (*mremap)(const struct vm_special_mapping *sm,
+		     struct vm_area_struct *new_vma);
 };
 
 enum tlb_flush_reason {
diff --git a/mm/mmap.c b/mm/mmap.c
index 25c2b4e0fbdc..86b18f334f4f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2961,9 +2961,19 @@ static const char *special_mapping_name(struct vm_area_struct *vma)
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
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
