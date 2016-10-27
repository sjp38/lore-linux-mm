Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 182DB6B027B
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:11:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so11034267pfa.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:11:51 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0117.outbound.protection.outlook.com. [104.47.1.117])
        by mx.google.com with ESMTPS id y77si8781763pff.233.2016.10.27.10.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 10:11:50 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 1/8] powerpc/vdso: unify return paths in setup_additional_pages
Date: Thu, 27 Oct 2016 20:09:41 +0300
Message-ID: <20161027170948.8279-2-dsafonov@virtuozzo.com>
In-Reply-To: <20161027170948.8279-1-dsafonov@virtuozzo.com>
References: <20161027170948.8279-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg
 Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Impact: cleanup

Rename `rc' variable which doesn't seems to mean anything into
kernel-known `ret'. Combine two function returns into one as it's
also easier to read.

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
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
