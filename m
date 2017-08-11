Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 109D66B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 23:44:45 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 16so26133595pgg.8
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 20:44:45 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t137si3488391pgb.538.2017.08.10.20.44.43
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 20:44:43 -0700 (PDT)
Date: Fri, 11 Aug 2017 12:43:28 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170811034328.GH20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
 <20170810131737.skdyy4qcxlikbyeh@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810131737.skdyy4qcxlikbyeh@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Aug 10, 2017 at 09:17:37PM +0800, Boqun Feng wrote:
> > > > > @@ -4826,6 +4851,7 @@ static inline int depend_after(struct held_lock
> > > > *hlock)
> > > > >   * Check if the xhlock is valid, which would be false if,
> > > > >   *
> > > > >   *    1. Has not used after initializaion yet.
> > > > > + *    2. Got invalidated.
> > > > >   *
> > > > >   * Remind hist_lock is implemented as a ring buffer.
> > > > >   */
> > > > > @@ -4857,6 +4883,7 @@ static void add_xhlock(struct held_lock *hlock)
> > > > >
> > > > >  	/* Initialize hist_lock's members */
> > > > >  	xhlock->hlock = *hlock;
> > > > > +	xhlock->hist_id = current->hist_id++;
> > 
> > Besides, is this code correct? Does this just make xhlock->hist_id
> > one-less-than the curr->hist_id, which cause the invalidation every time
> > you do ring buffer unwinding?
> > 
> > Regards,
> > Boqun
> > 
> 
> So basically, I'm suggesting do this on top of your patch, there is also
> a fix in commit_xhlocks(), which I think you should swap the parameters
> in before(...), no matter using task_struct::hist_id or using
> task_struct::xhlock_idx as the timestamp.
> 
> Hope this could make my point more clear, and if I do miss something,
> please point it out, thanks ;-)

Sorry for mis-understanding. I like your patch. I think it works.

Additionally.. See below..

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 074872f016f8..886ba79bfc38 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -854,9 +854,6 @@ struct task_struct {
>  	unsigned int xhlock_idx;
>  	/* For restoring at history boundaries */
>  	unsigned int xhlock_idx_hist[XHLOCK_NR];
> -	unsigned int hist_id;
> -	/* For overwrite check at each context exit */
> -	unsigned int hist_id_save[XHLOCK_NR];
>  #endif
>  
>  #ifdef CONFIG_UBSAN
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 699fbeab1920..04c6c8d68e18 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -4752,10 +4752,8 @@ void crossrelease_hist_start(enum xhlock_context_t c)
>  {
>  	struct task_struct *cur = current;
>  
> -	if (cur->xhlocks) {
> +	if (cur->xhlocks)
>  		cur->xhlock_idx_hist[c] = cur->xhlock_idx;
> -		cur->hist_id_save[c] = cur->hist_id;
> -	}
>  }
>  
>  void crossrelease_hist_end(enum xhlock_context_t c)
> @@ -4769,7 +4767,7 @@ void crossrelease_hist_end(enum xhlock_context_t c)
>  		cur->xhlock_idx = idx;
>  
>  		/* Check if the ring was overwritten. */
> -		if (h->hist_id != cur->hist_id_save[c])
> +		if (h->hist_id != idx)
>  			invalidate_xhlock(h);
>  	}
>  }
> @@ -4849,7 +4847,7 @@ static void add_xhlock(struct held_lock *hlock)
>  
>  	/* Initialize hist_lock's members */
>  	xhlock->hlock = *hlock;
> -	xhlock->hist_id = current->hist_id++;
> +	xhlock->hist_id = idx;
>  
>  	xhlock->trace.nr_entries = 0;
>  	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
> @@ -5005,7 +5003,7 @@ static int commit_xhlock(struct cross_lock *xlock, struct hist_lock *xhlock)
>  static void commit_xhlocks(struct cross_lock *xlock)
>  {
>  	unsigned int cur = current->xhlock_idx;
> -	unsigned int prev_hist_id = xhlock(cur).hist_id;
> +	unsigned int prev_hist_id = cur + 1;

I should have named it another. Could you suggest a better one?

>  	unsigned int i;
>  
>  	if (!graph_lock())
> @@ -5030,7 +5028,7 @@ static void commit_xhlocks(struct cross_lock *xlock)
>  			 * hist_id than the following one, which is impossible
>  			 * otherwise.

Or we need to modify the comment so that the word 'prev' does not make
readers confused. It was my mistake.

Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
