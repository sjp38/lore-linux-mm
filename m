Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB4528027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 05:33:42 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so123157329wid.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 02:33:41 -0700 (PDT)
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id ot4si6860476wjc.143.2015.07.15.02.33.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 02:33:40 -0700 (PDT)
Received: by wgmn9 with SMTP id n9so28646192wgm.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 02:33:39 -0700 (PDT)
Date: Wed, 15 Jul 2015 11:33:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm 2/2] mm, oom: remove unnecessary variable
Message-ID: <20150715093336.GD5101@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1507141644320.16182@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1507141644530.16182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507141644530.16182@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 14-07-15 16:45:13, David Rientjes wrote:
> The "killed" variable in out_of_memory() can be removed since the call to
> oom_kill_process() where we should block to allow the process time to
> exit is obvious.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -645,7 +645,6 @@ bool out_of_memory(struct oom_control *oc)
>  	unsigned long freed = 0;
>  	unsigned int uninitialized_var(points);
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
> -	int killed = 0;
>  
>  	if (oom_killer_disabled)
>  		return false;
> @@ -653,7 +652,7 @@ bool out_of_memory(struct oom_control *oc)
>  	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
>  	if (freed > 0)
>  		/* Got some memory back in the last second. */
> -		goto out;
> +		return true;
>  
>  	/*
>  	 * If current has a pending SIGKILL or is exiting, then automatically
> @@ -666,7 +665,7 @@ bool out_of_memory(struct oom_control *oc)
>  	if (current->mm &&
>  	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
>  		mark_oom_victim(current);
> -		goto out;
> +		return true;
>  	}
>  
>  	/*
> @@ -684,7 +683,7 @@ bool out_of_memory(struct oom_control *oc)
>  		get_task_struct(current);
>  		oom_kill_process(oc, current, 0, totalpages, NULL,
>  				 "Out of memory (oom_kill_allocating_task)");
> -		goto out;
> +		return true;
>  	}
>  
>  	p = select_bad_process(oc, &points, totalpages);
> @@ -696,16 +695,12 @@ bool out_of_memory(struct oom_control *oc)
>  	if (p && p != (void *)-1UL) {
>  		oom_kill_process(oc, p, points, totalpages, NULL,
>  				 "Out of memory");
> -		killed = 1;
> -	}
> -out:
> -	/*
> -	 * Give the killed threads a good chance of exiting before trying to
> -	 * allocate memory again.
> -	 */
> -	if (killed)
> +		/*
> +		 * Give the killed process a good chance to exit before trying
> +		 * to allocate memory again.
> +		 */
>  		schedule_timeout_killable(1);
> -
> +	}
>  	return true;
>  }
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
