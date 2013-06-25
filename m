Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A06A86B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 11:49:08 -0400 (EDT)
Date: Tue, 25 Jun 2013 17:49:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130625154903.GA10617@dhcp22.suse.cz>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130620111206.GA14809@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130620111206.GA14809@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Thu 20-06-13 12:12:06, Mel Gorman wrote:
> On Tue, Jun 18, 2013 at 02:09:39PM +0200, Michal Hocko wrote:
> > base is mmotm-2013-05-09-15-57
> > baserebase is mmotm-2013-06-05-17-24-63 + patches from the current mmots
> > without slab shrinkers patchset.
> > reworkrebase all patches 8 applied on top of baserebase
> > 
> > * No-limit
> > User
> > base: min: 1164.94 max: 1169.75 avg: 1168.31 std: 1.57 runs: 6
> > baserebase: min: 1169.46 [100.4%] max: 1176.07 [100.5%] avg: 1172.49 [100.4%] std: 2.38 runs: 6
> > reworkrebase: min: 1172.58 [100.7%] max: 1177.43 [100.7%] avg: 1175.53 [100.6%] std: 1.91 runs: 6
> > System
> > base: min: 242.55 max: 245.36 avg: 243.92 std: 1.17 runs: 6
> > baserebase: min: 235.36 [97.0%] max: 238.52 [97.2%] avg: 236.70 [97.0%] std: 1.04 runs: 6
> > reworkrebase: min: 236.21 [97.4%] max: 239.46 [97.6%] avg: 237.55 [97.4%] std: 1.05 runs: 6
> > Elapsed
> > base: min: 596.81 max: 620.04 avg: 605.52 std: 7.56 runs: 6
> > baserebase: min: 666.45 [111.7%] max: 710.89 [114.7%] avg: 690.62 [114.1%] std: 13.85 runs: 6
> > reworkrebase: min: 664.05 [111.3%] max: 701.06 [113.1%] avg: 689.29 [113.8%] std: 12.36 runs: 6
> > 
> > Elapsed time regressed by 13% wrt. base but it seems that this came from
> > baserebase which regressed by the same amount.
> > 
> 
> boo-urns
> 
> > Page fault statistics tell us at least part of the story:
> > Minor
> > base: min: 35941845.00 max: 36029788.00 avg: 35986860.17 std: 28288.66 runs: 6
> > baserebase: min: 35852414.00 [99.8%] max: 35899605.00 [99.6%] avg: 35874906.83 [99.7%] std: 18722.59 runs: 6
> > reworkrebase: min: 35538346.00 [98.9%] max: 35584907.00 [98.8%] avg: 35562362.17 [98.8%] std: 18921.74 runs: 6
> > Major
> > base: min: 25390.00 max: 33132.00 avg: 29961.83 std: 2476.58 runs: 6
> > baserebase: min: 34224.00 [134.8%] max: 45674.00 [137.9%] avg: 41556.83 [138.7%] std: 3595.39 runs: 6
> > reworkrebase: min: 277.00 [1.1%] max: 480.00 [1.4%] avg: 384.67 [1.3%] std: 74.67 runs: 6
> 
> Can you try this monolithic patch please?

Now that I've tested the patch properly, finally, I have to say that the
situation has improved.
0-limit case has a bigger variation with 15% regression in the worst
case and down to 4% regression in the best case (which gets us to 7% on
average).
no-limit configuration behaves better. The worst case is not so bad and
we are down to 3% regression in average.

* 0-limit
User
base: min: 1188.28 max: 1198.54 avg: 1194.10 std: 3.31 runs: 6
baserebase: min: 1186.17 [99.8%] max: 1196.46 [99.8%] avg: 1189.75 [99.6%] std: 3.41 runs: 6
mel: min: 1183.62 [99.6%] max: 1208.19 [100.8%] avg: 1194.00 [100.0%] std: 8.71 runs: 6
System
base: min: 248.40 max: 252.00 avg: 250.19 std: 1.38 runs: 6
baserebase: min: 240.77 [96.9%] max: 246.74 [97.9%] avg: 243.63 [97.4%] std: 2.23 runs: 6
mel: min: 249.41 [100.4%] max: 253.34 [100.5%] avg: 251.28 [100.4%] std: 1.20 runs: 6
Elapsed
base: min: 759.28 max: 805.30 avg: 784.87 std: 15.45 runs: 6
baserebase: min: 881.69 [116.1%] max: 938.14 [116.5%] avg: 911.68 [116.2%] std: 19.58 runs: 6
mel: min: 789.62 [104.0%] max: 928.68 [115.3%] avg: 845.62 [107.7%] std: 59.31 runs: 6

* no-limit
User
base: min: 1164.94 max: 1169.75 avg: 1168.31 std: 1.57 runs: 6
baserebase: min: 1169.46 [100.4%] max: 1176.07 [100.5%] avg: 1172.49 [100.4%] std: 2.38 runs: 6
mel: min: 1174.58 [100.8%] max: 1176.46 [100.6%] avg: 1175.53 [100.6%] std: 0.59 runs: 6
System
base: min: 242.55 max: 245.36 avg: 243.92 std: 1.17 runs: 6
baserebase: min: 235.36 [97.0%] max: 238.52 [97.2%] avg: 236.70 [97.0%] std: 1.04 runs: 6
mel: min: 244.79 [100.9%] max: 246.86 [100.6%] avg: 246.30 [101.0%] std: 0.76 runs: 6
Elapsed
base: min: 596.81 max: 620.04 avg: 605.52 std: 7.56 runs: 6
baserebase: min: 666.45 [111.7%] max: 710.89 [114.7%] avg: 690.62 [114.1%] std: 13.85 runs: 6
mel: min: 618.77 [103.7%] max: 637.84 [102.9%] avg: 627.92 [103.7%] std: 6.64 runs: 6
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
