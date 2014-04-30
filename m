Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 842F56B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 19:04:02 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e51so1807203eek.16
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:04:02 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 45si32354526eeh.3.2014.04.30.16.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 16:04:01 -0700 (PDT)
Date: Wed, 30 Apr 2014 19:03:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] memcg, doc: clarify global vs. limit reclaims
Message-ID: <20140430230350.GF26041@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398688005-26207-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Apr 28, 2014 at 02:26:44PM +0200, Michal Hocko wrote:
> Be explicit about global and hard limit reclaims in our documentation.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  Documentation/cgroups/memory.txt | 31 +++++++++++++++++--------------
>  1 file changed, 17 insertions(+), 14 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 4937e6fff9b4..add1be001416 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -236,23 +236,26 @@ it by cgroup.
>  2.5 Reclaim
>  
>  Each cgroup maintains a per cgroup LRU which has the same structure as
> -global VM. When a cgroup goes over its limit, we first try
> -to reclaim memory from the cgroup so as to make space for the new
> -pages that the cgroup has touched. If the reclaim is unsuccessful,
> -an OOM routine is invoked to select and kill the bulkiest task in the
> -cgroup. (See 10. OOM Control below.)
> -
> -The reclaim algorithm has not been modified for cgroups, except that
> -pages that are selected for reclaiming come from the per-cgroup LRU
> -list.
> -
> -NOTE: Reclaim does not work for the root cgroup, since we cannot set any
> -limits on the root cgroup.
> +global VM. Cgroups can get reclaimed basically under two conditions
> + - under global memory pressure when all cgroups are reclaimed
> +   proportionally wrt. their LRU size in a round robin fashion
> + - when a cgroup or its hierarchical parent (see 6. Hierarchical support)
> +   hits hard limit. If the reclaim is unsuccessful, an OOM routine is invoked
> +   to select and kill the bulkiest task in the cgroup. (See 10. OOM Control
> +   below.)

In the whole hierarchy, not just that cgroup.

> +Global and hard-limit reclaims share the same code the only difference
> +is the objective of the reclaim. The global reclaim aims at balancing
> +zones' watermarks while the limit reclaim frees some memory to allow new
> +charges.

This is a kswapd vs. direct reclaim issue, not global vs. memcg.
Memcg reclaim just happens to be direct reclaim.  Either way, I'd
rather not have such implementation details in the user documentation.

> +NOTE: Hard limit reclaim does not work for the root cgroup, since we cannot set
> +any limits on the root cgroup.

Not sure it's necessary to include this...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
