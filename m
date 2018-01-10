Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA8BE6B025F
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:37:03 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id l20so2838070qkj.10
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:37:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f74sor3603708qkh.18.2018.01.10.10.37.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 10:37:02 -0800 (PST)
Date: Wed, 10 Jan 2018 10:36:59 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110183659.GN3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <20180110132255.30745b57@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110132255.30745b57@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello,

On Wed, Jan 10, 2018 at 01:22:55PM -0500, Steven Rostedt wrote:
> > Can you please chime in?  Would you be opposed to offloading to an
> > independent context even if it were only for cases where we were
> > already punting?  The thing with the current offloading is that we
> > don't know who we're offloading to.  It might end up in faster or
> > slower context, or more importantly a dangerous one.
> 
> And how is that different to what we have today? It could be the
> "dangerous one" that did the first printk, and 100 other CPUs in "non
> dangerous" locations are constantly calling printk and making that
> "dangerous" one NEVER STOP.

So, the dangerous one would punt to the dedicated safe one beyond
certain point.  The posted version just flushes to the last message
that it saw on entry to flush.

> > The particular case that we've been seeing regularly in the fleet was
> > the following scenario.
> > 
> > 1. Console is IPMI emulated serial console.  Super slow.  Also
> >    netconsole is in use.
> > 2. System runs out of memory, OOM triggers.
> > 3. OOM handler is printing out OOM debug info.
> > 4. While trying to emit the messages for netconsole, the network stack
> >    / driver tries to allocate memory and then fail, which in turn
> >    triggers allocation failure or other warning messages.  printk was
> >    already flushing, so the messages are queued on the ring.
> 
> This looks like a bug in the netconsole, as the net console shouldn't
> print warnings if the warning is caused by it doing a print.
> 
> Totally unrelated problem to my and Petr's patch set. Basically your
> argument is "I see this bug, and your patch doesn't fix it". Well maybe
> we are not solving your bug. Not to mention, it looks like printk isn't
> the bug, but net console is.

Sure, that could be the case, especially if punting to a safe context
can't be done reasonably (and there are downsides to silencing the
recursive messages too), but it'd also be really great to have printk
generaly safe from brining down a machine this way, right?  I just
don't yet see why punting to a safe context is so difficult /
undesirable that we can't solve the issue in a general manner.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
