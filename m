Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4DD6B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 17:57:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 189so764997pge.0
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 14:57:03 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id h61-v6si2910118pld.816.2018.02.11.14.57.00
        for <linux-mm@kvack.org>;
        Sun, 11 Feb 2018 14:57:01 -0800 (PST)
Date: Mon, 12 Feb 2018 09:56:57 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
Message-ID: <20180211225657.GA6778@dastard>
References: <1517337604.9211.13.camel@gmail.com>
 <20180131022209.lmhespbauhqtqrxg@destitution>
 <1517888875.7303.3.camel@gmail.com>
 <20180206060840.kj2u6jjmkuk3vie6@destitution>
 <CABXGCsOgcYyj8Xukn7Pi_M2qz2aJ1MJZTaxaSgYno7f_BtZH6w@mail.gmail.com>
 <1517974845.4352.8.camel@gmail.com>
 <20180207065520.66f6gocvxlnxmkyv@destitution>
 <1518255240.31843.6.camel@gmail.com>
 <1518255352.31843.8.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518255352.31843.8.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail <mikhail.v.gavrilov@gmail.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Feb 10, 2018 at 02:35:52PM +0500, mikhail wrote:
> On Sat, 2018-02-10 at 14:34 +0500, mikhail wrote:
> > 
> > This is happens because in manual
> > http://xfs.org/index.php/XFS_FAQ#Q:_What_information_should_I_include_when_reporting_a_problem.3F
> > was proposed first enter "# echo w > /proc/sysrq-trigger" and then "trace-cmd record -e xfs\*"
> > And first waiting on a lock always registered after entering "# echo w > /proc/sysrq-trigger" command.
> > Would be more correct if first was proposed to type "trace-cmd record -e xfs \ *", and then "# echo w> / proc / sysrq-
> > trigger".

Yes, but you still haven't provided me with all the other info that
this link asks for. Namely:

kernel version (uname -a)
xfsprogs version (xfs_repair -V)
number of CPUs
contents of /proc/meminfo
contents of /proc/mounts
contents of /proc/partitions
RAID layout (hardware and/or software)
LVM configuration
type of disks you are using
write cache status of drives
size of BBWC and mode it is running in
xfs_info output on the filesystem in question

And:

"Then you need to describe your workload that is causing the
problem, ..."

Without any idea of what you are actually doing and what storage you
are doing that work on, I have no idea what the expected behaviour
should be. All I can tell is you have something with disk caches and
io pools on your desktop machine and it's slow....

> > The result is a new trace in which is nothing missed:
> > https://dumps.sy24.ru/5/trace_report.txt.bz2 (278 MB)
> > 
> > 
> 
> Forgot to attach dmesg

It's the same thing.

If I look at 


> [  861.288279] INFO: task disk_cache:0:8665 blocked for more than 120 seconds.
> [  861.288283]       Not tainted 4.15.0-rc4-amd-vega+ #13
> [  861.288287] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  861.288290] disk_cache:0    D12480  8665   8656 0x00000000
> [  861.288297] Call Trace:
> [  861.288304]  __schedule+0x2dc/0xba0
> [  861.288314]  ? wait_for_completion+0x10e/0x1a0
> [  861.288318]  schedule+0x33/0x90
> [  861.288322]  schedule_timeout+0x25a/0x5b0
> [  861.288329]  ? mark_held_locks+0x5f/0x90
> [  861.288332]  ? _raw_spin_unlock_irq+0x2c/0x40
> [  861.288336]  ? wait_for_completion+0x10e/0x1a0
> [  861.288340]  ? trace_hardirqs_on_caller+0xf4/0x190
> [  861.288346]  ? wait_for_completion+0x10e/0x1a0
> [  861.288350]  wait_for_completion+0x136/0x1a0
> [  861.288355]  ? wake_up_q+0x80/0x80
> [  861.288387]  ? _xfs_buf_read+0x23/0x30 [xfs]
> [  861.288427]  xfs_buf_submit_wait+0xb2/0x530 [xfs]
> [  861.288457]  _xfs_buf_read+0x23/0x30 [xfs]
> [  861.288483]  xfs_buf_read_map+0x14b/0x300 [xfs]
> [  861.288514]  ? xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  861.288547]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  861.288577]  xfs_imap_to_bp+0x67/0xe0 [xfs]
> [  861.288613]  xfs_iunlink_remove+0x231/0x370 [xfs]
> [  861.288617]  ? trace_event_buffer_commit+0x7c/0x1d0
> [  861.288626]  ? __lock_is_held+0x65/0xb0
> [  861.288658]  xfs_ifree+0x47/0x150 [xfs]
> [  861.288690]  xfs_inactive_ifree+0xc0/0x220 [xfs]
> [  861.288726]  xfs_inactive+0x7b/0x110 [xfs]
> [  861.288757]  xfs_fs_destroy_inode+0xbb/0x2d0 [xfs]
> [  861.288764]  destroy_inode+0x3b/0x60

