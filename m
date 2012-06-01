Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id BED7A6B005A
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 04:37:34 -0400 (EDT)
Date: Fri, 1 Jun 2012 10:37:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120601083730.GA25986@tiehlicka.suse.cz>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
 <20120529030857.GA7762@localhost>
 <20120529072853.GD1734@cmpxchg.org>
 <20120529084848.GC10469@localhost>
 <20120529093511.GE1734@cmpxchg.org>
 <20120529135101.GD15293@tiehlicka.suse.cz>
 <20120531090957.GA12809@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120531090957.GA12809@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Thu 31-05-12 11:09:57, Michal Hocko wrote:
> On Tue 29-05-12 15:51:01, Michal Hocko wrote:
> [...]
> > OK, I have tried it with a simpler approach:
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index c978ce4..e45cf2a 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1294,8 +1294,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  	 *                     isolated page is PageWriteback
> >  	 */
> >  	if (nr_writeback && nr_writeback >=
> > -			(nr_taken >> (DEF_PRIORITY - sc->priority)))
> > -		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> > +			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
> > +		if (global_reclaim(sc))
> > +			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> > +		else
> > +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +	}
> >  
> >  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
> >  		zone_idx(zone),
> > 
> [...]
> > As a conclusion congestion wait performs better (even though I haven't
> > done repeated testing to see what is the deviation) when the
> > reader/writer size doesn't fit into the memcg, while it performs much
> > worse (at least for writer) if it does fit.
> > 
> > I will play with that some more
> 
> I have, yet again, updated the test. I am writing data to an USB stick
> (with ext3, mounted in sync mode) and which writes 1G in 274.518s,
> 3.8MB/s so the storage is really slow. The parallel read is performed
> from tmpfs and from a local ext3 partition (testing script is attached).
> We start with writing so the LRUs will have some dirty pages when the
> read starts and fill up the LRU with clean page cache.
> 
> congestion wait:
> ================
> * ext3 (reader)                         avg      std/avg
> ** Write
> 5M	412.128	334.944	337.708	339.457	356.0593 [10.51%]
> 60M	566.652	321.607	492.025	317.942	424.5565 [29.39%]
> 300M	318.437	315.321	319.515	314.981	317.0635 [0.71%]
> 2G	317.777	314.8	318.657	319.409	317.6608 [0.64%]
> 
> ** Read
> 5M	40.1829	40.8907	48.8362	40.0535	42.4908  [9.99%]
> 60M	15.4104	16.1693	18.9162	16.0049	16.6252  [9.39%]
> 300M	17.0376	15.6721	15.6137	15.756	16.0199  [4.25%]
> 2G	15.3718	17.3714	15.3873	15.4554	15.8965  [6.19%]
> 
> * Tmpfs (reader)
> ** Write
> 5M	324.425	327.395	573.688	314.884	385.0980 [32.68%]
> 60M	464.578	317.084	375.191	318.947	368.9500 [18.76%]
> 300M	316.885	323.759	317.212	318.149	319.0013 [1.01%]
> 2G	317.276	318.148	318.97	316.897	317.8228 [0.29%]
> 
> ** Read
> 5M	0.9241	0.8620	0.9391	1.2922	1.0044   [19.39%]
> 60M	0.8753	0.8359	1.0072	1.3317	1.0125   [22.23%]
> 300M	0.9825	0.8143	0.9864	0.8692	0.9131   [9.35%]
> 2G	0.9990	0.8281	1.0312	0.9034	0.9404   [9.83%]
> 
> 
> PageReclaim:
> =============
> * ext3 (reader)
> ** Write                                avg      std/avg  comparision 
>                                                          (cong is 100%)
> 5M	313.08	319.924	325.206	325.149	320.8398 [1.79%]  90.11%
> 60M	314.135	415.245	502.157	313.776	386.3283 [23.50%] 91.00%
> 300M	313.718	320.448	315.663	316.714	316.6358 [0.89%]  99.87%
> 2G	317.591	316.67	316.285	316.624	316.7925 [0.18%]  99.73%
> 
> ** Read
> 5M	19.0228	20.6743	17.2508	17.5946	18.6356	 [8.37%]  43.86%
> 60M	17.3657	15.6402	16.5168	15.5601	16.2707	 [5.22%]  97.87%
> 300M	17.1986	15.7616	19.5163	16.9544	17.3577	 [9.05%]  108.35%
> 2G	15.6696	15.5384	15.4381	15.2454	15.4729	 [1.16%]  97.34%
> 
> * Tmpfs (reader)
> ** Write
> 5M	317.303	314.366	316.508	318.883	316.7650 [0.59%]  82.26%
> 60M	579.952	666.606	660.021	655.346	640.4813 [6.34%]  173.60%
> 300M	318.494	318.64	319.516	316.79	318.3600 [0.36%]  99.80%
> 2G	315.935	318.069	321.097	320.329	318.8575 [0.73%]  100.33%
> 
> ** Read  
> 5M	0.8415	0.8550	0.7892	0.8515	0.8343	 [3.67%]  83.07%
> 60M	0.8536	0.8685	0.8237	0.8805	0.8565	 [2.86%]  84.60%
> 300M	0.8309	0.8724	0.8553	0.8577	0.8541	 [2.01%]  93.53%
> 2G	0.8427	0.8468	0.8325	1.4658	0.9970	 [31.36%] 106.01%

