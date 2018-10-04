Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F35D66B026B
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:44:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p89-v6so5377316pfj.12
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:44:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h21-v6sor2982605pgb.10.2018.10.04.00.44.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 00:44:47 -0700 (PDT)
Date: Thu, 4 Oct 2018 16:44:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181004074442.GA12879@jagdpanzerIV>
References: <20180927194601.207765-1-wonderfly@google.com>
 <20181001152324.72a20bea@gandalf.local.home>
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
 <20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
 <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home>
 <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
 <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
 <20181003133704.43a58cf5@gandalf.local.home>
 <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: rostedt@goodmis.org, Petr Mladek <pmladek@suse.com>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (10/03/18 11:37), Daniel Wang wrote:
> When `softlockup_panic` is set (which is what my original repro had and
> what we use in production), without the backport patch, the expected panic
> would hit a seemingly deadlock. So even when the machine is configured
> to reboot immediately after the panic (kernel.panic=-1), it just hangs there
> with an incomplete backtrace. With your patch, the deadlock doesn't happen
> and the machine reboots successfully.
> 
> This was and still is the issue this thread is trying to fix. The last
> log snippet
> was from an "experiment" that I did in order to understand what's really
> happening. So far the speculation has been that the panic path was trying
> to get a lock held by a backtrace dumping thread, but there is not enough
> evidence which thread is holding the lock and how it uses it. So I set
> `softlockup_panic` to 0, to get panic out of the equation. Then I saw that one
> CPU was indeed holding the console lock, trying to write something out. If
> the panic was to hit while it's doing that, we might get a deadlock.

Hmm, console_sem state is ignored when we flush logbuf, so it's OK to
have it locked when we declare panic():

void console_flush_on_panic(void)
{
	/*
	 * If someone else is holding the console lock, trylock will fail
	 * and may_schedule may be set.  Ignore and proceed to unlock so
	 * that messages are flushed out.  As this can be called from any
	 * context and we don't want to get preempted while flushing,
	 * ensure may_schedule is cleared.
	 */
	console_trylock();
	console_may_schedule = 0;
	console_unlock();
}

Things are not so simple with uart_port lock. Generally speaking we
should deadlock when we NMI panic() kills the system while one of the
CPUs holds uart_port lock.

8250 has sort of a workaround for this scenario:

serial8250_console_write()
{
	if (port->sysrq)
		locked = 0;
	else if (oops_in_progress)
		locked = spin_trylock_irqsave(&port->lock, flags);
	else
		spin_lock_irqsave(&port->lock, flags);

	...
	uart_console_write(port, s, count, serial8250_console_putchar);
	...

	if (locked)
		spin_unlock_irqrestore(&port->lock, flags);
}

Note, spin_trylock_irqsave() path.
So, as long as we are in sysrq or oops_in_progress, uart_port lock state
is sort of ignored.

Looking at your backtraces:

---
[  348.058207] NMI backtrace for cpu 8
[  348.058207] CPU: 8 PID: 1700 Comm: dd Tainted: G           O L  4.14.73 #18
[  348.058214]  <IRQ>
[  348.058214]  wait_for_xmitr+0x2c/0xb0
[  348.058215]  serial8250_console_putchar+0x1c/0x40
[  348.058215]  ? wait_for_xmitr+0xb0/0xb0
[  348.058215]  uart_console_write+0x33/0x70
[  348.058216]  serial8250_console_write+0xe2/0x2b0
[  348.058216]  ? msg_print_text+0xa6/0x110
[  348.058216]  console_unlock+0x306/0x4a0
[  348.058217]  wake_up_klogd_work_func+0x55/0x60
[  348.058217]  irq_work_run_list+0x50/0x80
[  348.058217]  smp_irq_work_interrupt+0x3f/0xe0
[  348.058218]  irq_work_interrupt+0x7d/0x90
---


Now... the problem. A theory, in fact.
panic() sets oops_in_progress back to zero - bust_spinlocks(0) -  too soon.

When we do console_flush_on_panic() we ignore console_sem state and go
to the 8250 driver - serial8250_console_write(). But at this point
oops_in_progress is zero, so we endup in spin_lock_irqsave(&port->lock, flags).

If the port->lock was already locked, then this is your deadlock. We
can't emergency_restart() because the panic() CPU stuck spinning on
port->lock in serial8250_console_write(), so it never returns from
console_flush_on_panic() and there is no progress.

---

void panic(const char *fmt, ...)
{
....
	bust_spinlocks(0);

	/*
	 * We may have ended up stopping the CPU holding the lock (in
	 * smp_send_stop()) while still having some valuable data in the console
	 * buffer.  Try to acquire the lock then release it regardless of the
	 * result.  The release will also print the buffers out.  Locks debug
	 * should be disabled to avoid reporting bad unlock balance when
	 * panic() is not being callled from OOPS.
	 */
	debug_locks_off();
	console_flush_on_panic();

	if (!panic_blink)
		panic_blink = no_blink;

	if (panic_timeout > 0) {
		/*
		 * Delay timeout seconds before rebooting the machine.
		 * We can't use the "normal" timers since we just panicked.
		 */
		pr_emerg("Rebooting in %d seconds..\n", panic_timeout);

		for (i = 0; i < panic_timeout * 1000; i += PANIC_TIMER_STEP) {
			touch_nmi_watchdog();
			if (i >= i_next) {
				i += panic_blink(state ^= 1);
				i_next = i + 3600 / PANIC_BLINK_SPD;
			}
			mdelay(PANIC_TIMER_STEP);
		}
	}
	if (panic_timeout != 0) {
		/*
		 * This will not be a clean reboot, with everything
		 * shutting down.  But if there is a chance of
		 * rebooting the system it will be rebooted.
		 */
		emergency_restart();
	}
---


So... Just an idea. Can you try a very dirty hack? Forcibly increase
oops_in_progress in panic() before console_flush_on_panic(), so 8250
serial8250_console_write() will use spin_trylock_irqsave() and maybe
avoid deadlock.

	-ss
