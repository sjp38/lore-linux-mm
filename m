Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6773E8D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 09:44:28 -0500 (EST)
Date: Fri, 25 Feb 2011 22:44:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: IO-less dirty throttling V6 results available
Message-ID: <20110225144412.GA19448@localhost>
References: <20110222142543.GA13132@localhost>
 <20110223151322.GA13637@localhost>
 <20110224152509.GA22513@localhost>
 <20110224185632.GJ23042@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110224185632.GJ23042@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan.kim@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, Sorin Faibish <sfaibish@emc.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Feb 25, 2011 at 02:56:32AM +0800, Jan Kara wrote:
> On Thu 24-02-11 23:25:09, Wu Fengguang wrote:
> > The bdi base throttle bandwidth is updated based on three class of
> > parameters.
> > 
> > (1) level of dirty pages
> > 
> > We try to avoid updating the base bandwidth whenever possible. The
> > main update criteria are based on the level of dirty pages, when
> > - the dirty pages are nearby the up or low control scope, or
> > - the dirty pages are departing from the global/bdi dirty goals
> > it's time to update the base bandwidth.
> > 
> > Because the dirty pages are fluctuating steadily, we try to avoid
> > disturbing the base bandwidth when the smoothed number of dirty pages
> > is within (write bandwidth / 8) distance to the goal, based on the
> > fact that fluctuations are typically bounded by the write bandwidth.
> > 
> > (2) the position bandwidth
> > 
> > The position bandwidth is equal to the base bandwidth if the dirty
> > number is equal to the dirty goal, and will be scaled up/down when
> > the dirty pages grow larger than or drop below the goal.
> > 
> > When it's decided to update the base bandwidth, the delta between
> > base bandwidth and position bandwidth will be calculated. The delta
> > value will be scaled down at least 8 times, and the smaller delta
> > value, the more it will be shrank. It's then added to the base
> > bandwidth. In this way, the base bandwidth will adapt to the position
> > bandwidth fast when there are large gaps, and remain stable when the
> > gap is small enough. 
> > 
> > The delta is scaled down considerably because the position bandwidth
> > is not very reliable. It fluctuates sharply when the dirty pages hit
> > the up/low limits. And it takes time for the dirty pages to return to
> > the goal even when the base bandwidth has be adjusted to the right
> > value. So if tracking the position bandwidth closely, the base
> > bandwidth could be overshot.
> > 
> > (3) the reference bandwidth
> > 
> > It's the theoretic base bandwidth! I take time to calculate it as a
> > reference value of base bandwidth to eliminate the fast-convergence
> > vs. steady-state-stability dilemma in pure position based control.
> > It would be optimal control if used directly, however the reference
> > bandwidth is not directly used as the base bandwidth because the
> > numbers for calculating it are all fluctuating, and it's not
> > acceptable for the base bandwidth to fluctuate in the plateau state.
> > So the roughly-accurate calculated value is now used as a very useful
> > double limit when updating the base bandwidth.
> > 
> > Now you should be able to understand the information rich
> > balance_dirty_pages-pages.png graph. Here are two nice ones:
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G-60%25/btrfs-16dd-1M-8p-3927M-60%-2.6.38-rc6-dt6+-2011-02-24-23-14/balance_dirty_pages-pages.png
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/10HDD-JBOD-6G-6%25/xfs-1dd-1M-16p-5904M-6%25-2.6.38-rc5-dt6+-2011-02-21-20-00/balance_dirty_pages-pages.png
>   Thanks for the update on your patch series :). As you probably noted,
> I've created patches which implement IO-less balance_dirty_pages()
> differently so we have two implementations to compare (which is a good
> thing I believe). The question is how to do the comparison...

Yeah :)

> I have implemented comments, Peter had to my patches and I have finished
> scripts for gathering mm statistics and processing trace output and
> plotting them. Looking at your test scripts I can probably use some
> of your workloads as mine are currently simpler. Currently I have some
> simple dd tests running, I'll run something over NFS, SATA+USB and
> hopefully several SATA drives next week.

The tests are pretty time consuming. It will help to reuse test
scripts for saving time and for ease of comparison.

> The question is how to compare results? Any idea? Obvious metrics are
> overall throughput and fairness for IO bound tasks. But then there are

I guess there will be little difference in throughput, as long as the
iostat output all have 100% disk util and full IO size.

As for faireness, I have the "ls-files" output for comparing the
file size created by each dd task. For example,

wfg ~/bee% cat xfs-4dd-1M-8p-970M-20%-2.6.38-rc6-dt6+-2011-02-25-21-55/ls-files
131 -rw-r--r-- 1 root root 2783969280 Feb 25 21:58 /fs/sda7/zero-1
132 -rw-r--r-- 1 root root 2772434944 Feb 25 21:58 /fs/sda7/zero-2
133 -rw-r--r-- 1 root root 2733637632 Feb 25 21:58 /fs/sda7/zero-3
134 -rw-r--r-- 1 root root 2735734784 Feb 25 21:58 /fs/sda7/zero-4

> more subtle things like how the algorithm behaves for tasks that are not IO
> bound for most of the time (or do less IO). Any good metrics here? More
> things we could compare?

For non IO bound tasks, there are fio job files that do different
dirty rates.  I have not run them though, as the bandwidth based
algorithm obviously assigns higher bandwidth to light dirtiers :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
