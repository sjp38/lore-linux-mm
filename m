Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 738A86B005C
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 09:14:28 -0400 (EDT)
Subject: Re: [PATCH 2/4] virtual block device driver (ramzswap)
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
References: <200909100215.36350.ngupta@vflare.org>
	 <200909100249.26284.ngupta@vflare.org>
	 <84144f020909141310y164b2d1ak44dd6945d35e6ec@mail.gmail.com>
	 <d760cf2d0909142339i30d74a9dic7ece86e7227c2e2@mail.gmail.com>
	 <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 15 Sep 2009 09:14:30 -0400
Message-Id: <1253020471.20020.76.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org, Ingo Molnar <mingo@elte.hu>, =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-09-15 at 10:30 +0300, Pekka Enberg wrote:
> Hi Nitin,

> 
> >>> +static int page_zero_filled(void *ptr)
> >>> +{
> >>> +       u32 pos;
> >>> +       u64 *page;
> >>> +
> >>> +       page = (u64 *)ptr;
> >>> +
> >>> +       for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
> >>> +               if (page[pos])
> >>> +                       return 0;
> >>> +       }
> >>> +
> >>> +       return 1;
> >>> +}
> >>
> >> This looks like something that could be in lib/string.c.
> >>
> >> /me looks
> >>
> >> There's strspn so maybe you could introduce a memspn equivalent.
> >
> > Maybe this is just too specific to this driver. Who else will use it?
> > So, this simple function should stay within this driver only. If it
> > finds more user, we can them move it to lib/string.c.
> >
> > If I now move it to string.c I am sure I will get reverse argument
> > from someone else:
> > "currently, it has no other users so bury it with this driver only".
> 
> How can you be sure about that? If you don't want to move it to
> generic code, fine, but the above argumentation doesn't really
> convince me. Check the git logs to see that this is *exactly* how new
> functions get added to lib/string.c. It's not always a question of two
> or more users, it's also an API issue. It doesn't make sense to put
> helpers in driver code where they don't belong (and won't be
> discovered if they're needed somewhere else).

I agree, a generic function like this should be put into string.c (or
some library). That's the first place I look when I want to do some kind
of generic string or memory manipulation.

If you don't put it there, and another driver writer needs the same
thing, they will write their own. That's how we get 10 different
implementations of the same code in the kernel. Because everyone thinks
"this will only be used by me".


> >>> +
> >>> +       trace_mark(ramzswap_lock_wait, "ramzswap_lock_wait");
> >>> +       mutex_lock(&rzs->lock);
> >>> +       trace_mark(ramzswap_lock_acquired, "ramzswap_lock_acquired");
> >>
> >> Hmm? What's this? I don't think you should be doing ad hoc
> >> trace_mark() in driver code.
> >
> > This is not ad hoc. It is to see contention over this lock which I believe is a
> > major bottleneck even on dual-cores. I need to keep this to measure improvements
> > as I gradually make this locking more fine grained (using per-cpu buffer etc).
> 
> It is ad hoc. Talk to the ftrace folks how to do it properly. I'd keep
> those bits out-of-tree until the issue is resolved, really.

Yes, trace_mark is deprecated. You want to use TRACE_EVENT. See how gfs2
does it in:

  fs/gfs2/gfs2_trace.h

and it is well documented in
samples/trace_events/trace-events-samples.[ch]

-- Steve



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
