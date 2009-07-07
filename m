Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 55A976B0062
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 11:16:13 -0400 (EDT)
Date: Tue, 7 Jul 2009 11:17:20 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
Message-ID: <20090707151720.GA4159@think>
References: <4A4D26C5.9070606@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A4D26C5.9070606@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Eric Sandeen <sandeen@redhat.com>
Cc: xfs mailing list <xfs@oss.sgi.com>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 02, 2009 at 04:29:41PM -0500, Eric Sandeen wrote:
> Talking w/ someone who had a raid6 of 15 drives on an areca
> controller, he wondered why he could only get 300MB/s or so
> out of a streaming buffered write to xfs like so:
> 
> dd if=/dev/zero of=/mnt/storage/10gbfile bs=128k count=81920
> 10737418240 bytes (11 GB) copied, 34.294 s, 313 MB/s

I did some quick tests and found some unhappy things ;)  On my 5 drive
sata array (configured via LVM in a stripeset), dd with O_DIRECT to the
block device can stream writes at a healthy 550MB/s.

On 2.6.30, XFS does O_DIRECT at the exact same 550MB/s, and buffered
writes at 370MB/s.  Btrfs does a little better on buffered and a little
worse on O_DIRECT.  Ext4 splits the middle and does 400MB/s on both
buffered and O_DIRECT.

2.6.31-rc2 gave similar results.  One thing I noticed was that pdflush
and friends aren't using the right flag in congestion_wait after it was
updated to do congestion based on sync/async instead of read/write.  I'm
always happy when I get to blame bugs on Jens, but fixing the congestion
flag usage actually made the runs slower (he still promises to send a
patch for the congestion).

A little while ago, Jan Kara sent seekwatcher changes that let it graph
per-process info about IO submission, so I cooked up a graph of the IO
done by pdflush, dd, and others during an XFS buffered streaming write.

http://oss.oracle.com/~mason/seekwatcher/xfs-dd-2.6.30.png

The dark blue dots are dd doing writes and the light green dots are
pdflush.  The graph shows that pdflush spends almost the entire run
sitting around doing nothing, and sysrq-w shows all the pdflush threads
waiting around in congestion_wait.

Just to make sure the graphing wasn't hiding work done by pdflush, I
filtered out all the dd IO:

http://oss.oracle.com/~mason/seekwatcher/xfs-dd-2.6.30-filtered.png

With all of this in mind, I think the reason why the nr_to_write change
is helping is because dd is doing all the IO during balance_dirty_pages,
and the higher nr_to_write number is making sure that more IO goes out
at a time.

Once dd starts doing IO in balance_dirty_pages, our queues get
congested.  From that moment on, the bdi_congested checks in the
writeback path make pdflush sit down.  I doubt the queue every really
leaves congestion because we get over the dirty high water mark and dd
is jumping in and sending IO down the pipe without waiting for
congestion to clear.

sysrq-w supports this.  dd is always in get_request_wait and pdflush is
always in congestion_wait.

This bad interaction between pdflush and congestion was one of the
motivations for Jens' new writeback work, so I was really hoping to git
pull and post a fantastic new benchmark result.  With Jens' code the
graph ends up completely inverted, with roughly the same performance.

Instead of dd doing all the work, the flusher thread is doing all the
work (horray!) and dd is almost always in congestion_wait (boo).  I
think the cause is a little different, it seems that with Jens' code, dd
finds the flusher thread has the inode locked, and so
balance_dirty_pages doesn't find any work to do.  It waits on
congestion_wait().

If I replace the balance_dirty_pages() congestion_wait() with
schedule_timeout(1) in Jens' writeback branch, xfs buffered writes go
from 370MB/s to 520MB/s.  There are still some big peaks and valleys,
but it at least shows where we need to think harder about congestion
flags, IO waiting and other issues.

All of this is a long way of saying that until Jens' new code goes in,
(with additional tuning) the nr_to_write change makes sense to me.  I
don't see a 2.6.31 suitable way to tune things without his work.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
