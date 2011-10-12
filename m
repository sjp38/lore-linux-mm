Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BF94F6B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:39:08 -0400 (EDT)
Date: Wed, 12 Oct 2011 21:34:17 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
	thread is singlestepping.
Message-ID: <20111012193417.GA11004@redhat.com>
References: <1317128626.15383.61.camel@twins> <20110927131213.GE3685@linux.vnet.ibm.com> <20111005180139.GA5704@redhat.com> <20111006054710.GB17591@linux.vnet.ibm.com> <20111007165828.GA32319@redhat.com> <20111010122556.GB16268@linux.vnet.ibm.com> <20111010182535.GA6934@redhat.com> <20111011172603.GD16268@linux.vnet.ibm.com> <20111011185653.GA10215@redhat.com> <20111012120112.GB11831@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111012120112.GB11831@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 10/12, Srikar Dronamraju wrote:
>
> I think we should be okay if the test exits in UTASK_SSTEP state.

Yes, and afaics we can't avoid this case, at least currently.

But we should move free_uprobe_utask() to mm_release(), or somewhere
else before mm->core_state check in exit_mm().

My main concern is stop/freeze in UTASK_SSTEP state. If nothing else,
debugger can attach to the stopped task and disable the stepping. Or
SIGKILL, it should work in this case.

> > Great. I'll think a bit more and send you the "final" version tomorrow.
> > Assuming we can change sstep_complete() as we discussed, it doesn't need
> > fatal_signal_pending().
>
> Okay.

Sorry. I was busy today. Tomorrow ;)

> > HOWEVER. There is yet another problem. Another thread can, say, unmap()
> > xol_vma. In this case we should ensure that the task can't fault in an
> > endless loop.
>
> Hmm should we add a check in unmap() to see if the vma that we are
> trying to unmap is the xol_vma and if so return?

Oh, I am not sure. You know, I _think_ that perhaps we should do something
diferent in the long term. In particular, this xol page should not have
vma at all. This way we shouldn't worry about unmap/remap/mprotect.
But even if this is possible (I am not really sure), I do not think we
should do this right now.

> Our assumption has been that once an xol_vma has been created, it should
> be around till the process gets killed.

Yes, I see. But afaics this assumption is currently wrong. This means
that we should ensure the evil application can't exploit this fact.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
