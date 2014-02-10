Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7936B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 16:40:59 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so6741427pab.4
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:40:59 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id cf2si16726125pad.24.2014.02.10.13.40.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 13:40:59 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so6779909pab.9
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:40:58 -0800 (PST)
Date: Mon, 10 Feb 2014 13:40:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: change oom_info_lock to mutex
In-Reply-To: <1392040082-14303-1-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.02.1402101339580.15624@chino.kir.corp.google.com>
References: <1392040082-14303-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 10 Feb 2014, Michal Hocko wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 19d5d4274e22..55e6731ebcd5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1687,7 +1687,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  	 * protects memcg_name and makes sure that parallel ooms do not
>  	 * interleave
>  	 */
> -	static DEFINE_SPINLOCK(oom_info_lock);
> +	static DEFINE_MUTEX(oom_info_lock);
>  	struct cgroup *task_cgrp;
>  	struct cgroup *mem_cgrp;
>  	static char memcg_name[PATH_MAX];
> @@ -1698,7 +1698,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  	if (!p)
>  		return;
>  
> -	spin_lock(&oom_info_lock);
> +	mutex_lock(&oom_info_lock);
>  	rcu_read_lock();
>  
>  	mem_cgrp = memcg->css.cgroup;
> @@ -1767,7 +1767,7 @@ done:
>  
>  		pr_cont("\n");
>  	}
> -	spin_unlock(&oom_info_lock);
> +	mutex_unlock(&oom_info_lock);
>  }
>  
>  /*

Can we change oom_info_lock() to only protecting memcg_name and forget 
about interleaving the hierarchical memcg stats instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
