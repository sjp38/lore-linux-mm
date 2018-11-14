Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id EED666B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 13:44:42 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id r200-v6so16617965wmg.1
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 10:44:42 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id n130-v6si8545373wma.76.2018.11.14.10.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 10:44:41 -0800 (PST)
Date: Wed, 14 Nov 2018 19:44:36 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 06/27] x86/cet: Control protection exception handler
Message-ID: <20181114184436.GK13926@zn.tnic>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-7-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181011151523.27101-7-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

That subject needs a verb:

Subject: [PATCH v5 06/27] x86/cet: Add control protection exception handler

On Thu, Oct 11, 2018 at 08:15:02AM -0700, Yu-cheng Yu wrote:
> A control protection exception is triggered when a control flow transfer
> attempt violated shadow stack or indirect branch tracking constraints.
> For example, the return address for a RET instruction differs from the
> safe copy on the shadow stack; or a JMP instruction arrives at a non-
> ENDBR instruction.
> 
> The control protection exception handler works in a similar way as the
> general protection fault handler.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/entry/entry_64.S          |  2 +-
>  arch/x86/include/asm/traps.h       |  3 ++
>  arch/x86/kernel/idt.c              |  4 ++
>  arch/x86/kernel/signal_compat.c    |  2 +-
>  arch/x86/kernel/traps.c            | 64 ++++++++++++++++++++++++++++++
>  include/uapi/asm-generic/siginfo.h |  3 +-
>  6 files changed, 75 insertions(+), 3 deletions(-)

A *lot* of style problems here. Please use checkpatch and then common
sense to check your patches before sending. All those below are valid,
AFAICT:

WARNING: function definition argument 'struct pt_regs *' should also have an identifier name
#76: FILE: arch/x86/include/asm/traps.h:81:
+dotraplinkage void do_control_protection(struct pt_regs *, long);

WARNING: function definition argument 'long' should also have an identifier name
#76: FILE: arch/x86/include/asm/traps.h:81:
+dotraplinkage void do_control_protection(struct pt_regs *, long);

WARNING: static const char * array should probably be static const char * const
#124: FILE: arch/x86/kernel/traps.c:581:
+static const char *control_protection_err[] =

ERROR: that open brace { should be on the previous line
#125: FILE: arch/x86/kernel/traps.c:582:
+static const char *control_protection_err[] =
+{

WARNING: quoted string split across lines
#158: FILE: arch/x86/kernel/traps.c:615:
+		WARN_ONCE(1, "CET is disabled but got control "
+			  "protection fault\n");

WARNING: Prefer printk_ratelimited or pr_<level>_ratelimited to printk_ratelimit
#165: FILE: arch/x86/kernel/traps.c:622:
+	    printk_ratelimit()) {

WARNING: Avoid logging continuation uses where feasible
#176: FILE: arch/x86/kernel/traps.c:633:
+		pr_cont("\n");

ERROR: "(foo*)" should be "(foo *)"
#183: FILE: arch/x86/kernel/traps.c:640:
+	info.si_addr	= (void __user*)uprobe_get_trap_addr(regs);


And now that patch doesn't even build anymore because of the siginfo
changes which came in during the merge window. I guess I'll wait for
your v6 patchset.

---
arch/x86/kernel/traps.c: In function a??do_control_protectiona??:
arch/x86/kernel/traps.c:627:16: error: passing argument 1 of a??clear_siginfoa?? from incompatible pointer type [-Werror=incompatible-pointer-types]
  clear_siginfo(&info);
                ^~~~~
In file included from ./include/linux/sched/signal.h:6,
                 from ./include/linux/ptrace.h:7,
                 from ./include/linux/ftrace.h:14,
                 from ./include/linux/kprobes.h:42,
                 from arch/x86/kernel/traps.c:19:
./include/linux/signal.h:20:52: note: expected a??kernel_siginfo_t *a?? {aka a??struct kernel_siginfo *a??} but argument is of type a??siginfo_t *a?? {aka a??struct siginfo *a??}
 static inline void clear_siginfo(kernel_siginfo_t *info)
                                  ~~~~~~~~~~~~~~~~~~^~~~
arch/x86/kernel/traps.c:632:26: error: passing argument 2 of a??force_sig_infoa?? from incompatible pointer type [-Werror=incompatible-pointer-types]
  force_sig_info(SIGSEGV, &info, tsk);
                          ^~~~~
In file included from ./include/linux/ptrace.h:7,
                 from ./include/linux/ftrace.h:14,
                 from ./include/linux/kprobes.h:42,
                 from arch/x86/kernel/traps.c:19:
./include/linux/sched/signal.h:327:32: note: expected a??struct kernel_siginfo *a?? but argument is of type a??siginfo_t *a?? {aka a??struct siginfo *a??}
 extern int force_sig_info(int, struct kernel_siginfo *, struct task_struct *);
                                ^~~~~~~~~~~~~~~~~~~~~~~
cc1: some warnings being treated as errors
make[2]: *** [scripts/Makefile.build:291: arch/x86/kernel/traps.o] Error 1
make[1]: *** [scripts/Makefile.build:516: arch/x86/kernel] Error 2
make[1]: *** Waiting for unfinished jobs....
make: *** [Makefile:1060: arch/x86] Error 2
make: *** Waiting for unfinished jobs....

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
