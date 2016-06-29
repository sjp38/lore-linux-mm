Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A62BD6B0263
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 06:59:05 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id hx8so94222700obb.0
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:59:05 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0116.outbound.protection.outlook.com. [104.47.0.116])
        by mx.google.com with ESMTPS id r135si2539241oie.6.2016.06.29.03.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Jun 2016 03:59:05 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 4/6] x86/coredump: use pr_reg size, rather that TIF_IA32 flag
Date: Wed, 29 Jun 2016 13:57:34 +0300
Message-ID: <20160629105736.15017-5-dsafonov@virtuozzo.com>
In-Reply-To: <20160629105736.15017-1-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, linux-mm@kvack.org, mingo@redhat.com, luto@amacapital.net, gorcunov@openvz.org, xemul@virtuozzo.com, oleg@redhat.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, x86@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org

Killed PR_REG_SIZE and PR_REG_PTR macro as we can get regset size
from regset view.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: x86@kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/asm/compat.h |  8 ++++----
 fs/binfmt_elf.c               | 23 ++++++++---------------
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/arch/x86/include/asm/compat.h b/arch/x86/include/asm/compat.h
index 5a3b2c119ed0..4b039bd297ac 100644
--- a/arch/x86/include/asm/compat.h
+++ b/arch/x86/include/asm/compat.h
@@ -264,10 +264,10 @@ struct compat_shmid64_ds {
 #ifdef CONFIG_X86_X32_ABI
 typedef struct user_regs_struct compat_elf_gregset_t;
 
-#define PR_REG_SIZE(S) (test_thread_flag(TIF_IA32) ? 68 : 216)
-#define PRSTATUS_SIZE(S) (test_thread_flag(TIF_IA32) ? 144 : 296)
-#define SET_PR_FPVALID(S,V) \
-  do { *(int *) (((void *) &((S)->pr_reg)) + PR_REG_SIZE(0)) = (V); } \
+/* Full regset -- prstatus on x32, otherwise on ia32 */
+#define PRSTATUS_SIZE(S, R) (R != sizeof(S.pr_reg) ? 144 : 296)
+#define SET_PR_FPVALID(S, V, R) \
+  do { *(int *) (((void *) &((S)->pr_reg)) + R) = (V); } \
   while (0)
 
 #define COMPAT_USE_64BIT_TIME \
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index a7a28110dc80..8fd6cf9083d0 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1622,20 +1622,12 @@ static void do_thread_regset_writeback(struct task_struct *task,
 		regset->writeback(task, regset, 1);
 }
 
-#ifndef PR_REG_SIZE
-#define PR_REG_SIZE(S) sizeof(S)
-#endif
-
 #ifndef PRSTATUS_SIZE
-#define PRSTATUS_SIZE(S) sizeof(S)
-#endif
-
-#ifndef PR_REG_PTR
-#define PR_REG_PTR(S) (&((S)->pr_reg))
+#define PRSTATUS_SIZE(S, R) sizeof(S)
 #endif
 
 #ifndef SET_PR_FPVALID
-#define SET_PR_FPVALID(S, V) ((S)->pr_fpvalid = (V))
+#define SET_PR_FPVALID(S, V, R) ((S)->pr_fpvalid = (V))
 #endif
 
 static int fill_thread_core_info(struct elf_thread_core_info *t,
@@ -1643,6 +1635,7 @@ static int fill_thread_core_info(struct elf_thread_core_info *t,
 				 long signr, size_t *total)
 {
 	unsigned int i;
+	unsigned int regset_size = view->regsets[0].n * view->regsets[0].size;
 
 	/*
 	 * NT_PRSTATUS is the one special case, because the regset data
@@ -1651,12 +1644,11 @@ static int fill_thread_core_info(struct elf_thread_core_info *t,
 	 * We assume that regset 0 is NT_PRSTATUS.
 	 */
 	fill_prstatus(&t->prstatus, t->task, signr);
-	(void) view->regsets[0].get(t->task, &view->regsets[0],
-				    0, PR_REG_SIZE(t->prstatus.pr_reg),
-				    PR_REG_PTR(&t->prstatus), NULL);
+	(void) view->regsets[0].get(t->task, &view->regsets[0], 0, regset_size,
+				    &t->prstatus.pr_reg, NULL);
 
 	fill_note(&t->notes[0], "CORE", NT_PRSTATUS,
-		  PRSTATUS_SIZE(t->prstatus), &t->prstatus);
+		  PRSTATUS_SIZE(t->prstatus, regset_size), &t->prstatus);
 	*total += notesize(&t->notes[0]);
 
 	do_thread_regset_writeback(t->task, &view->regsets[0]);
@@ -1686,7 +1678,8 @@ static int fill_thread_core_info(struct elf_thread_core_info *t,
 						  regset->core_note_type,
 						  size, data);
 				else {
-					SET_PR_FPVALID(&t->prstatus, 1);
+					SET_PR_FPVALID(&t->prstatus,
+							1, regset_size);
 					fill_note(&t->notes[i], "CORE",
 						  NT_PRFPREG, size, data);
 				}
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
