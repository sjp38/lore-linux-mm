Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8AC8A6B0023
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 11:53:54 -0400 (EDT)
Date: Tue, 25 Oct 2011 17:49:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: test-case (Was: [PATCH 12/X] uprobes: x86: introduce
	abort_xol())
Message-ID: <20111025154906.GA17067@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com> <20111019215326.GF16395@redhat.com> <20111021144207.GN11831@linux.vnet.ibm.com> <20111021162631.GB2552@in.ibm.com> <20111021164221.GA30770@redhat.com> <20111021175915.GA1705@redhat.com> <20111025140613.GA17914@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111025140613.GA17914@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On 10/25, Srikar Dronamraju wrote:
> >
> > 	static inline void *uc_ip(struct ucontext *ctxt)
> > 	{
> > 		return (void*)ctxt->uc_mcontext.gregs[16];
> > 	}
> > ...
> >
> I have tested this on both x86_32 and x86_64 and can confirm that the
> behaviour is same with or without uprobes placed at that instruction.
> This is on the uprobes code with your changes.

Great, thanks.

> However on x86_32; the output is different from x86_64.
>
> On x86_32 (I have additionally printed the uc_ip and fault_insn.
>
> SIGSEGV! ip=0x10246 addr=0x12345678
> ERR!! wrong ip uc_ip(ctxt) = 10246 fault_insn = 804856c

Yep. uc_ip() is not correct on x86_32. Sorry, I forgot to mention this.

I was really surprised when I wrote this test. I simply can't understand
how can I play with ucontext in the user-space. I guess uc_ip() should use
REG_EIP instead of 16, but I wasn't able to compile it even if I added
__USE_GNU. It would be even better to use sigcontext instead of the ugly
mcontext_t, but this looks "impossible". The kernel is much simpler ;)


> I still trying to dig up what uc_ip is and why its different on x86_32.

See above. I guess it needs ctxt->uc_mcontext.gregs[14]. Or REG_EIP.

uc_ip() simply reads sigcontext->ip passed by setup_sigcontext().

> Also I was thinking on your suggestion of making abort_xol a weak
> function. In which case we could have architecture independent function
> in kernel/uprobes.c which is just a wrapper for set_instruction_pointer.
>
> void __weak abort_xol(struct pt_regs *regs, struct uprobe_task *utask)
> {
> 	set_instruction_pointer(regs, utask->vaddr);
> }
>
> where it would called  from uprobe_notify_resume() as
>
> 	abort_xol(regs, utask);
>
> If other archs would want to do something else, they could override
> abort_xol definition.

I didn't suggest this ;) But looks reasonable to me. And afaics x86_32
can use this arch-independent function.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
