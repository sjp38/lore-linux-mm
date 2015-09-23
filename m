Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7B45A6B0256
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 03:45:22 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so194430041wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:45:22 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id xm4si9464567wib.90.2015.09.23.00.45.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 00:45:21 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so56266418wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:45:21 -0700 (PDT)
Date: Wed, 23 Sep 2015 09:45:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: remove pcp_counter_lock
Message-ID: <20150923074518.GC6283@dhcp22.suse.cz>
References: <1442976106-49685-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442976106-49685-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Tue 22-09-15 19:41:46, Greg Thelen wrote:
> Commit 733a572e66d2 ("memcg: make mem_cgroup_read_{stat|event}() iterate
> possible cpus instead of online") removed the last use of the per memcg
> pcp_counter_lock but forgot to remove the variable.
> 
> Kill the vestigial variable.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 1 -
>  mm/memcontrol.c            | 1 -
>  2 files changed, 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index ad800e62cb7a..6452ff4c463f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -242,7 +242,6 @@ struct mem_cgroup {
>  	 * percpu counter.
>  	 */
>  	struct mem_cgroup_stat_cpu __percpu *stat;
> -	spinlock_t pcp_counter_lock;
>  
>  #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
>  	struct cg_proto tcp_mem;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6ddaeba34e09..da21143550c0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4179,7 +4179,6 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
>  		goto out_free_stat;
>  
> -	spin_lock_init(&memcg->pcp_counter_lock);
>  	return memcg;
>  
>  out_free_stat:
> -- 
> 2.6.0.rc0.131.gf624c3d

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
