Subject: Re: [PATCH] updated low-latency zap_page_range
From: Robert Love <rml@tech9.net>
In-Reply-To: <3D3F4A2F.B1A9F379@zip.com.au>
References: <1027556975.927.1641.camel@sinai>
	<3D3F4A2F.B1A9F379@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 24 Jul 2002 18:16:24 -0700
Message-Id: <1027559785.17950.3.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: torvalds@transmeta.com, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2002-07-24 at 17:45, Andrew Morton wrote:

> Robert Love wrote:
> >
> > +static inline void cond_resched_lock(spinlock_t * lock)
> > +{
> > +       if (need_resched() && preempt_count() == 1) {
> > +               _raw_spin_unlock(lock);
> > +               preempt_enable_no_resched();
> > +               __cond_resched();
> > +               spin_lock(lock);
> > +       }
> > +}
> 
> Maybe I'm being thick.  How come a simple spin_unlock() in here
> won't do the right thing?

It will, but we will check need_resched twice.  And preempt_count
again.  My original version just did the "unlock; lock" combo and thus
the checking was automatic... but if we want to check before we unlock,
we might as well be optimal about it.

> And this won't _really_ compile to nothing with CONFIG_PREEMPT=n,
> will it?  It just does nothing because preempt_count() is zero?

I hope it compiles to nothing!  There is a false in an if... oh, wait,
to preserve possible side-effects gcc will keep the need_resched() call
so I guess we should reorder it as:

	if (preempt_count() == 1 && need_resched())

Then we get "if (0 && ..)" which should hopefully be evaluated away. 
Then the inline is empty and nothing need be done.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
