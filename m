Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 835D9830BE
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 13:16:17 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w136so196319799oie.2
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 10:16:17 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50133.outbound.protection.outlook.com. [40.107.5.133])
        by mx.google.com with ESMTPS id p25si3676845otc.145.2016.08.26.10.15.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Aug 2016 10:15:56 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Date: Fri, 26 Aug 2016 20:13:14 +0300
Message-ID: <20160826171317.3944-4-dsafonov@virtuozzo.com>
In-Reply-To: <20160826171317.3944-1-dsafonov@virtuozzo.com>
References: <20160826171317.3944-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com, Dmitry Safonov <dsafonov@virtuozzo.com>

Add API to change vdso blob type with arch_prctl.
As this is usefull only by needs of CRIU, expose
this interface under CONFIG_CHECKPOINT_RESTORE.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/entry/vdso/vma.c         | 45 ++++++++++++++++++++++++++++++---------
 arch/x86/include/asm/vdso.h       |  2 ++
 arch/x86/include/uapi/asm/prctl.h |  6 ++++++
 arch/x86/kernel/process_64.c      | 25 ++++++++++++++++++++++
 4 files changed, 68 insertions(+), 10 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 5bcb25a9e573..dad2b2d8ff03 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -176,6 +176,16 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 	return VM_FAULT_SIGBUS;
 }
 
+static const struct vm_special_mapping vdso_mapping = {
+	.name = "[vdso]",
+	.fault = vdso_fault,
+	.mremap = vdso_mremap,
+};
+static const struct vm_special_mapping vvar_mapping = {
+	.name = "[vvar]",
+	.fault = vvar_fault,
+};
+
 /*
  * Add vdso and vvar mappings to current process.
  * @image          - blob to map
@@ -188,16 +198,6 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	unsigned long text_start;
 	int ret = 0;
 
-	static const struct vm_special_mapping vdso_mapping = {
-		.name = "[vdso]",
-		.fault = vdso_fault,
-		.mremap = vdso_mremap,
-	};
-	static const struct vm_special_mapping vvar_mapping = {
-		.name = "[vvar]",
-		.fault = vvar_fault,
-	};
-
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
@@ -256,6 +256,31 @@ static int map_vdso_randomized(const struct vdso_image *image)
 	return map_vdso(image, addr);
 }
 
+int map_vdso_once(const struct vdso_image *image, unsigned long addr)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+
+	down_write(&mm->mmap_sem);
+	/*
+	 * Check if we have already mapped vdso blob - fail to prevent
+	 * abusing from userspace install_speciall_mapping, which may
+	 * not do accounting and rlimit right.
+	 * We could search vma near context.vdso, but it's a slowpath,
+	 * so let's explicitely check all VMAs to be completely sure.
+	 */
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->vm_private_data == &vdso_mapping ||
+				vma->vm_private_data == &vvar_mapping) {
+			up_write(&mm->mmap_sem);
+			return -EEXIST;
+		}
+	}
+	up_write(&mm->mmap_sem);
+
+	return map_vdso(image, addr);
+}
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
 static int load_vdso32(void)
 {
diff --git a/arch/x86/include/asm/vdso.h b/arch/x86/include/asm/vdso.h
index 43dc55be524e..2444189cbe28 100644
--- a/arch/x86/include/asm/vdso.h
+++ b/arch/x86/include/asm/vdso.h
@@ -41,6 +41,8 @@ extern const struct vdso_image vdso_image_32;
 
 extern void __init init_vdso_image(const struct vdso_image *image);
 
+extern int map_vdso_once(const struct vdso_image *image, unsigned long addr);
+
 #endif /* __ASSEMBLER__ */
 
 #endif /* _ASM_X86_VDSO_H */
diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index 3ac5032fae09..ae135de547f5 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -6,4 +6,10 @@
 #define ARCH_GET_FS 0x1003
 #define ARCH_GET_GS 0x1004
 
+#ifdef CONFIG_CHECKPOINT_RESTORE
+# define ARCH_MAP_VDSO_X32	0x2001
+# define ARCH_MAP_VDSO_32	0x2002
+# define ARCH_MAP_VDSO_64	0x2003
+#endif
+
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 63236d8f84bf..555d21f2f492 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -49,6 +49,7 @@
 #include <asm/debugreg.h>
 #include <asm/switch_to.h>
 #include <asm/xen/hypervisor.h>
+#include <asm/vdso.h>
 
 asmlinkage extern void ret_from_fork(void);
 
@@ -524,6 +525,17 @@ void set_personality_ia32(bool x32)
 }
 EXPORT_SYMBOL_GPL(set_personality_ia32);
 
+static long prctl_map_vdso(const struct vdso_image *image, unsigned long addr)
+{
+	int ret;
+
+	ret = map_vdso_once(image, addr);
+	if (ret)
+		return ret;
+
+	return (long)image->size;
+}
+
 long do_arch_prctl(struct task_struct *task, int code, unsigned long addr)
 {
 	int ret = 0;
@@ -577,6 +589,19 @@ long do_arch_prctl(struct task_struct *task, int code, unsigned long addr)
 		break;
 	}
 
+#ifdef CONFIG_CHECKPOINT_RESTORE
+#ifdef CONFIG_X86_X32
+	case ARCH_MAP_VDSO_X32:
+		return prctl_map_vdso(&vdso_image_x32, addr);
+#endif
+#if defined CONFIG_X86_32 || defined CONFIG_COMPAT
+	case ARCH_MAP_VDSO_32:
+		return prctl_map_vdso(&vdso_image_32, addr);
+#endif
+	case ARCH_MAP_VDSO_64:
+		return prctl_map_vdso(&vdso_image_64, addr);
+#endif
+
 	default:
 		ret = -EINVAL;
 		break;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
