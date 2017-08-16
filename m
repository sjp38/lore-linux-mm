Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B776E6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 03:15:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e74so5995720pfd.12
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:15:46 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id q14si147778pli.588.2017.08.16.00.15.44
        for <linux-mm@kvack.org>;
        Wed, 16 Aug 2017 00:15:45 -0700 (PDT)
Date: Wed, 16 Aug 2017 16:14:21 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170816071421.GT20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
 <20170816050506.GR20323@X58A-UD3R>
 <20170816055808.GB11771@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816055808.GB11771@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 16, 2017 at 01:58:08PM +0800, Boqun Feng wrote:
> > I'm not sure this caused the lockdep warning but, if they belongs to the
> > same class even though they couldn't be the same instance as you said, I
> > also think that is another problem and should be fixed.
> > 
> 
> My point was more like this is a false positive case, which we should
> avoid as hard as we can, because this very case doesn't look like a
> deadlock to me.
> 
> Maybe the pattern above does exist in current kernel, but we need to
> guide/adjust lockdep to find the real case showing it's happening.

As long as they are initialized as a same class, there's no way to
distinguish between them within lockdep.

And I also think we should avoid false positive cases. Do you think
there are many places where completions are initialized in a same place
even though they could never be the same instance?

If no, it would be better to fix it whenever we face it, as you did.

If yes, we have to change it for completion, for example:

1. Do not apply crossrelease into completions initialized on stack.

or

2. Use the full call path instead of a call site as a lockdep_map key.

or

3. So on.

Could you let me know your opinion about it?

Thanks,
Byungchul

> Regards,
> Boqun
> 
> > > this, we need to differ barr->done with different lock classes based on
> > > the corresponding works.
> > > 
> > > How about the this(only compilation test):
> > > 
> > > ----------------->8
> > > diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> > > index e86733a8b344..d14067942088 100644
> > > --- a/kernel/workqueue.c
> > > +++ b/kernel/workqueue.c
> > > @@ -2431,6 +2431,27 @@ struct wq_barrier {
> > >  	struct task_struct	*task;	/* purely informational */
> > >  };
> > >  
> > > +#ifdef CONFIG_LOCKDEP_COMPLETE
> > > +# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
> > > +do {										\
> > > +	INIT_WORK_ONSTACK(&(barr)->work, func);					\
> > > +	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
> > > +	lockdep_init_map_crosslock((struct lockdep_map *)&(barr)->done.map,	\
> > > +				   "(complete)" #barr,				\
> > > +				   (target)->lockdep_map.key, 1); 		\
> > > +	__init_completion(&barr->done);						\
> > > +	barr->task = current;							\
> > > +} while (0)
> > > +#else
> > > +# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
> > > +do {										\
> > > +	INIT_WORK_ONSTACK(&(barr)->work, func);					\
> > > +	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
> > > +	init_completion(&barr->done);						\
> > > +	barr->task = current;							\
> > > +} while (0)
> > > +#endif
> > > +
> > >  static void wq_barrier_func(struct work_struct *work)
> > >  {
> > >  	struct wq_barrier *barr = container_of(work, struct wq_barrier, work);
> > > @@ -2474,10 +2495,7 @@ static void insert_wq_barrier(struct pool_workqueue *pwq,
> > >  	 * checks and call back into the fixup functions where we
> > >  	 * might deadlock.
> > >  	 */
> > > -	INIT_WORK_ONSTACK(&barr->work, wq_barrier_func);
> > > -	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&barr->work));
> > > -	init_completion(&barr->done);
> > > -	barr->task = current;
> > > +	INIT_WQ_BARRIER_ONSTACK(barr, wq_barrier_func, target);
> > >  
> > >  	/*
> > >  	 * If @target is currently being executed, schedule the


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
