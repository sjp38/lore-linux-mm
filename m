Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 75A166B013D
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:54:06 -0400 (EDT)
Date: Wed, 29 May 2013 16:54:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
Message-ID: <20130529145400.GG10224@dhcp22.suse.cz>
References: <20130517160247.GA10023@cmpxchg.org>
 <1369674791-13861-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369674791-13861-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 27-05-13 19:13:08, Michal Hocko wrote:
[...]
> > I think that the numbers can be improved even without introducing
> > the list of groups in excess. One way to go could be introducing a
> > conditional (callback) to the memcg iterator so the groups under the
> > limit would be excluded during the walk without playing with css
> > references and other things. My quick and dirty patch shows that
> > 4k-0-limit System time was reduced by 40% wrt. this patchset. With a
> > proper tagging we can make the walk close to free.
> 
> And the following patchset implements that. My first numbers shown an
> improvement (I will post some numbers later after I collect them).

With that series applied (+some minor cleanups - no functional changes)
I am getting much numbers this time. Again the test case is a streaming
IO (dd from /dev/zero to a file with 4*MemTotal) booted with mem=1G so
there are just DMA and DMA32 zones. This helps the previous soft limit
implementation as the over limit group will be in the proper mztree.

The load was running in a group (A) and other groups were created under
the root/bunch cgroups (with use_hierarchy and two groups at each
level). I have ran each test 3 times. rework denotes to the original
series, reworkoptim contains 3 patches on top.  First number in the name
tells us the number of groups under root/bunch and the second the soft
limit for A.

System
0-0-limit/base: min: 32.45 max: 36.91 avg: 34.65 std: 1.82 runs: 3
0-0-limit/rework: min: 38.03 [117.2%] max: 45.30 [122.7%] avg: 42.30 [122.1%] std: 3.10 runs: 3
0-0-limit/reworkoptim: min: 43.99 [135.6%] max: 47.80 [129.5%] avg: 45.45 [131.2%] std: 1.68 runs: 3
Elapsed
0-0-limit/base: min: 88.21 max: 94.61 avg: 91.73 std: 2.65 runs: 3
0-0-limit/rework: min: 76.05 [86.2%] max: 79.08 [83.6%] avg: 77.84 [84.9%] std: 1.30 runs: 3
0-0-limit/reworkoptim: min: 77.98 [88.4%] max: 80.36 [84.9%] avg: 78.92 [86.0%] std: 1.03 runs: 3
System
0.5k-0-limit/base: min: 34.86 max: 36.42 avg: 35.89 std: 0.73 runs: 3
0.5k-0-limit/rework: min: 43.26 [124.1%] max: 48.95 [134.4%] avg: 46.09 [128.4%] std: 2.32 runs: 3
0.5k-0-limit/reworkoptim: min: 46.98 [134.8%] max: 50.98 [140.0%] avg: 48.49 [135.1%] std: 1.77 runs: 3
Elapsed
0.5k-0-limit/base: min: 88.50 max: 97.52 avg: 93.92 std: 3.90 runs: 3
0.5k-0-limit/rework: min: 75.92 [85.8%] max: 78.45 [80.4%] avg: 77.34 [82.3%] std: 1.06 runs: 3
0.5k-0-limit/reworkoptim: min: 75.79 [85.6%] max: 79.37 [81.4%] avg: 77.55 [82.6%] std: 1.46 runs: 3
System
2k-0-limit/base: min: 34.57 max: 37.65 avg: 36.34 std: 1.30 runs: 3
2k-0-limit/rework: min: 64.17 [185.6%] max: 68.20 [181.1%] avg: 66.21 [182.2%] std: 1.65 runs: 3
2k-0-limit/reworkoptim: min: 49.78 [144.0%] max: 52.99 [140.7%] avg: 51.00 [140.3%] std: 1.42 runs: 3
Elapsed
2k-0-limit/base: min: 92.61 max: 97.83 avg: 95.03 std: 2.15 runs: 3
2k-0-limit/rework: min: 78.33 [84.6%] max: 84.08 [85.9%] avg: 81.09 [85.3%] std: 2.35 runs: 3
2k-0-limit/reworkoptim: min: 75.72 [81.8%] max: 78.57 [80.3%] avg: 76.73 [80.7%] std: 1.30 runs: 3
System
8k-0-limit/base: min: 39.78 max: 42.09 avg: 41.09 std: 0.97 runs: 3
8k-0-limit/rework: min: 200.86 [504.9%] max: 265.42 [630.6%] avg: 241.80 [588.5%] std: 29.06 runs: 3
8k-0-limit/reworkoptim: min: 53.70 [135.0%] max: 54.89 [130.4%] avg: 54.43 [132.5%] std: 0.52 runs: 3
Elapsed
8k-0-limit/base: min: 95.11 max: 98.61 avg: 96.81 std: 1.43 runs: 3
8k-0-limit/rework: min: 246.96 [259.7%] max: 331.47 [336.1%] avg: 301.32 [311.2%] std: 38.52 runs: 3
8k-0-limit/reworkoptim: min: 76.79 [80.7%] max: 81.71 [82.9%] avg: 78.97 [81.6%] std: 2.05 runs: 3