Ok, once and for all: this is not an XFS problem.

The trace from task 8665, which is the one that triggered above
waiting for IO. task -395 is an IO completion worker in XFS that
is triggered by the lower layer IO completion callbacks, and it's
running regularly and doing lots of IO completion work every few
milliseconds.

<...>-8665  [007]   627.332389: xfs_buf_submit_wait:  dev 8:16 bno 0xe96a4040 nblks 0x20 hold 1 pincount 0 lock 0 flags READ|PAGES caller _xfs_buf_read
<...>-8665  [007]   627.332390: xfs_buf_hold:         dev 8:16 bno 0xe96a4040 nblks 0x20 hold 1 pincount 0 lock 0 flags READ|PAGES caller xfs_buf_submit_wait
<...>-8665  [007]   627.332416: xfs_buf_iowait:       dev 8:16 bno 0xe96a4040 nblks 0x20 hold 2 pincount 0 lock 0 flags READ|PAGES caller _xfs_buf_read
<...>-395   [000]   875.682080: xfs_buf_iodone:       dev 8:16 bno 0xe96a4040 nblks 0x20 hold 2 pincount 0 lock 0 flags READ|PAGES caller xfs_buf_ioend_work
<...>-8665  [007]   875.682105: xfs_buf_iowait_done:  dev 8:16 bno 0xe96a4040 nblks 0x20 hold 2 pincount 0 lock 0 flags DONE|PAGES caller _xfs_buf_read
<...>-8665  [007]   875.682107: xfs_buf_rele:         dev 8:16 bno 0xe96a4040 nblks 0x20 hold 2 pincount 0 lock 0 flags DONE|PAGES caller xfs_buf_submit_wait

IOWs, that IO completion took close on 250s for it to be signalled
to XFS, and so these delays have nothing to do with XFS.

What is clear from the trace is that you are overloading your IO
subsystem. I see average synchronous read times of 40-50ms which
implies a constant and heavy load on the underlying storage. In
the ~1400s trace I see:

$ grep "submit:\|submit_wait:" trace_report.txt |wc -l
133427
$

~130k metadata IO submissions.

$ grep "writepage:" trace_report.txt |wc -l
1662764
$

There was also over 6GB of data written, and:

$ grep "readpages:" trace_report.txt |wc -l
85866
$

About 85000 data read IOs were issued.

A typical SATA drive can sustain ~150 IOPS. I count from the trace
at least 220,000 IOs in ~1400s, which is pretty much spot on an
average of 150 IOPS. IOWs, your system is running at the speed of
you disk and it's clear that it's completely overloaded at times
leading to large submission backlog queues and excessively long IO
times.

IOWs, this is not an XFS problem. It's exactly what I'd expect to
see when you try to run a very IO intensive workload on a cheap SATA
drive that can't keep up with what is being asked of it....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
