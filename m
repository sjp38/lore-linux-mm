Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 73FDC6B0037
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 23:57:11 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so4280221pbb.25
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 20:57:11 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id e6si8390578pbj.313.2014.03.15.20.57.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 20:57:10 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so4176979pdi.16
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 20:57:10 -0700 (PDT)
Date: Sat, 15 Mar 2014 20:56:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: performance regression due to commit e82e0561("mm: vmscan: obey
 proportional scanning requirements for kswapd")
In-Reply-To: <20140314142103.GV10663@suse.de>
Message-ID: <alpine.LSU.2.11.1403152040380.21540@eggly.anvils>
References: <20140218080122.GO26593@yliu-dev.sh.intel.com> <20140312165447.GO10663@suse.de> <alpine.LSU.2.11.1403130516050.10128@eggly.anvils> <20140314142103.GV10663@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 14 Mar 2014, Mel Gorman wrote:
> On Thu, Mar 13, 2014 at 05:44:57AM -0700, Hugh Dickins wrote:
> > On Wed, 12 Mar 2014, Mel Gorman wrote:
> > > On Tue, Feb 18, 2014 at 04:01:22PM +0800, Yuanhan Liu wrote:
> > > > Hi,
> > > > 
> > > > Commit e82e0561("mm: vmscan: obey proportional scanning requirements for
> > > > kswapd") caused a big performance regression(73%) for vm-scalability/
> > > > lru-file-readonce testcase on a system with 256G memory without swap.
> > > > 
> > > > That testcase simply looks like this:
> > > >      truncate -s 1T /tmp/vm-scalability.img
> > > >      mkfs.xfs -q /tmp/vm-scalability.img
> > > >      mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability
> > > > 
> > > >      SPARESE_FILE="/tmp/vm-scalability/sparse-lru-file-readonce"
> > > >      for i in `seq 1 120`; do
> > > >          truncate $SPARESE_FILE-$i -s 36G
> > > >          timeout --foreground -s INT 300 dd bs=4k if=$SPARESE_FILE-$i of=/dev/null
> > > >      done
> > > > 
> > > >      wait
> > > > 
> > > 
> > > The filename implies that it's a sparse file with no IO but does not say
> > > what the truncate function/program/whatever actually does. If it's really a
> > > sparse file then the dd process should be reading zeros and writing them to
> > > NULL without IO. Where are pages being dirtied? Does the truncate command
> > > really create a sparse file or is it something else?
> > > 
> > > > Actually, it's not the newlly added code(obey proportional scanning)
> > > > in that commit caused the regression. But instead, it's the following
> > > > change:
> > > > +
> > > > +               if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> > > > +                       continue;
> > > > +
> > > > 
> > > > 
> > > > -               if (nr_reclaimed >= nr_to_reclaim &&
> > > > -                   sc->priority < DEF_PRIORITY)
> > > > +               if (global_reclaim(sc) && !current_is_kswapd())
> > > >                         break;
> > > > 
> > > > The difference is that we might reclaim more than requested before
> > > > in the first round reclaimming(sc->priority == DEF_PRIORITY).
> > > > 
> > > > So, for a testcase like lru-file-readonce, the dirty rate is fast, and
> > > > reclaimming SWAP_CLUSTER_MAX(32 pages) each time is not enough for catching
> > > > up the dirty rate. And thus page allocation stalls, and performance drops:
> > ...
> > > > I made a patch which simply keeps reclaimming more if sc->priority == DEF_PRIORITY.
> > > > I'm not sure it's the right way to go or not. Anyway, I pasted it here for comments.
> > > > 
> > > 
> > > The impact of the patch is that a direct reclaimer will now scan and
> > > reclaim more pages than requested so the unlucky reclaiming process will
> > > stall for longer than it should while others make forward progress.
> > > 
> > > That would explain the difference in allocstall figure as each stall is
> > > now doing more work than it did previously. The throughput figure is
> > > harder to explain. What is it measuring?
> > > 
> > > Any idea why kswapd is failing to keep up?
> > > 
> > > I'm not saying the patch is wrong but there appears to be more going on
> > > that is explained in the changelog. Is the full source of the benchmark
> > > suite available? If so, can you point me to it and the exact commands
> > > you use to run the testcase please?
> > 
> > I missed Yuanhan's mail, but seeing your reply reminds me of another
> > issue with that proportionality patch - or perhaps more thought would
> > show them to be two sides of the same issue, with just one fix required.
> > Let me throw our patch into the cauldron.
> > 
> > [PATCH] mm: revisit shrink_lruvec's attempt at proportionality
> > 
> > We have a memcg reclaim test which exerts a certain amount of pressure,
> > and expects to see a certain range of page reclaim in response.  It's a
> > very wide range allowed, but the test repeatably failed on v3.11 onwards,
> > because reclaim goes wild and frees up almost everything.
> > 
> > This wild behaviour bisects to Mel's "scan_adjusted" commit e82e0561dae9
> > "mm: vmscan: obey proportional scanning requirements for kswapd".  That
> > attempts to achieve proportionality between anon and file lrus: to the
> > extent that once one of those is empty, it then tries to empty the other.
> > Stop that.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> > 
> > We've been running happily with this for months; but all that time it's
> > been on my TODO list with a "needs more thought" tag before we could
> > upstream it, and I never got around to that.  We also have a somewhat
> > similar, but older and quite independent, fix to get_scan_count() from
> > Suleiman, which I'd meant to send along at the same time: I'll dig that
> > one out tomorrow or the day after.

I've sent that one out now in a new thread
https://lkml.org/lkml/2014/3/15/168
and also let's tie these together with Hannes's
https://lkml.org/lkml/2014/3/14/277

> > 
> 
> I ran a battery of page reclaim related tests against it on top of
> 3.14-rc6. Workloads showed small improvements in their absolute performance
> but actual IO behaviour looked much better in some tests.  This is the
> iostats summary for the test that showed the biggest different -- dd of
> a large file on ext3.
> 
>  	                3.14.0-rc6	3.14.0-rc6
> 	                   vanilla	proportional-v1r1
> Mean	sda-avgqz 	1045.64		224.18	
> Mean	sda-await 	2120.12		506.77	
> Mean	sda-r_await	18.61		19.78	
> Mean	sda-w_await	11089.60	2126.35	
> Max 	sda-avgqz 	2294.39		787.13	
> Max 	sda-await 	7074.79		2371.67	
> Max 	sda-r_await	503.00		414.00	
> Max 	sda-w_await	35721.93	7249.84	
> 
> Not all workloads benefitted. The same workload on ext4 showed no useful
> difference. btrfs looks like
> 
>  	             3.14.0-rc6	3.14.0-rc6
> 	               vanilla	proportional-v1r1
> Mean	sda-avgqz 	762.69		650.39	
> Mean	sda-await 	2438.46		2495.15	
> Mean	sda-r_await	44.18		47.20	
> Mean	sda-w_await	6109.19		5139.86	
> Max 	sda-avgqz 	2203.50		1870.78	
> Max 	sda-await 	7098.26		6847.21	
> Max 	sda-r_await	63.02		156.00	
> Max 	sda-w_await	19921.70	11085.13	
> 
> Better but not as dramatically so. I didn't analyse why. A workload that
> had a large anonymous mapping with large amounts of IO in the background
> did not show any regressions so based on that and the fact the patch looks
> ok, here goes nothing;
> 
> Acked-by: Mel Gorman <mgorman@suse.de>

Big thank you, Mel, for doing so much work on it, and so very quickly.
I get quite lost in the numbers myself: I'm much more convinced of it
by your numbers and ack.

> 
> You say it's already been tested for months but it would be nice if the
> workload that generated this thread was also tested.

Yes indeed: Yuanhan, do you have time to try this patch for your
testcase?  I'm hoping it will prove at least as effective as your
own suggested patch, but please let us know what you find - thanks.

> Regrettably I'm not
> going to have the chance to setup and do it myself for some time.

Understood, I'll continue to Cc you, but not expecting more.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
