Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1FFE36B004D
	for <linux-mm@kvack.org>; Thu, 31 May 2012 23:10:18 -0400 (EDT)
Date: Fri, 1 Jun 2012 11:10:15 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
Message-ID: <20120601031015.GB7896@localhost>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
 <1337878751-22942-3-git-send-email-jack@suse.cz>
 <1338220185.4284.19.camel@lappy>
 <20120529123408.GA23991@quack.suse.cz>
 <1338295111.26856.57.camel@twins>
 <20120529125452.GB23991@quack.suse.cz>
 <20120531221146.GA19050@quack.suse.cz>
 <1338503165.28384.134.camel@twins>
 <20120531224206.GC19050@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20120531224206.GC19050@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, Sasha Levin <levinsasha928@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 01, 2012 at 12:42:06AM +0200, Jan Kara wrote:
> On Fri 01-06-12 00:26:05, Peter Zijlstra wrote:
> > On Fri, 2012-06-01 at 00:11 +0200, Jan Kara wrote:
> > >  bool fprop_new_period(struct fprop_global *p, int periods)
> > >  {
> > > -       u64 events = percpu_counter_sum(&p->events);
> > > +       u64 events;
> > > +       unsigned long flags;
> > >  
> > > +       local_irq_save(flags);
> > > +       events = percpu_counter_sum(&p->events);
> > > +       local_irq_restore(flags);
> > >         /*
> > >          * Don't do anything if there are no events.
> > >          */
> > > @@ -73,7 +77,9 @@ bool fprop_new_period(struct fprop_global *p, int periods)
> > >         if (periods < 64)
> > >                 events -= events >> periods;
> > >         /* Use addition to avoid losing events happening between sum and set */
> > > +       local_irq_save(flags);
> > >         percpu_counter_add(&p->events, -events);
> > > +       local_irq_restore(flags);
> > >         p->period += periods;
> > >         write_seqcount_end(&p->sequence); 
> > 
> > Uhm, why bother enabling it in between? Just wrap the whole function in
> > a single IRQ disable.
>   I wanted to have interrupts disabled for as short as possible but if you
> think it doesn't matter, I'll take your advice. The result is attached.

Thank you! I applied this incremental fix next to the commit
"lib: Proportions with flexible period".

Thanks,
Fengguang

> From: Jan Kara <jack@suse.cz>
> Subject: lib: Fix possible deadlock in flexible proportion code
> 
> When percpu counter function in fprop_new_period() is interrupted by an
> interrupt while holding counter lock, it can cause deadlock when the
> interrupt wants to take the lock as well. Fix the problem by disabling
> interrupts when calling percpu counter functions.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> 
> diff -u b/lib/flex_proportions.c b/lib/flex_proportions.c
> --- b/lib/flex_proportions.c
> +++ b/lib/flex_proportions.c
> @@ -62,13 +62,18 @@
>   */
>  bool fprop_new_period(struct fprop_global *p, int periods)
>  {
> -	u64 events = percpu_counter_sum(&p->events);
> +	u64 events;
> +	unsigned long flags;
>  
> +	local_irq_save(flags);
> +	events = percpu_counter_sum(&p->events);
>  	/*
>  	 * Don't do anything if there are no events.
>  	 */
> -	if (events <= 1)
> +	if (events <= 1) {
> +		local_irq_restore(flags);
>  		return false;
> +	}
>  	write_seqcount_begin(&p->sequence);
>  	if (periods < 64)
>  		events -= events >> periods;
> @@ -76,6 +81,7 @@
>  	percpu_counter_add(&p->events, -events);
>  	p->period += periods;
>  	write_seqcount_end(&p->sequence);
> +	local_irq_restore(flags);
>  
>  	return true;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
