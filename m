Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE476B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 07:21:30 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x24so4633937pge.13
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 04:21:30 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o10si13536657pgv.773.2018.01.12.04.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 04:21:28 -0800 (PST)
Date: Fri, 12 Jan 2018 07:21:23 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180112072123.33bb567d@gandalf.local.home>
In-Reply-To: <20180112100544.GA441@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180111045817.GA494@jagdpanzerIV>
	<20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
	<20180112025612.GB6419@jagdpanzerIV>
	<20180111222140.7fd89d52@gandalf.local.home>
	<20180112100544.GA441@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Fri, 12 Jan 2018 19:05:44 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> Steven, we are having too many things in one email, I've dropped most
> of them to concentrate on one topic only.

I totally agree, and I believe this is the reason behind the tensions
between us. We are not discussing the topic of the patch.


> 
> On (01/11/18 22:21), Steven Rostedt wrote:
> [..]
> >
> > After playing with the module in my last email, I think your trying to
> > solve multiple printks, not one that is stuck  
> 
> I wouldn't say so. I'm trying to fix the same thing. but when system has
> additional limitations - there are NO concurrent printk-s to hand off to
> and A * B > C, so we can't have "last console_sem prints it all" bounded
> to O(A * B).
> 
> - no concurrent printk-s to hand off is explainable - preemption under
>   console_sem and the fact that console_sem is a sleeping lock.
> 
> - on a system with slow consoles A * B > C is also pretty clear.
> 
> - slow consoles make preemption under console_sem more likely.
> 
> 
> to summarize:
> 
> 1) I have a slow serial console. call_console_drivers() is significantly
>    slower than log_store().
> 
>    the disproportion can be 1:1000. that is while CPUA prints a single
>    logbuf message, other CPUs can add 1000 new entries.
> 
> 2) not every CPU that stuck in console_unlock() came there through printk().
>    CPUs that directly call console_lock() can sleep under console_sem. a bunch
>    of printk-s can happen in the meantime -- OOM can happen in the meantime;
>    no hand off will happen.

Yep, but I'm still not convinced you are seeing an issue with a single
printk. An OOM does not do everything in one printk, it calls hundreds.
Having hundreds of printks is an issue, especially in critical sections.

The thing is, all of your analysis has been done on a system with the
bug my patch fixes. The bug being, that any printk has no limit to how
much it can print, regardless of logbuf size.

When debugging an issue, if I find a bug that can affect that issue,
although it may not be the cause, I fix that first, and start over
looking at the original issue, because that bug fix can have an effect,
and in lots of cases, fixing the bug makes the fix for the original
bug easier.

There's two issues here:

 #1) The bug I'm fixing. printk() can get stuck printing forever. I
 demonstrated this by a simple module, that locked up the system by
 doing something that was not stressful.

 #2) The bug you are seeing, where printk can trigger the watchdog
 timer. This is much harder to hit. I have not seen any simple module
 that can trigger it.

This patch series is focused on fixing #1, #2 is out of scope, and
continuing discussing it will just cause us to argue more.


> 
> 3) console_unlock(void)
>    {
> 	for (;;) {
> 		printk_safe_enter_irqsave(flags);
> 		// lock-unlock logbuf
> 		call_console_drivers(ext_text, ext_len, text, len);
> 		printk_safe_exit_irqrestore(flags);
> 	}
>    }
> 
> with slow serial console, call_console_drivers() takes enough time to
> to make preemption of a current console_sem owner right after it irqrestore()
> highly possible; unless there is a spinning console_waiter. which easily may
> not be there; but can come in while current console_sem is preempted, why not.
> so when preempted console_sem owner comes back - it suddenly has a whole bunch
> of new messages to print and on one to hand off printing to. in a super
> imperfect and ugly world, BTW, this is how console_unlock() still can be
> O(infinite): schedule between the printed lines [even !PREEMPT kernel tries

I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
PREEMPT kernels than !PREEMPT ones.

> to cond_resched() after every line it prints] from current console_sem
> owner and printk() while console_sem owner is scheduled out.
> 
> 4) the interesting thing here is that call_console_drivers() can
>    cause console_sem owner to schedule even if it has handed off the
>    ownership. because waiting CPU has to spin with local IRQs disabled
>    as long as call_console_drivers() prints its message. so if consoles
>    are slow, then the first thing the waiter will face after it receives
>    the console_sem ownership and enables the IRQs is - preemption.

