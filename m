Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC146B005D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 19:52:43 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 02/80] x86: ptrace debugreg checks rewrite
Date: Wed, 23 Sep 2009 19:50:42 -0400
Message-Id: <1253749920-18673-3-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

This is a mess.

Pre unified-x86 code did check for breakpoint addr
to be "< TASK_SIZE - 3 (or 7)". This was fine from security POV,
but banned valid breakpoint usage when address is close to TASK_SIZE.
E. g. 1-byte breakpoint at TASK_SIZE - 1 should be allowed, but it wasn't.

Then came commit 84929801e14d968caeb84795bfbb88f04283fbd9
("[PATCH] x86_64: TASK_SIZE fixes for compatibility mode processes")
which for some reason touched ptrace as well and made effective
TASK_SIZE of 32-bit process depending on IA32_PAGE_OFFSET
which is not a constant!:

	#define IA32_PAGE_OFFSET ((current->personality & ADDR_LIMIT_3GB) ? 0xc0000000 : 0xFFFFe000)
				   ^^^^^^^
Maximum addr for breakpoint became dependent on personality of ptracer.

Commit also relaxed danger zone for 32-bit processes from 8 bytes to 4
not taking into account that 8-byte wide breakpoints are possible even
for 32-bit processes. This was fine, however, because 64-bit kernel
addresses are too far from 32-bit ones.

Then came utrace with commit 2047b08be67b70875d8765fc81d34ce28041bec3
("x86: x86 ptrace getreg/putreg merge") which copy-pasted and ifdeffed 32-bit
part of TASK_SIZE_OF() leaving 8-byte issue as-is.

So, what patch fixes?
1) Too strict logic near TASK_SIZE boundary -- as long as we don't cross
   TASK_SIZE_MAX, we're fine.
2) Too smart logic of using breakpoints over non-existent kernel
   boundary -- we should only protect against setting up after
   TASK_SIZE_MAX, the rest is none of kernel business. This fixes
   IA32_PAGE_OFFSET beartrap as well.

As a bonus, remove uberhack and big comment determining DR7 validness,
rewrite with clear algorithm when it's obvious what's going on.

Make DR validness checker suitable for C/R. On restart DR registers
must be checked the same way they are checked on PTRACE_POKEUSR.

Question 1: TIF_DEBUG can set even if none of breakpoints is turned on,
should this be optimized?

Question 2: Breakpoints are allowed to be globally enabled, is this a
security risk?

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 arch/x86/kernel/ptrace.c |  175 +++++++++++++++++++++++++++-------------------
 1 files changed, 103 insertions(+), 72 deletions(-)

diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 09ecbde..9b4cacf 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -136,11 +136,6 @@ static int set_segment_reg(struct task_struct *task,
 	return 0;
 }
 
-static unsigned long debugreg_addr_limit(struct task_struct *task)
-{
-	return TASK_SIZE - 3;
-}
-
 #else  /* CONFIG_X86_64 */
 
 #define FLAG_MASK		(FLAG_MASK_32 | X86_EFLAGS_NT)
@@ -264,16 +259,6 @@ static int set_segment_reg(struct task_struct *task,
 
 	return 0;
 }
-
-static unsigned long debugreg_addr_limit(struct task_struct *task)
-{
-#ifdef CONFIG_IA32_EMULATION
-	if (test_tsk_thread_flag(task, TIF_IA32))
-		return IA32_PAGE_OFFSET - 3;
-#endif
-	return TASK_SIZE_MAX - 7;
-}
-
 #endif	/* CONFIG_X86_32 */
 
 static unsigned long get_flags(struct task_struct *task)
@@ -481,77 +466,123 @@ static unsigned long ptrace_get_debugreg(struct task_struct *child, int n)
 	return 0;
 }
 
