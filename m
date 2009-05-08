Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1097F6B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 09:42:57 -0400 (EDT)
Date: Fri, 8 May 2009 21:43:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: ftrace: concurrent accesses possible?
Message-ID: <20090508134303.GA15127@localhost>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508125821.GC15949@localhost> <alpine.DEB.2.00.0905080908120.28378@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0905080908120.28378@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@elte.hu>, =?utf-8?B?RnLDqWTDqXJpYw==?= Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 08, 2009 at 09:17:04PM +0800, Steven Rostedt wrote:
> 
> On Fri, 8 May 2009, Wu Fengguang wrote:
> 
> > Hello,
> > 
> > On Fri, May 08, 2009 at 07:47:42PM +0800, Ingo Molnar wrote:
> > > 
> > > So this should be done in cooperation with instrumentation folks, 
> > > while improving _all_ of Linux instrumentation in general. Or, if 
> > > you dont have the time/interest to work with us on that, it should 
> > > not be done at all. Not having the resources/interest to do 
> > > something properly is not a license to introduce further 
> > > instrumentation crap into Linux.
> > 
> > I have a dummy question on /debug/trace: is it possible to
> > - use 2+ tracers concurrently?
> 
> Two plugins? no.
> 
> Two types of tracing? yes.
> 
> The "current_tracer" is for specific tracing purposes that like, latency 
> tracing, function tracing and graph tracing. There are others, but they 
> are more "themes" than tracers. The latency tracing only shows a "max 
> latency" and does not show current traces unless they hit the max 
> threshold. The function graph tracer has a different output format that 
> has indentation based on the depth of the traced functions.
> 
> But with tracing events, we can pick and choose any event and trace them 
> all together. You can filter them as well. For new events in the kernel, 
> we only add them via trace events. These events show up in the plugin 
> tracers too.

OK. Thanks for explaining!

> > - run a system script that makes use of a tracer,
> 
> Sure
> 
> >   without disturbing the sysadmin's tracer activities?
> 
> Hmm, you mean have individual tracers tracing different things. We sorta 

Right. Plus two 'instances' of the same tracer run with different options.

> do that now, but they are more custom. That is, you can have the stack 
> tracer running (recording max stack of the kernel) and run other tracers 
> as well, without noticing.  But those that write to the ring buffer, only 
> write to a single ring buffer. If another trace facility created their own 
> ring buffer, then you could have more than one ring buffer being used. But 
> ftrace currently uses only one (This is net exactly true, because the 
> latency tracers have a separate ring buffer to store the max).

That's OK.

> > - access 1 tracer concurrently from many threads,
> 
> More than one reader can happen, but inside the kernel, they are 
> serialized. When reading from the trace_pipe (consumer mode), every read 
> will produce a different output, because the previous read was "consumed". 
> If two threads try to read this way at the same time, they will each get a 
> different result.
> 
> >   with different filter etc. options?
> 
> Not sure what you mean here. If you two threads filtering differently, 
> this should be done in userspace.

It's about efficiency.  Here is a use case: one have N CPUs and want
to create N threads to query N different segments of the total memory
via kpageflags. This ability is important for a large memory system.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
