Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E6E576B0044
	for <linux-mm@kvack.org>; Wed,  9 May 2012 08:33:23 -0400 (EDT)
Date: Wed, 9 May 2012 13:38:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
Message-ID: <20120509113850.GD5092@quack.suse.cz>
References: <1336084760-19534-1-git-send-email-jack@suse.cz>
 <1336084760-19534-3-git-send-email-jack@suse.cz>
 <20120507144715.GB13983@localhost>
 <1336404067.27020.67.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336404067.27020.67.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Mon 07-05-12 17:21:07, Peter Zijlstra wrote:
> On Mon, 2012-05-07 at 22:47 +0800, Fengguang Wu wrote:
> > On Fri, May 04, 2012 at 12:39:20AM +0200, Jan Kara wrote:
> > > Convert calculations of proportion of writeback each bdi does to new flexible
> > > proportion code. That allows us to use aging period of fixed wallclock time
> > > which gives better proportion estimates given the hugely varying throughput of
> > > different devices.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > ---
> > >  include/linux/backing-dev.h |    6 ++--
> > >  mm/backing-dev.c            |    5 +--
> > >  mm/page-writeback.c         |   80 ++++++++++++++++++++----------------------
> > >  3 files changed, 43 insertions(+), 48 deletions(-)
> > 
> > > +static void vm_completions_period(struct work_struct *work);
> > > +/* Work for aging of vm_completions */
> > > +static DECLARE_DEFERRED_WORK(vm_completions_period_work, vm_completions_period);
> > 
> > > +
> > > +static void vm_completions_period(struct work_struct *work)
> > > +{
> > > +	fprop_new_period(&vm_completions);
> > > +	schedule_delayed_work(&vm_completions_period_work,
> > > +			      VM_COMPLETIONS_PERIOD_LEN);
> > > +}
> > > +
> > 
> > Is it possible to optimize away the periodic work when there are no
> > disk writes?
> 
> That should really be a timer, nothing in there requires scheduling so
> the entire addition of the workqueue muck is pure overhead.
> 
> You could keep a second period counter that tracks the last observed
> period and whenever the period and last_observed_period are further
> apart than BITS_PER_LONG you can stop the timer.
> 
> You'll have to restart it when updating last_observed_period.
  Good points. I'll improve this in the next version.

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
