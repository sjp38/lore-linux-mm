Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3EA6B025F
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:30:59 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id q185so11347628qke.2
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:30:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i124sor10999156qkd.10.2018.01.10.10.30.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 10:30:58 -0800 (PST)
Date: Wed, 10 Jan 2018 10:30:55 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110183055.GM3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <20180110182153.GP6176@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110182153.GP6176@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Peter.

On Wed, Jan 10, 2018 at 07:21:53PM +0100, Peter Zijlstra wrote:
> On Wed, Jan 10, 2018 at 09:02:23AM -0800, Tejun Heo wrote:
> > 2. System runs out of memory, OOM triggers.
> > 3. OOM handler is printing out OOM debug info.
> > 4. While trying to emit the messages for netconsole, the network stack
> >    / driver tries to allocate memory and then fail, which in turn
> >    triggers allocation failure or other warning messages.  printk was
> >    already flushing, so the messages are queued on the ring.
> > 5. OOM handler keeps flushing but 4 repeats and the queue is never
> >    shrinking.  Because OOM handler is trapped in printk flushing, it
> >    never manages to free memory and no one else can enter OOM path
> >    either, so the system is trapped in this state.
> 
> Why not kill recursive OOM (msgs) ?

Sure, we can do that too, e.g. marking flushing thread and ignoring
new messages from it, although that does come with its own downsides.
The choices are

* If we can make printk safe without much downside, that'd be the best
  option.

* If we decide that we can't do that in a reasonable way, we sure can
  try to plug the identified cases.  We might have to play a bit of
  whack-a-mole (e.g. the feedback loop might not necessarily be from
  the same context) but there likely are very few repeatable cases.

It could be me not knowing the history of the discussion but up until
now the discussion hasn't really gotten to that point since I brought
up the case that we've been seeing.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
