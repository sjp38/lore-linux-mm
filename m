Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D90FB6B0262
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 09:35:29 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g185so56400289ith.3
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 06:35:29 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0128.outbound.protection.outlook.com. [104.47.2.128])
        by mx.google.com with ESMTPS id g84si21904502oia.290.2016.09.05.06.35.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Sep 2016 06:35:26 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv5 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Date: Mon, 5 Sep 2016 16:33:05 +0300
Message-ID: <20160905133308.28234-4-dsafonov@virtuozzo.com>
In-Reply-To: <20160905133308.28234-1-dsafonov@virtuozzo.com>
References: <20160905133308.28234-1-dsafonov@virtuozzo.com>
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
 include/linux/mm.h                |  2 ++
 mm/mmap.c                         |  8 +++++++
 6 files changed, 78 insertions(+), 10 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 5bcb25a9e573..4459e73e234d 100644
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
+		if (vma_is_special_mapping(vma, &vdso_mapping) ||
+				vma_is_special_mapping(vma, &vvar_mapping)) {
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
index 63236d8f84bf..f240a465920b 100644
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
+#if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef815b9cd426..5f14534f0c90 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2019,6 +2019,8 @@ extern struct file *get_task_exe_file(struct task_struct *task);
 extern bool may_expand_vm(struct mm_struct *, vm_flags_t, unsigned long npages);
 extern void vm_stat_account(struct mm_struct *, vm_flags_t, long npages);
 
+extern bool vma_is_special_mapping(const struct vm_area_struct *vma,
+				   const struct vm_special_mapping *sm);
 extern struct vm_area_struct *_install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags,
diff --git a/mm/mmap.c b/mm/mmap.c
index ca9d91bca0d6..6373ebd358c0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3063,6 +3063,14 @@ out:
 	return ERR_PTR(ret);
 }
 
+bool vma_is_special_mapping(const struct vm_area_struct *vma,
+	const struct vm_special_mapping *sm)
+{
+	return vma->vm_private_data == sm &&
+		(vma->vm_ops == &special_mapping_vmops ||
+		 vma->vm_ops == &legacy_special_mapping_vmops);
+}
+
 /*
  * Called with mm->mmap_sem held for writing.
  * Insert a new vma covering the given region, with the given flags.
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
