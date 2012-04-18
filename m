Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 46E346B0083
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 08:25:44 -0400 (EDT)
Date: Wed, 18 Apr 2012 14:24:48 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
Message-ID: <20120418122448.GB1771@cmpxchg.org>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334680666-12361-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Apr 17, 2012 at 09:37:46AM -0700, Ying Han wrote:
> The "soft_limit" was introduced in memcg to support over-committing the
> memory resource on the host. Each cgroup configures its "hard_limit" where
> it will be throttled or OOM killed by going over the limit. However, the
> cgroup can go above the "soft_limit" as long as there is no system-wide
> memory contention. So, the "soft_limit" is the kernel mechanism for
> re-distributing system spare memory among cgroups.
> 
> This patch reworks the softlimit reclaim by hooking it into the new global
> reclaim scheme. So the global reclaim path including direct reclaim and
> background reclaim will respect the memcg softlimit.
> 
> v3..v2:
> 1. rebase the patch on 3.4-rc3
> 2. squash the commits of replacing the old implementation with new
> implementation into one commit. This is to make sure to leave the tree
> in stable state between each commit.
> 3. removed the commit which changes the nr_to_reclaim for global reclaim
> case. The need of that patch is not obvious now.
> 
> Note:
> 1. the new implementation of softlimit reclaim is rather simple and first
> step for further optimizations. there is no memory pressure balancing between
> memcgs for each zone, and that is something we would like to add as follow-ups.
> 
> 2. this patch is slightly different from the last one posted from Johannes
> http://comments.gmane.org/gmane.linux.kernel.mm/72382
> where his patch is closer to the reverted implementation by doing hierarchical
> reclaim for each selected memcg. However, that is not expected behavior from
> user perspective. Considering the following example:
> 
> root (32G capacity)
> --> A (hard limit 20G, soft limit 15G, usage 16G)
>    --> A1 (soft limit 5G, usage 4G)
>    --> A2 (soft limit 10G, usage 12G)
> --> B (hard limit 20G, soft limit 10G, usage 16G)
> 
> Under global reclaim, we shouldn't add pressure on A1 although its parent(A)
> exceeds softlimit. This is what admin expects by setting softlimit to the
> actual working set size and only reclaim pages under softlimit if system has
> trouble to reclaim.

Actually, this is exactly what the admin expects when creating a
hierarchy, because she defines that A1 is a child of A and is
responsible for the memory situation in its parent.

That's the single point of having a hierarchy.  Why do you create them
if you don't want their behaviour?

And A does not have its own pages (usage is just the sum of its
children), what SHOULD its soft limit even mean in your example?

If you had

    A (hard 20G, usage 16G)
       A1 (soft  5G, usage  4G)
       A2 (soft 10G, usage 12G)
    B (hard 20G, soft 10G, usage 16G)

(i.e. no soft limit on A), you could reasonably make it so that on
global reclaim, only A2 and B would get reclaimed, like you want it
to, while still keeping the hierarchical properties of soft limits.
If you want soft limits applied to leaf nodes only, don't set them
anywhere else..?

Ultimately, we want to support nesting memcgs within containers.  For
this reason, they need to be applied hierarchically, or the admin of
the host does not have soft limit control over untrusted guest groups:

    container A (hard 20G, soft 16G)
      group A-1 (soft 100G)
    container B (hard 20G, soft 16G)
      group B-1

In this case under global memory pressure, contrary to your claims, we
actually do want to from reclaim A-1, not just from B-1.  Otherwise, a
container could gain priority over another one by setting ridiculous
soft limits.

We have been at this point a couple times.  Could you please explain
what you are trying to do in the first place, why you need
hierarchies, why you configure them like you do?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
