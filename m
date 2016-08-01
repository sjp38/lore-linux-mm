Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96F0D6B025E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 13:17:23 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so79073944lfw.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 10:17:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cm17si32383318wjb.239.2016.08.01.10.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 10:17:22 -0700 (PDT)
Date: Mon, 1 Aug 2016 13:17:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: put soft limit reclaim out of way if the excess
 tree is empty
Message-ID: <20160801171717.GB8724@cmpxchg.org>
References: <1470045621-14335-1-git-send-email-mhocko@kernel.org>
 <20160801135757.GB19395@esperanza>
 <20160801141227.GI13544@dhcp22.suse.cz>
 <20160801150343.GA7603@cmpxchg.org>
 <20160801152454.GK13544@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160801152454.GK13544@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 01, 2016 at 05:24:54PM +0200, Michal Hocko wrote:
> @@ -2564,7 +2559,13 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
>  		return 0;
>  
>  	mctz = soft_limit_tree_node(pgdat->node_id);
> -	if (soft_limit_tree_empty(mctz))
> +
> +	/*
> +	 * Do not even bother to check the largest node if the node

                                                               root

> +	 * is empty. Do it lockless to prevent lock bouncing. Races
> +	 * are acceptable as soft limit is best effort anyway.
> +	 */
> +	if (RB_EMPTY_ROOT(&mctz->rb_root))
>  		return 0;

Other than that, looks good. Please retain my

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

in version 2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
