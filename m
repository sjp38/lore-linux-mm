Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F17978E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 13:54:14 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b17so15941726pfc.11
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 10:54:14 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id z20si13629875pgv.159.2018.12.18.10.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 10:54:13 -0800 (PST)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: [PATCH 1/2] ARC: show_regs: avoid page allocator
Date: Tue, 18 Dec 2018 10:53:58 -0800
Message-ID: <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-snps-arc@lists.infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Vineet  Gupta <vineet.gupta1@synopsys.com>

Use on-stack smaller buffers instead of dynamic pages.

The motivation for this change was to address lockdep splat when
signal handling code calls show_regs (with preemption disabled) and
ARC show_regs calls into sleepable page allocator.

| potentially unexpected fatal signal 11.
| BUG: sleeping function called from invalid context at ../mm/page_alloc.c:4317
| in_atomic(): 1, irqs_disabled(): 0, pid: 57, name: segv
| no locks held by segv/57.
| Preemption disabled at:
| [<8182f17e>] get_signal+0x4a6/0x7c4
| CPU: 0 PID: 57 Comm: segv Not tainted 4.17.0+ #23
|
| Stack Trace:
|  arc_unwind_core.constprop.1+0xd0/0xf4
|  __might_sleep+0x1f6/0x234
|  __get_free_pages+0x174/0xca0
|  show_regs+0x22/0x330
|  get_signal+0x4ac/0x7c4     # print_fatal_signals() -> preempt_disable()
|  do_signal+0x30/0x224
|  resume_user_mode_begin+0x90/0xd8

Despite this, lockdep still barfs (see next change), but this patch
still has merit as in we use smaller/localized buffers now and there's
less instructoh trace to sift thru when debugging pesky issues.

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/kernel/troubleshoot.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/arch/arc/kernel/troubleshoot.c b/arch/arc/kernel/troubleshoot.c
index e8d9fb452346..2885bec71fb8 100644
--- a/arch/arc/kernel/troubleshoot.c
+++ b/arch/arc/kernel/troubleshoot.c
@@ -58,11 +58,12 @@ static void show_callee_regs(struct callee_regs *cregs)
 	print_reg_file(&(cregs->r13), 13);
 }
 
-static void print_task_path_n_nm(struct task_struct *tsk, char *buf)
+static void print_task_path_n_nm(struct task_struct *tsk)
 {
 	char *path_nm = NULL;
 	struct mm_struct *mm;
 	struct file *exe_file;
+	char buf[256];
 
 	mm = get_task_mm(tsk);
 	if (!mm)
@@ -80,10 +81,9 @@ static void print_task_path_n_nm(struct task_struct *tsk, char *buf)
 	pr_info("Path: %s\n", !IS_ERR(path_nm) ? path_nm : "?");
 }
 
-static void show_faulting_vma(unsigned long address, char *buf)
+static void show_faulting_vma(unsigned long address)
 {
 	struct vm_area_struct *vma;
-	char *nm = buf;
 	struct mm_struct *active_mm = current->active_mm;
 
 	/* can't use print_vma_addr() yet as it doesn't check for
@@ -96,8 +96,11 @@ static void show_faulting_vma(unsigned long address, char *buf)
 	 * if the container VMA is not found
 	 */
 	if (vma && (vma->vm_start <= address)) {
+		char buf[256];
+		char *nm = "?";
+
 		if (vma->vm_file) {
-			nm = file_path(vma->vm_file, buf, PAGE_SIZE - 1);
+			nm = file_path(vma->vm_file, buf, 256-1);
 			if (IS_ERR(nm))
 				nm = "?";
 		}
@@ -173,13 +176,8 @@ void show_regs(struct pt_regs *regs)
 {
 	struct task_struct *tsk = current;
 	struct callee_regs *cregs;
-	char *buf;
-
-	buf = (char *)__get_free_page(GFP_KERNEL);
-	if (!buf)
-		return;
 
-	print_task_path_n_nm(tsk, buf);
+	print_task_path_n_nm(tsk);
 	show_regs_print_info(KERN_INFO);
 
 	show_ecr_verbose(regs);
@@ -189,7 +187,7 @@ void show_regs(struct pt_regs *regs)
 		(void *)regs->blink, (void *)regs->ret);
 
 	if (user_mode(regs))
-		show_faulting_vma(regs->ret, buf); /* faulting code, not data */
+		show_faulting_vma(regs->ret); /* faulting code, not data */
 
 	pr_info("[STAT32]: 0x%08lx", regs->status32);
 
@@ -221,8 +219,6 @@ void show_regs(struct pt_regs *regs)
 	cregs = (struct callee_regs *)current->thread.callee_reg;
 	if (cregs)
 		show_callee_regs(cregs);
-
-	free_page((unsigned long)buf);
 }
 
 void show_kernel_fault_diag(const char *str, struct pt_regs *regs,
-- 
2.7.4
