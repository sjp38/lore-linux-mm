Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 906966B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 07:51:43 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id bs8so3953793wib.8
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 04:51:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ef9si10758461wjd.148.2014.07.31.04.51.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 04:51:39 -0700 (PDT)
Date: Thu, 31 Jul 2014 13:51:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] swap: remove the struct cpumask has_work
Message-ID: <20140731115137.GA20244@dhcp22.suse.cz>
References: <1406777421-12830-3-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406777421-12830-3-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Chris Metcalf <cmetcalf@tilera.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@gentwo.org>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-mm@kvack.org

On Thu 31-07-14 11:30:19, Lai Jiangshan wrote:
> It is suggested that cpumask_var_t and alloc_cpumask_var() should be used
> instead of struct cpumask.  But I don't want to add this complicity nor
> leave this unwelcome "static struct cpumask has_work;", so I just remove
> it and use flush_work() to perform on all online drain_work.  flush_work()
> performs very quickly on initialized but unused work item, thus we don't
> need the struct cpumask has_work for performance.

Why? Just because there is general recommendation for using
cpumask_var_t rather than cpumask?

In this particular case cpumask shouldn't matter much as it is static.
Your code will work as well, but I do not see any strong reason to
change it just to get rid of cpumask which is not on stack.

> CC: akpm@linux-foundation.org
> CC: Chris Metcalf <cmetcalf@tilera.com>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Tejun Heo <tj@kernel.org>
> CC: Christoph Lameter <cl@gentwo.org>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---
>  mm/swap.c |   11 ++++-------
>  1 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 9e8e347..bb524ca 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -833,27 +833,24 @@ static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
>  void lru_add_drain_all(void)
>  {
>  	static DEFINE_MUTEX(lock);
> -	static struct cpumask has_work;
>  	int cpu;
>  
>  	mutex_lock(&lock);
>  	get_online_cpus();
> -	cpumask_clear(&has_work);
>  
>  	for_each_online_cpu(cpu) {
>  		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
>  
> +		INIT_WORK(work, lru_add_drain_per_cpu);
> +
>  		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
>  		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
>  		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
> -		    need_activate_page_drain(cpu)) {
> -			INIT_WORK(work, lru_add_drain_per_cpu);
> +		    need_activate_page_drain(cpu))
>  			schedule_work_on(cpu, work);
> -			cpumask_set_cpu(cpu, &has_work);
> -		}
>  	}
>  
> -	for_each_cpu(cpu, &has_work)
> +	for_each_online_cpu(cpu)
>  		flush_work(&per_cpu(lru_add_drain_work, cpu));
>  
>  	put_online_cpus();
> -- 
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
