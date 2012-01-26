Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id BCF536B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 06:11:14 -0500 (EST)
Date: Thu, 26 Jan 2012 12:10:41 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v9 3.2 0/9] Uprobes patchset with perf probe support
Message-ID: <20120126111041.GG3853@elte.hu>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120116083442.GA23622@elte.hu>
 <20120116151755.GH10189@linux.vnet.ibm.com>
 <20120117093925.GC10397@elte.hu>
 <1327500687.2614.70.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327500687.2614.70.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arnaldo Carvalho de Melo <acme@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, 2012-01-17 at 10:39 +0100, Ingo Molnar wrote:
> 
> > I did not suggest anything complex or intrusive: just basically 
> > unify the namespace, have a single set of callbacks, and call 
> > into the uprobes and perf code from those callbacks - out of the 
> > sight of MM code.
> > 
> > That unified namespace could be called:
> > 
> >     event_mmap(...);
> >     event_fork(...);
> > 
> > etc. - and from event_mmap() you could do a simple:
> > 
> > 	perf_event_mmap(...)
> > 	uprobes_event_mmap(...)
> > 
> > [ Once all this is updated to use tracepoints it would turn into 
> >   a notification callback chain kind of thing. ]
> 
> We keep disagreeing on this. I utterly loathe hiding stuff in 
> notifier lists. It makes it completely non-obvious who all 
> does what.

My immediate suggestion was not a notifier list but an 
open-coded list of function calls done in helper inline 
functions - to minimize the impact of the callbacks on mm/.

> Another very good reason to not do what you suggest is that 
> perf_event_mmap() is a pure consumer, it doesn't have a return 
> value, whereas uprobes_mmap() can actually fail the mmap.

You know that i disagree with that, there is no fundamental 
reason why event callbacks couldnt participate in program logic, 
as long as the call site explicitly wants such side effects. It 
avoids senseless duplication of callbacks.

Anyway, if Andrew is fine with the current callbacks as-is then 
it's fine to me as well.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
