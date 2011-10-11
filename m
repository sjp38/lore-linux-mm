Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2BC146B002F
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 13:28:45 -0400 (EDT)
Date: Tue, 11 Oct 2011 19:24:22 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
	thread is singlestepping.
Message-ID: <20111011172422.GA7878@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com> <1317128626.15383.61.camel@twins> <20110927131213.GE3685@linux.vnet.ibm.com> <20111005180139.GA5704@redhat.com> <20111006054710.GB17591@linux.vnet.ibm.com> <20111007165828.GA32319@redhat.com> <20111010122556.GB16268@linux.vnet.ibm.com> <20111010182535.GA6934@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111010182535.GA6934@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 10/10, Oleg Nesterov wrote:
>
> HOWEVER! I simply do not know what should we do if the probed insn
> is something like asm("1:; jmp 1b;"). IIUC, in this sstep_complete()
> never returns true. The patch also adds the fatal_signal_pending()
> check to make this task killlable, but the problem is: whatever we do,
> I do not think it is correct to disable/delay the signals in this case.
> With any approach.
>
> What do you think? Maybe we should simply disallow to probe such insns?

Or. Could you explain why we can't simply remove the
"if (vaddr == current->utask->xol_vaddr)" check from sstep_complete() ?

In some sense, imho this looks more correct for "rep" or jmp/call self.
The task will trap again on the same (original) address, and
handler_chain() will be called to notify the consumers.

But. I am really, really ignorant in this area, I am almost sure this
is not that simple.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
