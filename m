Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 51F346B005C
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 06:37:05 -0500 (EST)
Message-ID: <1322739387.4699.10.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 01 Dec 2011 12:36:27 +0100
In-Reply-To: <20111201054018.GC18380@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
	 <1322071812.14799.87.camel@twins>
	 <20111124134742.GH28065@linux.vnet.ibm.com>
	 <1322492384.2921.143.camel@twins>
	 <20111129083322.GD13445@linux.vnet.ibm.com>
	 <1322567326.2921.226.camel@twins>
	 <20111129162237.GA18380@linux.vnet.ibm.com>
	 <1322655933.2921.271.camel@twins>
	 <20111201054018.GC18380@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

On Thu, 2011-12-01 at 11:10 +0530, Srikar Dronamraju wrote:

> > What I really would like is for this patch set not to have such subtle
> > stuff at all, esp. at first. Once its in and its been used a bit we can
> > start optimizing and add subtle crap like this.
>=20
> We actually started the discussion of why we increment the count in
> mmap_uprobe() in EEXIST case (and read_opcode()). It exists for two
> reasons.
> 	- To handle fork case (that I wrote in another mail).
> 	- To handle mremap.(the case where we are discussing now)
>=20
> I would contend that removing the breakpoint in munmap doesnt amount to
> optimization. Since the start of unmap(), there cannot be another
> remove_breakpoint called for the vma,vaddr tuple, until the vma is
> cleaned up, or the subsequent mmap() is done. So the case of accounting
> for an already decremented count should never occur.
>=20
> I was following the general convention being used within the kernel to no=
t
> bother about the area that we are going to unmap. For example: If a ptrac=
ed
> area were to be unmapped or remapped, I dont see the breakpoint being
> removed and added back. Also if a ptrace process is exitting, we dont go
> about removing the installed breakpoints.
>=20
> Also we would still need the check for EEXIST and read_opcode for handlin=
g
> the fork() case. So even if we add extra line to remove the actual
> breakpoint in munmap, It doesnt make the code any more simpler.

Not adding the counter now does though. The whole mm->mm_uprobes_count
thing itself is basically an optimization.

Without it we'll get to uprobe_notify_resume() too often, but who cares.
And not having to worry about it removes a lot of this complexity.

Then in the patch where you introduce this optimization you can list all
the nitty gritty details of mremap/fork and counter balancing.

Another point, maybe add some comments on how the generic bits of
uprobe_notify_resume()/uprobe_bkpt_notifier()/uprobe_post_notifier() etc
hang together and what the arch stuff should do.=20

Currently I have to flip back and forth between those to figure out what
happens.

Having that information also helps validate that x86 does indeed do what
is expected and helps other arch maintainers write their code without
having to grok wtf x86 does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
