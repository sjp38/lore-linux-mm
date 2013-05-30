Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9F7176B0002
	for <linux-mm@kvack.org>; Thu, 30 May 2013 04:36:52 -0400 (EDT)
Date: Thu, 30 May 2013 10:36:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
Message-ID: <20130530083650.GB3582@dhcp22.suse.cz>
References: <20130517160247.GA10023@cmpxchg.org>
 <1369674791-13861-1-git-send-email-mhocko@suse.cz>
 <20130529145400.GG10224@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529145400.GG10224@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 29-05-13 16:54:00, Michal Hocko wrote:
[...]
> I am still running kbuild tests with the same configuration to see a
> more general workload.

And here we go with the kbuild numbers. Same configuration (mem=1G, one
group for kernel build - it is actually expand the three + build a
distro config + bunch of groups under root/bunch).
System
0-0-limit/base: min: 242.70 max: 245.17 avg: 243.85 std: 1.02 runs: 3
0-0-limit/reclaim: min: 237.86 [98.0%] max: 240.22 [98.0%] avg: 239.00 [98.0%] std: 0.97 runs: 3
0-0-limit/reworkoptim: min: 241.11 [99.3%] max: 243.53 [99.3%] avg: 242.01 [99.2%] std: 1.08 runs: 3
Elapsed
0-0-limit/base: min: 348.48 max: 360.86 avg: 356.04 std: 5.41 runs: 3
0-0-limit/reclaim: min: 286.95 [82.3%] max: 290.26 [80.4%] avg: 288.27 [81.0%] std: 1.43 runs: 3
0-0-limit/reworkoptim: min: 286.55 [82.2%] max: 289.00 [80.1%] avg: 287.69 [80.8%] std: 1.01 runs: 3
System
0.5k-0-limit/base: min: 251.77 max: 254.41 avg: 252.70 std: 1.21 runs: 3
0.5k-0-limit/reclaim: min: 286.44 [113.8%] max: 289.30 [113.7%] avg: 287.60 [113.8%] std: 1.23 runs: 3
0.5k-0-limit/reworkoptim: min: 252.18 [100.2%] max: 253.16 [99.5%] avg: 252.62 [100.0%] std: 0.41 runs: 3
Elapsed
0.5k-0-limit/base: min: 347.83 max: 353.06 avg: 350.04 std: 2.21 runs: 3
0.5k-0-limit/reclaim: min: 290.19 [83.4%] max: 295.62 [83.7%] avg: 293.12 [83.7%] std: 2.24 runs: 3
0.5k-0-limit/reworkoptim: min: 293.91 [84.5%] max: 294.87 [83.5%] avg: 294.29 [84.1%] std: 0.42 runs: 3
System
2k-0-limit/base: min: 263.05 max: 271.52 avg: 267.94 std: 3.58 runs: 3
2k-0-limit/reclaim: min: 458.99 [174.5%] max: 468.31 [172.5%] avg: 464.45 [173.3%] std: 3.97 runs: 3
2k-0-limit/reworkoptim: min: 267.10 [101.5%] max: 279.38 [102.9%] avg: 272.78 [101.8%] std: 5.05 runs: 3
Elapsed
2k-0-limit/base: min: 372.33 max: 379.32 avg: 375.47 std: 2.90 runs: 3
2k-0-limit/reclaim: min: 334.40 [89.8%] max: 339.52 [89.5%] avg: 337.44 [89.9%] std: 2.20 runs: 3
2k-0-limit/reworkoptim: min: 301.47 [81.0%] max: 319.19 [84.1%] avg: 307.90 [82.0%] std: 8.01 runs: 3
System
8k-0-limit/base: min: 320.50 max: 332.10 avg: 325.46 std: 4.88 runs: 3
8k-0-limit/reclaim: min: 1115.76 [348.1%] max: 1165.66 [351.0%] avg: 1132.65 [348.0%] std: 23.34 runs: 3
8k-0-limit/reworkoptim: min: 403.75 [126.0%] max: 409.22 [123.2%] avg: 406.16 [124.8%] std: 2.28 runs: 3
Elapsed
8k-0-limit/base: min: 475.48 max: 585.19 avg: 525.54 std: 45.30 runs: 3
8k-0-limit/reclaim: min: 616.25 [129.6%] max: 625.90 [107.0%] avg: 620.68 [118.1%] std: 3.98 runs: 3
8k-0-limit/reworkoptim: min: 420.18 [88.4%] max: 428.28 [73.2%] avg: 423.05 [80.5%] std: 3.71 runs: 3

