Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 19369900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 18:13:22 -0400 (EDT)
Date: Sat, 16 Apr 2011 00:13:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
Message-ID: <20110415221314.GE5432@quack.suse.cz>
References: <20110413085937.981293444@intel.com>
 <20110413090415.763161169@intel.com>
 <20110413220444.GF4648@quack.suse.cz>
 <20110413233122.GA6097@localhost>
 <20110413235211.GN31057@dastard>
 <20110414002301.GA9826@localhost>
 <20110414151424.GA367@localhost>
 <20110414181609.GH5054@quack.suse.cz>
 <20110415034300.GA23430@localhost>
 <20110415143711.GA17181@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110415143711.GA17181@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Fri 15-04-11 22:37:11, Wu Fengguang wrote:
> On Fri, Apr 15, 2011 at 11:43:00AM +0800, Wu Fengguang wrote:
> > On Fri, Apr 15, 2011 at 02:16:09AM +0800, Jan Kara wrote:
> > > On Thu 14-04-11 23:14:25, Wu Fengguang wrote:
> > > > On Thu, Apr 14, 2011 at 08:23:02AM +0800, Wu Fengguang wrote:
> > > > > On Thu, Apr 14, 2011 at 07:52:11AM +0800, Dave Chinner wrote:
> > > > > > On Thu, Apr 14, 2011 at 07:31:22AM +0800, Wu Fengguang wrote:
> > > > > > > On Thu, Apr 14, 2011 at 06:04:44AM +0800, Jan Kara wrote:
> > > > > > > > On Wed 13-04-11 16:59:41, Wu Fengguang wrote:
> > > > > > > > > Reduce the dampening for the control system, yielding faster
> > > > > > > > > convergence. The change is a bit conservative, as smaller values may
> > > > > > > > > lead to noticeable bdi threshold fluctuates in low memory JBOD setup.
> > > > > > > > > 
> > > > > > > > > CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > > > > > > > > CC: Richard Kennedy <richard@rsk.demon.co.uk>
> > > > > > > > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > > > > > >   Well, I have nothing against this change as such but what I don't like is
> > > > > > > > that it just changes magical +2 for similarly magical +0. It's clear that
> > > > > > > 
> > > > > > > The patch tends to make the rampup time a bit more reasonable for
> > > > > > > common desktops. From 100s to 25s (see below).
> > > > > > > 
> > > > > > > > this will lead to more rapid updates of proportions of bdi's share of
> > > > > > > > writeback and thread's share of dirtying but why +0? Why not +1 or -1? So
> > > > > > > 
> > > > > > > Yes, it will especially be a problem on _small memory_ JBOD setups.
> > > > > > > Richard actually has requested for a much radical change (decrease by
> > > > > > > 6) but that looks too much.
> > > > > > > 
> > > > > > > My team has a 12-disk JBOD with only 6G memory. The memory is pretty
> > > > > > > small as a server, but it's a real setup and serves well as the
> > > > > > > reference minimal setup that Linux should be able to run well on.
> > > > > > 
> > > > > > FWIW, linux runs on a lot of low power NAS boxes with jbod and/or
> > > > > > raid setups that have <= 1GB of RAM (many of them run XFS), so even
> > > > > > your setup could be considered large by a significant fraction of
> > > > > > the storage world. Hence you need to be careful of optimising for
> > > > > > what you think is a "normal" server, because there simply isn't such
> > > > > > a thing....
> > > > > 
> > > > > Good point! This patch is likely to hurt a loaded 1GB 4-disk NAS box...
> > > > > I'll test the setup.
> > > > 
> > > > Just did a comparison of the IO-less patches' performance with and
> > > > without this patch. I hardly notice any differences besides some more
> > > > bdi goal fluctuations in the attached graphs. The write throughput is
> > > > a bit large with this patch (80MB/s vs 76MB/s), however the delta is
> > > > within the even larger stddev range (20MB/s).
> > >   Thanks for the test but I cannot find out from the numbers you provided
> > > how much did the per-bdi thresholds fluctuate in this low memory NAS case?
> > > You can gather current bdi threshold from /sys/kernel/debug/bdi/<dev>/stats
> > > so it shouldn't be hard to get the numbers...
> > 
> > Hi Jan, attached are your results w/o this patch. The "bdi goal" (gray
> > line) is calculated as (bdi_thresh - bdi_thresh/8) and is fluctuating
> > all over the place.. and average wkB/s is only 49MB/s..
> 
> I got the numbers for vanilla kernel: XFS can do 57MB/s and 63MB/s in
> the two runs.  There are large fluctuations in the attached graphs, too.
  Hmm, so the graphs from previous email are with longer "proportion
period (without patch we discuss here)" and graphs from this email are
with it?

> To summary it up, for a 1GB mem, 4 disks JBOD setup, running 1 dd per
> disk:
> 
> vanilla: 57MB/s, 63MB/s
> Jan:     49MB/s, 103MB/s
> Wu:      76MB/s, 80MB/s
> 
> The balance_dirty_pages-task-bw-jan.png and
> balance_dirty_pages-pages-jan.png shows very unfair allocation of
> dirty pages and throughput among the disks...
  Fengguang, can we please stay on topic? It's good to know that throughput
fluctuates so much with my patches (although not that surprising seeing the
fluctuations of bdi limits) but for the sake of this patch throughput
numbers with different balance_dirty_pages() implementations do not seem
that interesting.  What is interesting (at least to me) is how this
particular patch changes fluctuations of bdi thresholds (fractions) in
vanilla kernel. In the graphs, I can see only bdi goal - that is the
per-bdi threshold we have in balance_dirty_pages() am I right? And it is
there for only a single device, right?

Anyway either with or without the patch, bdi thresholds are jumping rather
wildly if I'm interpreting the graphs right. Hmm, which is not that surprising
given that in ideal case we should have about 0.5s worth of writeback for
each disk in the page cache. So with your patch the period for proportion
estimation is also just about 0.5s worth of page writeback which is
understandably susceptible to fluctuations. Thinking about it, the original
period of 4*"dirty limit" on your machine is about 2.5 GB which is about
50s worth of writeback on that machine so it is in match with your
observation that it takes ~100s for bdi threshold to climb up.

So what is a takeaway from this for me is that scaling the period
with the dirty limit is not the right thing. If you'd have 4-times more
memory, your choice of "dirty limit" as the period would be as bad as
current 4*"dirty limit". What would seem like a better choice of period
to me would be to have the period in an order of a few seconds worth of
writeback. That would allow the bdi limit to scale up reasonably fast when
new bdi starts to be used and still not make it fluctuate that much
(hopefully).

Looking at math in lib/proportions.c, nothing really fundamental requires
that each period has the same length. So it shouldn't be hard to actually
create proportions calculator that would have timer triggered periods -
simply whenever the timer fires, we would declare a new period. The only
things which would be broken by this are (t represents global counter of
events):
a) counting of periods as t/period_len - we would have to maintain global
period counter but that's trivial
b) trick that we don't do t=t/2 for each new period but rather use
period_len/2+(t % (period_len/2)) when calculating fractions - again we
would have to bite the bullet and divide the global counter when we declare
new period but again it's not a big deal in our case.

Peter what do you think about this? Do you (or anyone else) think it makes
sense?

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
