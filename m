Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D55F2C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 05:49:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8E921721
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 05:49:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8E921721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37C8D6B000A; Fri, 30 Aug 2019 01:49:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32CEA6B000C; Fri, 30 Aug 2019 01:49:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21CBF6B000D; Fri, 30 Aug 2019 01:49:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 00E4D6B000A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 01:49:35 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A2F5F1A4D2
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:49:35 +0000 (UTC)
X-FDA: 75878017110.12.corn45_19845c315f85a
X-HE-Tag: corn45_19845c315f85a
X-Filterd-Recvd-Size: 3636
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:49:35 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 65AC2B671;
	Fri, 30 Aug 2019 05:49:33 +0000 (UTC)
Date: Fri, 30 Aug 2019 07:49:31 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org
Subject: Re: [PATCH] mm: memcontrol: fix percpu vmstats and vmevents flush
Message-ID: <20190830054931.GN28313@dhcp22.suse.cz>
References: <20190829203110.129263-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829203110.129263-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 29-08-19 13:31:10, Shakeel Butt wrote:
> Instead of using raw_cpu_read() use per_cpu() to read the actual data of
> the corresponding cpu otherwise we will be reading the data of the
> current cpu for the number of online CPUs.
> 
> Fixes: bb65f89b7d3d ("mm: memcontrol: flush percpu vmevents before releasing memcg")
> Fixes: c350a99ea2b1 ("mm: memcontrol: flush percpu vmstats before releasing memcg")
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: <stable@vger.kernel.org>

Ups, missed that when reviewing. Sorry about that.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
> Note: The buggy patches were marked for stable therefore adding Cc to
> stable.
> 
>  mm/memcontrol.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 26e2999af608..f4e60ee8b845 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3271,7 +3271,7 @@ static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
>  
>  	for_each_online_cpu(cpu)
>  		for (i = 0; i < MEMCG_NR_STAT; i++)
> -			stat[i] += raw_cpu_read(memcg->vmstats_percpu->stat[i]);
> +			stat[i] += per_cpu(memcg->vmstats_percpu->stat[i], cpu);
>  
>  	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
>  		for (i = 0; i < MEMCG_NR_STAT; i++)
> @@ -3286,8 +3286,8 @@ static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
>  
>  		for_each_online_cpu(cpu)
>  			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> -				stat[i] += raw_cpu_read(
> -					pn->lruvec_stat_cpu->count[i]);
> +				stat[i] += per_cpu(
> +					pn->lruvec_stat_cpu->count[i], cpu);
>  
>  		for (pi = pn; pi; pi = parent_nodeinfo(pi, node))
>  			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> @@ -3306,8 +3306,8 @@ static void memcg_flush_percpu_vmevents(struct mem_cgroup *memcg)
>  
>  	for_each_online_cpu(cpu)
>  		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
> -			events[i] += raw_cpu_read(
> -				memcg->vmstats_percpu->events[i]);
> +			events[i] += per_cpu(memcg->vmstats_percpu->events[i],
> +					     cpu);
>  
>  	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
>  		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
> -- 
> 2.23.0.187.g17f5b7556c-goog
> 

-- 
Michal Hocko
SUSE Labs

