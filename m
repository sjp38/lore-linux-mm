Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 256B36B0171
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 07:13:41 -0400 (EDT)
Date: Wed, 10 Aug 2011 19:13:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110810111334.GB27604@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.002914580@intel.com>
 <1312914906.1083.71.camel@twins>
 <20110810034012.GD24486@localhost>
 <1312971948.23660.8.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312971948.23660.8.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 10, 2011 at 06:25:48PM +0800, Peter Zijlstra wrote:
> On Wed, 2011-08-10 at 11:40 +0800, Wu Fengguang wrote:
> > On Wed, Aug 10, 2011 at 02:35:06AM +0800, Peter Zijlstra wrote:
> > > On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
> > > > 
> > > > Add two fields to task_struct.
> > > > 
> > > > 1) account dirtied pages in the individual tasks, for accuracy
> > > > 2) per-task balance_dirty_pages() call intervals, for flexibility
> > > > 
> > > > The balance_dirty_pages() call interval (ie. nr_dirtied_pause) will
> > > > scale near-sqrt to the safety gap between dirty pages and threshold.
> > > > 
> > > > XXX: The main problem of per-task nr_dirtied is, if 10k tasks start
> > > > dirtying pages at exactly the same time, each task will be assigned a
> > > > large initial nr_dirtied_pause, so that the dirty threshold will be
> > > > exceeded long before each task reached its nr_dirtied_pause and hence
> > > > call balance_dirty_pages(). 
> > > 
> > > Right, so why remove the per-cpu threshold? you can keep that as a bound
> > > on the number of out-standing dirty pages.
> > 
> > Right, I also have the vague feeling that the per-cpu threshold can
> > somehow backup the per-task threshold in case there are too many tasks.
> > 
> > > Loosing that bound is actually a bad thing (TM), since you could have
> > > configured a tight dirty limit and lock up your machine this way.
> > 
> > It seems good enough to only remove the 4MB upper limit for
> > ratelimit_pages, so that the per-cpu limit won't kick in too
> > frequently in typical machines.
> > 
> >   * Here we set ratelimit_pages to a level which ensures that when all CPUs are
> >   * dirtying in parallel, we cannot go more than 3% (1/32) over the dirty memory
> >   * thresholds before writeback cuts in.
> > - *
> > - * But the limit should not be set too high.  Because it also controls the
> > - * amount of memory which the balance_dirty_pages() caller has to write back.
> > - * If this is too large then the caller will block on the IO queue all the
> > - * time.  So limit it to four megabytes - the balance_dirty_pages() caller
> > - * will write six megabyte chunks, max.
> > - */
> > -
> >  void writeback_set_ratelimit(void)
> >  {
> >         ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
> >         if (ratelimit_pages < 16)
> >                 ratelimit_pages = 16;
> > -       if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
> > -               ratelimit_pages = (4096 * 1024) / PAGE_CACHE_SIZE;
> >  }
> 
> Uhm, so what's your bound then? 1/32 of the per-cpu memory seems rather
> a lot.

Ah yes, vm_total_pages is not longer suitable here, may use

        ratelimit_pages = dirty_threshold / (num_online_cpus() * 32);

We just need to ensure the dirty_threshold won't be exceeded too much
in the rare case tsk->nr_dirtied_pause cannot keep dirty pages under
control when there are >10k dirtier tasks.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
