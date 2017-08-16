Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD9D06B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 01:06:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 24so3570040pfk.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:06:27 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 1si3973plk.518.2017.08.15.22.06.26
        for <linux-mm@kvack.org>;
        Tue, 15 Aug 2017 22:06:26 -0700 (PDT)
Date: Wed, 16 Aug 2017 14:05:06 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170816050506.GR20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816035842.p33z5st3rr2gwssh@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 16, 2017 at 12:05:31PM +0800, Boqun Feng wrote:
> > I see...
> > 
> > Worker A : acquired of wfc.work -> wait for cpu_hotplug_lock to be released
> > Task   B : acquired of cpu_hotplug_lock -> wait for lock#3 to be released
> > Task   C : acquired of lock#3 -> wait for completion of barr->done
> 
> >From the stack trace below, this barr->done is for flush_work() in
> lru_add_drain_all_cpuslocked(), i.e. for work "per_cpu(lru_add_drain_work)"
> 
> > Worker D : wait for wfc.work to be released -> will complete barr->done
> 
> and this barr->done is for work "wfc.work".
> 
> So those two barr->done could not be the same instance, IIUC. Therefore
> the deadlock case is not possible.
> 
> The problem here is all barr->done instances are initialized at
> insert_wq_barrier() and they belongs to the same lock class, to fix

I'm not sure this caused the lockdep warning but, if they belongs to the
same class even though they couldn't be the same instance as you said, I
also think that is another problem and should be fixed.

> this, we need to differ barr->done with different lock classes based on
> the corresponding works.
> 
> How about the this(only compilation test):
> 
> ----------------->8
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index e86733a8b344..d14067942088 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -2431,6 +2431,27 @@ struct wq_barrier {
>  	struct task_struct	*task;	/* purely informational */
>  };
>  
> +#ifdef CONFIG_LOCKDEP_COMPLETE
> +# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
> +do {										\
> +	INIT_WORK_ONSTACK(&(barr)->work, func);					\
> +	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
> +	lockdep_init_map_crosslock((struct lockdep_map *)&(barr)->done.map,	\
> +				   "(complete)" #barr,				\
> +				   (target)->lockdep_map.key, 1); 		\
> +	__init_completion(&barr->done);						\
> +	barr->task = current;							\
> +} while (0)
> +#else
> +# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
> +do {										\
> +	INIT_WORK_ONSTACK(&(barr)->work, func);					\
> +	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
> +	init_completion(&barr->done);						\
> +	barr->task = current;							\
> +} while (0)
> +#endif
> +
>  static void wq_barrier_func(struct work_struct *work)
>  {
>  	struct wq_barrier *barr = container_of(work, struct wq_barrier, work);
> @@ -2474,10 +2495,7 @@ static void insert_wq_barrier(struct pool_workqueue *pwq,
>  	 * checks and call back into the fixup functions where we
>  	 * might deadlock.
>  	 */
> -	INIT_WORK_ONSTACK(&barr->work, wq_barrier_func);
> -	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&barr->work));
> -	init_completion(&barr->done);
> -	barr->task = current;
> +	INIT_WQ_BARRIER_ONSTACK(barr, wq_barrier_func, target);
>  
>  	/*
>  	 * If @target is currently being executed, schedule the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
