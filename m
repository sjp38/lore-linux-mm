Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DA0776B0055
	for <linux-mm@kvack.org>; Sun, 17 May 2009 10:12:18 -0400 (EDT)
Date: Sun, 17 May 2009 22:12:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [rfc] object collection tracing (was: [PATCH 5/5] proc: export
	more page flags in /proc/kpageflags)
Message-ID: <20090517141205.GF3254@localhost>
References: <20090428183237.EBDE.A69D9226@jp.fujitsu.com> <20090428093833.GE21085@elte.hu> <20090428095551.GB21168@localhost> <20090428110553.GD25347@elte.hu> <20090428113616.GA22439@localhost> <20090428121751.GA28157@elte.hu> <20090428133108.GA23560@localhost> <20090512130110.GA6255@nowhere> <20090517133659.GD3254@localhost> <20090517135510.GC4640@nowhere>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090517135510.GC4640@nowhere>
Sender: owner-linux-mm@kvack.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Tom Zanussi <tzanussi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Steven Rostedt <rostedt@goodmis.org>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, May 17, 2009 at 09:55:12PM +0800, Frederic Weisbecker wrote:
> On Sun, May 17, 2009 at 09:36:59PM +0800, Wu Fengguang wrote:
> > On Tue, May 12, 2009 at 09:01:12PM +0800, Frederic Weisbecker wrote:
> > > On Tue, Apr 28, 2009 at 09:31:08PM +0800, Wu Fengguang wrote:
> > > > On Tue, Apr 28, 2009 at 08:17:51PM +0800, Ingo Molnar wrote:
> > > >
> > > > There are two possible challenges for the conversion:
> > > >
> > > > - One trick it does is to select different lists to traverse on
> > > >   different filter options. Will this be possible in the object
> > > >   tracing framework?
> > >
> > > Yeah, I guess.
> >
> > Great.
> >
> > >
> > > > - The file name lookup(last field) is the performance killer. Is it
> > > >   possible to skip the file name lookup when the filter failed on the
> > > >   leading fields?
> > >
> > > objects collection lays on trace events where filters basically ignore
> > > a whole entry in case of non-matching. Not sure if we can easily only
> > > ignore one field.
> > >
> > > But I guess we can do something about the performances...
> >
> > OK, but it's not as important as the previous requirement, so it could
> > be the last thing to work on :)
> >
> > > Could you send us the (sob'ed) patch you made which implements this.
> > > I could try to adapt it to object collection.
> >
> > Attached for your reference. Be aware that I still have plans to
> > change it in non trivial way, and there are ongoing works by Nick(on
> > inode_lock) and Jens(on s_dirty) that can create merge conflicts.
> > So basically it is not a right time to do the adaption.
> 
> 
> Ah ok, so I will wait a bit :-)
> 
> 
> > However we can still do something to polish up the page object
> > collection under /debug/tracing/objects/mm/pages/. For example,
> > the timestamps and function name could be removed from the following
> > list :)
> >
> > # tracer: nop
> > #
> > #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> > #              | |       |          |         |
> >            <...>-3743  [001]  3035.649769: dump_pages: pfn=1 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176403: dump_pages: pfn=1 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176407: dump_pages: pfn=2 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176408: dump_pages: pfn=3 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176409: dump_pages: pfn=4 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176409: dump_pages: pfn=5 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176410: dump_pages: pfn=6 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176410: dump_pages: pfn=7 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176411: dump_pages: pfn=8 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176411: dump_pages: pfn=9 flags=400 count=1 mapcount=0 index=0
> >            <...>-3743  [001]  3044.176412: dump_pages: pfn=10 flags=400 count=1 mapcount=0 index=0
> 
> 
> echo nocontext-info > /debug/tracing/trace_options :-)

Nice tip - I should really learn more about ftrace :-)

> But you'll have only the function and the pages specifics. It's not really the
> function but more specifically the name of the event. It's useful to distinguish
> multiple events to a trace.
> 
> Hmm, may be it's not that much useful in a object dump...

Yeah - and to enable that option automatically in relevant code :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
