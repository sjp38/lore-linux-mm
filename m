Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4701C6B00A2
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 09:39:51 -0400 (EDT)
Date: Mon, 7 Sep 2009 15:35:44 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
Message-ID: <20090907133544.GA6365@redhat.com>
References: <dgRNo-3uc-5@gated-at.bofh.it> <dhb9j-1hp-5@gated-at.bofh.it> <dhcf5-263-13@gated-at.bofh.it> <36bbf267-be27-4c9e-b782-91ed32a1dfe9@g1g2000pra.googlegroups.com> <1252218779.6126.17.camel@marge.simson.net> <1252232289.29247.11.camel@marge.simson.net> <DDFD17CC94A9BD49A82147DDF7D545C54DC482@exchange.ZeugmaSystems.local> <1252249790.13541.28.camel@marge.simson.net> <1252311463.7586.26.camel@marge.simson.net> <1252321596.7959.6.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1252321596.7959.6.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 09/07, Peter Zijlstra wrote:
>
> On Mon, 2009-09-07 at 10:17 +0200, Mike Galbraith wrote:
>
> > [  774.651779] SysRq : Show Blocked State
> > [  774.655770]   task                        PC stack   pid father
> > [  774.655770] evolution.bin D ffff8800bc1575f0     0  7349   6459 0x00000000
> > [  774.676008]  ffff8800bc3c9d68 0000000000000086 ffff8800015d9340 ffff8800bb91b780
> > [  774.676008]  000000000000dd28 ffff8800bc3c9fd8 0000000000013340 0000000000013340
> > [  774.676008]  00000000000000fd ffff8800015d9340 ffff8800bc1575f0 ffff8800bc157888
> > [  774.676008] Call Trace:
> > [  774.676008]  [<ffffffff812c4a11>] schedule_timeout+0x2d/0x20c
> > [  774.676008]  [<ffffffff812c4891>] wait_for_common+0xde/0x155
> > [  774.676008]  [<ffffffff8103f1cd>] ? default_wake_function+0x0/0x14
> > [  774.676008]  [<ffffffff810c0e63>] ? lru_add_drain_per_cpu+0x0/0x10
> > [  774.676008]  [<ffffffff810c0e63>] ? lru_add_drain_per_cpu+0x0/0x10
> > [  774.676008]  [<ffffffff812c49ab>] wait_for_completion+0x1d/0x1f
> > [  774.676008]  [<ffffffff8105fdf5>] flush_work+0x7f/0x93
> > [  774.676008]  [<ffffffff8105f870>] ? wq_barrier_func+0x0/0x14
> > [  774.676008]  [<ffffffff81060109>] schedule_on_each_cpu+0xb4/0xed
> > [  774.676008]  [<ffffffff810c0c78>] lru_add_drain_all+0x15/0x17
> > [  774.676008]  [<ffffffff810d1dbd>] sys_mlock+0x2e/0xde
> > [  774.676008]  [<ffffffff8100bc1b>] system_call_fastpath+0x16/0x1b
>
> FWIW, something like the below (prone to explode since its utterly
> untested) should (mostly) fix that one case. Something similar needs to
> be done for pretty much all machine wide workqueue thingies, possibly
> also flush_workqueue().

Failed to google the previous discussion. Could you please point me?
What is the problem?

> +struct sched_work_struct {
> +	struct work_struct work;
> +	work_func_t func;
> +	atomic_t *count;
> +	struct completion *completion;
> +};

(not that it matters, but perhaps sched_work_struct should have a single
 pointer to the struct which contains func,count,comletion).

> -int schedule_on_each_cpu(work_func_t func)
> +int schedule_on_mask(const struct cpumask *mask, work_func_t func)

Looks like a usefule helper. But,

> +	for_each_cpu(cpu, mask) {
> +		struct sched_work_struct *work = per_cpu_ptr(works, cpu);
> +		work->count = &count;
> +		work->completion = &completion;
> +		work->func = func;
>
> -		INIT_WORK(work, func);
> -		schedule_work_on(cpu, work);
> +		INIT_WORK(&work->work, do_sched_work);
> +		schedule_work_on(cpu, &work->work);

This means the caller must ensure CPU online and can't go away. Otherwise
we can hang forever.

schedule_on_each_cpu() is fine, it calls us under get_online_cpus().
But,

>  int lru_add_drain_all(void)
>  {
> -	return schedule_on_each_cpu(lru_add_drain_per_cpu);
> +	return schedule_on_mask(lru_drain_mask, lru_add_drain_per_cpu);
>  }

This doesn't look safe.

Looks like, schedule_on_mask() should take get_online_cpus(), do
cpus_and(mask, mask, online_cpus), then schedule works.

If we don't care the work can migrate to another CPU, schedule_on_mask()
can do put_online_cpus() before wait_for_completion().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
