Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F70A8D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 15:51:22 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 02/12] x86: mark associated mm when running a task in 32 bit compatibility mode
Date: Sun, 13 Mar 2011 15:49:14 -0400
Message-Id: <1300045764-24168-3-git-send-email-wilsons@start.ca>
In-Reply-To: <1300045764-24168-1-git-send-email-wilsons@start.ca>
References: <1300045764-24168-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

This patch simply follows the same practice as for setting the TIF_IA32 flag.
In particular, an mm is marked as holding 32-bit tasks when a 32-bit binary is
exec'ed.  Both ELF and a.out formats are updated.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: Michel Lespinasse <walken@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/x86/ia32/ia32_aout.c    |    1 +
 arch/x86/kernel/process_64.c |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index 2d93bdb..fd84387 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -298,6 +298,7 @@ static int load_aout_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	/* OK, This is the point of no return */
 	set_personality(PER_LINUX);
 	set_thread_flag(TIF_IA32);
+	current->mm->context.ia32_compat = 1;
 
 	setup_new_exec(bprm);
 
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index bd387e8..6c9dd92 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -501,6 +501,10 @@ void set_personality_64bit(void)
 	/* Make sure to be in 64bit mode */
 	clear_thread_flag(TIF_IA32);
 
+	/* Ensure the corresponding mm is not marked. */
+	if (current->mm)
+		current->mm->context.ia32_compat = 0;
+
 	/* TBD: overwrites user setup. Should have two bits.
 	   But 64bit processes have always behaved this way,
 	   so it's not too bad. The main problem is just that
@@ -516,6 +520,10 @@ void set_personality_ia32(void)
 	set_thread_flag(TIF_IA32);
 	current->personality |= force_personality32;
 
+	/* Mark the associated mm as containing 32-bit tasks. */
+	if (current->mm)
+		current->mm->context.ia32_compat = 1;
+
 	/* Prepare the first "return" to user space */
 	current_thread_info()->status |= TS_COMPAT;
 }
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
