Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDEC16B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 09:58:07 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e139so298001070oib.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:58:07 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0102.outbound.protection.outlook.com. [104.47.0.102])
        by mx.google.com with ESMTPS id g67si19583852otb.74.2016.08.01.06.58.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 06:58:07 -0700 (PDT)
Date: Mon, 1 Aug 2016 16:57:57 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] memcg: put soft limit reclaim out of way if the excess
 tree is empty
Message-ID: <20160801135757.GB19395@esperanza>
References: <1470045621-14335-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1470045621-14335-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Aug 01, 2016 at 12:00:21PM +0200, Michal Hocko wrote:
...
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c265212bec8c..eb7e39c2d948 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2543,6 +2543,11 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  	return ret;
>  }
>  
> +static inline bool soft_limit_tree_empty(struct mem_cgroup_tree_per_node *mctz)
> +{
> +	return rb_last(&mctz->rb_root) == NULL;
> +}
> +

I don't think traversing rb tree as rb_last() does w/o holding the lock
is a good idea. Why is RB_EMPTY_ROOT() insufficient here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
