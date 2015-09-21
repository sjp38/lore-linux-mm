Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C1C686B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:18:34 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so154624129wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:18:34 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id kd5si32217918wjb.41.2015.09.21.09.18.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 09:18:33 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so154004355wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:18:33 -0700 (PDT)
Date: Mon, 21 Sep 2015 18:18:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm/oom_kill: introduce is_sysrq_oom helper
Message-ID: <20150921161831.GF19811@dhcp22.suse.cz>
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
 <1442404800-4051-2-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442404800-4051-2-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 16-09-15 19:59:59, Yaowei Bai wrote:
> Introduce is_sysrq_oom helper function indicating oom kill triggered
> by sysrq to improve readability.
> 
> No functional changes.

I was complaining about a subtle semantic of order -1 when it was
introduced. This is easier to follow. At least for me.
 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1ecc0bc..7b6228e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -118,6 +118,15 @@ found:
>  	return t;
>  }
>  
> +/*
> + * order == -1 means the oom kill is required by sysrq, otherwise only
> + * for display purposes.
> + */
> +static inline bool is_sysrq_oom(struct oom_control *oc)
> +{
> +	return oc->order == -1;
> +}
> +
>  /* return true if the task is not adequate as candidate victim task. */
>  static bool oom_unkillable_task(struct task_struct *p,
>  		struct mem_cgroup *memcg, const nodemask_t *nodemask)
> @@ -265,7 +274,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 * Don't allow any other task to have access to the reserves.
>  	 */
>  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> -		if (oc->order != -1)
> +		if (!is_sysrq_oom(oc))
>  			return OOM_SCAN_ABORT;
>  	}
>  	if (!task->mm)
> @@ -278,7 +287,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	if (oom_task_origin(task))
>  		return OOM_SCAN_SELECT;
>  
> -	if (task_will_free_mem(task) && oc->order != -1)
> +	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
>  		return OOM_SCAN_ABORT;
>  
>  	return OOM_SCAN_OK;
> @@ -608,7 +617,7 @@ void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint,
>  			return;
>  	}
>  	/* Do not panic for oom kills triggered by sysrq */
> -	if (oc->order == -1)
> +	if (is_sysrq_oom(oc))
>  		return;
>  	dump_header(oc, NULL, memcg);
>  	panic("Out of memory: %s panic_on_oom is enabled\n",
> @@ -688,7 +697,7 @@ bool out_of_memory(struct oom_control *oc)
>  
>  	p = select_bad_process(oc, &points, totalpages);
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
> -	if (!p && oc->order != -1) {
> +	if (!p && !is_sysrq_oom(oc)) {
>  		dump_header(oc, NULL, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}
> -- 
> 1.9.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
