Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 9E29D6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 18:11:51 -0400 (EDT)
Date: Fri, 1 Jun 2012 00:11:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
Message-ID: <20120531221146.GA19050@quack.suse.cz>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
 <1337878751-22942-3-git-send-email-jack@suse.cz>
 <1338220185.4284.19.camel@lappy>
 <20120529123408.GA23991@quack.suse.cz>
 <1338295111.26856.57.camel@twins>
 <20120529125452.GB23991@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Content-Disposition: inline
In-Reply-To: <20120529125452.GB23991@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Sasha Levin <levinsasha928@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 29-05-12 14:54:52, Jan Kara wrote:
> On Tue 29-05-12 14:38:31, Peter Zijlstra wrote:
> > On Tue, 2012-05-29 at 14:34 +0200, Jan Kara wrote:
> > 
> > > The only safe solution seems to be to create a variant of percpu counters
> > > that can be used from an interrupt. Or do you have other idea Peter?
> > 
> > > > [   20.680186]  [<ffffffff8325ac9b>] _raw_spin_lock+0x3b/0x70
> > > > [   20.680186]  [<ffffffff81993527>] ? __percpu_counter_sum+0x17/0xc0
> > > > [   20.680186]  [<ffffffff81993527>] __percpu_counter_sum+0x17/0xc0
> > > > [   20.680186]  [<ffffffff810ebf90>] ? init_timer_deferrable_key+0x20/0x20
> > > > [   20.680186]  [<ffffffff8195b5c2>] fprop_new_period+0x12/0x60
> > > > [   20.680186]  [<ffffffff811d929d>] writeout_period+0x3d/0xa0
> > > > [   20.680186]  [<ffffffff810ec0bf>] call_timer_fn+0x12f/0x260
> > > > [   20.680186]  [<ffffffff810ebf90>] ? init_timer_deferrable_key+0x20/0x20
> > 
> > Yeah, just make sure IRQs are disabled around doing that ;-)
>   Evil ;) But we'd need to have IRQs disabled also in each
> fprop_fraction_percpu() call, and generally, if we want things clean, we'd
> need to disable them in all entry points to proportion code (or at least
> around all percpu calls)...
  OK, after some thought I was wrong and fixing fprop_new_period() is
enough. Attached patch should fix the warning (and possible deadlock).
Fengguang should I resend you fixed patch implementing flexible proportions
or do you prefer incremental patch against your tree?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--zhXaljGHf11kAtnf
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="flex-proportion-irq-save.diff"

From: Jan Kara <jack@suse.cz>
Subject: lib: Fix possible deadlock in flexible proportion code

When percpu counter function in fprop_new_period() is interrupted by an
interrupt while holding counter lock, it can cause deadlock when the
interrupt wants to take the lock as well. Fix the problem by disabling
interrupts when calling percpu counter functions.

Signed-off-by: Jan Kara <jack@suse.cz>

diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
index 530dbc2..fbf6b11 100644
--- a/lib/flex_proportions.c
+++ b/lib/flex_proportions.c
@@ -62,8 +62,12 @@ void fprop_global_destroy(struct fprop_global *p)
  */
 bool fprop_new_period(struct fprop_global *p, int periods)
 {
-	u64 events = percpu_counter_sum(&p->events);
+	u64 events;
+	unsigned long flags;
 
+	local_irq_save(flags);
+	events = percpu_counter_sum(&p->events);
+	local_irq_restore(flags);
 	/*
 	 * Don't do anything if there are no events.
 	 */
@@ -73,7 +77,9 @@ bool fprop_new_period(struct fprop_global *p, int periods)
 	if (periods < 64)
 		events -= events >> periods;
 	/* Use addition to avoid losing events happening between sum and set */
+	local_irq_save(flags);
 	percpu_counter_add(&p->events, -events);
+	local_irq_restore(flags);
 	p->period += periods;
 	write_seqcount_end(&p->sequence);
 

--zhXaljGHf11kAtnf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
