Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A40D96B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 21:55:53 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a9so3627021pgf.12
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 18:55:53 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 59si2493522plp.298.2018.01.11.18.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 18:55:51 -0800 (PST)
Date: Thu, 11 Jan 2018 21:55:47 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111215547.2f66a23a@gandalf.local.home>
In-Reply-To: <20180111203057.5b1a8f8f@gandalf.local.home>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180111045817.GA494@jagdpanzerIV>
	<20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
	<20180111203057.5b1a8f8f@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Thu, 11 Jan 2018 20:30:57 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> I have to say that your analysis here really does point out the benefit
> of my patch.
> 
> Today, printk() can print for a time of A * B, where, as you state
> above:
> 
>    A is the amount of data to print in the worst case
>    B the time call_console_drivers() needs to print a single
> 	  char to all registered and enabled consoles
> 
> In the worse case, the current approach is A is infinite. That is,
> printk() never stops, as long as there is a printk happening on another
> CPU before B can finish. A will keep growing. The call to printk() will
> never return. The more CPUs you have, the more likely this will occur.
> All it takes is a few CPUs doing periodic printks. If there is a slow
> console, where the periodic printk on other CPUs occur quicker than the
> first can finish, the first one will be stuck forever. Doesn't take
> much to have this happen.
> 
> With my patch, A is fixed to the size of the buffer. A single printk()
> can never print more than that. If another CPU comes in and does a
> printk, then it will take over the task of printing, and release the
> first printk.

In fact, below is a module I made (starting with Tejun's crazy stress
test, then removing all the craziness). This simple module locks up the
system without my patch. After applying my patch, the system runs fine.

All I did was start off a work queue on each CPU, and each CPU does one
printk() followed by a millisecond sleep. No 10,000 printks, nothing
in an interrupt handler. Preemption is disabled while the printk
happens, but that's normal.

This is much closer to an OOM happening all over the system, where OOMs
stack dumps are occurring on different CPUS.

I ran this on a box with 4 CPUs and a serial console (so it has a slow
console). Again, all I have is each CPU doing exactly ONE printk()!
then sleeping for a full millisecond! It will cause a lot of output,
and perhaps slow the system down. But it should not lock up the system.
But without my patch, it does!

Try it!

Test it on a box, and it will lock up. Then add my patch and see what
the results are. I think this speaks very loudly in favor of applying
my patch.

Again, the below module locks up my system immediately without my
patch. With my patch, no problem. In fact, it's still running, while I
wrote this email, and it hardly shows a slow down in the system.


-- Steve

#include <linux/module.h>
#include <linux/delay.h>
#include <linux/sched.h>
#include <linux/mutex.h>
#include <linux/workqueue.h>
#include <linux/hrtimer.h>

static bool stop_testing;

static void preempt_printk_workfn(struct work_struct *work)
{
	while (!READ_ONCE(stop_testing)) {
		preempt_disable();
		printk("%5d%-75s\n", smp_processor_id(), " XXX PREEMPT");
		preempt_enable();
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

module_init(test_init);
module_exit(test_exit);
MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
