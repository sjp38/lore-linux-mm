Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 35F106B0012
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 22:42:25 -0400 (EDT)
Date: Sat, 2 Jul 2011 12:42:19 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
 clustering
Message-ID: <20110702024219.GT561@dastard>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701145935.GB29530@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110701145935.GB29530@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, xfs@oss.sgi.com, jack@suse.cz, linux-mm@kvack.org

On Fri, Jul 01, 2011 at 03:59:35PM +0100, Mel Gorman wrote:
> On Fri, Jul 01, 2011 at 05:33:05AM -0400, Christoph Hellwig wrote:
> > Johannes, Mel, Wu,
> 
> Am adding Jan Kara as he has been working on writeback efficiency
> recently as well.

Writeback looks to be working fine - it's kswapd screwing up the
writeback patterns that appears to be the problem....

> > Dave has been stressing some XFS patches of mine that remove the XFS
> > internal writeback clustering in favour of using write_cache_pages.
> 
> Against what kernel? 2.6.38 was a disaster for reclaim I've been
> finding out this week. I don't know about 2.6.38.8. 2.6.39 was better.

3.0-rc4

....
> The number of pages written from reclaim is exceptionally low (2.6.38
> was a total disaster but that release was bad for a number of reasons,
> haven't tested 2.6.38.8 yet) but reduced by 2.6.37 as expected. Direct
> reclaim usage was reduced and efficiency (ratio of pages scanned to
> pages reclaimed) was high.

And is that consistent across ext3/ext4/xfs/btrfs filesystems? I
doubt it very much, as all have very different .writepage
behaviours...

BTW, called a workload "fsmark" tells us nothing about the workload
being tested - fsmark can do a lot of interesting things. IOWs, you
need to quote the command line for it to be meaningful to anyone...

> As I look through the results I have at the moment, the number of
> pages written back was simply really low which is why the problem fell
> off my radar.

It doesn't take many to completely screw up writeback IO patterns.
Write a few random pages to a 10MB file well before writeback would
get to the file, and instead of getting optimal sequential writeback
patterns when writeback gets to it, we get multiple disjoint IOs
that require multiple seeks to complete.

Slower, less efficient writeback IO causes memory pressure to last
longer and hence more likely to result in kswapd writeback, and it's
just a downward spiral from there....

> > > That means the test is only using 1GB of disk space, and
> > > I'm running on a VM with 1GB RAM. It appears to be related to the VM
> > > triggering random page writeback from the LRU - 100x10MB files more
> > > than fills memory, hence it being the smallest test case i could
> > > reproduce the problem on.
> > > 
> 
> My tests were on a machine with 8G and ext3. I'm running some of
> the tests against ext4 and xfs to see if that makes a difference but
> it's possible the tests are simply not agressive enough so I want to
> reproduce Dave's test if possible.

To tell the truth, I don't think anyone really cares how ext3
performs these days. XFS seems to be the filesystem that brings out
all the bad behaviour in the mm subsystem....

FWIW, the mm subsystem works well enough when there is RAM
available, so I'd suggest that your reclaim testing needs to focus
on smaller memory configurations to really stress the reclaim
algorithms. That's one of the reason why I regularly test on 1GB, 1p
machines - they show problems that are hard to repa??oduce on larger
configs....

> I'm assuming "test 180" is from xfstests which was not one of the tests
> I used previously. To run with 1000 files instead of 100, was the file
> "180" simply editted to make it look like this loop instead?

I reduced it to 100 files simply to speed up the testing process for
the "bad file size" problem I was trying to find. If you want to
reproduce the IO collapse in a big way, run it with 1000 files, and
it happens about 2/3rds of the way through the test on my hardware.

> > > It is very clear that from the IO completions that we are getting a
> > > *lot* of kswapd driven writeback directly through .writepage:
> > > 
> > > $ grep "xfs_setfilesize:" t.t |grep "4096$" | wc -l
> > > 801
> > > $ grep "xfs_setfilesize:" t.t |grep -v "4096$" | wc -l
> > > 78
> > > 
> > > So there's ~900 IO completions that change the file size, and 90% of
> > > them are single page updates.
> > > 
> > > $ ps -ef |grep [k]swap
> > > root       514     2  0 12:43 ?        00:00:00 [kswapd0]
> > > $ grep "writepage:" t.t | grep "514 " |wc -l
> > > 799
> > > 
> > > Oh, now that is too close to just be a co-incidence. We're getting
> > > significant amounts of random page writeback from the the ends of
> > > the LRUs done by the VM.
> > > 
> > > <sigh>
> 
> Does the value for nr_vmscan_write in /proc/vmstat correlate? It must
> but lets me sure because I'm using that figure rather than ftrace to
> count writebacks at the moment.

The number in /proc/vmstat is higher. Much higher.  I just ran the
test at 1000 files (only collapsed to ~3000 iops this time because I
ran it on a plain 3.0-rc4 kernel that still has the .writepage
clustering in XFS), and I see:

nr_vmscan_write 6723

after the test. The event trace only capture ~1400 writepage events
from kswapd, but it tends to miss a lot of events as the system is
quite unresponsive at times under this workload - it's not uncommon
to have ssh sessions not echo a character for 10s... e.g: I started
the workload ~11:08:22:

$ while [ 1 ]; do date; sleep 1; done
Sat Jul  2 11:08:15 EST 2011
Sat Jul  2 11:08:16 EST 2011
Sat Jul  2 11:08:17 EST 2011
Sat Jul  2 11:08:18 EST 2011
Sat Jul  2 11:08:19 EST 2011
Sat Jul  2 11:08:20 EST 2011
Sat Jul  2 11:08:21 EST 2011
Sat Jul  2 11:08:22 EST 2011         <<<<<<<< start test here
Sat Jul  2 11:08:23 EST 2011
Sat Jul  2 11:08:24 EST 2011
Sat Jul  2 11:08:25 EST 2011
Sat Jul  2 11:08:26 EST 2011         <<<<<<<<
Sat Jul  2 11:08:27 EST 2011         <<<<<<<<
Sat Jul  2 11:08:30 EST 2011         <<<<<<<<
Sat Jul  2 11:08:35 EST 2011         <<<<<<<<
Sat Jul  2 11:08:36 EST 2011
Sat Jul  2 11:08:37 EST 2011
Sat Jul  2 11:08:38 EST 2011         <<<<<<<<
Sat Jul  2 11:08:40 EST 2011         <<<<<<<<
Sat Jul  2 11:08:41 EST 2011
Sat Jul  2 11:08:42 EST 2011
Sat Jul  2 11:08:43 EST 2011

And there are quite a few more multi-second holdoffs during the
test, too.

> A more relevant question is this -
> how many pages were reclaimed by kswapd and what percentage is 799
> pages of that? What do you consider an acceptable percentage?

I don't care what the percentage is or what the number is. kswapd is
reclaiming pages most of the time without affect IO patterns, and
when that happens I just don't care because it is working just fine.

What I care about is what kswapd is doing when it finds dirty pages
and it decides they need to be written back. It's not a problem that
they are found or need to be written, the problem is the utterly
crap way that memory reclaim is throwing the pages at the filesystem.

I'm not sure how to get through to you guys that single, random page
writeback is *BAD*. Using .writepage directly is considered harmful
to IO throughput, and memory reclaim needs to stop doing that.
We've got hacks in the filesystems to try to make the IO memory
reclaim executes suck less, but ultimately the problem is the IO
memory reclaim is doing. And now the memory reclaim IO patterns are
getting in the way of further improving the writeback path in XFS
because were finding the hacks we've been carrying for years are
*still* the only thing that is making IO under memory pressure not
suck completely.

What I find extremely frustrating is that this is not a new issue.
We (filesystem people) have been asking for a long time to have the
memory reclaim subsystem either defer IO to the writeback threads or
to use the .writepages interface. We're not asking this to be
difficult, we're asking for this so that we can cluster IO in an
optimal manner to avoid these IO collapses that memory reclaim
currently triggers.  We now have generic methods of handing off IO
to flusher threads that also provide some level of throttling/
blocking while IO is submitted (e.g.  writeback_inodes_sb_nr()), so
this shouldn't be a difficult problem to solve for the memory
reclaim subsystem.

Hell, maybe memory reclaim should take a leaf from the IO-less
throttle work we are doing - hit a bunch of dirty pages on the LRU,
just back off and let the writeback subsystem clean a few more pages
before starting another scan.  Letting the writeback code clean
pages is the fastest way to get pages cleaned in the system, so if
we've already got a generic method for cleaning and/or waiting for
pages to be cleaned, why not aim to use that?

And while I'm ranting, when on earth is the issue-writeback-from-
direct-reclaim problem going to be fixed so we can remove the hacks
in the filesystem .writepage implementations to prevent this from
occurring?

I mean, when we combine the two issues, doesn't it imply that the
memory reclaim subsystem needs to be redesigned around the fact it
*can't clean pages directly*?  This IO collapse issue shows that we
really don't 't want kswapd issuing IO directly via .writepage, and
we already reject IO from direct reclaim in .writepage in ext4, XFS
and BTRFS because we'll overrun the stack on anything other than
trivial storage configurations.

That says to me in a big, flashing bright pink neon sign way that
memory reclaim simply should not be issuing IO at all. Perhaps it's
time to rethink the way memory reclaim deals with dirty pages to
take into account the current reality?

</rant>

> > On Fri, Jul 01, 2011 at 07:20:21PM +1000, Dave Chinner wrote:
> > > > Looks good.  I still wonder why I haven't been able to hit this.
> > > > Haven't seen any 180 failure for a long time, with both 4k and 512 byte
> > > > filesystems and since yesterday 1k as well.
> > > 
> > > It requires the test to run the VM out of RAM and then force enough
> > > memory pressure for kswapd to start writeback from the LRU. The
> > > reproducer I have is a 1p, 1GB RAM VM with it's disk image on a
> > > 100MB/s HW RAID1 w/ 512MB BBWC disk subsystem.
> > > 
> 
> You say it's a 1G VM but you don't say what architecure.

x86-64 for both the guest and the host.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
