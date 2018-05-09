Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B95046B04C8
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:58:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 62so21435292pfw.21
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:58:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p6-v6sor4450536pgc.316.2018.05.09.01.58.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 01:58:27 -0700 (PDT)
Date: Wed, 9 May 2018 17:58:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180509085822.GB353@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110170223.GF3668920@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hi,

Move printk and (some of) MM people to the recipients list.

On (01/10/18 09:02), Tejun Heo wrote:
[..]
> The particular case that we've been seeing regularly in the fleet was
> the following scenario.
> 
> 1. Console is IPMI emulated serial console.  Super slow.  Also
>    netconsole is in use.
> 2. System runs out of memory, OOM triggers.
> 3. OOM handler is printing out OOM debug info.
> 4. While trying to emit the messages for netconsole, the network stack
>    / driver tries to allocate memory and then fail, which in turn
>    triggers allocation failure or other warning messages.  printk was
>    already flushing, so the messages are queued on the ring.
> 5. OOM handler keeps flushing but 4 repeats and the queue is never
>    shrinking.  Because OOM handler is trapped in printk flushing, it
>    never manages to free memory and no one else can enter OOM path
>    either, so the system is trapped in this state.

Tejun, we have a theory [since there are no logs available] that what
you are looking at is something as follows:

console_unlock()
{
  for (;;) {
   call_console_drivers()
     kmalloc()/etc        /* netconsole, skb kmalloc(), for instance */
      __alloc_pages_slowpath()
        warn_alloc()      /* a bunch of printk() -> log_store() */
  }
}

Now, warn_alloc() is rate limited to
	DEFAULT_RATELIMIT_INTERVAL / DEFAULT_RATELIMIT_BURST

so net console driver can add 10 warn_alloc() reports every 5 seconds to
the logbuf.

You have a "super slow" IPMI console and net console. So for every
logbuf entry we do:

console_unlock()
{
  for (;;) {
    call_console_drivers(msg) -> IPMI_write()
    call_console_drivers(msg) -> netconsole_write() -> skb kmalloc() -> warn_alloc() -> ratelimit
  }
}

IPMI_write() is very slow, as you have noted, so it consumes time
printing messages, simultaneously warn_alloc() rate limit depends on
time. *Probably*, slow IPMI_write() is unable to flush 10 warn_alloc()
reports under 5 seconds, which gives net console a chance to add another
10 warn_alloc()-s, while the previous 10 warn_alloc()-s have not been
flushed yet.

It seems that DEFAULT_RATELIMIT_INTERVAL / DEFAULT_RATELIMIT_BURST
warn_alloc() rate limit is too permissive for your setup.

Can you confirm that the theory is actually correct?

If it is correct, then can we simply tweak warn_alloc() rate limit?
Say, make it x2 / x4 / etc. times less verbose? E.g. "up to 5 warn_alloc()-s
every 10 seconds"? What do MM folks think?

	-ss
