Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 1E9636B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 09:04:40 -0400 (EDT)
Date: Thu, 11 Apr 2013 15:04:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] soft reclaim rework
Message-ID: <20130411130436.GE1488@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <20130411084346.GB1488@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411084346.GB1488@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Thu 11-04-13 10:43:46, Michal Hocko wrote:
> Hi,
> I have retested kbuild test on a bare HW (8CPUs, 1GB RAM limited by
> mem=1G, 2GB swap partition). There are 2 groups (A, B) without any hard
> limit and group A has soft limit set to 700M (to have 70% of available
> memory). Build starts after fresh boot by extracting sources and
> make -j4 vmlinux.
> Each group works on a separate source tree. I have repeated the test 3
> times:

[Cutting the previous results and keeping only averages for overview]
> * Patched:
> A:
> User time (seconds): Avg: 1133.76
> System time (seconds): Avg: 258.73
> Elapsed (wall clock) time (h:mm:ss or m:ss): Avg: 08:54.73
> 
> B:
> User time (seconds): Avg: 1151.19 (101.5% of A)
> System time (seconds): Avg: 262.09 (101.3% of A)
> Elapsed (wall clock) time (h:mm:ss or m:ss): Avg: 10:11.92 (114.4% of A)
> 
> * Base:
> A:
> User time (seconds): avg: 1136.30 (100.2% of A - patched)
> System time (seconds): avg: 263.47 (101.8 of A - patched)
> Elapsed (wall clock) time (h:mm:ss or m:ss): avg: 09:47.75 (109.9% of A - patched)
> 
> B:
> User time (seconds): avg: 1136.94 (100.2% of A - patched)
> System time (seconds): avg: 261.97  (100% of A - patched)
> Elapsed (wall clock) time (h:mm:ss or m:ss): avg: 09:47.75 (109.1% of A - patched)

Same test again with 300M soft limit instead (for A).
* Patched:
A:
User time (seconds): 1143.68, 1137.85, 1137.47
		avg:1139.67
System time (seconds): 264.73, 265.50, 262.44
		avg:264.22
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:54.07, 9:48.23, 9:39.35
		avg:09:47.22

B:
User time (seconds): 1139.10, 1135.94, 1138.13
		avg:1137.72 (99.8% of A)
System time (seconds): 260.94, 262.37, 263.56
		avg:262.29 (99.2% of A)
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:53.04, 9:48.17, 9:51.34
		avg:09:50.85 (100.6% of A)

Both groups are comparable now as both of them are reclaimed (see bellow
for the reclaim statistics).
So we are 1min slower (in Elapsed time) than with 700M soft limit for
both groups.

* Base:
A:
User time (seconds): 1148.50, 1145.96, 1144.60
		avg:1146.35 (100.5% of A patched)
System time (seconds): 265.00, 262.31, 264.98
		avg:264.10 (100% of A patched)
Elapsed (wall clock) time (h:mm:ss or m:ss): 10:44.57, 10:14.74, 10:32.28
		avg:10:30.53 (107.4% of A patched)

B:
User time (seconds): 1137.01, 1131.44, 1136.86
		avg:1135.10 (99.6% of A patched)
System time (seconds): 259.72, 259.05, 262.62
		avg:260.46 (98.6% of A patched)
Elapsed (wall clock) time (h:mm:ss or m:ss): 9:33.82, 9:25.39, 9:38.35
		avg:09:32.52 (97.5% of A patched)

A is hammered by soft reclaim much more than with 700M soft limit which
is expected.
If we sum A+B Elapsed time, though, then the workload is faster by ~2%
with the patched kernel (same as with the 700M limit). This confirms
that the soft limit is too harsh with the base kernel.
Just for completness, if we compare A+B to 700M soft limited runs then
we get ~3% slowdown for both patched and unpatched kernels with smaller
softlimit.

> * Patched:
> pgscan_direct_dma32 	252408
> pgscan_kswapd_dma32 	988928
> pgsteal_direct_dma32 	63565
> pgsteal_kswapd_dma32	905223
> 
> * Base:
> pgscan_direct_dma32 	97310	(38% of patched)
> pgscan_kswapd_dma32 	1702971	(172%)
> pgsteal_direct_dma32 	83377	(131%)
> pgsteal_kswapd_dma32 	1534616	(169.5%)

* Patched:
pgscan_direct_dma32 153455 	(60.8% Patched 700M limit)
pgscan_kswapd_dma32 1670779 	(168.9% Patched 700M limit)
pgsteal_direct_dma32 109624	(172.5% Patched 700M limit)
pgsteal_kswapd_dma32 1512120	(167% Patched 700M limit)

* Base:
pgscan_direct_dma32 492381	(320% of A)
pgscan_kswapd_dma32 1373732	(82.2% of A)
pgsteal_direct_dma32 339563	(309.8 of A)
pgsteal_kswapd_dma32 1108240	(73.3% of A)

And this shows it nicely. We scan and reclaim 3 times more in direct
reclaim context while we scan ~20% resp. reclaim ~30% less in the
background.

We scan and reclaim ~70% more in kswapd context than with 700M soft
limit but the direct reclaim is reduced which is nice.

Same graphs as for the 700M:
http://labs.suse.cz/mhocko/soft_limit_rework/kbuild/300-softlimit/base-usage.png
http://labs.suse.cz/mhocko/soft_limit_rework/kbuild/300-softlimit/patched-usage.png

charges over time. We can see that the patched kernel bahaves much more
just to both groups than the base kernel.

http://labs.suse.cz/mhocko/soft_limit_rework/kbuild/300-softlimit/base-usage-histogram.png
http://labs.suse.cz/mhocko/soft_limit_rework/kbuild/300-softlimit/patched-usage-histogram.png

Same can be seen in the histogram.

http://labs.suse.cz/mhocko/soft_limit_rework/kbuild/300-softlimit/pgscan.png
http://labs.suse.cz/mhocko/soft_limit_rework/kbuild/300-softlimit/pgsteal.png

And the scanning/reclaiming data over time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
