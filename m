Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 80A926B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 20:41:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w187so23088798pgb.10
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 17:41:39 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f1si3690165plb.867.2017.08.10.17.41.37
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 17:41:37 -0700 (PDT)
Date: Fri, 11 Aug 2017 09:40:21 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170811004021.GF20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810125133.2poixhni4d5aqkpy@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Aug 10, 2017 at 08:51:33PM +0800, Boqun Feng wrote:
> > > >  void crossrelease_hist_end(enum context_t c)
> > > >  {
> > > > -	if (current->xhlocks)
> > > > -		current->xhlock_idx = current->xhlock_idx_hist[c];
> > > > +	struct task_struct *cur = current;
> > > > +
> > > > +	if (cur->xhlocks) {
> > > > +		unsigned int idx = cur->xhlock_idx_hist[c];
> > > > +		struct hist_lock *h = &xhlock(idx);
> > > > +
> > > > +		cur->xhlock_idx = idx;
> > > > +
> > > > +		/* Check if the ring was overwritten. */
> > > > +		if (h->hist_id != cur->hist_id_save[c])
> > > 
> > > Could we use:
> > > 
> > > 		if (h->hist_id != idx)
> > 
> > No, we cannot.
> > 
> 
> Hey, I'm not buying it. task_struct::hist_id and task_struct::xhlock_idx
> are increased at the same place(in add_xhlock()), right?

Right.

> And, yes, xhlock_idx will get decreased when we do ring-buffer

This is why we should keep both of them.

> unwinding, but that's OK, because we need to throw away those recently
> added items.
> 
> And xhlock_idx always points to the most recently added valid item,

No, it's not true in case that the ring buffer was wrapped like:

          ppppppppppppppppppppppppiiiiiiiiiiiiiiiiiiiiiiii
wrapped > iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii................
                                 ^
                     xhlock_idx points here after unwinding,
                     and it's not a valid one.

          where p represents an acquisition in process context,
          i represents an acquisition in irq context.

> right?  Any other item's idx must "before()" the most recently added
> one's, right? So ::xhlock_idx acts just like a timestamp, doesn't it?

Both of two answers are _no_.

> Maybe I'm missing something subtle, but could you show me an example,
> that could end up being a problem if we use xhlock_idx as the hist_id?

See the example above. We cannot detect whether it was wrapped or not using
xhlock_idx.

> 
> > hist_id is a kind of timestamp and used to detect overwriting
> > data into places of same indexes of the ring buffer. And idx is
> > just an index. :) IOW, they mean different things.
> > 
> > > 
> > > here, and
> > > 
> > > > +			invalidate_xhlock(h);
> > > > +	}
> > > >  }
> > > >
> > > >  static int cross_lock(struct lockdep_map *lock)
> > > > @@ -4826,6 +4851,7 @@ static inline int depend_after(struct held_lock
> > > *hlock)
> > > >   * Check if the xhlock is valid, which would be false if,
> > > >   *
> > > >   *    1. Has not used after initializaion yet.
> > > > + *    2. Got invalidated.
> > > >   *
> > > >   * Remind hist_lock is implemented as a ring buffer.
> > > >   */
> > > > @@ -4857,6 +4883,7 @@ static void add_xhlock(struct held_lock *hlock)
> > > >
> > > >  	/* Initialize hist_lock's members */
> > > >  	xhlock->hlock = *hlock;
> > > > +	xhlock->hist_id = current->hist_id++;
> 
> Besides, is this code correct? Does this just make xhlock->hist_id
> one-less-than the curr->hist_id, which cause the invalidation every time
> you do ring buffer unwinding?

Right. "save = hist_id++" should be "save = ++hist_id". Could you fix it?

Thank you,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
