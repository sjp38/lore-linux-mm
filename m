Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5E8EB6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 18:42:09 -0400 (EDT)
Date: Fri, 1 Jun 2012 00:42:06 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
Message-ID: <20120531224206.GC19050@quack.suse.cz>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
 <1337878751-22942-3-git-send-email-jack@suse.cz>
 <1338220185.4284.19.camel@lappy>
 <20120529123408.GA23991@quack.suse.cz>
 <1338295111.26856.57.camel@twins>
 <20120529125452.GB23991@quack.suse.cz>
 <20120531221146.GA19050@quack.suse.cz>
 <1338503165.28384.134.camel@twins>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="IiVenqGWf+H9Y6IX"
Content-Disposition: inline
In-Reply-To: <1338503165.28384.134.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Sasha Levin <levinsasha928@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri 01-06-12 00:26:05, Peter Zijlstra wrote:
> On Fri, 2012-06-01 at 00:11 +0200, Jan Kara wrote:
> >  bool fprop_new_period(struct fprop_global *p, int periods)
> >  {
> > -       u64 events = percpu_counter_sum(&p->events);
> > +       u64 events;
> > +       unsigned long flags;
> >  
> > +       local_irq_save(flags);
> > +       events = percpu_counter_sum(&p->events);
> > +       local_irq_restore(flags);
> >         /*
> >          * Don't do anything if there are no events.
> >          */
> > @@ -73,7 +77,9 @@ bool fprop_new_period(struct fprop_global *p, int periods)
> >         if (periods < 64)
> >                 events -= events >> periods;
> >         /* Use addition to avoid losing events happening between sum and set */
> > +       local_irq_save(flags);
> >         percpu_counter_add(&p->events, -events);
> > +       local_irq_restore(flags);
> >         p->period += periods;
> >         write_seqcount_end(&p->sequence); 
> 
> Uhm, why bother enabling it in between? Just wrap the whole function in
> a single IRQ disable.
  I wanted to have interrupts disabled for as short as possible but if you
think it doesn't matter, I'll take your advice. The result is attached.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--IiVenqGWf+H9Y6IX
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="flex-proportion-irq-save.diff"

From: Jan Kara <jack@suse.cz>
Subject: lib: Fix possible deadlock in flexible proportion code

When percpu counter function in fprop_new_period() is interrupted by an
interrupt while holding counter lock, it can cause deadlock when the
interrupt wants to take the lock as well. Fix the problem by disabling
interrupts when calling percpu counter functions.

Signed-off-by: Jan Kara <jack@suse.cz>

diff -u b/lib/flex_proportions.c b/lib/flex_proportions.c
--- b/lib/flex_proportions.c
+++ b/lib/flex_proportions.c
@@ -62,13 +62,18 @@
  */
 bool fprop_new_period(struct fprop_global *p, int periods)
 {
-	u64 events = percpu_counter_sum(&p->events);
+	u64 events;
+	unsigned long flags;
 
+	local_irq_save(flags);
+	events = percpu_counter_sum(&p->events);
 	/*
 	 * Don't do anything if there are no events.
 	 */
-	if (events <= 1)
+	if (events <= 1) {
+		local_irq_restore(flags);
 		return false;
+	}
 	write_seqcount_begin(&p->sequence);
 	if (periods < 64)
 		events -= events >> periods;
@@ -76,6 +81,7 @@
 	percpu_counter_add(&p->events, -events);
 	p->period += periods;
 	write_seqcount_end(&p->sequence);
+	local_irq_restore(flags);
 
 	return true;
 }

--IiVenqGWf+H9Y6IX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
