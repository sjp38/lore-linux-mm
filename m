Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B7D8C8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 04:55:13 -0500 (EST)
Date: Tue, 1 Mar 2011 17:55:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: IO-less dirty throttling V6 results available
Message-ID: <20110301095508.GA637@localhost>
References: <20110222142543.GA13132@localhost>
 <20110223151322.GA13637@localhost>
 <20110224152509.GA22513@localhost>
 <20110224185632.GJ23042@quack.suse.cz>
 <20110225144412.GA19448@localhost>
 <20110228172211.GB20805@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110228172211.GB20805@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan.kim@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, Sorin Faibish <sfaibish@emc.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 01, 2011 at 01:22:11AM +0800, Jan Kara wrote:
> On Fri 25-02-11 22:44:12, Wu Fengguang wrote:
> > On Fri, Feb 25, 2011 at 02:56:32AM +0800, Jan Kara wrote:
> > > On Thu 24-02-11 23:25:09, Wu Fengguang wrote:

> > The tests are pretty time consuming. It will help to reuse test
> > scripts for saving time and for ease of comparison.
>   What my scripts gather is:
> global dirty pages & writeback pages (from /proc/meminfo)

Yeah I also wrote script to collect them, you can find
collect-vmstat.sh and plot-vmstat.sh in
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/scripts/

Later on I find them too coarse and did a trace event
global_dirty_state to export the information, together with
plot-global_dirty_state.sh to visualize it.  The trace event is
defined in this combined patch
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/dirty-throttling-v6-2.6.38-rc6.patch

> per-bdi dirty pages, writeback pages, threshold (from
> /proc/sys/kernel/debug/bdi/<bdi>/stats),

I exported the bdi dirty+writeback+unstable pages and thresh via the
balance_dirty_pages trace event, but didn't separate out the
dirty/writeback numbers.

> read and write throughput (from
> /sys/block/<dev>/stat)

That's collected by iostat and visulized by plot-iostat.sh

> Things specific to my patches are:
> estimated bdi throughput, time processes spend waiting in
> balance_dirty_pages().

balance_dirty_pages also traces the bdi write bandwidth and the
pause/paused time :)

> Then I plot two graphs per test. The first graph is showing number of dirty
> and writeback pages, dirty threshold, real current IO throuput and
> estimated throughput for each BDI. The second graph is showing how much (in
> %) each process waited in last 2s window.

My main plots are

bandwidth
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-8dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-18/balance_dirty_pages-bandwidth.png

dirty pages + bandwidth
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-8dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-18/balance_dirty_pages-pages.png

pause time + balance_dirty_pages() call interval
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-8dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-18/balance_dirty_pages-pause.png

> Thinking about it, all these parameters would make sense for your patches
> as well. So if we just agreed on the format of tracepoints for process
> entering and leaving balance_dirty_pages(), we could use same scripts for
> tracking and plotting the behavior. My two relevant tracepoints are:
> 
> TRACE_EVENT(writeback_balance_dirty_pages_waiting,
>        TP_PROTO(struct backing_dev_info *bdi, unsigned long pages),
>        TP_ARGS(bdi, pages),
>        TP_STRUCT__entry(
>                __array(char, name, 32)
>                __field(unsigned long, pages)
>        ),
>        TP_fast_assign(
>                strncpy(__entry->name, dev_name(bdi->dev), 32);
>                __entry->pages = pages;
>        ),
>        TP_printk("bdi=%s pages=%lu",
>                  __entry->name, __entry->pages
>        )
> );
> 
> TRACE_EVENT(writeback_balance_dirty_pages_woken,
>        TP_PROTO(struct backing_dev_info *bdi),
>        TP_ARGS(bdi),
>        TP_STRUCT__entry(
>                __array(char, name, 32)
>        ),
>        TP_fast_assign(
>                strncpy(__entry->name, dev_name(bdi->dev), 32);
>        ),
>        TP_printk("bdi=%s",
>                  __entry->name
>        )
> );
> 
> So I only have the 'pages' argument in
> writeback_balance_dirty_pages_waiting() which you maybe don't need (but
> you probably still have the number of pages dirtied before we got to
> balance_dirty_pages(), don't you?). In fact I don't currently use
> it for plotting (I just use it when inspecting the behavior in detail).

Yes, I records the dirtied pages passed to balance_dirty_pages() and
plot it in the balance_dirty_pages-pause.png (the y2 axis). The time
elapsed in balance_dirty_pages() is showed as pause/paused in the same
graph. "pause" means how much time each loop takes; "paused" is the
sum of all previous "pause" during the same balance_dirty_pages()
invocation.

> > > The question is how to compare results? Any idea? Obvious metrics are
> > > overall throughput and fairness for IO bound tasks. But then there are
> > 
> > I guess there will be little difference in throughput, as long as the
> > iostat output all have 100% disk util and full IO size.
>   Hopefully yes, unless we delay processes far too much...

