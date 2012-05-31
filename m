Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 687276B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 05:10:01 -0400 (EDT)
Date: Thu, 31 May 2012 11:09:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120531090957.GA12809@tiehlicka.suse.cz>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
 <20120529030857.GA7762@localhost>
 <20120529072853.GD1734@cmpxchg.org>
 <20120529084848.GC10469@localhost>
 <20120529093511.GE1734@cmpxchg.org>
 <20120529135101.GD15293@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Content-Disposition: inline
In-Reply-To: <20120529135101.GD15293@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 29-05-12 15:51:01, Michal Hocko wrote:
[...]
> OK, I have tried it with a simpler approach:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c978ce4..e45cf2a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1294,8 +1294,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	 *                     isolated page is PageWriteback
>  	 */
>  	if (nr_writeback && nr_writeback >=
> -			(nr_taken >> (DEF_PRIORITY - sc->priority)))
> -		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
> +		if (global_reclaim(sc))
> +			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +		else
> +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> +	}
>  
>  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
>  		zone_idx(zone),
> 
[...]
> As a conclusion congestion wait performs better (even though I haven't
> done repeated testing to see what is the deviation) when the
> reader/writer size doesn't fit into the memcg, while it performs much
> worse (at least for writer) if it does fit.
> 
> I will play with that some more

I have, yet again, updated the test. I am writing data to an USB stick
(with ext3, mounted in sync mode) and which writes 1G in 274.518s,
3.8MB/s so the storage is really slow. The parallel read is performed
from tmpfs and from a local ext3 partition (testing script is attached).
We start with writing so the LRUs will have some dirty pages when the
read starts and fill up the LRU with clean page cache.

congestion wait:
================
* ext3 (reader)                         avg      std/avg
** Write
5M	412.128	334.944	337.708	339.457	356.0593 [10.51%]
60M	566.652	321.607	492.025	317.942	424.5565 [29.39%]
300M	318.437	315.321	319.515	314.981	317.0635 [0.71%]
2G	317.777	314.8	318.657	319.409	317.6608 [0.64%]

** Read
5M	40.1829	40.8907	48.8362	40.0535	42.4908  [9.99%]
60M	15.4104	16.1693	18.9162	16.0049	16.6252  [9.39%]
300M	17.0376	15.6721	15.6137	15.756	16.0199  [4.25%]
2G	15.3718	17.3714	15.3873	15.4554	15.8965  [6.19%]

* Tmpfs (reader)
** Write
5M	324.425	327.395	573.688	314.884	385.0980 [32.68%]
60M	464.578	317.084	375.191	318.947	368.9500 [18.76%]
300M	316.885	323.759	317.212	318.149	319.0013 [1.01%]
2G	317.276	318.148	318.97	316.897	317.8228 [0.29%]

** Read
5M	0.9241	0.8620	0.9391	1.2922	1.0044   [19.39%]
60M	0.8753	0.8359	1.0072	1.3317	1.0125   [22.23%]
300M	0.9825	0.8143	0.9864	0.8692	0.9131   [9.35%]
2G	0.9990	0.8281	1.0312	0.9034	0.9404   [9.83%]


PageReclaim:
=============
* ext3 (reader)
** Write                                avg      std/avg  comparision 
                                                         (cong is 100%)
5M	313.08	319.924	325.206	325.149	320.8398 [1.79%]  90.11%
60M	314.135	415.245	502.157	313.776	386.3283 [23.50%] 91.00%
300M	313.718	320.448	315.663	316.714	316.6358 [0.89%]  99.87%
2G	317.591	316.67	316.285	316.624	316.7925 [0.18%]  99.73%

** Read
5M	19.0228	20.6743	17.2508	17.5946	18.6356	 [8.37%]  43.86%
60M	17.3657	15.6402	16.5168	15.5601	16.2707	 [5.22%]  97.87%
300M	17.1986	15.7616	19.5163	16.9544	17.3577	 [9.05%]  108.35%
2G	15.6696	15.5384	15.4381	15.2454	15.4729	 [1.16%]  97.34%

