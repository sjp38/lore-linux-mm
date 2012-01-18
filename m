Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id AE7616B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 03:39:37 -0500 (EST)
Date: Wed, 18 Jan 2012 09:39:06 +0100
From: Anton Arapov <anton@redhat.com>
Subject: Re: [PATCH v9 3.2 2/9] uprobes: handle breakpoint and signal step
 exception.
Message-ID: <20120118083906.GA4697@bandura.brq.redhat.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114842.17610.27081.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120110114842.17610.27081.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, Jan 10, 2012 at 05:18:42PM +0530, Srikar Dronamraju wrote:
[snip]
> diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
> index 8208234..475563b 100644
> --- a/arch/x86/include/asm/uprobes.h
> +++ b/arch/x86/include/asm/uprobes.h
[snip]
> @@ -37,6 +39,21 @@ struct uprobe_arch_info {
>  #endif
>  };
>  
> +struct uprobe_task_arch_info {
> +	unsigned long saved_trap_no;
> +#ifdef CONFIG_X86_64
> +	unsigned long saved_scratch_register;
> +#endif
> +};
> +
>  struct uprobe;
> +
>  extern int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe);
> +extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);
Srikar,

  Can we use existing SET_IP() instead of set_instruction_pointer() ?

[snip]  
>  static void __exit exit_uprobes(void)
> 

===
[PATCH] uprobes: cleanup, eliminate set_instruction_pointer(), use existing SET_IP() instead

Use SET_IP() available in include/asm-generic/ptrace.h

Signed-off-by: Anton Arapov <anton@redhat.com>
---
 arch/x86/include/asm/uprobes.h |    1 -
 arch/x86/kernel/uprobes.c      |   12 +-----------
 kernel/uprobes.c               |    2 +-
 3 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 475563b..88df7ec 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -49,7 +49,6 @@ struct uprobe_task_arch_info {
 struct uprobe;
 
 extern int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe);
-extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);
 extern int pre_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern int post_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern bool xol_was_trapped(struct task_struct *tsk);
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index e4e0dfd..08b633f 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -409,16 +409,6 @@ int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe)
 	return 0;
 }
 
-/*
- * @reg: reflects the saved state of the task
- * @vaddr: the virtual address to jump to.
- * Return 0 on success or a -ve number on error.
- */
-void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr)
-{
-	regs->ip = vaddr;
-}
-
 #define	UPROBE_TRAP_NO		UINT_MAX
 
 /*
@@ -624,7 +614,7 @@ void abort_xol(struct pt_regs *regs, struct uprobe *uprobe)
 
 	current->thread.trap_no = utask->tskinfo.saved_trap_no;
 	handle_riprel_post_xol(uprobe, regs, NULL);
-	set_instruction_pointer(regs, utask->vaddr);
+	SET_IP(regs, utask->vaddr);
 }
 
 /*
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 0918448..b0db46b 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1479,7 +1479,7 @@ cleanup_ret:
 	}
 	if (u) {
 		if (!(u->flags & UPROBES_SKIP_SSTEP))
-			set_instruction_pointer(regs, probept);
+			SET_IP(regs, probept);
 
 		put_uprobe(u);
 	} else
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