Yeah.

> > As for faireness, I have the "ls-files" output for comparing the
> > file size created by each dd task. For example,
> > 
> > wfg ~/bee% cat xfs-4dd-1M-8p-970M-20%-2.6.38-rc6-dt6+-2011-02-25-21-55/ls-files
> > 131 -rw-r--r-- 1 root root 2783969280 Feb 25 21:58 /fs/sda7/zero-1
> > 132 -rw-r--r-- 1 root root 2772434944 Feb 25 21:58 /fs/sda7/zero-2
> > 133 -rw-r--r-- 1 root root 2733637632 Feb 25 21:58 /fs/sda7/zero-3
> > 134 -rw-r--r-- 1 root root 2735734784 Feb 25 21:58 /fs/sda7/zero-4
>   This works nicely for dd threads doing the same thing but for less
> trivial load it isn't that easy. I thought we could compare fairness by

You are right. For more dd's the file size is not accurate, because
the first started dd's will be able to dirty much more pages at full
CPU/memory bandwidth before entering the throttled region starting
from (dirty+background)/2.

> measuring time the process is throttled in balance_dirty_pages() in each
> time slot (where the length of a time slot is for discussion, I use 2s but
> that's just an arbitrary number not too big and not too small) and then
> this should relate to the relative dirtying rate of a thread. What do you

It's a reasonable approach. As I'm directly exporting each task's
throttle bandwidth together with the pause time in the
balance_dirty_pages trace event, it'll even be possible to calculate
the errors between the target task bandwidth and the task's real
bandwidth. But for the fairness, I write a simple plot script
plot-task-bw.sh to plot the progress of 3 tasks. The following results
show that the tasks are progressing at roughly the same rate
(indicated by equal slopes):

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1G/btrfs-8dd-1M-8p-970M-20%25-2.6.38-rc6-dt6+-2011-02-28-00-04/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1G/ext4_wb-8dd-1M-8p-970M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-45/balance_dirty_pages-task-bw.png

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-8dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-18/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/ext3-128dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-28-00-30/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/ext4-128dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-46/balance_dirty_pages-task-bw.png

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/10HDD-JBOD-16G/xfs-1dd-1M-24p-16013M-20%25-2.6.38-rc6-dt6+-2011-02-26-13-27/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/10HDD-JBOD-16G/ext4-10dd-1M-24p-16013M-20%25-2.6.38-rc6-dt6+-2011-02-26-15-01/balance_dirty_pages-task-bw.png


> think? Another interesting parameter might be max time spent waiting in
> balance_dirty_pages() - that would tell something about the latency induced
> by the algorithm.

You can visually see all abnormally long sleep time in balance_dirty_pages() 
in the balance_dirty_pages-pause.png graphs. In typical situations the
"paused" field will all be zero and the "pause" field will be under
200ms. Browsing through the graphs, I can hardly find one graph with
non-zero "paused" field -- the only exception is the low-memory case,
where fluctuations are inevitable given the small control scope,
however the "paused" field are still mostly under 200ms.

normal cases
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1G/btrfs-2dd-1M-8p-970M-20%25-2.6.38-rc6-dt6+-2011-02-28-10-11/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1G/xfs-1dd-1M-8p-970M-20%25-2.6.38-rc6-dt6+-2011-02-28-09-07/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1G/ext4-8dd-1M-8p-970M-20%25-2.6.38-rc6-dt6+-2011-02-28-09-39/balance_dirty_pages-pause.png

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-8dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-22/balance_dirty_pages-pause.png

low memory cases

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/256M/xfs-8dd-1M-8p-214M-20%25-2.6.38-rc6-dt6+-2011-02-26-23-07/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/256M/ext4-8dd-1M-8p-214M-20%25-2.6.38-rc6-dt6+-2011-02-26-23-29/balance_dirty_pages-pause.png

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/512M-2%25/btrfs-1dd-1M-8p-435M-2%25-2.6.38-rc5-dt6+-2011-02-22-14-56/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/512M-2%25/ext3-1dd-1M-8p-435M-2%25-2.6.38-rc6-dt6+-2011-02-22-15-11/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/512M-2%25/ext4-4dd-1M-8p-435M-2%25-2.6.38-rc5-dt6+-2011-02-22-14-49/balance_dirty_pages-pause.png

Note that the negative "pause" fields is normally caused by long sleep
time inside write_begin()/write_end().

> > > more subtle things like how the algorithm behaves for tasks that are not IO
> > > bound for most of the time (or do less IO). Any good metrics here? More
> > > things we could compare?
> > 
> > For non IO bound tasks, there are fio job files that do different
> > dirty rates.  I have not run them though, as the bandwidth based
> > algorithm obviously assigns higher bandwidth to light dirtiers :)
>   Yes :) But I'd be interested how our algorithms behave in such cases...

OK, will do more tests later.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
