Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4508C32757
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:26:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75BEE205F4
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:26:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75BEE205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 109336B0006; Wed, 14 Aug 2019 07:26:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0919A6B0007; Wed, 14 Aug 2019 07:26:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE9AE6B0008; Wed, 14 Aug 2019 07:26:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id C810B6B0006
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:26:31 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6E2EB3A9E
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:26:31 +0000 (UTC)
X-FDA: 75820805382.14.can55_9037984addf3c
X-HE-Tag: can55_9037984addf3c
X-Filterd-Recvd-Size: 4789
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:26:30 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A7AA8AD0B;
	Wed, 14 Aug 2019 11:26:29 +0000 (UTC)
Date: Wed, 14 Aug 2019 13:26:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH 1/2] mm: memcontrol: flush percpu vmstats before
 releasing memcg
Message-ID: <20190814112629.GU17933@dhcp22.suse.cz>
References: <20190812222911.2364802-1-guro@fb.com>
 <20190812222911.2364802-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812222911.2364802-2-guro@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 12-08-19 15:29:10, Roman Gushchin wrote:
> Percpu caching of local vmstats with the conditional propagation
> by the cgroup tree leads to an accumulation of errors on non-leaf
> levels.
> 
> Let's imagine two nested memory cgroups A and A/B. Say, a process
> belonging to A/B allocates 100 pagecache pages on the CPU 0.
> The percpu cache will spill 3 times, so that 32*3=96 pages will be
> accounted to A/B and A atomic vmstat counters, 4 pages will remain
> in the percpu cache.
> 
> Imagine A/B is nearby memory.max, so that every following allocation
> triggers a direct reclaim on the local CPU. Say, each such attempt
> will free 16 pages on a new cpu. That means every percpu cache will
> have -16 pages, except the first one, which will have 4 - 16 = -12.
> A/B and A atomic counters will not be touched at all.
> 
> Now a user removes A/B. All percpu caches are freed and corresponding
> vmstat numbers are forgotten. A has 96 pages more than expected.
> 
> As memory cgroups are created and destroyed, errors do accumulate.
> Even 1-2 pages differences can accumulate into large numbers.
> 
> To fix this issue let's accumulate and propagate percpu vmstat
> values before releasing the memory cgroup. At this point these
> numbers are stable and cannot be changed.

It is worth spending a word or two on why this doesn't matter during the
memcg life time.

> Since on cpu hotplug we do flush percpu vmstats anyway, we can
> iterate only over online cpus.
> 
> Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 40 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 40 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3e821f34399f..348f685ab94b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3412,6 +3412,41 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
>  	return 0;
>  }
>  
> +static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
> +{
> +	unsigned long stat[MEMCG_NR_STAT];
> +	struct mem_cgroup *mi;
> +	int node, cpu, i;
> +
> +	for (i = 0; i < MEMCG_NR_STAT; i++)
> +		stat[i] = 0;
> +
> +	for_each_online_cpu(cpu)
> +		for (i = 0; i < MEMCG_NR_STAT; i++)
> +			stat[i] += raw_cpu_read(memcg->vmstats_percpu->stat[i]);
> +
> +	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
> +		for (i = 0; i < MEMCG_NR_STAT; i++)
> +			atomic_long_add(stat[i], &mi->vmstats[i]);
> +
> +	for_each_node(node) {
> +		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
> +		struct mem_cgroup_per_node *pi;
> +
> +		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> +			stat[i] = 0;
> +
> +		for_each_online_cpu(cpu)
> +			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> +				stat[i] += raw_cpu_read(
> +					pn->lruvec_stat_cpu->count[i]);
> +
> +		for (pi = pn; pi; pi = parent_nodeinfo(pi, node))
> +			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> +				atomic_long_add(stat[i], &pi->lruvec_stat[i]);
> +	}
> +}
> +
>  static void memcg_offline_kmem(struct mem_cgroup *memcg)
>  {
>  	struct cgroup_subsys_state *css;
> @@ -4805,6 +4840,11 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  {
>  	int node;
>  
> +	/*
> +	 * Flush percpu vmstats to guarantee the value correctness
> +	 * on parent's and all ancestor levels.
> +	 */
> +	memcg_flush_percpu_vmstats(memcg);
>  	for_each_node(node)
>  		free_mem_cgroup_per_node_info(memcg, node);
>  	free_percpu(memcg->vmstats_percpu);
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

