Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59113C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 07:57:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2312820665
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 07:57:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2312820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE69D6B0005; Tue, 13 Aug 2019 03:57:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A70126B0006; Tue, 13 Aug 2019 03:57:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9105F6B0007; Tue, 13 Aug 2019 03:57:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0025.hostedemail.com [216.40.44.25])
	by kanga.kvack.org (Postfix) with ESMTP id 685276B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 03:57:10 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 0EE1D8248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:57:10 +0000 (UTC)
X-FDA: 75816649020.28.suit64_454302ef901d
X-HE-Tag: suit64_454302ef901d
X-Filterd-Recvd-Size: 3357
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:57:09 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 34D64AD3A;
	Tue, 13 Aug 2019 07:57:08 +0000 (UTC)
Date: Tue, 13 Aug 2019 09:57:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Wei Yang <richardw.yang@linux.intel.com>
Cc: akpm@linux-foundation.org, osalvador@suse.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: prevent memory leak when reuse pgdat
Message-ID: <20190813075707.GA17933@dhcp22.suse.cz>
References: <20190813020608.10194-1-richardw.yang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813020608.10194-1-richardw.yang@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 13-08-19 10:06:08, Wei Yang wrote:
> When offline a node in try_offline_node, pgdat is not released. So that
> pgdat could be reused in hotadd_new_pgdat. While we re-allocate
> pgdat->per_cpu_nodestats if this pgdat is reused.
> 
> This patch prevents the memory leak by just allocate per_cpu_nodestats
> when it is a new pgdat.

Yes this makes sense! I was slightly confused why we haven't initialized
the allocated pcp area because __alloc_percpu does GFP_KERNEL without
__GFP_ZERO but then I've just found out that the zeroying is done
regardless. A bit unexpected...

> NOTE: This is not tested since I didn't manage to create a case to
> offline a whole node. If my analysis is not correct, please let me know.
> 
> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memory_hotplug.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c73f09913165..efaf9e6f580a 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -933,8 +933,11 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  		if (!pgdat)
>  			return NULL;
>  
> +		pgdat->per_cpu_nodestats =
> +			alloc_percpu(struct per_cpu_nodestat);
>  		arch_refresh_nodedata(nid, pgdat);
>  	} else {
> +		int cpu;
>  		/*
>  		 * Reset the nr_zones, order and classzone_idx before reuse.
>  		 * Note that kswapd will init kswapd_classzone_idx properly
> @@ -943,6 +946,12 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  		pgdat->nr_zones = 0;
>  		pgdat->kswapd_order = 0;
>  		pgdat->kswapd_classzone_idx = 0;
> +		for_each_online_cpu(cpu) {
> +			struct per_cpu_nodestat *p;
> +
> +			p = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu);
> +			memset(p, 0, sizeof(*p));
> +		}
>  	}
>  
>  	/* we can use NODE_DATA(nid) from here */
> @@ -952,7 +961,6 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  
>  	/* init node's zones as empty zones, we don't have any present pages.*/
>  	free_area_init_core_hotplug(nid);
> -	pgdat->per_cpu_nodestats = alloc_percpu(struct per_cpu_nodestat);
>  
>  	/*
>  	 * The node we allocated has no zone fallback lists. For avoiding
> -- 
> 2.17.1
> 

-- 
Michal Hocko
SUSE Labs

