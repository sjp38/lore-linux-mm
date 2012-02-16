Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7FCD66B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 23:10:26 -0500 (EST)
Date: Thu, 16 Feb 2012 12:00:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120216040019.GB17597@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <4F36816A.6030609@redhat.com>
 <20120212031029.GA17435@localhost>
 <20120213154313.GD6478@quack.suse.cz>
 <20120214100348.GA7000@localhost>
 <20120214132950.GE1934@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120214132950.GE1934@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Tue, Feb 14, 2012 at 02:29:50PM +0100, Jan Kara wrote:

> > >   I wonder what happens if you run:
> > >        mkdir /cgroup/x
> > >        echo 100M > /cgroup/x/memory.limit_in_bytes
> > >        echo $$ > /cgroup/x/tasks
> > > 
> > >        for (( i = 0; i < 2; i++ )); do
> > >          mkdir /fs/d$i
> > >          for (( j = 0; j < 5000; j++ )); do 
> > >            dd if=/dev/zero of=/fs/d$i/f$j bs=1k count=50
> > >          done &
> > >        done
> > 
> > That's a very good case, thanks!
> >  
> > >   Because for small files the writearound logic won't help much...
> > 
> > Right, it also means the native background work cannot be more I/O
> > efficient than the pageout works, except for the overheads of more
> > work items..
>   Yes, that's true.
> 
> > >   Also the number of work items queued might become interesting.
> > 
> > It turns out that the 1024 mempool reservations are not exhausted at
> > all (the below patch as a trace_printk on alloc failure and it didn't
> > trigger at all).
> > 
> > Here is the representative iostat lines on XFS (full "iostat -kx 1 20" log attached):
> > 
> > avg-cpu:  %user   %nice %system %iowait  %steal   %idle                                                                     
> >            0.80    0.00    6.03    0.03    0.00   93.14                                                                     
> >                                                                                                                             
> > Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util                   
> > sda               0.00   205.00    0.00  163.00     0.00 16900.00   207.36     4.09   21.63   1.88  30.70                   
> > 
> > The attached dirtied/written progress graph looks interesting.
> > Although the iostat disk utilization is low, the "dirtied" progress
> > line is pretty straight and there is no single congestion_wait event
> > in the trace log. Which makes me wonder if there are some unknown
> > blocking issues in the way.
>   Interesting. I'd also expect we should block in reclaim path. How fast
> can dd threads progress when there is no cgroup involved?

I tried running the dd tasks in global context with

        echo $((100<<20)) > /proc/sys/vm/dirty_bytes

and got mostly the same results on XFS:

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.85    0.00    8.88    0.00    0.00   90.26

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00   50.00     0.00 23036.00   921.44     9.59  738.02   7.38  36.90

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.95    0.00    8.95    0.00    0.00   90.11

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00   854.00    0.00   99.00     0.00 19552.00   394.99    34.14   87.98   3.82  37.80

Interestingly, ext4 shows comparable throughput, however is reporting
near 100% disk utilization:

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.76    0.00    9.02    0.00    0.00   90.23

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00  317.00     0.00 20956.00   132.21    28.57   82.71   3.16 100.10

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.82    0.00    8.95    0.00    0.00   90.23

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00  402.00     0.00 24388.00   121.33    21.09   58.55   2.42  97.40

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.82    0.00    8.99    0.00    0.00   90.19

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00  409.00     0.00 21996.00   107.56    15.25   36.74   2.30  94.10

And btrfs shows

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.76    0.00   23.59    0.00    0.00   75.65

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00   801.00    0.00  141.00     0.00 48984.00   694.81    41.08  291.36   6.11  86.20

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.72    0.00   12.65    0.00    0.00   86.62

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00   792.00    0.00   69.00     0.00 15288.00   443.13    22.74   69.35   4.09  28.20

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.83    0.00   23.11    0.00    0.00   76.06

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00   73.00     0.00 33280.00   911.78    22.09  548.58   8.10  59.10

> > > Another common case to test - run 'slapadd' command in each cgroup to
> > > create big LDAP database. That does pretty much random IO on a big mmaped
> > > DB file.
> > 
> > I've not used this. Will it need some configuration and data feed?
> > fio looks more handy to me for emulating mmap random IO.
>   Yes, fio can generate random mmap IO. It's just that this is a real life
> workload. So it is not completely random, it happens on several files and
> is also interleaved with other memory allocations from DB. I can send you
> the config files and data feed if you are interested.

I'm very interested, thank you!

> > > > +/*
> > > > + * schedule writeback on a range of inode pages.
> > > > + */
> > > > +static struct wb_writeback_work *
> > > > +bdi_flush_inode_range(struct backing_dev_info *bdi,
> > > > +		      struct inode *inode,
> > > > +		      pgoff_t offset,
> > > > +		      pgoff_t len,
> > > > +		      bool wait)
> > > > +{
> > > > +	struct wb_writeback_work *work;
> > > > +
> > > > +	if (!igrab(inode))
> > > > +		return ERR_PTR(-ENOENT);
> > >   One technical note here: If the inode is deleted while it is queued, this
> > > reference will keep it living until flusher thread gets to it. Then when
> > > flusher thread puts its reference, the inode will get deleted in flusher
> > > thread context. I don't see an immediate problem in that but it might be
> > > surprising sometimes. Another problem I see is that if you try to
> > > unmount the filesystem while the work item is queued, you'll get EBUSY for
> > > no apparent reason (for userspace).
> > 
> > Yeah, we need to make umount work.
>   The positive thing is that if the inode is reaped while the work item is
> queue, we know all that needed to be done is done. So we don't really need
> to pin the inode.

But I do need to make sure the *inode pointer does not point to some
invalid memory at work exec time. Is this possible without raising
->i_count?

> > And I find the pageout works seem to have some problems with ext4.
> > For example, this can be easily triggered with 10 dd tasks running
> > inside the 100MB limited memcg:
>   So journal thread is getting stuck while committing transaction. Most
> likely waiting for some dd thread to stop a transaction so that commit can
> proceed. The processes waiting in start_this_handle() are just secondary
> effect resulting from the first problem. It might be interesting to get
> stack traces of all bloked processes when the journal thread is stuck.

For completeness of discussion, citing your conclusion on my private
data feed:

: We enter memcg reclaim from grab_cache_page_write_begin() and are
: waiting in congestion_wait(). Because grab_cache_page_write_begin() is
: called with transaction started, this blocks transaction from
: committing and subsequently blocks all other activity on the
: filesystem. The fact is this isn't new with your patches, just your
: changes or the fact that we are running in a memory constrained cgroup
: make this more visible.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
