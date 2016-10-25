Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 823136B0275
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:53:15 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fl2so12298416pad.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:53:15 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20122.outbound.protection.outlook.com. [40.107.2.122])
        by mx.google.com with ESMTPS id nw5si17771895pab.314.2016.10.25.08.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 08:53:14 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH 1/7] powerpc/vdso: unify return paths in setup_additional_pages
Date: Tue, 25 Oct 2016 18:51:00 +0300
Message-ID: <20161025155106.29946-2-dsafonov@virtuozzo.com>
In-Reply-To: <20161025155106.29946-1-dsafonov@virtuozzo.com>
References: <20161025155106.29946-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

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
 arch/powerpc/kernel/vdso.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 4111d30badfa..4ffb82a2d9e9 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -154,7 +154,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	struct page **vdso_pagelist;
 	unsigned long vdso_pages;
 	unsigned long vdso_base;
-	int rc;
+	int ret = 0;
 
 	if (!vdso_ready)
 		return 0;
@@ -203,8 +203,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 				      ((VDSO_ALIGNMENT - 1) & PAGE_MASK),
 				      0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
-		rc = vdso_base;
-		goto fail_mmapsem;
+		ret = vdso_base;
+		goto out_up_mmap_sem;
 	}
 
 	/* Add required alignment. */
@@ -227,21 +227,16 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 * It's fine to use that for setting breakpoints in the vDSO code
 	 * pages though.
 	 */
-	rc = install_special_mapping(mm, vdso_base, vdso_pages << PAGE_SHIFT,
+	ret = install_special_mapping(mm, vdso_base, vdso_pages << PAGE_SHIFT,
 				     VM_READ|VM_EXEC|
 				     VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
 				     vdso_pagelist);
-	if (rc) {
+	if (ret)
 		current->mm->context.vdso_base = 0;
-		goto fail_mmapsem;
-	}
-
-	up_write(&mm->mmap_sem);
-	return 0;
 
- fail_mmapsem:
+out_up_mmap_sem:
 	up_write(&mm->mmap_sem);
-	return rc;
+	return ret;
 }
 
 const char *arch_vma_name(struct vm_area_struct *vma)
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
