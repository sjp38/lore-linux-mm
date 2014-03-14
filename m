Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 109476B0037
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 00:53:00 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so2027136pdj.6
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 21:52:59 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ff3si88531pad.460.2014.03.13.21.52.58
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 21:52:59 -0700 (PDT)
Date: Fri, 14 Mar 2014 12:54:33 +0800
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: Re: performance regression due to commit e82e0561("mm: vmscan: obey
 proportional scanning requirements for kswapd")
Message-ID: <20140314045433.GN29270@yliu-dev.sh.intel.com>
References: <20140218080122.GO26593@yliu-dev.sh.intel.com>
 <20140312165447.GO10663@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140312165447.GO10663@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 12, 2014 at 04:54:47PM +0000, Mel Gorman wrote:
> On Tue, Feb 18, 2014 at 04:01:22PM +0800, Yuanhan Liu wrote:
> > Hi,
> > 
> > Commit e82e0561("mm: vmscan: obey proportional scanning requirements for
> > kswapd") caused a big performance regression(73%) for vm-scalability/
> > lru-file-readonce testcase on a system with 256G memory without swap.
> > 
> > That testcase simply looks like this:
> >      truncate -s 1T /tmp/vm-scalability.img
> >      mkfs.xfs -q /tmp/vm-scalability.img
> >      mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability
> > 
> >      SPARESE_FILE="/tmp/vm-scalability/sparse-lru-file-readonce"
> >      for i in `seq 1 120`; do
> >          truncate $SPARESE_FILE-$i -s 36G
> >          timeout --foreground -s INT 300 dd bs=4k if=$SPARESE_FILE-$i of=/dev/null
> >      done
> > 
> >      wait
> > 
> 
> The filename implies that it's a sparse file with no IO but does not say
> what the truncate function/program/whatever actually does.

It's actually the /usr/bin/truncate file from coreutils.

> If it's really a
> sparse file then the dd process should be reading zeros and writing them to
> NULL without IO. Where are pages being dirtied?

Sorry, my bad. I was wrong and I meant to "the speed of getting new
pages", but not "the speed of dirtying pages".

> Does the truncate command
> really create a sparse file or is it something else?
> 
> > Actually, it's not the newlly added code(obey proportional scanning)
> > in that commit caused the regression. But instead, it's the following
> > change:
> > +
> > +               if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> > +                       continue;
> > +
> > 
> > 
> > -               if (nr_reclaimed >= nr_to_reclaim &&
> > -                   sc->priority < DEF_PRIORITY)
> > +               if (global_reclaim(sc) && !current_is_kswapd())
> >                         break;
> > 
> > The difference is that we might reclaim more than requested before
> > in the first round reclaimming(sc->priority == DEF_PRIORITY).
> > 
> > So, for a testcase like lru-file-readonce, the dirty rate is fast, and
> > reclaimming SWAP_CLUSTER_MAX(32 pages) each time is not enough for catching
> > up the dirty rate. And thus page allocation stalls, and performance drops:
> > 
> >    O for e82e0561
> >    * for parent commit
> > 
> >                                 proc-vmstat.allocstall
> > 
> >      2e+06 ++---------------------------------------------------------------+
> >    1.8e+06 O+              O                O               O               |
> >            |                                                                |
> >    1.6e+06 ++                                                               |
> >    1.4e+06 ++                                                               |
> >            |                                                                |
> >    1.2e+06 ++                                                               |
> >      1e+06 ++                                                               |
> >     800000 ++                                                               |
> >            |                                                                |
> >     600000 ++                                                               |
> >     400000 ++                                                               |
> >            |                                                                |
> >     200000 *+..............*................*...............*...............*
> >          0 ++---------------------------------------------------------------+
> > 
> >                                vm-scalability.throughput
> > 
> >    2.2e+07 ++---------------------------------------------------------------+
> >            |                                                                |
> >      2e+07 *+..............*................*...............*...............*
> >    1.8e+07 ++                                                               |
> >            |                                                                |
> >    1.6e+07 ++                                                               |
> >            |                                                                |
> >    1.4e+07 ++                                                               |
> >            |                                                                |
> >    1.2e+07 ++                                                               |
> >      1e+07 ++                                                               |
> >            |                                                                |
> >      8e+06 ++              O                O               O               |
> >            O                                                                |
> >      6e+06 ++---------------------------------------------------------------+
> > 
> > I made a patch which simply keeps reclaimming more if sc->priority == DEF_PRIORITY.
> > I'm not sure it's the right way to go or not. Anyway, I pasted it here for comments.
> > 
> 
> The impact of the patch is that a direct reclaimer will now scan and
> reclaim more pages than requested so the unlucky reclaiming process will
> stall for longer than it should while others make forward progress.
> 
> That would explain the difference in allocstall figure as each stall is
> now doing more work than it did previously. The throughput figure is
> harder to explain. What is it measuring?

It's just a sum of all dd's output like following:

	18267619328 bytes (18 GB) copied, 299.999 s, 60.9 MB/s
	4532509+0 records in
	4532508+0 records out
	18565152768 bytes (19 GB) copied, 299.999 s, 61.9 MB/s
	4487453+0 records in
	...

And as you noticed, the average dd's throughput is about 60 MB/s,
however, it's about 170 MB/s without this bad commit.

> 
> Any idea why kswapd is failing to keep up?

I don't know. But, isn't it normal for case like this?

> 
> I'm not saying the patch is wrong but there appears to be more going on
> that is explained in the changelog. Is the full source of the benchmark
> suite available? If so, can you point me to it and the exact commands
> you use to run the testcase please?

https://github.com/aristeu/vm-scalability/blob/master/case-lru-file-readonce

Where nr_cpu is 120 as I showed in early email.

Thanks.

	--yliu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
