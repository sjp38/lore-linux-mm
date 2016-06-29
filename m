Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA27D6B0260
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 06:59:02 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id f6so89307381ith.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:59:02 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0132.outbound.protection.outlook.com. [104.47.0.132])
        by mx.google.com with ESMTPS id l39si2526277ote.168.2016.06.29.03.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Jun 2016 03:59:02 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 2/6] x86/vdso: introduce do_map_vdso() and vdso_type enum
Date: Wed, 29 Jun 2016 13:57:32 +0300
Message-ID: <20160629105736.15017-3-dsafonov@virtuozzo.com>
In-Reply-To: <20160629105736.15017-1-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, linux-mm@kvack.org, mingo@redhat.com, luto@amacapital.net, gorcunov@openvz.org, xemul@virtuozzo.com, oleg@redhat.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Make in-kernel API to map vDSO blobs on x86.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: x86@kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/entry/vdso/vma.c   | 70 +++++++++++++++++++++++++--------------------
 arch/x86/include/asm/vdso.h |  4 +++
 2 files changed, 43 insertions(+), 31 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 387028e6755d..4017b60eed33 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -176,11 +176,18 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 	return VM_FAULT_SIGBUS;
 }
 
-static int map_vdso(const struct vdso_image *image, bool calculate_addr)
+/*
+ * Add vdso and vvar mappings to current process.
+ * @image          - blob to map
+ * @addr           - request a specific address (zero to map at free addr)
+ * @calculate_addr - turn on aslr (@addr will be ignored)
+ */
+static int map_vdso(const struct vdso_image *image,
+		unsigned long addr, bool calculate_addr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	unsigned long addr, text_start;
+	unsigned long text_start;
 	int ret = 0;
 
 	static const struct vm_special_mapping vdso_mapping = {
@@ -193,12 +200,9 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 		.fault = vvar_fault,
 	};
 
-	if (calculate_addr) {
+	if (calculate_addr)
 		addr = vdso_addr(current->mm->start_stack,
 				 image->size - image->sym_vvar_start);
-	} else {
-		addr = 0;
-	}
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
@@ -249,48 +253,52 @@ up_fail:
 	return ret;
 }
 
-#if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
-static int load_vdso32(void)
+int do_map_vdso(vdso_type type, unsigned long addr, bool randomize_addr)
 {
-	if (vdso32_enabled != 1)  /* Other values all mean "disabled" */
-		return 0;
-
-	return map_vdso(&vdso_image_32, false);
-}
+	switch (type) {
+#if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
+	case VDSO_32:
+		if (vdso32_enabled != 1)  /* Other values all mean "disabled" */
+			return 0;
+		/* vDSO aslr turned off for i386 vDSO */
+		return map_vdso(&vdso_image_32, addr, false);
+#endif
+#ifdef CONFIG_X86_64
+	case VDSO_64:
+		if (!vdso64_enabled)
+			return 0;
+		return map_vdso(&vdso_image_64, addr, randomize_addr);
+#endif
+#ifdef CONFIG_X86_X32_ABI
+	case VDSO_X32:
+		if (!vdso64_enabled)
+			return 0;
+		return map_vdso(&vdso_image_x32, addr, randomize_addr);
 #endif
+	default:
+		return -EINVAL;
+	}
+}
 
 #ifdef CONFIG_X86_64
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
-	if (!vdso64_enabled)
-		return 0;
-
-	return map_vdso(&vdso_image_64, true);
+	return do_map_vdso(VDSO_64, 0, true);
 }
 
 #ifdef CONFIG_COMPAT
 int compat_arch_setup_additional_pages(struct linux_binprm *bprm,
 				       int uses_interp)
 {
-#ifdef CONFIG_X86_X32_ABI
-	if (test_thread_flag(TIF_X32)) {
-		if (!vdso64_enabled)
-			return 0;
-
-		return map_vdso(&vdso_image_x32, true);
-	}
-#endif
-#ifdef CONFIG_IA32_EMULATION
-	return load_vdso32();
-#else
-	return 0;
-#endif
+	if (test_thread_flag(TIF_X32))
+		return do_map_vdso(VDSO_X32, 0, true);
+	return do_map_vdso(VDSO_32, 0, false);
 }
 #endif
 #else
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
-	return load_vdso32();
+	return do_map_vdso(VDSO_32, 0, false);
 }
 #endif
 
diff --git a/arch/x86/include/asm/vdso.h b/arch/x86/include/asm/vdso.h
index 43dc55be524e..2be137897842 100644
--- a/arch/x86/include/asm/vdso.h
+++ b/arch/x86/include/asm/vdso.h
@@ -41,6 +41,10 @@ extern const struct vdso_image vdso_image_32;
 
 extern void __init init_vdso_image(const struct vdso_image *image);
 
+typedef enum { VDSO_32, VDSO_64, VDSO_X32 } vdso_type;
+
+extern int do_map_vdso(vdso_type type, unsigned long addr, bool randomize_addr);
+
 #endif /* __ASSEMBLER__ */
 
 #endif /* _ASM_X86_VDSO_H */
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
