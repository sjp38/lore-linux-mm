Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B32856B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:01:38 -0400 (EDT)
Received: by widdi4 with SMTP id di4so120621979wid.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 13:01:38 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id d5si1425226wie.74.2015.05.11.13.01.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 13:01:37 -0700 (PDT)
Date: Mon, 11 May 2015 22:01:27 +0200
From: Helge Deller <deller@gmx.de>
Subject: [PATCH] Fix crashes due to stack randomization on
 stack-grows-upwards architectures
Message-ID: <20150511200127.GA2338@ls3530.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, James Hogan <james.hogan@imgtec.com>, linux-metag@vger.kernel.org, linux-mm@kvack.org

On architectures where the stack grows upwards (CONFIG_STACK_GROWSUP=y,
currently parisc and metag only) stack randomization sometimes leads to crashes
when the stack ulimit is set to lower values than STACK_RND_MASK (which is 8 MB
by default if not defined in arch-specific headers).

The problem is, that when the stack vm_area_struct is set up in fs/exec.c, the
additional space needed for the stack randomization (as defined by the value of
STACK_RND_MASK) was not taken into account yet and as such, when the stack
randomization code added a random offset to the stack start, the stack
effectively got smaller than what the user defined via rlimit_max(RLIMIT_STACK)
which then sometimes leads to out-of-stack situations and crashes.

This patch fixes it by adding the maximum possible amount of memory (based on
STACK_RND_MASK) which theoretically could be added by the stack randomization
code to the initial stack size. That way, the user-defined stack size is always
guaranteed to be at minimum what is defined via rlimit_max(RLIMIT_STACK).

This bug is currently not visible on the metag architecture, because on metag
STACK_RND_MASK is defined to 0 which effectively disables stack randomization.

The changes to fs/exec.c are inside an "#ifdef CONFIG_STACK_GROWSUP"
section, so it does not affect other platformws beside those where the
stack grows upwards (parisc and metag).

Signed-off-by: Helge Deller <deller@gmx.de>
Cc: linux-parisc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-metag@vger.kernel.org
Cc: linux-mm@kvack.org

diffstat:
 arch/parisc/include/asm/elf.h   |    4 ++++
 arch/parisc/kernel/sys_parisc.c |    3 +++
 fs/exec.c                       |    3 +++
 3 files changed, 10 insertions(+)


diff --git a/arch/parisc/include/asm/elf.h b/arch/parisc/include/asm/elf.h
index 3391d06..78c9fd3 100644
--- a/arch/parisc/include/asm/elf.h
+++ b/arch/parisc/include/asm/elf.h
@@ -348,6 +348,10 @@ struct pt_regs;	/* forward declaration... */
 
 #define ELF_HWCAP	0
 
+#define STACK_RND_MASK	(is_32bit_task() ? \
+				0x7ff >> (PAGE_SHIFT - 12) : \
+				0x3ffff >> (PAGE_SHIFT - 12))
+
 struct mm_struct;
 extern unsigned long arch_randomize_brk(struct mm_struct *);
 #define arch_randomize_brk arch_randomize_brk
diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index e1ffea2..5aba01a 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -77,6 +77,9 @@ static unsigned long mmap_upper_limit(void)
 	if (stack_base > STACK_SIZE_MAX)
 		stack_base = STACK_SIZE_MAX;
 
+	/* Add space for stack randomization. */
+	stack_base += (STACK_RND_MASK << PAGE_SHIFT);
+
 	return PAGE_ALIGN(STACK_TOP - stack_base);
 }
 
diff --git a/fs/exec.c b/fs/exec.c
index 49a1c61..1977c2a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -659,6 +659,9 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	if (stack_base > STACK_SIZE_MAX)
 		stack_base = STACK_SIZE_MAX;
 
+	/* Add space for stack randomization. */
+	stack_base += (STACK_RND_MASK << PAGE_SHIFT);
+
 	/* Make sure we didn't let the argument array grow too large. */
 	if (vma->vm_end - vma->vm_start > stack_base)
 		return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
