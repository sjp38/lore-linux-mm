Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5366C6B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 15:22:43 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id j1-v6so2227975pll.7
        for <linux-mm@kvack.org>; Wed, 23 May 2018 12:22:43 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g2-v6si19993891pli.48.2018.05.23.12.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 12:22:41 -0700 (PDT)
Date: Wed, 23 May 2018 12:22:39 -0700
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH 3/8] md: raid5: use refcount_t for reference counting
 instead atomic_t
Message-ID: <20180523192239.GA59657@kernel.org>
References: <20180509193645.830-1-bigeasy@linutronix.de>
 <20180509193645.830-4-bigeasy@linutronix.de>
 <20180523132119.GC19987@bombadil.infradead.org>
 <20180523174904.GY12198@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523174904.GY12198@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

On Wed, May 23, 2018 at 07:49:04PM +0200, Peter Zijlstra wrote:
> On Wed, May 23, 2018 at 06:21:19AM -0700, Matthew Wilcox wrote:
> > On Wed, May 09, 2018 at 09:36:40PM +0200, Sebastian Andrzej Siewior wrote:
> > > refcount_t type and corresponding API should be used instead of atomic_t when
> > > the variable is used as a reference counter. This allows to avoid accidental
> > > refcounter overflows that might lead to use-after-free situations.
> > > 
> > > Most changes are 1:1 replacements except for
> > > 	BUG_ON(atomic_inc_return(&sh->count) != 1);
> > > 
> > > which has been turned into
> > >         refcount_inc(&sh->count);
> > >         BUG_ON(refcount_read(&sh->count) != 1);
> > 
> > @@ -5387,7 +5387,8 @@ static struct stripe_head *__get_priority_stripe(struct
> > +r5conf *conf, int group)
> >                 sh->group = NULL;
> >         }
> >         list_del_init(&sh->lru);
> > -       BUG_ON(atomic_inc_return(&sh->count) != 1);
> > +       refcount_inc(&sh->count);
> > +	BUG_ON(refcount_read(&sh->count) != 1);
> >         return sh;
> >  }
> > 
> > 
> > That's the only problematic usage.  And I think what it's really saying is:
> > 
> > 	BUG_ON(refcount_read(&sh->count) != 0);
> > 	refcount_set(&sh->count, 1);
> > 
> > With that, this looks like a reasonable use of refcount_t to me.
> 
> I'm not so sure, look at:
> 
>   r5c_do_reclaim():
> 
> 	if (!list_empty(&sh->lru) &&
> 	    !test_bit(STRIPE_HANDLE, &sh->state) &&
> 	    atomic_read(&sh->count) == 0) {
> 	      r5c_flush_stripe(cond, sh)
> 
> Which does:
> 
>   r5c_flush_stripe():
> 
> 	atomic_inc(&sh->count);
> 
> Which is another inc-from-zero. Also, having sh's with count==0 in a
> list is counter to the concept of refcounts and smells like usage-counts
> to me. For refcount 0 really means deads and gone.
> 
> If this really is supposed to be a refcount, someone more familiar with
> the raid5 should do the patch and write a comprehensive changelog on it.

I don't know what is changed in the refcount, such raid5 change has attempted
before and didn't work. 0 for the stripe count is a valid usage and we do
inc-from-zero in several places.

Thanks,
Shaohua
