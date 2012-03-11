Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 284B26B00F5
	for <linux-mm@kvack.org>; Sun, 11 Mar 2012 04:21:21 -0400 (EDT)
Message-ID: <4F5C602B.4050806@parallels.com>
Date: Sun, 11 Mar 2012 12:19:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 03/13] memcg: Uncharge all kmem when deleting a cgroup.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org> <1331325556-16447-4-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1331325556-16447-4-git-send-email-ssouhlal@FreeBSD.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
> Signed-off-by: Suleiman Souhlal<suleiman@google.com>
> ---
>   mm/memcontrol.c |   31 ++++++++++++++++++++++++++++++-
>   1 files changed, 30 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e6fd558..6fbb438 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -382,6 +382,7 @@ static void mem_cgroup_get(struct mem_cgroup *memcg);
>   static void mem_cgroup_put(struct mem_cgroup *memcg);
>   static void memcg_kmem_init(struct mem_cgroup *memcg,
>       struct mem_cgroup *parent);
> +static void memcg_kmem_move(struct mem_cgroup *memcg);
>
>   static inline bool
>   mem_cgroup_test_flag(const struct mem_cgroup *memcg, enum memcg_flags flag)
> @@ -3700,6 +3701,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
>   	int ret;
>   	int node, zid, shrink;
>   	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	unsigned long usage;
>   	struct cgroup *cgrp = memcg->css.cgroup;
>
>   	css_get(&memcg->css);
> @@ -3719,6 +3721,8 @@ move_account:
>   		/* This is for making all *used* pages to be on LRU. */
>   		lru_add_drain_all();
>   		drain_all_stock_sync(memcg);
> +		if (!free_all)
> +			memcg_kmem_move(memcg);
Any reason we're not moving kmem charges when free_all is set as well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
