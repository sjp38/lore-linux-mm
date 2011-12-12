Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 4C7C46B01A3
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 12:35:59 -0500 (EST)
Date: Mon, 12 Dec 2011 18:30:19 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH RFC 0/5] uprobes: kill xol vma
Message-ID: <20111212173019.GA25226@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com> <20111128190614.GA4602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111128190614.GA4602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, Josh Stone <jistone@redhat.com>

On 11/28, Oleg Nesterov wrote:
>
> On top of this series, not for inclusion yet, just to explain what
> I mean. May be someone can test it ;)
>
> This series kills xol_vma. Instead we use the per_cpu-like xol slots.
>
> This is much more simple and efficient. And this of course solves
> many problems we currently have with xol_vma.
>
> For example, we simply can not trust it. We do not know what actually
> we are going to execute in UTASK_SSTEP mode. An application can unmap
> this area and then do mmap(PROT_EXEC|PROT_WRITE, MAP_FIXED) to fool
> uprobes.
>
> The only disadvantage is that this adds a bit more arch-dependant
> code.
>
> The main question, can this work?

OK, it almost works.

But, this way we can't probe the compat tasks. A __USER32_CS task can't
access the fix_to_virt() area, so it can't use uprobe_xol_slots[].

Many thanks to Josh who noticed this.

I'll try to think more, but so far I do not see any simple solution.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
