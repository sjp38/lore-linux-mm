Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 19D446B0008
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 02:57:38 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id jg9so2603079bkc.9
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 23:57:36 -0800 (PST)
Date: Mon, 4 Feb 2013 08:57:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: stop warning on memcg_propagate_kmem
Message-ID: <20130204075732.GA2556@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1302032023280.4611@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1302032023280.4611@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun 03-02-13 20:29:01, Hugh Dickins wrote:
> Whilst I run the risk of a flogging for disloyalty to the Lord of Sealand,
> I do have CONFIG_MEMCG=y CONFIG_MEMCG_KMEM not set, and grow tired of the
> "mm/memcontrol.c:4972:12: warning: `memcg_propagate_kmem' defined but not
> used [-Wunused-function]" seen in 3.8-rc: move the #ifdef outwards.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Hmm, if you are not too tired then moving the function downwards to
where it is called (memcg_init_kmem) will reduce the number of ifdefs.
But this can wait for a bigger clean up which is getting due:
git grep "def.*CONFIG_MEMCG_KMEM" mm/memcontrol.c | wc -l
12

Thanks
> ---
> 
>  mm/memcontrol.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- 3.8-rc6/mm/memcontrol.c	2012-12-22 09:43:27.628015582 -0800
> +++ linux/mm/memcontrol.c	2013-02-02 16:56:06.188325771 -0800
> @@ -4969,6 +4969,7 @@ out:
>  	return ret;
>  }
>  
> +#ifdef CONFIG_MEMCG_KMEM
>  static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  {
>  	int ret = 0;
> @@ -4977,7 +4978,6 @@ static int memcg_propagate_kmem(struct m
>  		goto out;
>  
>  	memcg->kmem_account_flags = parent->kmem_account_flags;
> -#ifdef CONFIG_MEMCG_KMEM
>  	/*
>  	 * When that happen, we need to disable the static branch only on those
>  	 * memcgs that enabled it. To achieve this, we would be forced to
> @@ -5003,10 +5003,10 @@ static int memcg_propagate_kmem(struct m
>  	mutex_lock(&set_limit_mutex);
>  	ret = memcg_update_cache_sizes(memcg);
>  	mutex_unlock(&set_limit_mutex);
> -#endif
>  out:
>  	return ret;
>  }
> +#endif /* CONFIG_MEMCG_KMEM */
>  
>  /*
>   * The user of this function is...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
