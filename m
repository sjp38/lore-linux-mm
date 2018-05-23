Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA9F96B0266
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:49:13 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s2-v6so18275425ioa.22
        for <linux-mm@kvack.org>; Wed, 23 May 2018 10:49:13 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x19-v6si652589ioa.277.2018.05.23.10.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 10:49:09 -0700 (PDT)
Date: Wed, 23 May 2018 19:49:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/8] md: raid5: use refcount_t for reference counting
 instead atomic_t
Message-ID: <20180523174904.GY12198@hirez.programming.kicks-ass.net>
References: <20180509193645.830-1-bigeasy@linutronix.de>
 <20180509193645.830-4-bigeasy@linutronix.de>
 <20180523132119.GC19987@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523132119.GC19987@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

On Wed, May 23, 2018 at 06:21:19AM -0700, Matthew Wilcox wrote:
> On Wed, May 09, 2018 at 09:36:40PM +0200, Sebastian Andrzej Siewior wrote:
> > refcount_t type and corresponding API should be used instead of atomic_t when
> > the variable is used as a reference counter. This allows to avoid accidental
> > refcounter overflows that might lead to use-after-free situations.
> > 
> > Most changes are 1:1 replacements except for
> > 	BUG_ON(atomic_inc_return(&sh->count) != 1);
> > 
> > which has been turned into
> >         refcount_inc(&sh->count);
> >         BUG_ON(refcount_read(&sh->count) != 1);
> 
> @@ -5387,7 +5387,8 @@ static struct stripe_head *__get_priority_stripe(struct
> +r5conf *conf, int group)
>                 sh->group = NULL;
>         }
>         list_del_init(&sh->lru);
> -       BUG_ON(atomic_inc_return(&sh->count) != 1);
> +       refcount_inc(&sh->count);
> +	BUG_ON(refcount_read(&sh->count) != 1);
>         return sh;
>  }
> 
> 
> That's the only problematic usage.  And I think what it's really saying is:
> 
> 	BUG_ON(refcount_read(&sh->count) != 0);
> 	refcount_set(&sh->count, 1);
> 
> With that, this looks like a reasonable use of refcount_t to me.

I'm not so sure, look at:

  r5c_do_reclaim():

	if (!list_empty(&sh->lru) &&
	    !test_bit(STRIPE_HANDLE, &sh->state) &&
	    atomic_read(&sh->count) == 0) {
	      r5c_flush_stripe(cond, sh)

Which does:

  r5c_flush_stripe():

	atomic_inc(&sh->count);

Which is another inc-from-zero. Also, having sh's with count==0 in a
list is counter to the concept of refcounts and smells like usage-counts
to me. For refcount 0 really means deads and gone.

If this really is supposed to be a refcount, someone more familiar with
the raid5 should do the patch and write a comprehensive changelog on it.