The System time is increased by ~30-40% which can be explained by the
fact that the original soft reclaim scanned at priority 0 so it was much
more effective for this workload (which is basically touch once and
writeback). The Elapsed time looks better though (~20%) which sounds
like a good news to me.

The tree walk overhead seems to be reduced considerably if we compare
reworkoptim to rework.

Same test without soft limit set to A:
System
0-no-limit/base: min: 42.18 max: 50.38 avg: 46.44 std: 3.36 runs: 3
0-no-limit/rework: min: 40.57 [96.2%] max: 47.04 [93.4%] avg: 43.82 [94.4%] std: 2.64 runs: 3
0-no-limit/reworkoptim: min: 40.45 [95.9%] max: 45.28 [89.9%] avg: 42.10 [90.7%] std: 2.25 runs: 3
Elapsed
0-no-limit/base: min: 75.97 max: 78.21 avg: 76.87 std: 0.96 runs: 3
0-no-limit/rework: min: 75.59 [99.5%] max: 80.73 [103.2%] avg: 77.64 [101.0%] std: 2.23 runs: 3
0-no-limit/reworkoptim: min: 77.85 [102.5%] max: 82.42 [105.4%] avg: 79.64 [103.6%] std: 1.99 runs: 3
System
0.5k-no-limit/base: min: 44.54 max: 46.93 avg: 46.12 std: 1.12 runs: 3
0.5k-no-limit/rework: min: 42.09 [94.5%] max: 46.16 [98.4%] avg: 43.92 [95.2%] std: 1.69 runs: 3
0.5k-no-limit/reworkoptim: min: 42.47 [95.4%] max: 45.67 [97.3%] avg: 44.06 [95.5%] std: 1.31 runs: 3
Elapsed
0.5k-no-limit/base: min: 78.26 max: 81.49 avg: 79.65 std: 1.36 runs: 3
0.5k-no-limit/rework: min: 77.01 [98.4%] max: 80.43 [98.7%] avg: 78.30 [98.3%] std: 1.52 runs: 3
0.5k-no-limit/reworkoptim: min: 76.13 [97.3%] max: 77.87 [95.6%] avg: 77.18 [96.9%] std: 0.75 runs: 3
System
2k-no-limit/base: min: 62.96 max: 69.14 avg: 66.14 std: 2.53 runs: 3
2k-no-limit/rework: min: 76.01 [120.7%] max: 81.06 [117.2%] avg: 78.17 [118.2%] std: 2.12 runs: 3
2k-no-limit/reworkoptim: min: 62.57 [99.4%] max: 66.10 [95.6%] avg: 64.53 [97.6%] std: 1.47 runs: 3
Elapsed
2k-no-limit/base: min: 76.47 max: 84.22 avg: 79.12 std: 3.60 runs: 3
2k-no-limit/rework: min: 89.67 [117.3%] max: 93.26 [110.7%] avg: 91.10 [115.1%] std: 1.55 runs: 3
2k-no-limit/reworkoptim: min: 76.94 [100.6%] max: 79.21 [94.1%] avg: 78.45 [99.2%] std: 1.07 runs: 3
System
8k-no-limit/base: min: 104.74 max: 151.34 avg: 129.21 std: 19.10 runs: 3
8k-no-limit/rework: min: 205.23 [195.9%] max: 285.94 [188.9%] avg: 258.98 [200.4%] std: 38.01 runs: 3
8k-no-limit/reworkoptim: min: 161.16 [153.9%] max: 184.54 [121.9%] avg: 174.52 [135.1%] std: 9.83 runs: 3
Elapsed
8k-no-limit/base: min: 125.43 max: 181.00 avg: 154.81 std: 22.80 runs: 3
8k-no-limit/rework: min: 254.05 [202.5%] max: 355.67 [196.5%] avg: 321.46 [207.6%] std: 47.67 runs: 3
8k-no-limit/reworkoptim: min: 193.77 [154.5%] max: 222.72 [123.0%] avg: 210.18 [135.8%] std: 12.13 runs: 3

Both System and Elapsed are in stdev with the base kernel for all
configurations except for 8k where both System and Elapsed are up by
35%. I do not have a good explanation for this because there is no soft
reclaim pass going on as no group is above the limit which is checked in
mem_cgroup_should_soft_reclaim.

I am still running kbuild tests with the same configuration to see a
more general workload.

Does this sound like it reasonable mitigation of the issue you were
worried about Johannes?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
