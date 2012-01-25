Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 1BA986B005A
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 09:11:36 -0500 (EST)
Received: from 178-85-86-190.dynamic.upc.nl ([178.85.86.190] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1Rq3ZW-0003Qy-0S
	for linux-mm@kvack.org; Wed, 25 Jan 2012 14:11:34 +0000
Subject: Re: [PATCH v9 3.2 0/9] Uprobes patchset with perf probe support
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20120117093925.GC10397@elte.hu>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
	 <20120116083442.GA23622@elte.hu>
	 <20120116151755.GH10189@linux.vnet.ibm.com>
	 <20120117093925.GC10397@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 25 Jan 2012 15:11:27 +0100
Message-ID: <1327500687.2614.70.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arnaldo Carvalho de Melo <acme@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, 2012-01-17 at 10:39 +0100, Ingo Molnar wrote:

> I did not suggest anything complex or intrusive: just basically 
> unify the namespace, have a single set of callbacks, and call 
> into the uprobes and perf code from those callbacks - out of the 
> sight of MM code.
> 
> That unified namespace could be called:
> 
>     event_mmap(...);
>     event_fork(...);
> 
> etc. - and from event_mmap() you could do a simple:
> 
> 	perf_event_mmap(...)
> 	uprobes_event_mmap(...)
> 
> [ Once all this is updated to use tracepoints it would turn into 
>   a notification callback chain kind of thing. ]

We keep disagreeing on this. I utterly loathe hiding stuff in notifier
lists. It makes it completely non-obvious who all does what.

Another very good reason to not do what you suggest is that
perf_event_mmap() is a pure consumer, it doesn't have a return value,
whereas uprobes_mmap() can actually fail the mmap.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
