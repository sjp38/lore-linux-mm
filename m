Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F5A36B0055
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 00:02:45 -0400 (EDT)
Date: Sat, 1 Aug 2009 12:03:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090801040313.GB13291@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com> <20090730213956.GH12579@kernel.dk> <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com> <20090730221727.GI12579@kernel.dk> <33307c790907301534v64c08f59o66fbdfbd3174ff5f@mail.gmail.com> <20090730224308.GJ12579@kernel.dk> <33307c790907301548t2ef1bb72k4adbe81865d2bde9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33307c790907301548t2ef1bb72k4adbe81865d2bde9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Martin Bligh <mbligh@google.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Rubin <mrubin@google.com>, sandeen@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 30, 2009 at 03:48:02PM -0700, Martin Bligh wrote:
> On Thu, Jul 30, 2009 at 3:43 PM, Jens Axboe<jens.axboe@oracle.com> wrote:
> > On Thu, Jul 30 2009, Martin Bligh wrote:
> >> > The test case above on a 4G machine is only generating 1G of dirty data.
> >> > I ran the same test case on the 16G, resulting in only background
> >> > writeout. The relevant bit here being that the background writeout
> >> > finished quickly, writing at disk speed.
> >> >
> >> > I re-ran the same test, but using 300 100MB files instead. While the
> >> > dd's are running, we are going at ~80MB/sec (this is disk speed, it's an
> >> > x25-m). When the dd's are done, it continues doing 80MB/sec for 10
> >> > seconds or so. Then the remainder (about 2G) is written in bursts at
> >> > disk speeds, but with some time in between.
> >>
> >> OK, I think the test case is sensitive to how many files you have - if
> >> we punt them to the back of the list, and yet we still have 299 other
> >> ones, it may well be able to keep the disk spinning despite the bug
> >> I outlined.Try using 30 1GB files?
> >
> > If this disk starts spinning, then we have bigger bugs :-)
> >>
> >> Though it doesn't seem to happen with just one dd streamer, and
> >> I don't see why the bug doesn't trigger in that case either.
> >>
> >> I believe the bugfix is correct independent of any bdi changes?
> >
> > Yeah I think so too, I'll run some more tests on this tomorrow and
> > verify it there as well.
> 
> There's another issue I was discussing with Peter Z. earlier that the
> bdi changes might help with - if you look at where the dirty pages
> get to, they are capped hard at the average of the dirty and
> background thresholds, meaning we can only dirty about half the
> pages we should be able to. That does very slowly go away when
> the bdi limit catches up, but it seems to start at 0, and it's progess
> seems glacially slow (at least if you're impatient ;-))

You mean the dirty limit will start from
(dirty_ratio+background_ratio)/2 = 15% to (dirty_ratio) = 20%,
and grow in a very slow pace? I did observed such curves long ago,
but it does not always show up, as in the below mini bench.

> This seems to affect some of our workloads badly when they have
> a sharp spike in dirty data to one device, they get throttled heavily
> when they wouldn't have before the per-bdi dirty limits.

Here is a single dd on my laptop with 4G memory, kernel 2.6.30.

        root /home/wfg# echo 10 > /proc/sys/vm/dirty_ratio                 
        root /home/wfg# echo 20 > /proc/sys/vm/dirty_background_ratio 

        wfg ~% dd if=/dev/zero of=/opt/vm/10G bs=1M count=1000  
        1000+0 records in
        1000+0 records out
        1048576000 bytes (1.0 GB) copied, 12.7143 s, 82.5 MB/s

output of vmmon:

         nr_dirty     nr_writeback
                0                0
                0                0
            56795                0
            51655            17020
            52071            17511
            51648            16898
            51655            16485
            52369            17425
            51648            16930
            51470            16809
            52630            17267
            51287            16634
            51260            16641
            51310            16903
            51281            16379
            46073            11169
            46086                0
            46089                0
             3132             9657
               21            17677
                3            14107
               14                2
                0                0
                0                0

In this case nr_dirty stays almost constant.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
