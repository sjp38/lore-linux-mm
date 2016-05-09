Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B75F6B0260
	for <linux-mm@kvack.org>; Mon,  9 May 2016 05:51:47 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id n2so380699527obo.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 02:51:47 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id 35si7866534ioi.168.2016.05.09.02.51.45
        for <linux-mm@kvack.org>;
        Mon, 09 May 2016 02:51:46 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <004b01d1a9d1$3817fc10$a847f430$@alibaba-inc.com>
In-Reply-To: <004b01d1a9d1$3817fc10$a847f430$@alibaba-inc.com>
Subject: Re: [PATCH v5] mm: Add memory allocation watchdog kernel thread.
Date: Mon, 09 May 2016 17:51:29 +0800
Message-ID: <006e01d1a9d8$5c7a15f0$156e41d0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

[...]
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1446,6 +1446,32 @@ struct tlbflush_unmap_batch {
>  	bool writable;
>  };
> 
> +struct memalloc_info {
> +	/*
> +	 * 0: not doing __GFP_RECLAIM allocation.
> +	 * 1: doing non-recursive __GFP_RECLAIM allocation.
> +	 * 2: doing recursive __GFP_RECLAIM allocation.
> +	 */
> +	u8 valid;
> +	/*
> +	 * bit 0: Will be reported as OOM victim.
> +	 * bit 1: Will be reported as dying task.
> +	 * bit 2: Will be reported as stalling task.
> +	 * bit 3: Will be reported as exiting task.
> +	 * bit 7: Will be reported unconditionally.
> +	 */
> +	u8 type;
> +	/* Index used for memalloc_in_flight[] counter. */
> +	u8 idx;

	u8 __pad;	is also needed perhaps.

> +	/* For progress monitoring. */
> +	unsigned int sequence;
> +	/* Started time in jiffies as of valid == 1. */
> +	unsigned long start;
> +	/* Requested order and gfp flags as of valid == 1. */
> +	unsigned int order;
> +	gfp_t gfp;
> +};
> +

[...]
> +
> +/*
> + * check_memalloc_stalling_tasks - Check for memory allocation stalls.
> + *
> + * @timeout: Timeout in jiffies.
> + *
> + * Returns number of stalling tasks.
> + *
> + * This function is marked as "noinline" in order to allow inserting dynamic
> + * probes (e.g. printing more information as needed using SystemTap, calling
> + * panic() if this function returned non 0 value).
> + */
> +static noinline int check_memalloc_stalling_tasks(unsigned long timeout)
> +{
> +	char buf[256];
> +	struct task_struct *g, *p;
> +	unsigned long now;
> +	unsigned long expire;
> +	unsigned int sigkill_pending = 0;
> +	unsigned int exiting_tasks = 0;
> +	unsigned int memdie_pending = 0;
> +	unsigned int stalling_tasks = 0;
> +
> +	cond_resched();
> +	now = jiffies;
> +	/*
> +	 * Report tasks that stalled for more than half of timeout duration
> +	 * because such tasks might be correlated with tasks that already
> +	 * stalled for full timeout duration.
> +	 */
> +	expire = now - timeout * (HZ / 2);
> +	/* Count stalling tasks, dying and victim tasks. */
> +	preempt_disable();
> +	rcu_read_lock();
> +	for_each_process_thread(g, p) {
> +		u8 type = 0;
> +
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> +			type |= 1;
> +			memdie_pending++;
> +		}
> +		if (fatal_signal_pending(p)) {
> +			type |= 2;
> +			sigkill_pending++;
> +		}
> +		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
> +			type |= 8;
> +			exiting_tasks++;
> +		}
> +		if (is_stalling_task(p, expire)) {
> +			type |= 4;
> +			stalling_tasks++;
> +		}
> +		if (p->flags & PF_KSWAPD)
> +			type |= 128;
> +		p->memalloc.type = type;
> +	}

The numbers assigned to type may be replaced with texts, 
for instance,
	MEMALLOC_TYPE_VICTIM 
	MEMALLOC_TYPE_DYING 
	MEMALLOC_TYPE_STALLING
	MEMALLOC_TYPE_EXITING
	MEMALLOC_TYPE_REPORT

> +	rcu_read_unlock();
> +	preempt_enable();
> +	if (!stalling_tasks)
> +		return 0;
> +	cond_resched();
> +	/* Report stalling tasks, dying and victim tasks. */
> +	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u\n",
> +		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending,
> +		out_of_memory_count);
> +	cond_resched();
> +	sigkill_pending = 0;
> +	exiting_tasks = 0;
> +	memdie_pending = 0;
> +	stalling_tasks = 0;
> +	preempt_disable();
> +	rcu_read_lock();
> + restart_report:
> +	for_each_process_thread(g, p) {
> +		bool can_cont;
> +		u8 type;
> +
> +		if (likely(!p->memalloc.type))
> +			continue;
> +		p->memalloc.type = 0;
> +		/* Recheck in case state changed meanwhile. */
> +		type = 0;
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> +			type |= 1;
> +			memdie_pending++;
> +		}
> +		if (fatal_signal_pending(p)) {
> +			type |= 2;
> +			sigkill_pending++;
> +		}
> +		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
> +			type |= 8;
> +			exiting_tasks++;
> +		}
> +		if (is_stalling_task(p, expire)) {
> +			type |= 4;
> +			stalling_tasks++;
> +			snprintf(buf, sizeof(buf),
> +				 " seq=%u gfp=0x%x(%pGg) order=%u delay=%lu",
> +				 memalloc.sequence, memalloc.gfp,
> +				 &memalloc.gfp,
> +				 memalloc.order, now - memalloc.start);
> +		} else {
> +			buf[0] = '\0';
> +		}
> +		if (p->flags & PF_KSWAPD)
> +			type |= 128;

ditto

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
