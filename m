Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 6D3A46B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 11:21:27 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1SRPkc-0003o7-8W
	for linux-mm@kvack.org; Mon, 07 May 2012 15:21:26 +0000
Received: from dhcp-089-099-019-018.chello.nl ([89.99.19.18] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1SRPkb-0001XS-RN
	for linux-mm@kvack.org; Mon, 07 May 2012 15:21:26 +0000
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20120507144715.GB13983@localhost>
References: <1336084760-19534-1-git-send-email-jack@suse.cz>
	 <1336084760-19534-3-git-send-email-jack@suse.cz>
	 <20120507144715.GB13983@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 May 2012 17:21:07 +0200
Message-ID: <1336404067.27020.67.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Mon, 2012-05-07 at 22:47 +0800, Fengguang Wu wrote:
> On Fri, May 04, 2012 at 12:39:20AM +0200, Jan Kara wrote:
> > Convert calculations of proportion of writeback each bdi does to new flexible
> > proportion code. That allows us to use aging period of fixed wallclock time
> > which gives better proportion estimates given the hugely varying throughput of
> > different devices.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  include/linux/backing-dev.h |    6 ++--
> >  mm/backing-dev.c            |    5 +--
> >  mm/page-writeback.c         |   80 ++++++++++++++++++++----------------------
> >  3 files changed, 43 insertions(+), 48 deletions(-)
> 
> > +static void vm_completions_period(struct work_struct *work);
> > +/* Work for aging of vm_completions */
> > +static DECLARE_DEFERRED_WORK(vm_completions_period_work, vm_completions_period);
> 
> > +
> > +static void vm_completions_period(struct work_struct *work)
> > +{
> > +	fprop_new_period(&vm_completions);
> > +	schedule_delayed_work(&vm_completions_period_work,
> > +			      VM_COMPLETIONS_PERIOD_LEN);
> > +}
> > +
> 
> Is it possible to optimize away the periodic work when there are no
> disk writes?

That should really be a timer, nothing in there requires scheduling so
the entire addition of the workqueue muck is pure overhead.

You could keep a second period counter that tracks the last observed
period and whenever the period and last_observed_period are further
apart than BITS_PER_LONG you can stop the timer.

You'll have to restart it when updating last_observed_period.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
