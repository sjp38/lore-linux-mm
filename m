Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 327906B026D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:36:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x20-v6so4997922eda.21
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:36:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g34-v6si744453eda.348.2018.10.04.01.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 01:36:11 -0700 (PDT)
Date: Thu, 4 Oct 2018 10:36:09 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
References: <20181001152324.72a20bea@gandalf.local.home>
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
 <20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
 <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home>
 <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
 <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
 <20181003133704.43a58cf5@gandalf.local.home>
 <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
 <20181004074442.GA12879@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181004074442.GA12879@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Daniel Wang <wonderfly@google.com>, rostedt@goodmis.org, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Thu 2018-10-04 16:44:42, Sergey Senozhatsky wrote:
> On (10/03/18 11:37), Daniel Wang wrote:
> > When `softlockup_panic` is set (which is what my original repro had and
> > what we use in production), without the backport patch, the expected panic
> > would hit a seemingly deadlock. So even when the machine is configured
> > to reboot immediately after the panic (kernel.panic=-1), it just hangs there
> > with an incomplete backtrace. With your patch, the deadlock doesn't happen
> > and the machine reboots successfully.
> > 
> > This was and still is the issue this thread is trying to fix. The last
> > log snippet
> > was from an "experiment" that I did in order to understand what's really
> > happening. So far the speculation has been that the panic path was trying
> > to get a lock held by a backtrace dumping thread, but there is not enough
> > evidence which thread is holding the lock and how it uses it. So I set
> > `softlockup_panic` to 0, to get panic out of the equation. Then I saw that one
> > CPU was indeed holding the console lock, trying to write something out. If
> > the panic was to hit while it's doing that, we might get a deadlock.
> 
> Hmm, console_sem state is ignored when we flush logbuf, so it's OK to
> have it locked when we declare panic():
> 
> void console_flush_on_panic(void)
> {
> 	/*
> 	 * If someone else is holding the console lock, trylock will fail
> 	 * and may_schedule may be set.  Ignore and proceed to unlock so
> 	 * that messages are flushed out.  As this can be called from any
> 	 * context and we don't want to get preempted while flushing,
> 	 * ensure may_schedule is cleared.
> 	 */
> 	console_trylock();
> 	console_may_schedule = 0;
> 	console_unlock();
> }
> 
> Things are not so simple with uart_port lock. Generally speaking we
> should deadlock when we NMI panic() kills the system while one of the
> CPUs holds uart_port lock.

This looks like a reasonable explanation of what is happening here.
It also explains why the console owner logic helped.


> 8250 has sort of a workaround for this scenario:
> 
> serial8250_console_write()
> {
> 	if (port->sysrq)
> 		locked = 0;
> 	else if (oops_in_progress)
> 		locked = spin_trylock_irqsave(&port->lock, flags);
> 	else
> 		spin_lock_irqsave(&port->lock, flags);
> 
> 	...
> 	uart_console_write(port, s, count, serial8250_console_putchar);
> 	...
> 
> 	if (locked)
> 		spin_unlock_irqrestore(&port->lock, flags);
> }
> 
> Now... the problem. A theory, in fact.
> panic() sets oops_in_progress back to zero - bust_spinlocks(0) -  too soon.

I see your point. I am just a bit scared of this way. Ignoring locks
is a dangerous and painful approach in general.

Best Regards,
Petr
