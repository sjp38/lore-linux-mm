Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 769456B00E6
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 02:37:03 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so6808717pbb.12
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 23:37:03 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xk4si9136449pbc.125.2014.03.17.23.36.46
        for <linux-mm@kvack.org>;
        Mon, 17 Mar 2014 23:37:02 -0700 (PDT)
Date: Tue, 18 Mar 2014 14:38:22 +0800
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: Re: performance regression due to commit e82e0561("mm: vmscan: obey
 proportional scanning requirements for kswapd")
Message-ID: <20140318063822.GS29270@yliu-dev.sh.intel.com>
References: <20140218080122.GO26593@yliu-dev.sh.intel.com>
 <20140312165447.GO10663@suse.de>
 <alpine.LSU.2.11.1403130516050.10128@eggly.anvils>
 <20140314142103.GV10663@suse.de>
 <alpine.LSU.2.11.1403152040380.21540@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1403152040380.21540@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yuanhan Liu <yuanhan.liu@linux.intel.com>

On Sat, Mar 15, 2014 at 08:56:10PM -0700, Hugh Dickins wrote:
> On Fri, 14 Mar 2014, Mel Gorman wrote:
> > On Thu, Mar 13, 2014 at 05:44:57AM -0700, Hugh Dickins wrote:
> > > On Wed, 12 Mar 2014, Mel Gorman wrote:
> > > > On Tue, Feb 18, 2014 at 04:01:22PM +0800, Yuanhan Liu wrote:
... snip ...

> > > I missed Yuanhan's mail, but seeing your reply reminds me of another
> > > issue with that proportionality patch - or perhaps more thought would
> > > show them to be two sides of the same issue, with just one fix required.
> > > Let me throw our patch into the cauldron.
> > > 
> > > [PATCH] mm: revisit shrink_lruvec's attempt at proportionality
> > > 
> > > We have a memcg reclaim test which exerts a certain amount of pressure,
> > > and expects to see a certain range of page reclaim in response.  It's a
> > > very wide range allowed, but the test repeatably failed on v3.11 onwards,
> > > because reclaim goes wild and frees up almost everything.
> > > 
> > > This wild behaviour bisects to Mel's "scan_adjusted" commit e82e0561dae9
> > > "mm: vmscan: obey proportional scanning requirements for kswapd".  That
> > > attempts to achieve proportionality between anon and file lrus: to the
> > > extent that once one of those is empty, it then tries to empty the other.
> > > Stop that.
> > > 
> > > Signed-off-by: Hugh Dickins <hughd@google.com>
> > > ---
> > > 
> > > We've been running happily with this for months; but all that time it's
> > > been on my TODO list with a "needs more thought" tag before we could
> > > upstream it, and I never got around to that.  We also have a somewhat
> > > similar, but older and quite independent, fix to get_scan_count() from
> > > Suleiman, which I'd meant to send along at the same time: I'll dig that
> > > one out tomorrow or the day after.
> 
> I've sent that one out now in a new thread
> https://lkml.org/lkml/2014/3/15/168
> and also let's tie these together with Hannes's
> https://lkml.org/lkml/2014/3/14/277
> 
> > > 
> > 
> > I ran a battery of page reclaim related tests against it on top of
> > 3.14-rc6. Workloads showed small improvements in their absolute performance
> > but actual IO behaviour looked much better in some tests.  This is the
> > iostats summary for the test that showed the biggest different -- dd of
> > a large file on ext3.
> > 
> >  	                3.14.0-rc6	3.14.0-rc6
> > 	                   vanilla	proportional-v1r1
> > Mean	sda-avgqz 	1045.64		224.18	
> > Mean	sda-await 	2120.12		506.77	
> > Mean	sda-r_await	18.61		19.78	
> > Mean	sda-w_await	11089.60	2126.35	
> > Max 	sda-avgqz 	2294.39		787.13	
> > Max 	sda-await 	7074.79		2371.67	
> > Max 	sda-r_await	503.00		414.00	
> > Max 	sda-w_await	35721.93	7249.84	
> > 
> > Not all workloads benefitted. The same workload on ext4 showed no useful
> > difference. btrfs looks like
> > 
> >  	             3.14.0-rc6	3.14.0-rc6
> > 	               vanilla	proportional-v1r1
> > Mean	sda-avgqz 	762.69		650.39	
> > Mean	sda-await 	2438.46		2495.15	
> > Mean	sda-r_await	44.18		47.20	
> > Mean	sda-w_await	6109.19		5139.86	
> > Max 	sda-avgqz 	2203.50		1870.78	
> > Max 	sda-await 	7098.26		6847.21	
> > Max 	sda-r_await	63.02		156.00	
> > Max 	sda-w_await	19921.70	11085.13	
> > 
> > Better but not as dramatically so. I didn't analyse why. A workload that
> > had a large anonymous mapping with large amounts of IO in the background
> > did not show any regressions so based on that and the fact the patch looks
> > ok, here goes nothing;
> > 
> > Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Big thank you, Mel, for doing so much work on it, and so very quickly.
> I get quite lost in the numbers myself: I'm much more convinced of it
> by your numbers and ack.
> 
> > 
> > You say it's already been tested for months but it would be nice if the
> > workload that generated this thread was also tested.
> 
> Yes indeed: Yuanhan, do you have time to try this patch for your
> testcase?  I'm hoping it will prove at least as effective as your
> own suggested patch, but please let us know what you find - thanks.

Hi Hugh,

Sure, and sorry to tell you that this patch introduced another half
performance descrease from avg 60 MB/s to 30 MB/s in this testcase.

Moreover, the dd throughput for each process was steady before, however,
it's quite bumpy from 20 MB/s to 40 MB/s w/ this patch applied, and thus
got a avg of 30 MB/s:

    11327188992 bytes (11 GB) copied, 300.014 s, 37.8 MB/s
    1809373+0 records in
    1809372+0 records out
    7411187712 bytes (7.4 GB) copied, 300.008 s, 24.7 MB/s
    3068285+0 records in
    3068284+0 records out
    12567691264 bytes (13 GB) copied, 300.001 s, 41.9 MB/s
    1883877+0 records in
    1883876+0 records out
    7716356096 bytes (7.7 GB) copied, 300.002 s, 25.7 MB/s
    1807674+0 records in
    1807673+0 records out
    7404228608 bytes (7.4 GB) copied, 300.024 s, 24.7 MB/s
    1796473+0 records in
    1796472+0 records out
    7358349312 bytes (7.4 GB) copied, 300.008 s, 24.5 MB/s
    1905655+0 records in
    1905654+0 records out
    7805558784 bytes (7.8 GB) copied, 300.016 s, 26.0 MB/s
    2819168+0 records in
    2819167+0 records out
    11547308032 bytes (12 GB) copied, 300.025 s, 38.5 MB/s
    1848381+0 records in
    1848380+0 records out
    7570964480 bytes (7.6 GB) copied, 300.005 s, 25.2 MB/s
    3023133+0 records in
    3023132+0 records out
    12382748672 bytes (12 GB) copied, 300.024 s, 41.3 MB/s
    1714585+0 records in
    1714584+0 records out
    7022936064 bytes (7.0 GB) copied, 300.011 s, 23.4 MB/s
    1835132+0 records in
    1835131+0 records out
    7516696576 bytes (7.5 GB) copied, 299.998 s, 25.1 MB/s
    1733341+0 records in
    

	--yliu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
