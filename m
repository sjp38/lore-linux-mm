Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 55E756B004D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 08:18:08 -0400 (EDT)
Date: Tue, 28 Apr 2009 14:17:51 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: [rfc] object collection tracing (was: [PATCH 5/5] proc: export
	more page flags in /proc/kpageflags)
Message-ID: <20090428121751.GA28157@elte.hu>
References: <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com> <20090428092918.GC21085@elte.hu> <20090428183237.EBDE.A69D9226@jp.fujitsu.com> <20090428093833.GE21085@elte.hu> <20090428095551.GB21168@localhost> <20090428110553.GD25347@elte.hu> <20090428113616.GA22439@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428113616.GA22439@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Li Zefan <lizf@cn.fujitsu.com>, Tom Zanussi <tzanussi@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Steven Rostedt <rostedt@goodmis.org>, =?utf-8?B?RnLpppjpp7tpYw==?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> > The above 'get object state' interface (which allows passive 
> > sampling) - integrated into the tracing framework - would serve 
> > that goal, agreed?
> 
> Agreed. That could in theory a good complement to dynamic 
> tracings.
> 
> Then what will be the canonical form for all the 'get object 
> state' interfaces - "object.attr=value", or whatever? [...]

Lemme outline what i'm thinking of.

I'd call the feature "object collection tracing", which would live 
in /debug/tracing, accessed via such files:

  /debug/tracing/objects/mm/pages/
  /debug/tracing/objects/mm/pages/format
  /debug/tracing/objects/mm/pages/filter
  /debug/tracing/objects/mm/pages/trace_pipe
  /debug/tracing/objects/mm/pages/stats
  /debug/tracing/objects/mm/pages/events/

here's the (proposed) semantics of those files:

1) /debug/tracing/objects/mm/pages/

There's a subsystem / object basic directory structure to make it 
easy and intuitive to find our way around there.

2) /debug/tracing/objects/mm/pages/format

the format file:

  /debug/tracing/objects/mm/pages/format

Would reuse the existing dynamic-tracepoint structured-logging 
descriptor format and code (this is upstream already):

 [root@phoenix sched_signal_send]# pwd
 /debug/tracing/events/sched/sched_signal_send

 [root@phoenix sched_signal_send]# cat format 
 name: sched_signal_send
 ID: 24
 format:
	field:unsigned short common_type;		offset:0;	size:2;
	field:unsigned char common_flags;		offset:2;	size:1;
	field:unsigned char common_preempt_count;	offset:3;	size:1;
	field:int common_pid;				offset:4;	size:4;
	field:int common_tgid;				offset:8;	size:4;

	field:int sig;					offset:12;	size:4;
	field:char comm[TASK_COMM_LEN];			offset:16;	size:16;
	field:pid_t pid;				offset:32;	size:4;

 print fmt: "sig: %d  task %s:%d", REC->sig, REC->comm, REC->pid

These format descriptors enumerate fields, types and sizes, in a 
structured way that user-space tools can parse easily. (The binary 
records that come from the trace_pipe file follow this format 
description.)

3) /debug/tracing/objects/mm/pages/filter

This is the tracing filter that can be set based on the 'format' 
descriptor. So with the above (signal-send tracepoint) you can 
define such filter expressions:

  echo "(sig == 10 && comm == bash) || sig == 13" > filter

To restrict the 'scope' of the object collection along pretty much 
any key or combination of keys. (Or you can leave it as it is and 
dump all objects and do keying in user-space.)

[ Using in-kernel filtering is obviously faster that streaming it 
  out to user-space - but there might be details and types of 
  visualization you want to do in user-space - so we dont want to 
  restrict things here. ]

For the mm object collection tracepoint i could imagine such filter 
expressions:

  echo "type == shared && file == /sbin/init" > filter

To dump all shared pages that are mapped to /sbin/init.

4) /debug/tracing/objects/mm/pages/trace_pipe

The 'trace_pipe' file can be used to dump all objects in the 
collection, which match the filter ('all objects' by default). The 
record format is described in 'format'.

trace_pipe would be a reuse of the existing trace_pipe code: it is a 
modern, poll()-able, read()-able, splice()-able pipe abstraction.

5) /debug/tracing/objects/mm/pages/stats

The 'stats' file would be a reuse of the existing histogram code of 
the tracing code. We already make use of it for the branch tracers 
and for the workqueue tracer - it could be extended to be applicable 
to object collections as well.

The advantage there would be that there's no dumping at all - all 
the integration is done straight in the kernel. ( The 'filter' 
condition is listened to - increasing flexibility. The filter file 
could perhaps also act as a default histogram key. )

6) /debug/tracing/objects/mm/pages/events/

The 'events' directory offers links back to existing dynamic 
tracepoints that are under /debug/tracing/events/. This would serve 
as an additional coherent force that keeps dynamic tracepoints 
collected by subsystem and by object type as well. (Tools could make 
use of this information as well - without being aware of actual 
object semantics.)


There would be a number of other object collections we could 
enumerate:

 tasks:

  /debug/tracing/objects/sched/tasks/

 active inodes known to the kernel:

  /debug/tracing/objects/fs/inodes/

 interrupts:

  /debug/tracing/objects/hw/irqs/

etc.

These would use the same 'object collection' framework. Once done we 
can use it for many other thing too.

Note how organically integrated it all is with the tracing 
framework. You could start from an 'object view' to get an overview 
and then go towards a more dynamic view of specific object 
attributes (or specific objects), as you drill down on a specific 
problem you want to analyze.

How does this all sound to you?

Can you see any conceptual holes in the scheme, any use-case that 
/proc/kpageflags supports but the object collection approach does 
not?

Would you be interested in seeing something like this, if we tried 
to implement it in the tracing tree? The majority of the code 
already exists, we just need interest from the MM side and we have 
to hook it all up. (it is by no means trivial to do - but looks like 
a very exciting feature.)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
