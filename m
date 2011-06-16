Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6821C6B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 08:13:41 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5GC1Xw9012774
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 08:01:33 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5GCCeb9028170
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 08:12:52 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5GCCbwV030290
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 09:12:40 -0300
Date: Thu, 16 Jun 2011 17:34:42 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 13/22] 13: uprobes: Handing int3 and
 singlestep exception.
Message-ID: <20110616120442.GA4093@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607130051.28590.68088.sendpatchset@localhost6.localdomain6>
 <1308225141.13240.25.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1308225141.13240.25.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

> > +
> > +cleanup_ret:
> > +       if (u) {
> > +               down_read(&mm->mmap_sem);
> > +               if (!set_orig_insn(current, u, probept, true))
> 
> we try to undo the probe? That doesn't make any sense. I thought you
> meant to return to userspace, let it re-take the trap and try again
> until you do manage to allocate the user resource.

I meant removing the probe itself
https://lkml.org/lkml/2011/4/21/279

We could try reseting and retrying the trap. Just that we might end up
looping under memory pressure.

> 
> This behaviour makes probes totally unreliable under memory pressure. 

Under memory pressure we could be unreliable.

> 
> > +                       atomic_dec(&mm->uprobes_count);
> > +               up_read(&mm->mmap_sem);
> > +               put_uprobe(u);
> > +       } else {
> > +       /*TODO Return SIGTRAP signal */
> > +       }
> > +       if (utask) {
> > +               utask->active_uprobe = NULL;
> > +               utask->state = UTASK_RUNNING;
> > +       }
> > +       set_instruction_pointer(regs, probept);
> > +} 
> 
> Also, there's a scary amount of TODO in there...

All of those deal with delaying the signals. I am working on it at this
moment. 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
