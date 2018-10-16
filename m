Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBA66B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 03:44:15 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b27-v6so22643065pfm.15
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 00:44:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o5-v6si12871518plk.95.2018.10.16.00.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Oct 2018 00:44:14 -0700 (PDT)
Date: Tue, 16 Oct 2018 09:43:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 17/18] mm/memory-failure: increase queued recovery
 work's priority
Message-ID: <20181016074351.GC4030@hirez.programming.kicks-ass.net>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-18-james.morse@arm.com>
 <20181015164913.GE11434@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015164913.GE11434@zn.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: James Morse <james.morse@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Mon, Oct 15, 2018 at 06:49:13PM +0200, Borislav Petkov wrote:
> On Fri, Sep 21, 2018 at 11:17:04PM +0100, James Morse wrote:
> > @@ -1463,11 +1465,14 @@ void memory_failure_queue(unsigned long pfn, int flags)
> >  
> >  	mf_cpu = &get_cpu_var(memory_failure_cpu);
> >  	spin_lock_irqsave(&mf_cpu->lock, proc_flags);
> > -	if (kfifo_put(&mf_cpu->fifo, entry))
> > -		schedule_work_on(smp_processor_id(), &mf_cpu->work);
> > -	else
> > +	if (kfifo_put(&mf_cpu->fifo, entry)) {
> > +		queue_work_on(cpu, system_highpri_wq, &mf_cpu->work);
> > +		set_tsk_need_resched(current);
> > +		preempt_set_need_resched();
> 
> What guarantees the workqueue would run before the process? I see this:
> 
> ``WQ_HIGHPRI``
>   Work items of a highpri wq are queued to the highpri
>   worker-pool of the target cpu.  Highpri worker-pools are
>   served by worker threads with elevated nice level.
> 
> but is that enough?

Nope. Nice just makes it more likely, but no guarantees what so ever.

If you want to absolutely run something before we return to userspace,
would not task_work() be what we're looking for?
