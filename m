Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id ED0E76B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 10:42:31 -0400 (EDT)
Date: Fri, 18 May 2012 16:42:17 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] lib: Proportions with flexible period
Message-ID: <20120518144217.GC6875@quack.suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
 <1337096583-6049-2-git-send-email-jack@suse.cz>
 <1337291805.4281.97.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337291805.4281.97.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu 17-05-12 23:56:45, Peter Zijlstra wrote:
> On Tue, 2012-05-15 at 17:43 +0200, Jan Kara wrote:
> > +void fprop_fraction_percpu(struct fprop_global *p,
> > +                          struct fprop_local_percpu *pl,
> > +                          unsigned long *numerator, unsigned long *denominator)
> > +{
> > +       unsigned int seq;
> > +       s64 den;
> > +
> > +       do {
> > +               seq = read_seqcount_begin(&p->sequence);
> > +               fprop_reflect_period_percpu(p, pl);
> > +               *numerator = percpu_counter_read_positive(&pl->events);
> > +               den = percpu_counter_read(&p->events);
> > +               if (den <= 0)
> > +                       den = percpu_counter_sum(&p->events);
> > +               *denominator = den;
> > +       } while (read_seqcount_retry(&p->sequence, seq));
> > +} 
> 
> 
> why not use percpu_counter_read_positive(&p->events) and ditch
> percpu_counter_sum()? That sum can be terribly expensive..
  Yes. I'm actually not sure why I used the _sum here... Thanks for
spotting this.

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
