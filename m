Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E29846B0023
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 10:32:18 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 25 Oct 2011 10:29:13 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9PESDKZ215866
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 10:28:15 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9PESBZY010018
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 12:28:13 -0200
Date: Tue, 25 Oct 2011 19:36:13 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: test-case (Was: [PATCH 12/X] uprobes: x86: introduce
 abort_xol())
Message-ID: <20111025140613.GA17914@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20111015190007.GA30243@redhat.com>
 <20111019215139.GA16395@redhat.com>
 <20111019215326.GF16395@redhat.com>
 <20111021144207.GN11831@linux.vnet.ibm.com>
 <20111021162631.GB2552@in.ibm.com>
 <20111021164221.GA30770@redhat.com>
 <20111021175915.GA1705@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111021175915.GA1705@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

> 
> Ananth, Srikar, I'd suggest this test-case:
> 
> 	#include <stdio.h>
> 	#include <signal.h>
> 	#include <ucontext.h>
> 
> 	void *fault_insn;
> 
> 	static inline void *uc_ip(struct ucontext *ctxt)
> 	{
> 		return (void*)ctxt->uc_mcontext.gregs[16];
> 	}
> 
> 	void segv(int sig, siginfo_t *info, void *ctxt)
> 	{
> 		static int cnt;
> 
> 		printf("SIGSEGV! ip=%p addr=%p\n", uc_ip(ctxt), info->si_addr);
> 
> 		if (uc_ip(ctxt) != fault_insn)
> 			printf("ERR!! wrong ip\n");
> 		if (info->si_addr != (void*)0x12345678)
> 			printf("ERR!! wrong addr\n");
> 
> 		if (++cnt == 3)
> 			signal(SIGSEGV, SIG_DFL);
> 	}
> 
> 	int main(void)
> 	{
> 		struct sigaction sa = {
> 			.sa_sigaction	= segv,
> 			.sa_flags	= SA_SIGINFO,
> 		};
> 
> 		sigaction(SIGSEGV, &sa, NULL);
> 
> 		fault_insn = &&label;
> 
> 	label:
> 		asm volatile ("movl $0x0,0x12345678");
> 
> 		return 0;
> 	}
> 
> result:
> 
> 	$ ulimit -c unlimited
> 
> 	$ ./segv
> 	SIGSEGV! ip=0x4006eb addr=0x12345678
> 	SIGSEGV! ip=0x4006eb addr=0x12345678
> 	SIGSEGV! ip=0x4006eb addr=0x12345678
> 	Segmentation fault (core dumped)
> 
> 	$ gdb -c ./core.1826
> 	...
> 	Program terminated with signal 11, Segmentation fault.
> 	#0  0x00000000004006eb in ?? ()
> 
> Now. If you insert uprobe at asm("movl") insn, result should be the same
> or the patches I sent are wrong. In particular, the addr in the coredump
> should be correct too. And consumer->handler() should be called 3 times
> too. This insn is really executed 3 times.
> 
> I have no idea how can I test this.
> 

I have tested this on both x86_32 and x86_64 and can confirm that the
behaviour is same with or without uprobes placed at that instruction.
This is on the uprobes code with your changes.

However on x86_32; the output is different from x86_64. 

On x86_32 (I have additionally printed the uc_ip and fault_insn.

SIGSEGV! ip=0x10246 addr=0x12345678
ERR!! wrong ip uc_ip(ctxt) = 10246 fault_insn = 804856c
SIGSEGV! ip=0x10246 addr=0x12345678
ERR!! wrong ip uc_ip(ctxt) = 10246 fault_insn = 804856c
SIGSEGV! ip=0x10246 addr=0x12345678
ERR!! wrong ip uc_ip(ctxt) = 10246 fault_insn = 804856c
Segmentation fault

the fault_insn matches the address shown in disassemble of gdb.
I still trying to dig up what uc_ip is and why its different on x86_32.

On x86_64 the result is what you pasted above.


Also I was thinking on your suggestion of making abort_xol a weak
function.  In which case we could have architecture independent function
in kernel/uprobes.c which is just a wrapper for set_instruction_pointer. 

void __weak abort_xol(struct pt_regs *regs, struct uprobe_task *utask)
{
	set_instruction_pointer(regs, utask->vaddr);	
}

where it would called  from uprobe_notify_resume() as 

	abort_xol(regs, utask);

If other archs would want to do something else, they could override
abort_xol definition.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
