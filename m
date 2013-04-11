Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 342156B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 04:43:51 -0400 (EDT)
Date: Thu, 11 Apr 2013 10:43:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] soft reclaim rework
Message-ID: <20130411084346.GB1488@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365509595-665-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

Hi,
I have retested kbuild test on a bare HW (8CPUs, 1GB RAM limited by
mem=1G, 2GB swap partition). There are 2 groups (A, B) without any hard
limit and group A has soft limit set to 700M (to have 70% of available
memory). Build starts after fresh boot by extracting sources and
make -j4 vmlinux.
Each group works on a separate source tree. I have repeated the test 3
times:

First some data as returned by /usr/bin/time -v:
* Patched:
A:
User time (seconds): 1133.06
User time (seconds): 1132.84
User time (seconds): 1135.37
		Avg: 1133.76
System time (seconds): 258.02
System time (seconds): 259.33
System time (seconds): 258.83
		Avg: 258.73
Elapsed (wall clock) time (h:mm:ss or m:ss): 8:57.55
Elapsed (wall clock) time (h:mm:ss or m:ss): 8:55.68
Elapsed (wall clock) time (h:mm:ss or m:ss): 8:50.96
		Avg: 08:54.73

B:
User time (seconds): 1149.22
User time (seconds): 1153.98
User time (seconds): 1150.37
		Avg: 1151.19 (101.5% of A)
System time (seconds): 262.13
System time (seconds): 263.31
System time (seconds): 260.84
		Avg: 262.09 (101.3% of A)
Elapsed (wall clock) time (h:mm:ss or m:ss): 10:13.37
Elapsed (wall clock) time (h:mm:ss or m:ss): 10:17.15
Elapsed (wall clock) time (h:mm:ss or m:ss): 10:05.23
		Avg: 10:11.92 (114.4% of A)

* Base:
A:
User time (seconds): 1132.58
User time (seconds): 1140.63
User time (seconds): 1135.68
		avg: 1136.30 (100.2% of A - patched)
System time (seconds): 264.88
System time (seconds): 263.54
System time (seconds): 261.99
		avg: 263.47 (101.8 of A - patched)
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:48.54
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:50.44
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:44.28
		avg: 09:47.75 (109.9% of A - patched)

B:
User time (seconds): 1138.32
User time (seconds): 1135.70
User time (seconds): 1136.80
		avg: 1136.94 (100.2% of A - patched)

System time (seconds): 261.56
System time (seconds): 262.10
System time (seconds): 262.24
		avg: 261.97  (100% of A - patched)
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:39.17
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:46.95
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:44.73
		avg: 09:47.75 (109.1% of A - patched)

While for the patched kernel soft limit helped to protect A's working
set so it was faster (14% in the total time) than B without any limits.
The unpatched kernel has treated them more or less equally regardless
the softlimit setting.

If we compare patched and base kernels numbers then the overall
situation improved slightly (A+B Elapsed time is 2% smaller) with the
patched kernel which was quite surprising for me. Maybe a side effect of
priority-0 soft reclaim in the base kernel.

As the variance between runs wasn't very high I have focused on the first
run for the memory usage and reclaim statistics comparisons between the
base and patched kernels.

* Patched:
pgscan_direct_dma32 	252408
pgscan_kswapd_dma32 	988928
pgsteal_direct_dma32 	63565
pgsteal_kswapd_dma32	905223

* Base:
pgscan_direct_dma32 	97310	(38% of patched)
pgscan_kswapd_dma32 	1702971	(172%)
pgsteal_direct_dma32 	83377	(131%)
pgsteal_kswapd_dma32 	1534616	(169.5%)

So it seems that we scanned much more on the patched kernel during the
direct reclaim but we have reclaimed less nevertheless. This is most
probably because there is a bigger pressure on B's LRU and we encounter
more dirty pages so more pages are scanned in the end. In sum we scanned
and reclaimed less (by 45% resp. 67%) though.

You can find some graphs at:
- http://labs.suse.cz/mhocko/soft_limit_rework/base-usage.png
- http://labs.suse.cz/mhocko/soft_limit_rework/patched-usage.png

Per group charges over time.

- http://labs.suse.cz/mhocko/soft_limit_rework/base-usage-histogram.png
- http://labs.suse.cz/mhocko/soft_limit_rework/patched-usage-histogram.png

Same here but in the histogram form to see the main tendencies.

- http://labs.suse.cz/mhocko/soft_limit_rework/pgscan.png
- http://labs.suse.cz/mhocko/soft_limit_rework/pgsteal.png

Scanning and reclaiming activity comparision between the base and the
patched kernel.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
