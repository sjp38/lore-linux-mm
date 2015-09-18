Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id D16206B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 03:42:23 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so20465201wic.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 00:42:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s6si9378868wjy.175.2015.09.18.00.42.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 00:42:22 -0700 (PDT)
Date: Fri, 18 Sep 2015 09:42:17 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: fix order calculation in try_charge()
Message-ID: <20150918074217.GD15395@cmpxchg.org>
References: <1442318757-7141-1-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442318757-7141-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 15, 2015 at 02:05:57PM +0200, Jerome Marchand wrote:
> Since commit <6539cc05386> (mm: memcontrol: fold mem_cgroup_do_charge()),
> the order to pass to mem_cgroup_oom() is calculated by passing the number
> of pages to get_order() instead of the expected  size in bytes. AFAICT,
> it only affects the value displayed in the oom warning message.
> This patch fix this.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks, Jerome. One minor thing:

> @@ -2032,7 +2032,8 @@ retry:
>  
>  	mem_cgroup_events(mem_over_limit, MEMCG_OOM, 1);
>  
> -	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(nr_pages));
> +	mem_cgroup_oom(mem_over_limit, gfp_mask,
> +		       get_order(nr_pages * PAGE_SIZE));

fls(nr_pages)?

get_order() is basically fls(x / PAGE_SIZE).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
