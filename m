Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1FBDC6B004D
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 00:53:11 -0400 (EDT)
Date: Sat, 1 Aug 2009 12:53:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090801045345.GA16011@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com> <20090730213956.GH12579@kernel.dk> <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com> <20090730221727.GI12579@kernel.dk> <33307c790907301534v64c08f59o66fbdfbd3174ff5f@mail.gmail.com> <20090730224308.GJ12579@kernel.dk> <33307c790907301548t2ef1bb72k4adbe81865d2bde9@mail.gmail.com> <20090801040313.GB13291@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090801040313.GB13291@localhost>
Sender: owner-linux-mm@kvack.org
To: Martin Bligh <mbligh@google.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Rubin <mrubin@google.com>, sandeen@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 01, 2009 at 12:03:13PM +0800, Wu Fengguang wrote:
> On Thu, Jul 30, 2009 at 03:48:02PM -0700, Martin Bligh wrote:
> > On Thu, Jul 30, 2009 at 3:43 PM, Jens Axboe<jens.axboe@oracle.com> wrote:
> > > On Thu, Jul 30 2009, Martin Bligh wrote:
> > >> > The test case above on a 4G machine is only generating 1G of dirty data.
> > >> > I ran the same test case on the 16G, resulting in only background
> > >> > writeout. The relevant bit here being that the background writeout
> > >> > finished quickly, writing at disk speed.
> > >> >
> > >> > I re-ran the same test, but using 300 100MB files instead. While the
> > >> > dd's are running, we are going at ~80MB/sec (this is disk speed, it's an
> > >> > x25-m). When the dd's are done, it continues doing 80MB/sec for 10
> > >> > seconds or so. Then the remainder (about 2G) is written in bursts at
> > >> > disk speeds, but with some time in between.
> > >>
> > >> OK, I think the test case is sensitive to how many files you have - if
> > >> we punt them to the back of the list, and yet we still have 299 other
> > >> ones, it may well be able to keep the disk spinning despite the bug
> > >> I outlined.Try using 30 1GB files?
> > >
> > > If this disk starts spinning, then we have bigger bugs :-)
> > >>
> > >> Though it doesn't seem to happen with just one dd streamer, and
> > >> I don't see why the bug doesn't trigger in that case either.
> > >>
> > >> I believe the bugfix is correct independent of any bdi changes?
> > >
> > > Yeah I think so too, I'll run some more tests on this tomorrow and
> > > verify it there as well.
> > 
> > There's another issue I was discussing with Peter Z. earlier that the
> > bdi changes might help with - if you look at where the dirty pages
> > get to, they are capped hard at the average of the dirty and
> > background thresholds, meaning we can only dirty about half the
> > pages we should be able to. That does very slowly go away when
> > the bdi limit catches up, but it seems to start at 0, and it's progess
> > seems glacially slow (at least if you're impatient ;-))
> 
> You mean the dirty limit will start from
> (dirty_ratio+background_ratio)/2 = 15% to (dirty_ratio) = 20%,
> and grow in a very slow pace? I did observed such curves long ago,
> but it does not always show up, as in the below mini bench.
> 
> > This seems to affect some of our workloads badly when they have
> > a sharp spike in dirty data to one device, they get throttled heavily
> > when they wouldn't have before the per-bdi dirty limits.
> 
> Here is a single dd on my laptop with 4G memory, kernel 2.6.30.
> 
>         root /home/wfg# echo 10 > /proc/sys/vm/dirty_ratio                 
>         root /home/wfg# echo 20 > /proc/sys/vm/dirty_background_ratio 
> 
>         wfg ~% dd if=/dev/zero of=/opt/vm/10G bs=1M count=1000  
>         1000+0 records in
>         1000+0 records out
>         1048576000 bytes (1.0 GB) copied, 12.7143 s, 82.5 MB/s
> 
> output of vmmon:
> 
>          nr_dirty     nr_writeback
>                 0                0
>                 0                0
>             56795                0
>             51655            17020
>             52071            17511
>             51648            16898
>             51655            16485
>             52369            17425
>             51648            16930
>             51470            16809
>             52630            17267
>             51287            16634
>             51260            16641
>             51310            16903
>             51281            16379
>             46073            11169
>             46086                0
>             46089                0
>              3132             9657
>                21            17677
>                 3            14107
>                14                2
>                 0                0
>                 0                0
> 
> In this case nr_dirty stays almost constant.

I can see the growth when I increased the dd size to 2GB,
and the dd throughput decreased from 82.5MB/s to 60.9MB/s.

        wfg ~% dd if=/dev/zero of=/opt/vm/10G bs=1M count=2000
        2000+0 records in
        2000+0 records out
        2097152000 bytes (2.1 GB) copied, 34.4114 s, 60.9 MB/s

         nr_dirty     nr_writeback
                0                0
            44980                0
            49929            20353
            49929            20353
            49189            17822
            54556            14852
            49191            17717
            52455            15501
            49903            19330
            50077            17293
            50040            19111
            52097             7040
            52656            16797
            53361            19455
            53551            16999
            57599            16396
            55165             6801
            57626            16534
            56193            18795
            57888            16655
            57740            18818
            65759            11304
            60015            19842
            61136            16618
            62166            17429
            62160            16782
            62036            11907
            59237            13715
            61991            18561
            66256            15111
            60574            17551
            17926            17930
            17919            17057
            17919            16379
               11            13717
            11470             4606
                2              913
                2                0
               10                0
               10                0
                0                0
                0                0

But when I redid the above test after dropping all the ~3GB caches,
the dirty limit again seem to remain constant.

        # echo 1 > /proc/sys/vm/drop_caches

        wfg ~% dd if=/dev/zero of=/opt/vm/10G bs=1M count=2000
        2000+0 records in
        2000+0 records out
        2097152000 bytes (2.1 GB) copied, 33.3299 s, 62.9 MB/s

         nr_dirty     nr_writeback
                0                0
            76425            10825
            66255            17302
            69942            15865
            65332            17305
            71207            14605
            69957            15380
            65901            18960
            66365            16233
            66040            17041
            66042            16378
            66434             2169
            67606            17143
            68660            17195
            67613            16514
            67366            17415
            65784             4620
            69053            16831
            66037            17033
            64601            19936
            64629            16922
            70459             9227
            66673            17789
            65638            20102
            65166            17662
            66255            16286
            69821            11264
            82247             4113
            64012            18060
            29585            17920
             5872            16653
             5872            14197
            25422             1913
             5884            16658
                0            12027
                2               26
                2                0
                2                0

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
