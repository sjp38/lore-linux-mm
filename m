Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5AF8A6B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 08:39:29 -0400 (EDT)
Date: Tue, 28 Sep 2010 07:39:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20100928050801.GA29021@sli10-conroe.sh.intel.com>
Message-ID: <alpine.DEB.2.00.1009280736020.4144@router.home>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Shaohua Li wrote:

> In a 4 socket 64 CPU system, zone_nr_free_pages() takes about 5% ~ 10% cpu time
> according to perf when memory pressure is high. The workload does something
> like:
> for i in `seq 1 $nr_cpu`
> do
>         create_sparse_file $SPARSE_FILE-$i $((10 * mem / nr_cpu))
>         $USEMEM -f $SPARSE_FILE-$i -j 4096 --readonly $((10 * mem / nr_cpu)) &
> done
> this simply reads a sparse file for each CPU. Apparently the
> zone->percpu_drift_mark is too big, and guess zone_page_state_snapshot() makes
> a lot of cache bounce for ->vm_stat_diff[]. below is the zoneinfo for reference.
> Is there any way to reduce the overhead?

I guess Mel could reduce the percpu_drift_mark? Or tune that with a
reduction in the stat_threshold? The less the count can deviate the less
the percpu_drift_mark has to be and the less we need calls to
zone_page_state_snapshot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
