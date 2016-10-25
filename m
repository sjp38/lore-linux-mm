Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 158426B0279
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:53:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i85so142002995pfa.5
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:53:20 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20118.outbound.protection.outlook.com. [40.107.2.118])
        by mx.google.com with ESMTPS id q29si21297186pgn.274.2016.10.25.08.53.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 08:53:18 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH 5/7] powerpc/vdso: split map_vdso from arch_setup_additional_pages
Date: Tue, 25 Oct 2016 18:51:04 +0300
Message-ID: <20161025155106.29946-6-dsafonov@virtuozzo.com>
In-Reply-To: <20161025155106.29946-1-dsafonov@virtuozzo.com>
References: <20161025155106.29946-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

I'll be easier to introduce vm_special_mapping struct in
a smaller map_vdso() function (see the next patches).

Impact: cleanup

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org 
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/powerpc/kernel/vdso.c | 67 +++++++++++++++++++++-------------------------
 1 file changed, 31 insertions(+), 36 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 25d03d773c49..e68601ffc9ad 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -143,52 +143,23 @@ struct lib64_elfinfo
 	unsigned long	text;
 };
 
-
-/*
- * This is called from binfmt_elf, we create the special vma for the
- * vDSO and insert it into the mm struct tree
- */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+static int map_vdso(struct page **vdso_pagelist, unsigned long vdso_pages,
+		unsigned long vdso_base)
 {
 	struct mm_struct *mm = current->mm;
-	struct page **vdso_pagelist;
-	unsigned long vdso_pages;
-	unsigned long vdso_base;
 	int ret = 0;
 
-	if (!vdso_ready)
-		return 0;
-
-#ifdef CONFIG_PPC64
-	if (is_32bit_task()) {
-		vdso_pagelist = vdso32_pagelist;
-		vdso_pages = vdso32_pages;
-		vdso_base = VDSO32_MBASE;
-	} else {
-		vdso_pagelist = vdso64_pagelist;
-		vdso_pages = vdso64_pages;
-		/*
-		 * On 64bit we don't have a preferred map address. This
-		 * allows get_unmapped_area to find an area near other mmaps
-		 * and most likely share a SLB entry.
-		 */
-		vdso_base = 0;
-	}
-#else
-	vdso_pagelist = vdso32_pagelist;
-	vdso_pages = vdso32_pages;
-	vdso_base = VDSO32_MBASE;
-#endif
-
-	current->mm->context.vdso_base = 0;
+	mm->context.vdso_base = 0;
 
-	/* vDSO has a problem and was disabled, just don't "enable" it for the
+	/*
+	 * vDSO has a problem and was disabled, just don't "enable" it for the
 	 * process
 	 */
 	if (vdso_pages == 0)
 		return 0;
+
 	/* Add a page to the vdso size for the data page */
-	vdso_pages ++;
+	vdso_pages++;
 
 	/*
 	 * pick a base address for the vDSO in process space. We try to put it
@@ -239,6 +210,30 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	return ret;
 }
 
+/*
+ * This is called from binfmt_elf, we create the special vma for the
+ * vDSO and insert it into the mm struct tree
+ */
+int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+{
+	if (!vdso_ready)
+		return 0;
+
+	if (is_32bit_task())
+		return map_vdso(vdso32_pagelist, vdso32_pages, VDSO32_MBASE);
+#ifdef CONFIG_PPC64
+	else
+		/*
+		 * On 64bit we don't have a preferred map address. This
+		 * allows get_unmapped_area to find an area near other mmaps
+		 * and most likely share a SLB entry.
+		 */
+		return map_vdso(vdso64_pagelist, vdso64_pages, 0);
+#endif
+	WARN_ONCE(1, "task is not 32-bit on non PPC64 kernel");
+	return -1;
+}
+
 const char *arch_vma_name(struct vm_area_struct *vma)
 {
 	if (vma->vm_mm && vma->vm_start == vma->vm_mm->context.vdso_base)
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
