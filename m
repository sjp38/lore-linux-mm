Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEB6F830BE
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 13:16:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id x131so3949331ite.3
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 10:16:14 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50110.outbound.protection.outlook.com. [40.107.5.110])
        by mx.google.com with ESMTPS id 76si16419303oib.99.2016.08.26.10.15.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Aug 2016 10:15:53 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 2/6] x86/vdso: replace calculate_addr in map_vdso() with addr
Date: Fri, 26 Aug 2016 20:13:13 +0300
Message-ID: <20160826171317.3944-3-dsafonov@virtuozzo.com>
In-Reply-To: <20160826171317.3944-1-dsafonov@virtuozzo.com>
References: <20160826171317.3944-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com, Dmitry Safonov <dsafonov@virtuozzo.com>

That will allow to specify address where to map vDSO blob.
For the randomized vDSO mappings introduce map_vdso_randomized()
which will simplify calls to map_vdso.

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
 arch/x86/entry/vdso/vma.c | 30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 3bab6ba3ffc5..5bcb25a9e573 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -176,11 +176,16 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 	return VM_FAULT_SIGBUS;
 }
 
-static int map_vdso(const struct vdso_image *image, bool calculate_addr)
+/*
+ * Add vdso and vvar mappings to current process.
+ * @image          - blob to map
+ * @addr           - request a specific address (zero to map at free addr)
+ */
+static int map_vdso(const struct vdso_image *image, unsigned long addr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	unsigned long addr, text_start;
+	unsigned long text_start;
 	int ret = 0;
 
 	static const struct vm_special_mapping vdso_mapping = {
@@ -193,13 +198,6 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 		.fault = vvar_fault,
 	};
 
-	if (calculate_addr) {
-		addr = vdso_addr(current->mm->start_stack,
-				 image->size - image->sym_vvar_start);
-	} else {
-		addr = 0;
-	}
-
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
@@ -251,13 +249,20 @@ up_fail:
 	return ret;
 }
 
+static int map_vdso_randomized(const struct vdso_image *image)
+{
+	unsigned long addr = vdso_addr(current->mm->start_stack,
+				 image->size - image->sym_vvar_start);
+	return map_vdso(image, addr);
+}
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
 static int load_vdso32(void)
 {
 	if (vdso32_enabled != 1)  /* Other values all mean "disabled" */
 		return 0;
 
-	return map_vdso(&vdso_image_32, false);
+	return map_vdso(&vdso_image_32, 0);
 }
 #endif
 
@@ -267,7 +272,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (!vdso64_enabled)
 		return 0;
 
-	return map_vdso(&vdso_image_64, true);
+	return map_vdso_randomized(&vdso_image_64);
 }
 
 #ifdef CONFIG_COMPAT
@@ -278,8 +283,7 @@ int compat_arch_setup_additional_pages(struct linux_binprm *bprm,
 	if (test_thread_flag(TIF_X32)) {
 		if (!vdso64_enabled)
 			return 0;
-
-		return map_vdso(&vdso_image_x32, true);
+		return map_vdso_randomized(&vdso_image_x32);
 	}
 #endif
 #ifdef CONFIG_IA32_EMULATION
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
