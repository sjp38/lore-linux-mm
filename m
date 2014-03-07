Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 591486B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 03:21:33 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so3733798pdi.30
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 00:21:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id u5si7477980pbi.238.2014.03.07.00.21.31
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 00:21:32 -0800 (PST)
Date: Fri, 7 Mar 2014 16:22:16 +0800
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: Re: performance regression due to commit e82e0561("mm: vmscan: obey
 proportional scanning requirements for kswapd")
Message-ID: <20140307082216.GJ29270@yliu-dev.sh.intel.com>
References: <20140218080122.GO26593@yliu-dev.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140218080122.GO26593@yliu-dev.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

ping...

On Tue, Feb 18, 2014 at 04:01:22PM +0800, Yuanhan Liu wrote:
> Hi,
> 
> Commit e82e0561("mm: vmscan: obey proportional scanning requirements for
> kswapd") caused a big performance regression(73%) for vm-scalability/
> lru-file-readonce testcase on a system with 256G memory without swap.
> 
> That testcase simply looks like this:
>      truncate -s 1T /tmp/vm-scalability.img
>      mkfs.xfs -q /tmp/vm-scalability.img
>      mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability
> 
>      SPARESE_FILE="/tmp/vm-scalability/sparse-lru-file-readonce"
>      for i in `seq 1 120`; do
>          truncate $SPARESE_FILE-$i -s 36G
>          timeout --foreground -s INT 300 dd bs=4k if=$SPARESE_FILE-$i of=/dev/null
>      done
> 
>      wait
> 
> Actually, it's not the newlly added code(obey proportional scanning)
> in that commit caused the regression. But instead, it's the following
> change:
> +
> +               if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> +                       continue;
> +
> 
> 
> -               if (nr_reclaimed >= nr_to_reclaim &&
> -                   sc->priority < DEF_PRIORITY)
> +               if (global_reclaim(sc) && !current_is_kswapd())
>                         break;
> 
> The difference is that we might reclaim more than requested before
> in the first round reclaimming(sc->priority == DEF_PRIORITY).
> 
> So, for a testcase like lru-file-readonce, the dirty rate is fast, and
> reclaimming SWAP_CLUSTER_MAX(32 pages) each time is not enough for catching
> up the dirty rate. And thus page allocation stalls, and performance drops:
> 
>    O for e82e0561
>    * for parent commit
> 
>                                 proc-vmstat.allocstall
> 
>      2e+06 ++---------------------------------------------------------------+
>    1.8e+06 O+              O                O               O               |
>            |                                                                |
>    1.6e+06 ++                                                               |
>    1.4e+06 ++                                                               |
>            |                                                                |
>    1.2e+06 ++                                                               |
>      1e+06 ++                                                               |
>     800000 ++                                                               |
>            |                                                                |
>     600000 ++                                                               |
>     400000 ++                                                               |
>            |                                                                |
>     200000 *+..............*................*...............*...............*
>          0 ++---------------------------------------------------------------+
> 
>                                vm-scalability.throughput
> 
>    2.2e+07 ++---------------------------------------------------------------+
>            |                                                                |
>      2e+07 *+..............*................*...............*...............*
>    1.8e+07 ++                                                               |
>            |                                                                |
>    1.6e+07 ++                                                               |
>            |                                                                |
>    1.4e+07 ++                                                               |
>            |                                                                |
>    1.2e+07 ++                                                               |
>      1e+07 ++                                                               |
>            |                                                                |
>      8e+06 ++              O                O               O               |
>            O                                                                |
>      6e+06 ++---------------------------------------------------------------+
> 
> I made a patch which simply keeps reclaimming more if sc->priority == DEF_PRIORITY.
> I'm not sure it's the right way to go or not. Anyway, I pasted it here for comments.
> 
> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 26ad67f..37004a8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1828,7 +1828,16 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
>  	struct blk_plug plug;
> -	bool scan_adjusted = false;
> +	/*
> +	 * On large memory systems, direct reclamming of SWAP_CLUSTER_MAX
> +	 * each time may not catch up the dirty rate in some cases(say,
> +	 * vm-scalability/lru-file-readonce), which may increase the
> +	 * page allocation stall latency in the end.
> +	 *
> +	 * Here we try to reclaim more than requested for the first round
> +	 * (sc->priority == DEF_PRIORITY) to reduce such latency.
> +	 */
> +	bool scan_adjusted = sc->priority == DEF_PRIORITY;
>  
>  	get_scan_count(lruvec, sc, nr);
>  
> -- 
> 1.7.7.6
> 
> 
> 	--yliu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
