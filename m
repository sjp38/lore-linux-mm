Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C4CC76B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 03:34:33 -0500 (EST)
Date: Tue, 24 Nov 2009 09:34:23 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
 statistics
Message-ID: <20091124083423.GE21991@elte.hu>
References: <4B0B6E44.6090106@cn.fujitsu.com>
 <84144f020911232315h7c8b7348u9ad97f585f54a014@mail.gmail.com>
 <20091124073426.GA21991@elte.hu>
 <4B0B937F.4080906@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B0B937F.4080906@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Arjan van de Ven <arjan@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Li Zefan <lizf@cn.fujitsu.com> wrote:

> Ingo Molnar wrote:
> > * Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> > 
> >> Hi Li,
> >>
> >> On Tue, Nov 24, 2009 at 7:25 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> >>> Pekka, do you think we can remove kmemtrace now?
> >> One more use case I forgot to mention: boot time tracing. Much of the 
> >> persistent kernel memory footprint comes from the boot process which 
> >> is why it's important to be able to trace memory allocations 
> >> immediately after kmem_cache_init() has run. Can we make "perf kmem" 
> >> do that? Eduard put most of his efforts into making that work for 
> >> kmemtrace.
> > 
> > Would be lovely if someone looked at perf from that angle (and extended 
> > it).
> > 
> > Another interesting area would be to allow a capture session without a 
> > process context running immediately. (i.e. pre-allocate all the buffers, 
> > use them, for a later 'perf save' to pick it up.)
> > 
> > The two are kind of the same thing conceptually: a boot time trace is a 
> > preallocated 'process context less' recording, to be picked up after 
> > bootup.
> > 
> > [ It also brings us 'stability/persistency of event logging' - i.e. a 
> >   capture session could be started and guaranteed by the kernel to be 
> >   underway, regardless of what user-space does. ]
> > 
> > Btw., Arjan is doing a _lot_ of boot time tracing for Moblin, and he 
> > indicated it in the past that starting a perf recording session from 
> > an initrd is a pretty practical substitute as well. (I've Cc:-ed 
> > Arjan.)
> 
> It would be great if perf can be used for boot time tracing. This 
> needs pretty big work on kernel side.

What would be needed is to open per cpu events right after perf events 
initializes, and allocate memory for output buffers to them.

They would round-robin after that point, and we could use 
perf_event_open() (with a special flag) to 'attach' to them and mmap() 
them - at which point they'd turn into regular objects with a lot of 
boot time data in them.

Perhaps it should be possible to attach/detach from events in a flexible 
way, not just during bootup. (bootup tracing is just a special case of 
it.)

For example a 'flight recorder' could be started by creating the events 
and then detaching from them. Whenever some exception is flagged the 
monitoring context (whatever task that might be at that time - at 
whatever point in the future) could attach to it and save it to a file 
(or send it over any other transport of choice).

This would IMO mix the best of ftrace with the best of perf, for these 
usecases.

[ Certainly not a feature for the faint hearted :-) ]

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
