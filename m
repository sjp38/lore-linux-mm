Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 5A8096B00E8
	for <linux-mm@kvack.org>; Fri, 18 May 2012 10:45:17 -0400 (EDT)
Date: Fri, 18 May 2012 16:45:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] lib: Proportions with flexible period
Message-ID: <20120518144504.GD6875@quack.suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
 <1337096583-6049-2-git-send-email-jack@suse.cz>
 <1337337824.573.16.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337337824.573.16.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 18-05-12 12:43:44, Peter Zijlstra wrote:
> On Tue, 2012-05-15 at 17:43 +0200, Jan Kara wrote:
> > +void __fprop_inc_percpu_max(struct fprop_global *p,
> > +                           struct fprop_local_percpu *pl, int max_frac)
> > +{
> > +       if (unlikely(max_frac < 100)) {
> > +               unsigned long numerator, denominator;
> > +
> > +               fprop_fraction_percpu(p, pl, &numerator, &denominator);
> > +               if (numerator > ((long long)denominator) * max_frac / 100)
> > +                       return;
> 
> Another thing, your fprop_fraction_percpu() can he horribly expensive
> due to using _sum() (and to a lesser degree the retry), remember that
> this function is called for _every_ page written out.
  The retry happens only when new period is declared while
fprop_fraction_percpu() is running. So that should be rather exceptional.
Regarding the _sum I agree, luckily that's easy enough to fix.

> Esp. on the mega fast storage (multi-spindle or SSD) they're pushing cpu
> limits as it is with iops, we should be very careful not to make it more
> expensive than absolutely needed.
  Yup.

> > +       } else
> > +               fprop_reflect_period_percpu(p, pl);
> > +       __percpu_counter_add(&pl->events, 1, PROP_BATCH);
> > +       percpu_counter_add(&p->events, 1);
> > +} 

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
