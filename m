Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CFDA16B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 12:02:27 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id p30so14125446qtg.23
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 09:02:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 53sor11749491qtr.114.2018.01.10.09.02.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 09:02:26 -0800 (PST)
Date: Wed, 10 Jan 2018 09:02:23 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110170223.GF3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110162900.GA21753@linux.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Linus, Andrew.

On Wed, Jan 10, 2018 at 05:29:00PM +0100, Petr Mladek wrote:
> Where is the acceptable compromise? I am not sure. So far, the most
> forceful people (Linus) did not see softlockups as a big problem.
> They rather wanted to see the messages.

Can you please chime in?  Would you be opposed to offloading to an
independent context even if it were only for cases where we were
already punting?  The thing with the current offloading is that we
don't know who we're offloading to.  It might end up in faster or
slower context, or more importantly a dangerous one.

The particular case that we've been seeing regularly in the fleet was
the following scenario.

1. Console is IPMI emulated serial console.  Super slow.  Also
   netconsole is in use.
2. System runs out of memory, OOM triggers.
3. OOM handler is printing out OOM debug info.
4. While trying to emit the messages for netconsole, the network stack
   / driver tries to allocate memory and then fail, which in turn
   triggers allocation failure or other warning messages.  printk was
   already flushing, so the messages are queued on the ring.
5. OOM handler keeps flushing but 4 repeats and the queue is never
   shrinking.  Because OOM handler is trapped in printk flushing, it
   never manages to free memory and no one else can enter OOM path
   either, so the system is trapped in this state.

The system usually never recovers in time once this sort of condition
hits and the following was the patch that I suggested which only punts
when messages are already being punted and we can easily make it less
punty by delaying the punting by N messages.

 http://lkml.kernel.org/r/20171102135258.GO3252168@devbig577.frc2.facebook.com

We definitely can fix the above described case by e.g. preventing
printk flushing task from queueing more messages or whatever, but it
just seems really dumb for the system to die from things like this in
general and it doesn't really take all that much to trigger the
condition.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
