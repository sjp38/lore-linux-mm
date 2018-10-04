Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 289AA6B0271
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:55:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c4-v6so7738667plz.20
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:55:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor2971161pgi.54.2018.10.04.01.55.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 01:55:21 -0700 (PDT)
Date: Thu, 4 Oct 2018 17:55:15 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181004085515.GC12879@jagdpanzerIV>
References: <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
 <20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
 <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home>
 <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
 <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
 <20181003133704.43a58cf5@gandalf.local.home>
 <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
 <20181004074442.GA12879@jagdpanzerIV>
 <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Daniel Wang <wonderfly@google.com>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (10/04/18 10:36), Petr Mladek wrote:
> 
> This looks like a reasonable explanation of what is happening here.
> It also explains why the console owner logic helped.

Well, I'm still a bit puzzled, frankly speaking. I've two theories.

Theory #1 [most likely]

  Steven is a wizard and his code cures whatever problem we throw it at.

Theory #2

  console_sem hand over actually spreads print out, so we don't have one CPU
doing all the printing job. Instead every CPU prints its backtrace, while the
CPU which issued all_cpus_backtrace() waits for them. So all_cpus_backtrace()
still has to wait for NR_CPUS * strlen(bakctrace), which still probably
truggers NMI panic on it at some point. The panic CPU send out stop IPI, then
it waits for foreign CPUs to ACK stop IPI request - for 10 seconds. So each
CPU prints its backtrace, then ACK stop IPI. So when panic CPU proceeds with
flush_on_panic() and emergency_reboot() uart_port->lock is unlocked. Without
the patch we probably declare NMI panic on the CPU which does all the printing
work, and panic sometimes jumps in when that CPU is in busy in
serial8250_console_write(), holding the uart_port->lock. So we can't re-enter
the 8250 driver from panic CPU and we can't reboot the system. In other
words... Steven is a wizard.

> > serial8250_console_write()
> > {
> > 	if (port->sysrq)
> > 		locked = 0;
> > 	else if (oops_in_progress)
> > 		locked = spin_trylock_irqsave(&port->lock, flags);
> > 	else
> > 		spin_lock_irqsave(&port->lock, flags);
> > 
> > 	...
> > 	uart_console_write(port, s, count, serial8250_console_putchar);
> > 	...
> > 
> > 	if (locked)
> > 		spin_unlock_irqrestore(&port->lock, flags);
> > }
> > 
> > Now... the problem. A theory, in fact.
> > panic() sets oops_in_progress back to zero - bust_spinlocks(0) -  too soon.
> 
> I see your point. I am just a bit scared of this way. Ignoring locks
> is a dangerous and painful approach in general.

Well, I agree. But 8250 is not the only console which does ignore
uart_port lock state sometimes. Otherwise sysrq would be totally unreliable,
including emergency reboot. So it's sort of how it has been for quite some
time, I guess. We are in panic(), it's over, so we probably can ignore
uart_port->lock at this point.

	-ss
