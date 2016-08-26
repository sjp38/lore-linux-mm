Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 43D4B830BE
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 13:16:19 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g62so4585231ith.1
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 10:16:19 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50133.outbound.protection.outlook.com. [40.107.5.133])
        by mx.google.com with ESMTPS id p25si3676845otc.145.2016.08.26.10.15.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Aug 2016 10:15:56 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 4/6] x86/coredump: use pr_reg size, rather that TIF_IA32 flag
Date: Fri, 26 Aug 2016 20:13:15 +0300
Message-ID: <20160826171317.3944-5-dsafonov@virtuozzo.com>
In-Reply-To: <20160826171317.3944-1-dsafonov@virtuozzo.com>
References: <20160826171317.3944-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com, Dmitry Safonov <dsafonov@virtuozzo.com>

Killed PR_REG_SIZE and PR_REG_PTR macro as we can get regset size
from regset view.
I wish I could also kill PRSTATUS_SIZE nicely.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/asm/compat.h |  8 ++++----
 fs/binfmt_elf.c               | 23 ++++++++---------------
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/arch/x86/include/asm/compat.h b/arch/x86/include/asm/compat.h
index a18806165fe4..03d269bed941 100644
--- a/arch/x86/include/asm/compat.h
+++ b/arch/x86/include/asm/compat.h
@@ -275,10 +275,10 @@ struct compat_shmid64_ds {
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
index 7f6aff3f72eb..8533aaaba2d2 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1624,20 +1624,12 @@ static void do_thread_regset_writeback(struct task_struct *task,
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
@@ -1645,6 +1637,7 @@ static int fill_thread_core_info(struct elf_thread_core_info *t,
 				 long signr, size_t *total)
 {
 	unsigned int i;
+	unsigned int regset_size = view->regsets[0].n * view->regsets[0].size;
 
 	/*
 	 * NT_PRSTATUS is the one special case, because the regset data
@@ -1653,12 +1646,11 @@ static int fill_thread_core_info(struct elf_thread_core_info *t,
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
@@ -1688,7 +1680,8 @@ static int fill_thread_core_info(struct elf_thread_core_info *t,
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
