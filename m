Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 910B66B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 04:56:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id q10-v6so830938edd.20
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 01:56:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i15-v6si11335074edl.176.2018.11.02.01.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 01:56:07 -0700 (PDT)
Date: Fri, 2 Nov 2018 09:55:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm: do not start node_reclaim for page order >
 MAX_ORDER
Message-ID: <20181102081949.GQ23921@dhcp22.suse.cz>
References: <154109387197.925352.10499549042420271600.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154109387197.925352.10499549042420271600.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu 01-11-18 20:37:52, Konstantin Khlebnikov wrote:
> Page allocator has check in __alloc_pages_slowpath() but nowdays
> there is earlier entry point into reclimer without such check:
> get_page_from_freelist() -> node_reclaim().

Is the order check so expensive that it would be visible in the fast
path? Spreading these MAX_ORDER checks sounds quite fragile to me.

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  mm/vmscan.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 62ac0c488624..52f672420f0b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -4117,6 +4117,12 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
>  {
>  	int ret;
>  
> +	/*
> +	 * Do not scan if allocation will never succeed.
> +	 */
> +	if (order >= MAX_ORDER)
> +		return NODE_RECLAIM_NOSCAN;
> +
>  	/*
>  	 * Node reclaim reclaims unmapped file backed pages and
>  	 * slab pages if we are over the defined limits.
> 

-- 
Michal Hocko
SUSE Labs
