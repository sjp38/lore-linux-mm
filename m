Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5CD280256
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:11:58 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ml10so23429478pab.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:11:58 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0134.outbound.protection.outlook.com. [104.47.1.134])
        by mx.google.com with ESMTPS id b190si8872791pfa.34.2016.10.27.10.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 10:11:57 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 8/8] powerpc/vdso: remove arch_vma_name
Date: Thu, 27 Oct 2016 20:09:48 +0300
Message-ID: <20161027170948.8279-9-dsafonov@virtuozzo.com>
In-Reply-To: <20161027170948.8279-1-dsafonov@virtuozzo.com>
References: <20161027170948.8279-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

It's not needed since vdso is inserted with vm_special_mapping
which contains vma name.
This also reverts commit f2053f1a7bf6 ("powerpc/perf_counter: Fix vdso
detection") as not needed anymore.
See also commit f7b6eb3fa072 ("x86: Set context.vdso before installing
the mapping").

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/powerpc/kernel/vdso.c | 20 +++-----------------
 1 file changed, 3 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 431bdf7ec68e..f66f52aa94de 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -208,13 +208,6 @@ static int map_vdso(struct vm_special_mapping *vsm, unsigned long vdso_pages,
 	vdso_base = ALIGN(vdso_base, VDSO_ALIGNMENT);
 
 	/*
-	 * Put vDSO base into mm struct. We need to do this before calling
-	 * install_special_mapping or the perf counter mmap tracking code
-	 * will fail to recognise it as a vDSO (since arch_vma_name fails).
-	 */
-	current->mm->context.vdso_base = vdso_base;
-
-	/*
 	 * our vma flags don't have VM_WRITE so by default, the process isn't
 	 * allowed to write those pages.
 	 * gdb can break that with ptrace interface, and thus trigger COW on
@@ -228,10 +221,10 @@ static int map_vdso(struct vm_special_mapping *vsm, unsigned long vdso_pages,
 				     VM_READ|VM_EXEC|
 				     VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
 				     vsm);
-	if (IS_ERR(vma)) {
+	if (IS_ERR(vma))
 		ret = PTR_ERR(vma);
-		current->mm->context.vdso_base = 0;
-	}
+	else
+		current->mm->context.vdso_base = vdso_base;
 
 out_up_mmap_sem:
 	up_write(&mm->mmap_sem);
@@ -262,13 +255,6 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	return -1;
 }
 
-const char *arch_vma_name(struct vm_area_struct *vma)
-{
-	if (vma->vm_mm && vma->vm_start == vma->vm_mm->context.vdso_base)
-		return "[vdso]";
-	return NULL;
-}
-
 #ifdef CONFIG_VDSO32
 #include "vdso_common.c"
 #endif /* CONFIG_VDSO32 */
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
