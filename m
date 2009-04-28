Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD236B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 07:03:48 -0400 (EDT)
Date: Tue, 28 Apr 2009 13:03:19 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428110319.GC25347@elte.hu>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu> <20090428074031.GK27382@one.firstfloor.org> <1240909484.1982.16.camel@penberg-laptop> <20090428091508.GA21085@elte.hu> <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com> <84144f020904280225h490ef682p8973cb1241a1f3ea@mail.gmail.com> <20090428093621.GD21085@elte.hu> <84144f020904280257j57b5b686k91cc4096a8e5ca29@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f020904280257j57b5b686k91cc4096a8e5ca29@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Hi Ingo,
> 
> On Tue, Apr 28, 2009 at 12:36 PM, Ingo Molnar <mingo@elte.hu> wrote:
> > I 'integrate' traces all the time to get summary counts. This series
> > of dynamic events:
> >
> >  allocation
> >  page count up
> >  page count up
> >  page count down
> >  page count up
> >  page count up
> >  page count up
> >  page count up
> >
> > integrates into: "page count is 6".
> >
> > Note that "integration" can be done wholly in the kernel too, 
> > without going to the overhead of streaming all dynamic events to 
> > user-space, just to summarize data into counts, in-kernel. That 
> > is what the ftrace statistics framework and various ftrace 
> > plugins are about.
> >
> > Also, it might make sense to extend the framework with a series 
> > of 'get current object state' events when tracing is turned on. 
> > A special case of _that_ would in essence be what the /proc hack 
> > does now - just expressed in a much more generic, and a much 
> > more usable form.
> 
> I guess the main question here is whether this approach will scale 
> to something like kmalloc() or the page allocator in production 
> environments. For any serious workload, the frequency of events is 
> going to be pretty high.

it depends on the level of integration. If the integration is done 
right at the tracepoint callback, performance overhead will be very 
small. If everything is traced and then streamed to user-space then 
there is going to be noticeable overhead starting somewhere around a 
few hundred thousand events per second per cpu.

Note that the 'get object state' approach i outlined above in the 
final paragraph has no runtime overhead at all. As long as 'object 
state' only covers fields that we maintain already for normal kernel 
functionality, it costs nothing to allow the passive sampling of 
that state. The /proc patch is a subset of such a facility in 
essence.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