And just finished a test without any patch (current memcg-devel tree).
Surprisingly enough OOM killer didn't trigger in this setup (the storage
is probably too slow):

					avg	std/avg		comparison      comparison 
                                                        	(cong is 100%)	(page reclaim 100%)
ext3 (reader)
** Write
5M	329.953	319.305	705.561	338.379	423.2995 [44.49%]	118.88%		131.93%
60M	320.940	529.418	314.126	552.817	429.3253 [30.16%]	101.12%		111.13%
300M	315.600	318.759	314.052	313.366	315.4443 [0.76%]	99.49%		99.62%
2G	316.799	313.328	316.605	317.873	316.151  [0.62%]	99.52%		99.80%

** Read	
5M	17.2729	15.9298	15.5007	15.7594	16.1157	[4.91%]		37.93%		86.48%
60M	16.0478	15.8576	16.7704	16.9675	16.4108	[3.29%]		98.71%		100.86%
300M	15.7392	15.5122	15.5084	15.6455	15.6013	[0.72%]		97.39%		89.88%
2G	15.3784	15.3592	15.5804	15.6464	15.4911	[0.93%]		97.45%		100.12%

Tmpfs (reader)
** write
5M	313.910	504.897	699.040	352.671	467.6295 [37.40%]	121.43%		147.63%
60M	654.229	316.980	316.147	651.824	484.7950 [40.07%]	131.40%		75.69%
300M	315.442	317.248	316.668	316.163	316.3803 [0.24%]	99.18%		99.38%
2G	316.971	315.687	316.283	316.879	316.4550 [0.19%]	99.57%		99.25%

** read
5M	0.8013	1.1041	0.8345	0.8223	0.8906	[16.06%]	88.67%		106.74%
60M	0.8312	0.7887	0.8577	0.8273	0.8262	[3.44%]		81.60%		96.46%
300M	1.1530	0.8674	1.1260	1.1116	1.0645	[12.45%]	116.58%		124.64%
2G	0.8318	0.8323	0.8897	0.8278	0.8454	[3.50%]		89.89%		84.79%

Write performance is within the noise. Sometimes the patched kernel does
much better, especially for the small groups.
Read performance is more interesting. We seem to regress. The PageReclaim
approach seem to regrees less than congestion_wait.
The biggest drop down seems to be for cong. wait and reader from ext3
with 5M cgroup (there was no big peak during that run ~10% std/avg and
the performance is steady also without any patches).

More detailed statistics (max/min - the worst/best performance).
	comparison (cong is 100%)	comparison (page reclaim 100%)			
	max	min	median		max	min	median
* ext3
** Write
5M	171.20%	95.33%	98.70%		216.96%	101.99%	103.61%
60M	97.56%	98.80%	104.51%		110.09%	100.11%	116.59%
300M	99.76%	99.49%	99.35%		99.47%	99.89%	99.57%
2G	99.52%	99.53%	99.52%		100.09%	99.07%	100.02%

** Read					
5M	35.37%	38.70%	39.09%		83.55%	89.85%	86.54%
60M	89.70%	102.90%	102.00%		97.71%	101.91%	102.06%
300M	92.38%	99.33%	99.14%		80.65%	98.39%	91.23%
2G	90.07%	99.92%	100.38%		99.85%	100.75%	99.94%

* Tmpfs					
** write
5M	121.85%	99.69%	131.57%		219.22%	99.85%	135.30%
60M	140.82%	99.70%	139.57%		98.14%	54.51%	73.65%
300M	97.99%	99.54%	99.60%		99.29%	99.57%	99.32%
2G	99.37%	99.62%	99.64%		98.72%	99.92%	99.18%

** read				
5M	85.44%	92.96%	88.92%		129.13%	101.54%	97.87%
60M	64.41%	94.35%	88.10%		97.41%	95.75%	96.31%
300M	116.89%	106.52%	120.84%		132.17%	104.39%	130.63%
2G	86.27%	99.96%	87.47%		60.69%	99.44%	98.49%

These numbers show  that PageReclaim gives us slightly better results
than congestion wait. There are not so big dropdowns (like 5M ext3 read
or 60M tmpfs read).
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
