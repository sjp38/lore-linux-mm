Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 48E2D8D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 10:13:42 -0500 (EST)
Date: Wed, 23 Feb 2011 23:13:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: IO-less dirty throttling V6 results available
Message-ID: <20110223151322.GA13637@localhost>
References: <20110222142543.GA13132@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110222142543.GA13132@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan.kim@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, Sorin Faibish <sfaibish@emc.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6

As you can see from the graphs, the write bandwidth, the dirty
throttle bandwidths and the number of dirty pages are all fluctuating. 
Fluctuations are regular for as simple as dd workloads.

The current threshold based balance_dirty_pages() has the effect of
keeping the number of dirty pages close to the dirty threshold at most
time, at the cost of directly passing the underneath fluctuations to
the application. As a result, the dirtier tasks are swinging from
"dirty as fast as possible" and "full stop" states. The pause time
in current balance_dirty_pages() are measured to be random numbers
between 0 and hundreds of milliseconds for local ext4 filesystem and
more for NFS.

Obviously end users are much more sensitive to the fluctuating
latencies than the fluctuation of dirty pages. It makes much sense to
expand the current on/off dirty threshold to some kind of dirty range
control, absorbing the fluctuation of dirty throttle latencies by
allowing the dirty pages to raise or drop within an acceptable range
as the underlying IO completion rate fluctuates up or down.

The proposed scheme is to allow the dirty pages to float within range
(thresh - thresh/4, thresh), targeting the average pages at near
(thresh - thresh/8).

I observed that if keeping the dirty rate fixed at the theoretic
average bdi write bandwidth, the fluctuation of dirty pages are
bounded by (bdi write bandwidth * 1 second) for all major local
filesystems and simple dd workloads. So if the machine has adequately
large memory, it's in theory able to achieve flat write() progress.

I'm not able to get the perfect smoothness, however in some cases it's
close:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G-60%25/btrfs-4dd-1M-8p-3911M-60%25-2.6.38-rc5-dt6+-2011-02-22-14-35/balance_dirty_pages-bandwidth.png

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G-60%25/xfs-4dd-1M-8p-3911M-60%25-2.6.38-rc5-dt6+-2011-02-22-11-17/balance_dirty_pages-bandwidth.png

In the bandwidth graph:

        write bandwidth - disk write bandwidth
          avg bandwidth - smoothed "write bandwidth"
         task bandwidth - task throttle bandwidth, the rate a dd task is allowed to dirty pages
         base bandwidth - base throttle bandwidth, a per-bdi base value for computing task throttle bandwidth

The "task throttle bandwidth" is what will directly impact individual dirtier
tasks. It's calculated from

(1) the base throttle bandwidth

(2) the level of dirty pages
    - if the number of dirty pages is equal to the control target
      (thresh - thresh / 8), then just use the base bandwidth
    - otherwise use higher/lower bandwidth to drive the dirty pages
      towards the target
    - ...omitting more rules in dirty_throttle_bandwidth()...

(3) the task's dirty weight
    a light dirtier has smaller weight and will be honored quadratic
    larger throttle bandwidth

The base throttle bandwidth should be equal to average bdi write
bandwidth when there is one dd, and scaled down by 1/(N*sqrt(N)) when
there are N dd writing to 1 bdi in the system. In a realistic file
server, there will be N tasks at _different_ dirty rates, in which
case it's virtually impossible to track and calculate the right value.

So the base throttle bandwidth is by far the most important and
hardest part to control.  It's required to

- quickly adapt to the right value, otherwise the dirty pages will be
  hitting the top or bottom boundaries;

- and stay rock stable there for a stable workload, as its fluctuation
  will directly impact all tasks writing to that bdi

Looking at the graphs, I'm pleased to say the above requirements are
met in not only the memory bounty cases, but also the much harder low
memory and JBOD cases. It's achieved by the rigid update policies in
bdi_update_throttle_bandwidth().  [to be continued tomorrow]

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
