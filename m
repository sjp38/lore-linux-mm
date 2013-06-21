Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 6C6BD6B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 10:06:31 -0400 (EDT)
Date: Fri, 21 Jun 2013 16:06:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130621140627.GI12424@dhcp22.suse.cz>
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

Wow, this looks much better!

* 0-limit
User
base: min: 1188.28 max: 1198.54 avg: 1194.10 std: 3.31 runs: 6
baserebase: min: 1186.17 [99.8%] max: 1196.46 [99.8%] avg: 1189.75 [99.6%] std: 3.41 runs: 6
mel: min: 993.25 [83.6%] max: 997.40 [83.2%] avg: 995.81 [83.4%] std: 1.43 runs: 6
System
base: min: 248.40 max: 252.00 avg: 250.19 std: 1.38 runs: 6
baserebase: min: 240.77 [96.9%] max: 246.74 [97.9%] avg: 243.63 [97.4%] std: 2.23 runs: 6
mel: min: 145.36 [58.5%] max: 148.69 [59.0%] avg: 147.66 [59.0%] std: 1.17 runs: 6
Elapsed
base: min: 759.28 max: 805.30 avg: 784.87 std: 15.45 runs: 6
baserebase: min: 881.69 [116.1%] max: 938.14 [116.5%] avg: 911.68 [116.2%] std: 19.58 runs: 6
mel: min: 367.99 [48.5%] max: 381.67 [47.4%] avg: 371.84 [47.4%] std: 4.72 runs: 6

* no-limit
User
base: min: 1164.94 max: 1169.75 avg: 1168.31 std: 1.57 runs: 6
baserebase: min: 1169.46 [100.4%] max: 1176.07 [100.5%] avg: 1172.49 [100.4%] std: 2.38 runs: 6
mel: min: 993.46 [85.3%] max: 995.07 [85.1%] avg: 994.26 [85.1%] std: 0.56 runs: 6
System
base: min: 242.55 max: 245.36 avg: 243.92 std: 1.17 runs: 6
baserebase: min: 235.36 [97.0%] max: 238.52 [97.2%] avg: 236.70 [97.0%] std: 1.04 runs: 6
mel: min: 148.55 [61.2%] max: 151.80 [61.9%] avg: 149.80 [61.4%] std: 1.07 runs: 6
Elapsed
base: min: 596.81 max: 620.04 avg: 605.52 std: 7.56 runs: 6
baserebase: min: 666.45 [111.7%] max: 710.89 [114.7%] avg: 690.62 [114.1%] std: 13.85 runs: 6
mel: min: 366.85 [61.5%] max: 375.98 [60.6%] avg: 372.25 [61.5%] std: 3.18 runs: 6
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
