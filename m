Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 870FC8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 08:52:10 -0500 (EST)
Date: Tue, 1 Mar 2011 21:52:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: IO-less dirty throttling V6 results available
Message-ID: <20110301135205.GA16735@localhost>
References: <20110222142543.GA13132@localhost>
 <20110223151322.GA13637@localhost>
 <20110224152509.GA22513@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110224152509.GA22513@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan.kim@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, Sorin Faibish <sfaibish@emc.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Feb 24, 2011 at 11:25:09PM +0800, Wu Fengguang wrote:
> On Wed, Feb 23, 2011 at 11:13:22PM +0800, Wu Fengguang wrote:
> > > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6
> > 
> > As you can see from the graphs, the write bandwidth, the dirty
> > throttle bandwidths and the number of dirty pages are all fluctuating. 
> > Fluctuations are regular for as simple as dd workloads.
> > 
> > The current threshold based balance_dirty_pages() has the effect of
> > keeping the number of dirty pages close to the dirty threshold at most
> > time, at the cost of directly passing the underneath fluctuations to
> > the application. As a result, the dirtier tasks are swinging from
> > "dirty as fast as possible" and "full stop" states. The pause time
> > in current balance_dirty_pages() are measured to be random numbers
> > between 0 and hundreds of milliseconds for local ext4 filesystem and
> > more for NFS.
> > 
> > Obviously end users are much more sensitive to the fluctuating
> > latencies than the fluctuation of dirty pages. It makes much sense to
> > expand the current on/off dirty threshold to some kind of dirty range
> > control, absorbing the fluctuation of dirty throttle latencies by
> > allowing the dirty pages to raise or drop within an acceptable range
> > as the underlying IO completion rate fluctuates up or down.
> > 
> > The proposed scheme is to allow the dirty pages to float within range
> > (thresh - thresh/4, thresh), targeting the average pages at near
> > (thresh - thresh/8).
> > 
> > I observed that if keeping the dirty rate fixed at the theoretic
> > average bdi write bandwidth, the fluctuation of dirty pages are
> > bounded by (bdi write bandwidth * 1 second) for all major local
> > filesystems and simple dd workloads. So if the machine has adequately
> > large memory, it's in theory able to achieve flat write() progress.
> > 
> > I'm not able to get the perfect smoothness, however in some cases it's
> > close:
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G-60%25/btrfs-4dd-1M-8p-3911M-60%25-2.6.38-rc5-dt6+-2011-02-22-14-35/balance_dirty_pages-bandwidth.png
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G-60%25/xfs-4dd-1M-8p-3911M-60%25-2.6.38-rc5-dt6+-2011-02-22-11-17/balance_dirty_pages-bandwidth.png
> > 
> > In the bandwidth graph:
> > 
> >         write bandwidth - disk write bandwidth
> >           avg bandwidth - smoothed "write bandwidth"
> >          task bandwidth - task throttle bandwidth, the rate a dd task is allowed to dirty pages
> >          base bandwidth - base throttle bandwidth, a per-bdi base value for computing task throttle bandwidth
> > 
> > The "task throttle bandwidth" is what will directly impact individual dirtier
> > tasks. It's calculated from
> > 
> > (1) the base throttle bandwidth
> > 
> > (2) the level of dirty pages
> >     - if the number of dirty pages is equal to the control target
> >       (thresh - thresh / 8), then just use the base bandwidth
> >     - otherwise use higher/lower bandwidth to drive the dirty pages
> >       towards the target
> >     - ...omitting more rules in dirty_throttle_bandwidth()...
> > 
> > (3) the task's dirty weight
> >     a light dirtier has smaller weight and will be honored quadratic
> 
> Sorry it's not "quadratic", but sqrt().
> 
> >     larger throttle bandwidth
> > 
> > The base throttle bandwidth should be equal to average bdi write
> > bandwidth when there is one dd, and scaled down by 1/(N*sqrt(N)) when
> > there are N dd writing to 1 bdi in the system. In a realistic file
> > server, there will be N tasks at _different_ dirty rates, in which
> > case it's virtually impossible to track and calculate the right value.
> > 
> > So the base throttle bandwidth is by far the most important and
> > hardest part to control.  It's required to
> > 
> > - quickly adapt to the right value, otherwise the dirty pages will be
> >   hitting the top or bottom boundaries;
> > 
> > - and stay rock stable there for a stable workload, as its fluctuation
> >   will directly impact all tasks writing to that bdi
> > 
> > Looking at the graphs, I'm pleased to say the above requirements are
> > met in not only the memory bounty cases, but also the much harder low
> > memory and JBOD cases. It's achieved by the rigid update policies in
> > bdi_update_throttle_bandwidth().  [to be continued tomorrow]
> 
> The bdi base throttle bandwidth is updated based on three class of
> parameters.
> 
> (1) level of dirty pages
> 
> We try to avoid updating the base bandwidth whenever possible. The
> main update criteria are based on the level of dirty pages, when
> - the dirty pages are nearby the up or low control scope, or
> - the dirty pages are departing from the global/bdi dirty goals
> it's time to update the base bandwidth.
> 
> Because the dirty pages are fluctuating steadily, we try to avoid
> disturbing the base bandwidth when the smoothed number of dirty pages
> is within (write bandwidth / 8) distance to the goal, based on the
> fact that fluctuations are typically bounded by the write bandwidth.
> 
> (2) the position bandwidth
> 
> The position bandwidth is equal to the base bandwidth if the dirty
> number is equal to the dirty goal, and will be scaled up/down when
> the dirty pages grow larger than or drop below the goal.
> 
> When it's decided to update the base bandwidth, the delta between
> base bandwidth and position bandwidth will be calculated. The delta
> value will be scaled down at least 8 times, and the smaller delta
> value, the more it will be shrank. It's then added to the base
> bandwidth. In this way, the base bandwidth will adapt to the position
> bandwidth fast when there are large gaps, and remain stable when the
> gap is small enough. 
> 
> The delta is scaled down considerably because the position bandwidth
> is not very reliable. It fluctuates sharply when the dirty pages hit
> the up/low limits. And it takes time for the dirty pages to return to
> the goal even when the base bandwidth has be adjusted to the right
> value. So if tracking the position bandwidth closely, the base
> bandwidth could be overshot.
> 
> (3) the reference bandwidth
> 
> It's the theoretic base bandwidth! I take time to calculate it as a
> reference value of base bandwidth to eliminate the fast-convergence
> vs. steady-state-stability dilemma in pure position based control.
> It would be optimal control if used directly, however the reference
> bandwidth is not directly used as the base bandwidth because the
> numbers for calculating it are all fluctuating, and it's not
> acceptable for the base bandwidth to fluctuate in the plateau state.
> So the roughly-accurate calculated value is now used as a very useful
> double limit when updating the base bandwidth.

Update: I've managed to make the reference bandwidth smooth enough for
guiding the base bandwidth. This removes the adhoc dependency on the
position bandwidth.

Now it's clear that there are two core control algorithms that are
cooperative _and_ decoupled:

- the position bandwidth (proportional control)
- the base bandwidth     (derivative control)

I've finished with code commenting and more test coverage. The
combined patch and test results can be found in

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/

I'll split up and submit the patches.

Thanks,
Fengguang

> Now you should be able to understand the information rich
> balance_dirty_pages-pages.png graph. Here are two nice ones:
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G-60%25/btrfs-16dd-1M-8p-3927M-60%-2.6.38-rc6-dt6+-2011-02-24-23-14/balance_dirty_pages-pages.png
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/10HDD-JBOD-6G-6%25/xfs-1dd-1M-16p-5904M-6%25-2.6.38-rc5-dt6+-2011-02-21-20-00/balance_dirty_pages-pages.png
> 
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