If the waiter is preempted, that means its not in a critical section.
Isn't that what you want?

> 
>    so hand off is not immediate. there is a possibility of re-scheduling
>    between hand off and actual printing. so that "there is always an active
>    printing CPU" is not quite true.
> 
> vprintk_emit()
> {
> 
> 	console_trylock_spinning(void)
> 	{
> 	   printk_safe_enter_irqsave(flags);
> 	   while (READ_ONCE(console_waiter))       // spins as long as call_console_drivers() on other CPU
> 	        cpu_relax();
> 	   printk_safe_exit_irqrestore(flags);
> --->	}  
> |						   // preemptible up until printk_safe_enter_irqsave() in console_unlock()

Again, this means the waiter is not in a critical section. Why do we
care?

You bring up a good point, that shows that my patch helps you
statistically. We want printks that are not in critical sections
(interrupts or preemption disabled) to do the most work. With my patch,
those that call printk in an atomic section, are the ones most likely
not have to print more than what they are printing. Because they will
have the console lock without having "console ownership" for the
shortest time. Remember, there is no hand off if you own console lock
without console ownership.

Those that can be preempted, are most likely to have console lock
without console ownership, and have to do the most printing.


> |	console_unlock()
> |	{
> |		
> |		....
> |		for (;;) {
> |-------------->	printk_safe_enter_irqsave(flags);
> 			....
> 		}
> 
> 	}
> }
> 
> reverting 6b97a20d3a7909daa06625d4440c2c52d7bf08d7 may be the right
> thing after all.

I would analyze that more before doing so. Because with my patch, I
think we make those that can do long prints (without triggering a
watchdog), the ones most likely doing the long prints.

> 
> preemption latencies can be high. especially during OOM. I went
> through reports that Tetsuo provided over the years. On some of
> his tests preempted console_sem owner can sleep long enough to
> let other CPUs to start overflowing the logbuf with the pending
> messages.

Sure, that's fine. Because if the one that has console_lock can be
preempted, it should be fine to take time to do printks.

> 
> more on preemption. see this email, for instance. a bunch of links in
> the middle, scroll down:
> https://marc.info/?l=linux-kernel&m=151375384500555
> 
> 
> BTW, note the disclaimer [in capitals] -
> 
> 	LIKE I SAID, IF STEVEN OR PETR WANT TO PUSH THE PATCH, I'M NOT
> 	GOING TO BLOCK IT.

GREAT! Then we can continue this conversation after the patch goes in.
Because I'm focused on fixing #1 above.

> 
> 
> > > and I demonstrated how exactly we end up having a full logbuf of pending
> > > messages even on systems with faster consoles.  
> > 
> > Where did you demonstrate that. There's so many emails I can't keep up.
> > 
> > But still, take a look at my simple module. I locked up the system
> > immediately with something that shouldn't have locked up the system.
> > And my patch fixed it. I think that speaks louder than any of our
> > opinions.  
> 
> sure it will!
> you don't have scheduler latencies mixed in under console_sem (neither in
> vprintk_emit(), nor in console_unlock(), nor anywhere in between), you have
> printks only from non-preemptible contexts, so your hand off logic always
> works and is never preempted, you have concurrent printks from many CPUs,
> so once again your hand off logic always works, and you have fast console,
> and, due to hand off, console_sem is never up() so no schedulable context
> can ever acquire it - you pass it between non-preemptible printk CPUs only.
> I cannot see why your patch would not help. your patch works fine in these
> conditions, I said it many times. and I have no issues with that. my setups
> (real HW, by the way) are far from those conditions. but there is an active
> denial of that.

