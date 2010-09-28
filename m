Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 957796B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 09:31:08 -0400 (EDT)
Date: Tue, 28 Sep 2010 14:30:59 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20100928133059.GL8187@csn.ul.ie>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009280736020.4144@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2010 at 07:39:24AM -0500, Christoph Lameter wrote:
> On Tue, 28 Sep 2010, Shaohua Li wrote:
> 
> > In a 4 socket 64 CPU system, zone_nr_free_pages() takes about 5% ~ 10% cpu time
> > according to perf when memory pressure is high. The workload does something
> > like:
> > for i in `seq 1 $nr_cpu`
> > do
> >         create_sparse_file $SPARSE_FILE-$i $((10 * mem / nr_cpu))
> >         $USEMEM -f $SPARSE_FILE-$i -j 4096 --readonly $((10 * mem / nr_cpu)) &
> > done
> > this simply reads a sparse file for each CPU. Apparently the
> > zone->percpu_drift_mark is too big, and guess zone_page_state_snapshot() makes
> > a lot of cache bounce for ->vm_stat_diff[]. below is the zoneinfo for reference.
> > Is there any way to reduce the overhead?
> 

The overhead is higher than I would have expected. I would guess the
cache bounces are a real problem.

> I guess Mel could reduce the percpu_drift_mark? Or tune that with a
> reduction in the stat_threshold? The less the count can deviate the less
> the percpu_drift_mark has to be and the less we need calls to
> zone_page_state_snapshot.
> 

This is true. It's helpful to remember why this patch exists. Under heavy
memory pressure, large machines run the risk of live-locking because the
NR_FREE_PAGES gets out of sync. The test case mentioned above is under
memory pressure so it is potentially at risk. Ordinarily, we would be less
concerned with performance under heavy memory pressure and more concerned with
correctness of behaviour. The percpu_drift_mark is set at a point where the
risk is "real".  Lowering it will help performance but increase risk. Reducing
stat_threshold shifts the cost elsewhere by increasing the frequency the
vmstat counters are updated which I considered to be worse overall.

Which of these is better or is there an alternative suggestion on how
this livelock can be avoided?

As a heads up, I'm preparing for exams at the moment and while I'm online, I'm
not in the position to prototype patches and test them at the moment but can
review alternative proposals if people have them. I'm also out early next week.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
