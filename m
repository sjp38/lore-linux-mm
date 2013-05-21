Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id DA12C6B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 02:53:33 -0400 (EDT)
Date: Tue, 21 May 2013 08:53:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
Message-ID: <20130521065329.GA9306@dhcp22.suse.cz>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
 <1368431172-6844-2-git-send-email-mhocko@suse.cz>
 <20130517160247.GA10023@cmpxchg.org>
 <20130520144438.GB24689@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130520144438.GB24689@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

On Mon 20-05-13 16:44:38, Michal Hocko wrote:
[...]
> I had one group (call it A) with the streaming IO load (dd if=/dev/zero
> of=file with 4*TotalRam size) and a parallel hierarchy with 2 groups
> with up to 12 levels each (512, 1024, 4096, 8192 groups) and no limit
> set.  I have compared the results with the same configuration with the
> base kernel.
> Two configurations have been tested. `A' group without any soft limit and
> with limit set to 0. The first configuration measures overhead of an
> additional pass as there is no soft reclaim done in both the base kernel
> and the rework. The second configuration compares the effectiveness of
> the reworked implementation wrt. the base kernel.

And I have forgotten to mention that the machine was booted with mem=1G
so there was only a single node without Normal zone. This setup with
only a single mem hog makes the original implementation really effective
because there is a good chance that the aggressive soft limit reclaim
prevents from getting into shrink_zone most of the time thus prevent
from iterating all groups.
The reality with bigger machines is quite different though. The
per-node tree where a group is inserted depends on timing because
mem_cgroup_update_tree uses the current page for the decision. So the
group can be hanging on the node where it charged just few pages.
So the figures below show the close the best case with an average case.

As I have already said. The numbers can be improved but is it essential
to do it right now rather than slowly evolve to something smarter?
 
> * No soft limit set 
> Elapsed
> 500-no-limit/base: min: 16.32 max: 18.03 avg: 17.37 std: 0.75 runs: 3
> 500-no-limit/rework: min: 15.76 [96.6%] max: 19.72 [109.4%] avg: 17.49 [100.7%] std: 1.66 runs: 3
> User
> 500-no-limit/base: min: 1.53 max: 1.60 avg: 1.57 std: 0.03 runs: 3
> 500-no-limit/rework: min: 1.18 [77.1%] max: 1.45 [90.6%] avg: 1.33 [84.7%] std: 0.11 runs: 3
> System
> 500-no-limit/base: min: 38.60 max: 41.54 avg: 39.95 std: 1.21 runs: 3
> 500-no-limit/rework: min: 39.78 [103.1%] max: 42.93 [103.3%] avg: 41.06 [102.8%] std: 1.35 runs: 3
> 
> Elapsed
> 1k-no-limit/base: min: 37.04 max: 43.36 avg: 40.26 std: 2.58 runs: 3
> 1k-no-limit/rework: min: 16.38 [44.2%] max: 17.82 [41.1%] avg: 17.22 [42.8%] std: 0.61 runs: 3
> User
> 1k-no-limit/base: min: 1.12 max: 1.38 avg: 1.24 std: 0.11 runs: 3
> 1k-no-limit/rework: min: 1.11 [99.1%] max: 1.26 [91.3%] avg: 1.20 [96.8%] std: 0.07 runs: 3
> System
> 1k-no-limit/base: min: 33.51 max: 36.29 avg: 34.99 std: 1.14 runs: 3
> 1k-no-limit/rework: min: 45.09 [134.6%] max: 49.52 [136.5%] avg: 47.99 [137.2%] std: 2.05 runs: 3
> 
> Elapsed
> 4k-no-limit/base: min: 40.04 max: 47.14 avg: 44.46 std: 3.15 runs: 3
> 4k-no-limit/rework: min: 30.38 [75.9%] max: 37.66 [79.9%] avg: 34.24 [77.0%] std: 2.99 runs: 3
> User
> 4k-no-limit/base: min: 1.16 max: 1.33 avg: 1.25 std: 0.07 runs: 3
> 4k-no-limit/rework: min: 0.70 [60.3%] max: 0.82 [61.7%] avg: 0.77 [61.6%] std: 0.05 runs: 3
> System
> 4k-no-limit/base: min: 37.91 max: 39.91 avg: 39.19 std: 0.91 runs: 3
> 4k-no-limit/rework: min: 130.35 [343.8%] max: 133.26 [333.9%] avg: 131.63 [335.9%] std: 1.21 runs: 3
> 
> Elapsed
> 8k-no-limit/base: min: 41.27 max: 50.60 avg: 45.51 std: 3.86 runs: 3
> 8k-no-limit/rework: min: 39.56 [95.9%] max: 52.12 [103.0%] avg: 44.49 [97.8%] std: 5.47 runs: 3
> User
> 8k-no-limit/base: min: 1.26 max: 1.38 avg: 1.32 std: 0.05 runs: 3
> 8k-no-limit/rework: min: 0.68 [54.0%] max: 0.82 [59.4%] avg: 0.73 [55.3%] std: 0.06 runs: 3
> System
> 8k-no-limit/base: min: 39.93 max: 40.73 avg: 40.25 std: 0.34 runs: 3
> 8k-no-limit/rework: min: 228.74 [572.9%] max: 238.43 [585.4%] avg: 232.57 [577.8%] std: 4.21 runs: 3
> 
> * Soft limit set to 0 for the group with the dd load
> Elapsed
> 500-0-limit/base: min: 30.29 max: 38.91 avg: 34.83 std: 3.53 runs: 3
> 500-0-limit/rework: min: 14.34 [47.3%] max: 17.18 [44.2%] avg: 16.01 [46.0%] std: 1.21 runs: 3
> User
> 500-0-limit/base: min: 1.14 max: 1.29 avg: 1.24 std: 0.07 runs: 3
> 500-0-limit/rework: min: 1.42 [124.6%] max: 1.47 [114.0%] avg: 1.44 [116.1%] std: 0.02 runs: 3
> System
> 500-0-limit/base: min: 31.94 max: 35.66 avg: 33.77 std: 1.52 runs: 3
> 500-0-limit/rework: min: 45.25 [141.7%] max: 47.43 [133.0%] avg: 46.27 [137.0%] std: 0.89 runs: 3
> 
> Elapsed
> 1k-0-limit/base: min: 37.23 max: 45.11 avg: 40.48 std: 3.36 runs: 3
> 1k-0-limit/rework: min: 15.18 [40.8%] max: 18.69 [41.4%] avg: 16.99 [42.0%] std: 1.44 runs: 3
> User
> 1k-0-limit/base: min: 1.33 max: 1.56 avg: 1.44 std: 0.09 runs: 3
> 1k-0-limit/rework: min: 1.31 [98.5%] max: 1.55 [99.4%] avg: 1.44 [100.0%] std: 0.10 runs: 3
> System
> 1k-0-limit/base: min: 33.21 max: 34.44 avg: 33.77 std: 0.51 runs: 3
> 1k-0-limit/rework: min: 45.52 [137.1%] max: 50.82 [147.6%] avg: 48.76 [144.4%] std: 2.32 runs: 3
> 
> Elapsed
> 4k-0-limit/base: min: 42.71 max: 47.83 avg: 45.45 std: 2.11 runs: 3
> 4k-0-limit/rework: min: 34.24 [80.2%] max: 34.99 [73.2%] avg: 34.56 [76.0%] std: 0.32 runs: 3
> User
> 4k-0-limit/base: min: 1.11 max: 1.34 avg: 1.21 std: 0.10 runs: 3
> 4k-0-limit/rework: min: 0.80 [72.1%] max: 0.87 [64.9%] avg: 0.83 [68.6%] std: 0.03 runs: 3
> System
> 4k-0-limit/base: min: 37.08 max: 40.28 avg: 38.91 std: 1.35 runs: 3
> 4k-0-limit/rework: min: 131.08 [353.5%] max: 132.33 [328.5%] avg: 131.66 [338.4%] std: 0.51 runs: 3
> 
> Elapsed
> 8k-0-limit/base: min: 35.71 max: 47.18 avg: 43.19 std: 5.29 runs: 3
> 8k-0-limit/rework: min: 43.95 [123.1%] max: 59.77 [126.7%] avg: 50.48 [116.9%] std: 6.75 runs: 3
> User
> 8k-0-limit/base: min: 1.18 max: 1.21 avg: 1.19 std: 0.01 runs: 3
> 8k-0-limit/rework: min: 0.72 [61.0%] max: 0.85 [70.2%] avg: 0.77 [64.7%] std: 0.06 runs: 3
> System
> 8k-0-limit/base: min: 38.34 max: 39.91 avg: 39.24 std: 0.66 runs: 3
> 8k-0-limit/rework: min: 196.90 [513.6%] max: 235.32 [589.6%] avg: 222.34 [566.6%] std: 17.99 runs: 3
> 
> As we can see the System time climbs really high but the Elapsed time
> is better than in the base kernel (except for 8k-0-limit). If we had
> more reclaimers then the system time should be amortized more because
> the reclaim tree walk is shared.
> 
> I think that the numbers can be improved even without introducing
> the list of groups in excess. One way to go could be introducing a
> conditional (callback) to the memcg iterator so the groups under the
> limit would be excluded during the walk without playing with css
> references and other things. My quick and dirty patch shows that
> 4k-0-limit System time was reduced by 40% wrt. this patchset. With a
> proper tagging we can make the walk close to free.
> 
> Nevertheless, I guess I can live with the excess list as well if the
> above sounds like a no-go for you.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