* Tmpfs (reader)
** Write
5M	317.303	314.366	316.508	318.883	316.7650 [0.59%]  82.26%
60M	579.952	666.606	660.021	655.346	640.4813 [6.34%]  173.60%
300M	318.494	318.64	319.516	316.79	318.3600 [0.36%]  99.80%
2G	315.935	318.069	321.097	320.329	318.8575 [0.73%]  100.33%

** Read  
5M	0.8415	0.8550	0.7892	0.8515	0.8343	 [3.67%]  83.07%
60M	0.8536	0.8685	0.8237	0.8805	0.8565	 [2.86%]  84.60%
300M	0.8309	0.8724	0.8553	0.8577	0.8541	 [2.01%]  93.53%
2G	0.8427	0.8468	0.8325	1.4658	0.9970	 [31.36%] 106.01%

Variance (std/avg) seems to be lower for both reads and writes with
PageReclaim approach and also if we compare the average numbers it seems
to be mostly better (especially for reads) or within the noise.
There are two "peaks" in numbers, though.
* 60M cgroup write performance when reading from tmpfs. While read
behaved well with PageReclaim patch (actually much better than
congwait), the writer stalled a lot.
* 5M cgroup read performance when reading from ext3 when congestion_wait
approach fall down flat while PageReclaim did better for both read and
write.

So I guess that the conclusion could be that the two approaches are
comparable. Both of them could lead to stalling but they are doing
mostly good which is much better than an OOM killer. We can do much
better but that would require conditional sleeping.

How do people feel about going with the simpler approach for now (even
for stable kernels as the problem is real and long term) and work on the
conditional part as a follow up?
Which way would be preferable? I can post a full patch for the
congestion wait approach if you are interested. I do not care much as
both of them fix the problem.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--h31gzZEtNLTqOjlF
Content-Type: application/x-sh
Content-Disposition: attachment; filename="cgroup_cache_oom_test.sh"
Content-Transfer-Encoding: quoted-printable

#! /bin/sh=0A=0AMEMCG_MOUNT=3D/dev/cgroups=0AMEMCG_LIMIT=3D60M=0AOOM_DISABL=
ED=3D0=0AWRITE_OUT=3D/var/tmp/file=0AREAD_IN=3D""=0A=0Aset -e=0A=0Aif [ $# =
-gt 0 ]=0Athen=0A	MEMCG_LIMIT=3D$1=0Afi=0A=0Aif [ $# -gt 1 ]=0Athen=0A	WRIT=
E_OUT=3D$2=0Afi=0A=0Aif [ $# -gt 2 ]=0Athen=0A	READ_IN=3D$3=0Afi=0A=0A=0Aif=
 [ ! -d $MEMCG_MOUNT ]=0Athen=0A	mkdir $MEMCG_MOUNT=0A	mount -t cgroup -o m=
emory none $MEMCG_MOUNT=0Afi=0A=0Acname=3D"$MEMCG_MOUNT/test.$$"=0Aecho usi=
ng Limit $MEMCG_LIMIT for group $name=0A=0A[ ! -d $cname ] && mkdir $cname=
=0Aecho $MEMCG_LIMIT > $cname/memory.limit_in_bytes=0Aecho $OOM_DISABLED > =
$cname/memory.oom_control=0A=0Async=0Aecho 3 > /proc/sys/vm/drop_caches=0As=
leep 1s=0A=0Aecho $$ >> $cname/tasks=0A=0Aback_pid=3D0=0Afor count in 1000;=
 do=0A  dd if=3D/dev/zero of=3D$WRITE_OUT bs=3D1M count=3D$count 2>&1 | sed=
 's/^/write /' &=0A  back_pid=3D$!=0A=0A  if [ ! -z "$READ_IN" ]=0A  then=
=0A	  dd if=3D$READ_IN of=3D/dev/null bs=3D1M count=3D$count 2>&1 | sed 's/=
^/read /'=0A  fi=0A  wait $back_pid=0A  rm $WRITE_OUT=0Adone=0A
--h31gzZEtNLTqOjlF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
