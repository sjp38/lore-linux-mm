Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A67006B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 13:50:07 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k78so21769436lfe.1
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 10:50:07 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id n18si16202775lfg.105.2017.06.03.10.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 10:50:06 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id x81so1370805lfb.3
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 10:50:05 -0700 (PDT)
Date: Sat, 3 Jun 2017 20:50:02 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 5/6] mm: memcontrol: per-lruvec stats infrastructure
Message-ID: <20170603175002.GE15130@esperanza>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-6-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530181724.27197-6-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, May 30, 2017 at 02:17:23PM -0400, Johannes Weiner wrote:
> lruvecs are at the intersection of the NUMA node and memcg, which is
> the scope for most paging activity.
> 
> Introduce a convenient accounting infrastructure that maintains
> statistics per node, per memcg, and the lruvec itself.
> 
> Then convert over accounting sites for statistics that are already
> tracked in both nodes and memcgs and can be easily switched.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h | 238 +++++++++++++++++++++++++++++++++++++++------
>  include/linux/vmstat.h     |   1 -
>  mm/memcontrol.c            |   6 ++
>  mm/page-writeback.c        |  15 +--
>  mm/rmap.c                  |   8 +-
>  mm/workingset.c            |   9 +-
>  6 files changed, 225 insertions(+), 52 deletions(-)
> 
...
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9c68a40c83e3..e37908606c0f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4122,6 +4122,12 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
>  	if (!pn)
>  		return 1;
>  
> +	pn->lruvec_stat = alloc_percpu(struct lruvec_stat);
> +	if (!pn->lruvec_stat) {
> +		kfree(pn);
> +		return 1;
> +	}
> +
>  	lruvec_init(&pn->lruvec);
>  	pn->usage_in_excess = 0;
>  	pn->on_tree = false;

I don't see the matching free_percpu() anywhere, forget to patch
free_mem_cgroup_per_node_info()?

Other than that and with the follow-up fix applied, this patch
is good IMO.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
