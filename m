Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DA30C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:26:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32BB72083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:26:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32BB72083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB4A46B0003; Wed, 14 Aug 2019 10:26:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C65C16B0005; Wed, 14 Aug 2019 10:26:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7A866B000A; Wed, 14 Aug 2019 10:26:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0200.hostedemail.com [216.40.44.200])
	by kanga.kvack.org (Postfix) with ESMTP id 950366B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:26:15 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4EE0852AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:26:15 +0000 (UTC)
X-FDA: 75821258310.08.drink67_70c7fff4eb63f
X-HE-Tag: drink67_70c7fff4eb63f
X-Filterd-Recvd-Size: 3499
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:26:14 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A45FEAEE9;
	Wed, 14 Aug 2019 14:26:13 +0000 (UTC)
Date: Wed, 14 Aug 2019 16:26:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v1 4/4] mm/memory_hotplug: online_pages cannot be 0 in
 online_pages()
Message-ID: <20190814142613.GC17933@dhcp22.suse.cz>
References: <20190809125701.3316-1-david@redhat.com>
 <20190809125701.3316-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809125701.3316-5-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 14:57:01, David Hildenbrand wrote:
> walk_system_ram_range() will fail with -EINVAL in case
> online_pages_range() was never called (== no resource applicable in the
> range). Otherwise, we will always call online_pages_range() with
> nr_pages > 0 and, therefore, have online_pages > 0.

I have no idea why those checks where there TBH. Tried to dig out
commits which added them but didn't help.

> Remove that special handling.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 22 +++++++++-------------
>  1 file changed, 9 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 87f85597a19e..07e72fe17495 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -854,6 +854,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
>  		online_pages_range);
>  	if (ret) {
> +		/* not a single memory resource was applicable */
>  		if (need_zonelists_rebuild)
>  			zone_pcp_reset(zone);
>  		goto failed_addition;
> @@ -867,27 +868,22 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  
>  	shuffle_zone(zone);
>  
> -	if (onlined_pages) {
> -		node_states_set_node(nid, &arg);
> -		if (need_zonelists_rebuild)
> -			build_all_zonelists(NULL);
> -		else
> -			zone_pcp_update(zone);
> -	}
> +	node_states_set_node(nid, &arg);
> +	if (need_zonelists_rebuild)
> +		build_all_zonelists(NULL);
> +	else
> +		zone_pcp_update(zone);
>  
>  	init_per_zone_wmark_min();
>  
> -	if (onlined_pages) {
> -		kswapd_run(nid);
> -		kcompactd_run(nid);
> -	}
> +	kswapd_run(nid);
> +	kcompactd_run(nid);
>  
>  	vm_total_pages = nr_free_pagecache_pages();
>  
>  	writeback_set_ratelimit();
>  
> -	if (onlined_pages)
> -		memory_notify(MEM_ONLINE, &arg);
> +	memory_notify(MEM_ONLINE, &arg);
>  	mem_hotplug_done();
>  	return 0;
>  
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

