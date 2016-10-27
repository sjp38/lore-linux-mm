Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3C46B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:17:23 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id py6so23037571pab.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:17:23 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30097.outbound.protection.outlook.com. [40.107.3.97])
        by mx.google.com with ESMTPS id c71si8152763pga.289.2016.10.27.07.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 07:17:22 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH 2/2] x86/vdso: set vdso pointer only after success
Date: Thu, 27 Oct 2016 17:15:16 +0300
Message-ID: <20161027141516.28447-3-dsafonov@virtuozzo.com>
In-Reply-To: <20161027141516.28447-1-dsafonov@virtuozzo.com>
References: <20161027141516.28447-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, 0x7f454c46@gmail.com, Cyrill
 Gorcunov <gorcunov@openvz.org>, Andy Lutomirski <luto@kernel.org>, oleg@redhat.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, x86@kernel.org

Those pointers were initialized before call to _install_special_mapping
after the commit f7b6eb3fa072 ("x86: Set context.vdso before installing
the mapping"). This is not required anymore as special mappings have
their vma name and don't use arch_vma_name() after commit a62c34bd2a8a
("x86, mm: Improve _install_special_mapping and fix x86 vdso naming").
So, this way to init looks less entangled.
I even belive, we can remove null initializers:
- on failure load_elf_binary() will not start a new thread;
- arch_prctl will have the same pointers as before syscall.

Cc: 0x7f454c46@gmail.com
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: oleg@redhat.com
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/entry/vdso/vma.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 23c881caabd1..e739002427ed 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -161,8 +161,6 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	}
 
 	text_start = addr - image->sym_vvar_start;
-	current->mm->context.vdso = (void __user *)text_start;
-	current->mm->context.vdso_image = image;
 
 	/*
 	 * MAYWRITE to allow gdb to COW and set breakpoints
@@ -189,14 +187,12 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
 		do_munmap(mm, text_start, image->size);
+	} else {
+		current->mm->context.vdso = (void __user *)text_start;
+		current->mm->context.vdso_image = image;
 	}
 
 up_fail:
-	if (ret) {
-		current->mm->context.vdso = NULL;
-		current->mm->context.vdso_image = NULL;
-	}
-
 	up_write(&mm->mmap_sem);
 	return ret;
 }
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