+static int ptrace_check_debugreg(int _32bit,
+				 unsigned long dr0, unsigned long dr1,
+				 unsigned long dr2, unsigned long dr3,
+				 unsigned long dr6, unsigned long dr7)
+{
+	/* Breakpoint type: 00: --x, 01: -w-, 10: undefined, 11: rw- */
+	unsigned int rw[4];
+	/* Breakpoint length: 00: 1 byte, 01: 2 bytes, 10: 8 bytes, 11: 4 bytes */
+	unsigned int len[4];
+	int n;
+
+	if (dr0 >= TASK_SIZE_MAX)
+		return -EINVAL;
+	if (dr1 >= TASK_SIZE_MAX)
+		return -EINVAL;
+	if (dr2 >= TASK_SIZE_MAX)
+		return -EINVAL;
+	if (dr3 >= TASK_SIZE_MAX)
+		return -EINVAL;
+
+	for (n = 0; n < 4; n++) {
+		rw[n] = (dr7 >> (16 + n * 4)) & 0x3;
+		len[n] = (dr7 >> (16 + n * 4 + 2)) & 0x3;
+
+		if (rw[n] == 0x2)
+			return -EINVAL;
+		if (rw[n] == 0x0 && len[n] != 0x0)
+			return -EINVAL;
+		if (_32bit && len[n] == 0x2)
+			return -EINVAL;
+
+		if (len[n] == 0x0)
+			len[n] = 1;
+		else if (len[n] == 0x1)
+			len[n] = 2;
+		else if (len[n] == 0x2)
+			len[n] = 8;
+		else if (len[n] == 0x3)
+			len[n] = 4;
+		/* From now breakpoint length is in bytes. */
+	}
+
+	if (dr6 & ~0xFFFFFFFFUL)
+		return -EINVAL;
+	if (dr7 & ~0xFFFFFFFFUL)
+		return -EINVAL;
+
+	if (dr7 == 0)
+		return 0;
+
+	if (dr0 + len[0] > TASK_SIZE_MAX)
+		return -EINVAL;
+	if (dr1 + len[1] > TASK_SIZE_MAX)
+		return -EINVAL;
+	if (dr2 + len[2] > TASK_SIZE_MAX)
+		return -EINVAL;
+	if (dr3 + len[3] > TASK_SIZE_MAX)
+		return -EINVAL;
+
+	return 0;
+}
+
 static int ptrace_set_debugreg(struct task_struct *child,
 			       int n, unsigned long data)
 {
-	int i;
+	unsigned long dr0, dr1, dr2, dr3, dr6, dr7;
+	int _32bit;
 
 	if (unlikely(n == 4 || n == 5))
 		return -EIO;
 
-	if (n < 4 && unlikely(data >= debugreg_addr_limit(child)))
-		return -EIO;
-
+	dr0 = child->thread.debugreg0;
+	dr1 = child->thread.debugreg1;
+	dr2 = child->thread.debugreg2;
+	dr3 = child->thread.debugreg3;
+	dr6 = child->thread.debugreg6;
+	dr7 = child->thread.debugreg7;
 	switch (n) {
-	case 0:		child->thread.debugreg0 = data; break;
-	case 1:		child->thread.debugreg1 = data; break;
-	case 2:		child->thread.debugreg2 = data; break;
-	case 3:		child->thread.debugreg3 = data; break;
-
+	case 0:
+		dr0 = data;
+		break;
+	case 1:
+		dr1 = data;
+		break;
+	case 2:
+		dr2 = data;
+		break;
+	case 3:
+		dr3 = data;
+		break;
 	case 6:
-		if ((data & ~0xffffffffUL) != 0)
-			return -EIO;
-		child->thread.debugreg6 = data;
+		dr6 = data;
 		break;
-
 	case 7:
-		/*
-		 * Sanity-check data. Take one half-byte at once with
-		 * check = (val >> (16 + 4*i)) & 0xf. It contains the
-		 * R/Wi and LENi bits; bits 0 and 1 are R/Wi, and bits
-		 * 2 and 3 are LENi. Given a list of invalid values,
-		 * we do mask |= 1 << invalid_value, so that
-		 * (mask >> check) & 1 is a correct test for invalid
-		 * values.
-		 *
-		 * R/Wi contains the type of the breakpoint /
-		 * watchpoint, LENi contains the length of the watched
-		 * data in the watchpoint case.
-		 *
-		 * The invalid values are:
-		 * - LENi == 0x10 (undefined), so mask |= 0x0f00.	[32-bit]
-		 * - R/Wi == 0x10 (break on I/O reads or writes), so
-		 *   mask |= 0x4444.
-		 * - R/Wi == 0x00 && LENi != 0x00, so we have mask |=
-		 *   0x1110.
-		 *
-		 * Finally, mask = 0x0f00 | 0x4444 | 0x1110 == 0x5f54.
-		 *
-		 * See the Intel Manual "System Programming Guide",
-		 * 15.2.4
-		 *
-		 * Note that LENi == 0x10 is defined on x86_64 in long
-		 * mode (i.e. even for 32-bit userspace software, but
-		 * 64-bit kernel), so the x86_64 mask value is 0x5454.
-		 * See the AMD manual no. 24593 (AMD64 System Programming)
-		 */
-#ifdef CONFIG_X86_32
-#define	DR7_MASK	0x5f54
-#else
-#define	DR7_MASK	0x5554
-#endif
-		data &= ~DR_CONTROL_RESERVED;
-		for (i = 0; i < 4; i++)
-			if ((DR7_MASK >> ((data >> (16 + 4*i)) & 0xf)) & 1)
-				return -EIO;
-		child->thread.debugreg7 = data;
-		if (data)
-			set_tsk_thread_flag(child, TIF_DEBUG);
-		else
-			clear_tsk_thread_flag(child, TIF_DEBUG);
+		dr7 = data & ~DR_CONTROL_RESERVED;
 		break;
 	}
 
+	_32bit = (sizeof(unsigned long) == 4);
+#ifdef CONFIG_COMPAT
+	if (test_tsk_thread_flag(child, TIF_IA32))
+		_32bit = 1;
+#endif
+	if (ptrace_check_debugreg(_32bit, dr0, dr1, dr2, dr3, dr6, dr7))
+		return -EIO;
+
+	child->thread.debugreg0 = dr0;
+	child->thread.debugreg1 = dr1;
+	child->thread.debugreg2 = dr2;
+	child->thread.debugreg3 = dr3;
+	child->thread.debugreg6 = dr6;
+	child->thread.debugreg7 = dr7;
+	if (dr7)
+		set_tsk_thread_flag(child, TIF_DEBUG);
+	else
+		clear_tsk_thread_flag(child, TIF_DEBUG);
+
 	return 0;
 }
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