OK, I modified my module to include a loop variable. You can add in a
loop variable and the printer now does this:

	while (!READ_ONCE(stop_testing)) {
		for (i = 0; i < loops && !READ_ONCE(stop_testing); i++) {
			if (i & 1)
				preempt_disable();
			pr_emerg("%5d%-75s\n", smp_processor_id(), " XXX PREEMPT");
			if (i & 1)
				preempt_enable();
		}
		msleep(1);
	}

So I do the printk "loops" times (defined by what variable you put in
as the module parameter). With my patch, I ran it with 10, then 100 and
then 100000! (It's still running). Every other printk is done with
preemption enabled. Is this what you mean?

I ran this with my patch with and without serial enabled (with
hyper-threading on 8 CPUs). Runs fine. 100,000 loops! Yes, and with
CONFIG_PREEMPT=y

Note, doing the preemption makes it harder to lock up the current
kernel. I was not able to lock it up even with serial console. This
goes to show that having printk called with preemption enabled, makes
the preempted printk much more likely to be the one stuck doing the
preemption. That means, statistically, the "safe" printks will be the
more likely one to print.

In fact, I had to add another option to my module to make it go back to
only calling printk without preemption enabled. That locks up the
kernel again with a slow console.

Then I ran this without serial enabled (just VGA) on the kernel without
my patch. With the printk always being called with preemption
disabled, it only took loops=100 before to make it lock up!

Yes, I'm able to lock up the kernel with no slow console, with a simple
loop of 100 printks. Where my patch allows me to do 100,000 printks in
that loop and I hardly notice it. But this only locks up if all printks
are called without preemption (call my module with preempt=1).

If I can lock up the kernel with a single fast console, with only a 100
printks per millisecond, I think that's a pretty serious bug. And my
patch fixes it.


I was not able lock up the system when calling printk with preemption
enabled with or without serial on the current kernel. I think this
shows that my point that statistically, a preemptable printk is more
likely to get stuck doing the slow prints. And since it can be
preempted, it doesn't affect the system at all. And the more it gets
preempted, the more likely it will continue doing the prints. Which is
a good thing.

> 
> anyway. like I said weeks ago and repeated it in several emails: I have
> no intention to NACK or block the patch.
> but the patch is not doing enough. that's all I'm saying.
> 

Great, then Petr can start pushing this through.

Below is my latest module I used for testing:

-- Steve

#include <linux/module.h>
#include <linux/delay.h>
#include <linux/sched.h>
#include <linux/mutex.h>
#include <linux/workqueue.h>
#include <linux/hrtimer.h>

static bool stop_testing;
static unsigned int loops = 1;
static int preempt;

static void preempt_printk_workfn(struct work_struct *work)
{
	int i;

	while (!READ_ONCE(stop_testing)) {
		for (i = 0; i < loops && !READ_ONCE(stop_testing); i++)
	{ bool no_preempt = preempt || (i & 1);

			if (no_preempt)
				preempt_disable();
			pr_emerg("%5d%-75s\n", smp_processor_id(),
				 no_preempt ? " XXX NOPREEMPT" : " XXX
			PREEMPT"); if (no_preempt)
				preempt_enable();
		}
		msleep(1);
	}
}

static struct work_struct __percpu *works;

static void finish(void)
{
	int cpu;

	WRITE_ONCE(stop_testing, true);
	for_each_online_cpu(cpu)
		flush_work(per_cpu_ptr(works, cpu));
	free_percpu(works);
}

static int __init test_init(void)
{
	int cpu;

	works = alloc_percpu(struct work_struct);
	if (!works)
		return -ENOMEM;

	/*
	 * This is just a test module. This will break if you
	 * do any CPU hot plugging between loading and
	 * unloading the module.
	 */

	for_each_online_cpu(cpu) {
		struct work_struct *work = per_cpu_ptr(works, cpu);

		INIT_WORK(work, &preempt_printk_workfn);
		schedule_work_on(cpu, work);
	}

	return 0;
}

static void __exit test_exit(void)
{
	finish();
}

module_param(loops, uint, 0);
module_param(preempt, int, 0);
module_init(test_init);
module_exit(test_exit);
MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
