Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C33926B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 04:41:19 -0400 (EDT)
Message-ID: <51934A62.2030606@parallels.com>
Date: Wed, 15 May 2013 12:42:10 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch v3 -mm 3/3] vmscan, memcg: Do softlimit reclaim also for
 targeted reclaim
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz> <1368431172-6844-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1368431172-6844-4-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

On 05/13/2013 11:46 AM, Michal Hocko wrote:
> Soft reclaim has been done only for the global reclaim (both background
> and direct). Since "memcg: integrate soft reclaim tighter with zone
> shrinking code" there is no reason for this limitation anymore as the
> soft limit reclaim doesn't use any special code paths and it is a
> part of the zone shrinking code which is used by both global and
> targeted reclaims.
> 
> From semantic point of view it is even natural to consider soft limit
> before touching all groups in the hierarchy tree which is touching the
> hard limit because soft limit tells us where to push back when there is
> a  memory pressure. It is not important whether the pressure comes from
> the limit or imbalanced zones.
> 
> This patch simply enables soft reclaim unconditionally in
> mem_cgroup_should_soft_reclaim so it is enabled for both global and
> targeted reclaim paths. mem_cgroup_soft_reclaim_eligible needs to learn
> about the root of the reclaim to know where to stop checking soft limit
> state of parents up the hierarchy.
> Say we have
> A (over soft limit)
>  \
>   B (below s.l., hit the hard limit)
>  / \
> C   D (below s.l.)
> 
> B is the source of the outside memory pressure now for D but we
> shouldn't soft reclaim it because it is behaving well under B subtree
> and we can still reclaim from C (pressumably it is over the limit).
> mem_cgroup_soft_reclaim_eligible should therefore stop climbing up the
> hierarchy at B (root of the memory pressure).
> 
> Changes since v1
> - add sc->target_mem_cgroup handling into mem_cgroup_soft_reclaim_eligible
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---

Reviewed-by: Glauber Costa <glommer@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
