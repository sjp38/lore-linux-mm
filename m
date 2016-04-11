Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9808E6B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:31:20 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id v188so74244707wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 00:31:20 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id m192si16912238wmg.14.2016.04.11.00.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 00:31:19 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id y144so19070286wmd.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 00:31:19 -0700 (PDT)
Date: Mon, 11 Apr 2016 09:31:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: let v2 cgroups follow changes in system
 swappiness
Message-ID: <20160411073117.GC23157@dhcp22.suse.cz>
References: <1460155744-15942-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460155744-15942-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri 08-04-16 18:49:04, Johannes Weiner wrote:
> Cgroup2 currently doesn't have a per-cgroup swappiness setting. We
> might want to add one later - that's a different discussion - but
> until we do, the cgroups should always follow the system setting.
> Otherwise it will be unchangeably set to whatever the ancestor
> inherited from the system setting at the time of cgroup creation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: stable@vger.kernel.org # 4.5

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/swap.h | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index e58dba3..15d17c8 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -534,6 +534,10 @@ static inline swp_entry_t get_swap_page(void)
>  #ifdef CONFIG_MEMCG
>  static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>  {
> +	/* Cgroup2 doesn't have per-cgroup swappiness */
> +	if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +		return vm_swappiness;
> +
>  	/* root ? */
>  	if (mem_cgroup_disabled() || !memcg->css.parent)
>  		return vm_swappiness;
> -- 
> 2.8.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
