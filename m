Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1E5256B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 09:16:51 -0400 (EDT)
Date: Fri, 8 May 2009 09:17:04 -0400 (EDT)
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: ftrace: concurrent accesses possible?
In-Reply-To: <20090508125821.GC15949@localhost>
Message-ID: <alpine.DEB.2.00.0905080908120.28378@gandalf.stny.rr.com>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508125821.GC15949@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, =?ISO-8859-15?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 8 May 2009, Wu Fengguang wrote:

> Hello,
> 
> On Fri, May 08, 2009 at 07:47:42PM +0800, Ingo Molnar wrote:
> > 
> > So this should be done in cooperation with instrumentation folks, 
> > while improving _all_ of Linux instrumentation in general. Or, if 
> > you dont have the time/interest to work with us on that, it should 
> > not be done at all. Not having the resources/interest to do 
> > something properly is not a license to introduce further 
> > instrumentation crap into Linux.
> 
> I have a dummy question on /debug/trace: is it possible to
> - use 2+ tracers concurrently?

Two plugins? no.

Two types of tracing? yes.

The "current_tracer" is for specific tracing purposes that like, latency 
tracing, function tracing and graph tracing. There are others, but they 
are more "themes" than tracers. The latency tracing only shows a "max 
latency" and does not show current traces unless they hit the max 
threshold. The function graph tracer has a different output format that 
has indentation based on the depth of the traced functions.

But with tracing events, we can pick and choose any event and trace them 
all together. You can filter them as well. For new events in the kernel, 
we only add them via trace events. These events show up in the plugin 
tracers too.

> - run a system script that makes use of a tracer,

Sure

>   without disturbing the sysadmin's tracer activities?

Hmm, you mean have individual tracers tracing different things. We sorta 
do that now, but they are more custom. That is, you can have the stack 
tracer running (recording max stack of the kernel) and run other tracers 
as well, without noticing.  But those that write to the ring buffer, only 
write to a single ring buffer. If another trace facility created their own 
ring buffer, then you could have more than one ring buffer being used. But 
ftrace currently uses only one (This is net exactly true, because the 
latency tracers have a separate ring buffer to store the max).

> - access 1 tracer concurrently from many threads,

More than one reader can happen, but inside the kernel, they are 
serialized. When reading from the trace_pipe (consumer mode), every read 
will produce a different output, because the previous read was "consumed". 
If two threads try to read this way at the same time, they will each get a 
different result.

>   with different filter etc. options?

Not sure what you mean here. If you two threads filtering differently, 
this should be done in userspace.

-- Steve

> 
> If not currently, will private mounts be a viable solution?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
