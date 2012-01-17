Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id AE0CD6B008A
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:39:50 -0500 (EST)
Date: Tue, 17 Jan 2012 10:39:25 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v9 3.2 0/9] Uprobes patchset with perf probe support
Message-ID: <20120117093925.GC10397@elte.hu>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120116083442.GA23622@elte.hu>
 <20120116151755.GH10189@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120116151755.GH10189@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnaldo Carvalho de Melo <acme@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


* Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> > We already have some other vma tracking goodies in perf 
> > itself (see perf_event_mmap() et al) - would it make sense 
> > to merge the two vma instrumentation facilities and not 
> > burden mm/ with two separate sets of callbacks?
> 
> Atleast for file backed vmas, perf_event_mmap seems to be 
> interested in just the new vma creations. Uprobes would also 
> be interested in the size changes like the vma 
> growing/shrinking/remap. Is perf_event_mmap interested in such 
> changes? From what i could see, perf_event_mmap seems to be 
> interested in stack vma size changes but not file vma size 
> changes.

I don't think perf_event_mmap() would be hurt from getting more 
callbacks, as long as there's enough metadata to differentiate 
the various events from each other.

( In the long run we really want all such callbacks to be
  tracepoints so that we can make them even less intrusive via
  jump label patching optimizations, etc. - but we are not there
  yet. )

> Also mmap_uprobe gets called in fork path. Currently we have a 
> hook in copy_mm/dup_mm so that we get to know the context of 
> each vma that gets added to the child and add its breakpoints. 
> At dup_mm/dup_mmap we would have taken mmap_sem for both 
> parent and child so there is no way we could have missed a 
> register/unregister in the parent not reflected in the child.
> 
> I see the perf_event_fork but that would have to enhanced to 
> do a lot more to help us do a mmap_uprobe.

Andrew's call i guess.

I did not suggest anything complex or intrusive: just basically 
unify the namespace, have a single set of callbacks, and call 
into the uprobes and perf code from those callbacks - out of the 
sight of MM code.

That unified namespace could be called:

    event_mmap(...);
    event_fork(...);

etc. - and from event_mmap() you could do a simple:

	perf_event_mmap(...)
	uprobes_event_mmap(...)

[ Once all this is updated to use tracepoints it would turn into 
  a notification callback chain kind of thing. ]

> > If all such issues are resolved then i guess we could queue 
> > up uprobes in -tip, conditional on it remaining sufficiently 
> > regression-, problem- and NAK-free.
> 
> Okay. Accepting uprobes into tip, would provide more 
> testing/feedback.
> 
> > Also, it would be nice to hear Arnaldo's opinion about the 
> > tools/perf/ bits.
> 
> Whatever comments Arnaldo/Masami have given till now have been 
> resolved.

Please see the probe installation syntax feedback i've sent in 
the previous mail - that needs to be addressed too.

You should think with the head of an ordinary user-space 
developer who wants to say debug a library and wants to use 
uprobes for that. What would he have to type to achieve that and 
is what he types the minimum number of characters to reasonably 
achieve that goal?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