Apart from 8k the system time is comparable with the base kernel while
Elapsed is up to 20% better with all configurations.

And with not soft limit set
System
0-no-limit/base: min: 234.76 max: 237.42 avg: 236.25 std: 1.11 runs: 3
0-no-limit/reclaim: min: 233.09 [99.3%] max: 238.65 [100.5%] avg: 236.09 [99.9%] std: 2.29 runs: 3
0-no-limit/reworkoptim: min: 236.12 [100.6%] max: 240.53 [101.3%] avg: 237.94 [100.7%] std: 1.88 runs: 3
Elapsed
0-no-limit/base: min: 288.52 max: 295.42 avg: 291.29 std: 2.98 runs: 3
0-no-limit/reclaim: min: 283.17 [98.1%] max: 284.33 [96.2%] avg: 283.78 [97.4%] std: 0.48 runs: 3
0-no-limit/reworkoptim: min: 288.50 [100.0%] max: 290.79 [98.4%] avg: 289.78 [99.5%] std: 0.95 runs: 3
System
0.5k-no-limit/base: min: 286.51 max: 293.23 avg: 290.21 std: 2.78 runs: 3
0.5k-no-limit/reclaim: min: 291.69 [101.8%] max: 294.38 [100.4%] avg: 292.97 [101.0%] std: 1.10 runs: 3
0.5k-no-limit/reworkoptim: min: 277.05 [96.7%] max: 288.76 [98.5%] avg: 284.17 [97.9%] std: 5.11 runs: 3
Elapsed
0.5k-no-limit/base: min: 294.94 max: 298.92 avg: 296.47 std: 1.75 runs: 3
0.5k-no-limit/reclaim: min: 292.55 [99.2%] max: 294.21 [98.4%] avg: 293.55 [99.0%] std: 0.72 runs: 3
0.5k-no-limit/reworkoptim: min: 294.41 [99.8%] max: 301.67 [100.9%] avg: 297.78 [100.4%] std: 2.99 runs: 3
System
2k-no-limit/base: min: 443.41 max: 466.66 avg: 457.66 std: 10.19 runs: 3
2k-no-limit/reclaim: min: 490.11 [110.5%] max: 516.02 [110.6%] avg: 501.42 [109.6%] std: 10.83 runs: 3
2k-no-limit/reworkoptim: min: 435.25 [98.2%] max: 458.11 [98.2%] avg: 446.73 [97.6%] std: 9.33 runs: 3
Elapsed
2k-no-limit/base: min: 330.85 max: 333.75 avg: 332.52 std: 1.23 runs: 3
2k-no-limit/reclaim: min: 343.06 [103.7%] max: 349.59 [104.7%] avg: 345.95 [104.0%] std: 2.72 runs: 3
2k-no-limit/reworkoptim: min: 330.01 [99.7%] max: 333.92 [100.1%] avg: 332.22 [99.9%] std: 1.64 runs: 3
System
8k-no-limit/base: min: 1175.64 max: 1259.38 avg: 1222.39 std: 34.88 runs: 3
8k-no-limit/reclaim: min: 1226.31 [104.3%] max: 1241.60 [98.6%] avg: 1233.74 [100.9%] std: 6.25 runs: 3
8k-no-limit/reworkoptim: min: 1023.45 [87.1%] max: 1056.74 [83.9%] avg: 1038.92 [85.0%] std: 13.69 runs: 3
Elapsed
8k-no-limit/base: min: 613.36 max: 619.60 avg: 616.47 std: 2.55 runs: 3
8k-no-limit/reclaim: min: 627.56 [102.3%] max: 642.33 [103.7%] avg: 633.44 [102.8%] std: 6.39 runs: 3
8k-no-limit/reworkoptim: min: 545.89 [89.0%] max: 555.36 [89.6%] avg: 552.06 [89.6%] std: 4.37 runs: 3

and these numbers look good as well. System time is around 100%
(suprisingly better for the 8k case) and Elapsed is copies that trend.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
