Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5238BC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:33:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DB33208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:33:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DB33208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA04C6B0006; Wed, 14 Aug 2019 07:33:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A50CB6B0007; Wed, 14 Aug 2019 07:33:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98E366B0008; Wed, 14 Aug 2019 07:33:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0184.hostedemail.com [216.40.44.184])
	by kanga.kvack.org (Postfix) with ESMTP id 7869A6B0006
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:33:12 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 158A6181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:33:12 +0000 (UTC)
X-FDA: 75820822224.04.badge60_3902a05899051
X-HE-Tag: badge60_3902a05899051
X-Filterd-Recvd-Size: 3501
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:33:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A3579ADEF;
	Wed, 14 Aug 2019 11:33:10 +0000 (UTC)
Date: Wed, 14 Aug 2019 13:33:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: memcontrol: flush percpu vmevents before releasing
 memcg
Message-ID: <20190814113310.GW17933@dhcp22.suse.cz>
References: <20190812233754.2570543-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812233754.2570543-1-guro@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 12-08-19 16:37:54, Roman Gushchin wrote:
> Similar to vmstats, percpu caching of local vmevents leads to an
> accumulation of errors on non-leaf levels. This happens because
> some leftovers may remain in percpu caches, so that they are
> never propagated up by the cgroup tree and just disappear into
> nonexistence with on releasing of the memory cgroup.
> 
> To fix this issue let's accumulate and propagate percpu vmevents
> values before releasing the memory cgroup similar to what we're
> doing with vmstats.
> 
> Since on cpu hotplug we do flush percpu vmstats anyway, we can
> iterate only over online cpus.
> 
> Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6d2427abcc0c..249187907339 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3459,6 +3459,25 @@ static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg, bool slab_only)
>  	}
>  }
>  
> +static void memcg_flush_percpu_vmevents(struct mem_cgroup *memcg)
> +{
> +	unsigned long events[NR_VM_EVENT_ITEMS];
> +	struct mem_cgroup *mi;
> +	int cpu, i;
> +
> +	for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
> +		events[i] = 0;
> +
> +	for_each_online_cpu(cpu)
> +		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
> +			events[i] += raw_cpu_read(
> +				memcg->vmstats_percpu->events[i]);
> +
> +	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
> +		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
> +			atomic_long_add(events[i], &mi->vmevents[i]);
> +}
> +
>  static void memcg_offline_kmem(struct mem_cgroup *memcg)
>  {
>  	struct cgroup_subsys_state *css;
> @@ -4860,10 +4879,11 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  	int node;
>  
>  	/*
> -	 * Flush percpu vmstats to guarantee the value correctness
> +	 * Flush percpu vmstats and vmevents to guarantee the value correctness
>  	 * on parent's and all ancestor levels.
>  	 */
>  	memcg_flush_percpu_vmstats(memcg, false);
> +	memcg_flush_percpu_vmevents(memcg);
>  	for_each_node(node)
>  		free_mem_cgroup_per_node_info(memcg, node);
>  	free_percpu(memcg->vmstats_percpu);
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

