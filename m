Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B29596B0055
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 07:09:30 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so260662ywm.26
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 04:09:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090428105603.GB25347@elte.hu>
References: <20090428093621.GD21085@elte.hu>
	 <84144f020904280257j57b5b686k91cc4096a8e5ca29@mail.gmail.com>
	 <20090428190822.EBED.A69D9226@jp.fujitsu.com>
	 <84144f020904280321u4be9fb10t6f0123b589752b80@mail.gmail.com>
	 <20090428105603.GB25347@elte.hu>
Date: Tue, 28 Apr 2009 20:09:38 +0900
Message-ID: <2f11576a0904280409h4dedc04u43a5b68ef492e56d@mail.gmail.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWMgV2Vpc2JlY2tlcg==?= <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

2009/4/28 Ingo Molnar <mingo@elte.hu>:
>
> * Pekka Enberg <penberg@cs.helsinki.fi> wrote:
>
>> Hi!
>>
>> 2009/4/28 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
>> >> I guess the main question here is whether this approach will scale to
>> >> something like kmalloc() or the page allocator in production
>> >> environments. For any serious workload, the frequency of events is
>> >> going to be pretty high.
>> >
>> > Immediate Values patch series makes zero-overhead to tracepoint
>> > while it's not used.
>> >
>> > So, We have to implement to stop collect stastics way. it restore
>> > zero overhead world.
>> > We don't lose any performance by trace.
>>
>> Sure but I meant the _enabled_ case here. kmalloc() (and the page
>> allocator to some extent) is very performance sensitive in many
>> workloads so you probably don't want to use tracepoints if you're
>> collecting some overall statistics (i.e. tracing all events) like
>> we do here.
>
> That's where 'collect current state' kind of tracepoints would help
> - they could be used even without enabling any of the other
> tracepoints. And they'd still be in a coherent whole with the
> dynamic-events tracepoints.
>
> So i'm not arguing against these techniques at all - and we can move
> on a wide scale from zero-overhead to lots-of-tracing-enabled models
> - what i'm arguing against is the splintering.

umm.
I guess Pekka and you talk about different thing.

if tracepoint is ON, tracepoint makes one function call. but few hot spot don't
have patience to one function call overhead.

scheduler stat and slab stat are one of good example, I think.

I really don't want convert slab_stat and sched_stat to ftrace base stastics.
currently it don't need extra function call and it only touch per-cpu variable.
So, a overhead is extream small.

Unfortunately, tracepoint still don't reach this extream performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
