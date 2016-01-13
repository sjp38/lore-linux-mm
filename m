Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D3839828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 19:45:37 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id cy9so348328722pac.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:45:37 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id q12si33873433par.45.2016.01.12.16.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 16:45:37 -0800 (PST)
Received: by mail-pa0-x233.google.com with SMTP id uo6so331984475pac.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:45:37 -0800 (PST)
Date: Tue, 12 Jan 2016 16:45:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 2/3] oom: Do not sacrifice already OOM killed children
In-Reply-To: <1452632425-20191-3-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1601121644250.28831@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 12 Jan 2016, Michal Hocko wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 2b9dc5129a89..8bca0b1e97f7 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -671,6 +671,63 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> +
> +/*
> + * If any of victim's children has a different mm and is eligible for kill,
> + * the one with the highest oom_badness() score is sacrificed for its
> + * parent.  This attempts to lose the minimal amount of work done while
> + * still freeing memory.
> + */
> +static struct task_struct *
> +try_to_sacrifice_child(struct oom_control *oc, struct task_struct *victim,
> +		       unsigned long totalpages, struct mem_cgroup *memcg)
> +{
> +	struct task_struct *child_victim = NULL;
> +	unsigned int victim_points = 0;
> +	struct task_struct *t;
> +
> +	read_lock(&tasklist_lock);
> +	for_each_thread(victim, t) {
> +		struct task_struct *child;
> +
> +		list_for_each_entry(child, &t->children, sibling) {
> +			unsigned int child_points;
> +
> +			/*
> +			 * Skip over already OOM killed children as this hasn't
> +			 * helped to resolve the situation obviously.
> +			 */
> +			if (test_tsk_thread_flag(child, TIF_MEMDIE) ||
> +					fatal_signal_pending(child) ||
> +					task_will_free_mem(child))
> +				continue;
> +

What guarantees that child had time to exit after it has been oom killed 
(better yet, what guarantees that it has even scheduled after it has been 
oom killed)?  It seems like this would quickly kill many children 
unnecessarily.

> +			if (process_shares_mm(child, victim->mm))
> +				continue;
> +
> +			child_points = oom_badness(child, memcg, oc->nodemask,
> +								totalpages);
> +			if (child_points > victim_points) {
> +				if (child_victim)
> +					put_task_struct(child_victim);
> +				child_victim = child;
> +				victim_points = child_points;
> +				get_task_struct(child_victim);
> +			}
> +		}
> +	}
> +	read_unlock(&tasklist_lock);
> +
> +	if (!child_victim)
> +		goto out;
> +
> +	put_task_struct(victim);
> +	victim = child_victim;
> +
> +out:
> +	return victim;
> +}
> +
>  /*
>   * Must be called while holding a reference to p, which will be released upon
>   * returning.
> @@ -680,10 +737,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  		      struct mem_cgroup *memcg, const char *message)
>  {
>  	struct task_struct *victim = p;
> -	struct task_struct *child;
> -	struct task_struct *t;
>  	struct mm_struct *mm;
> -	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
>  	bool can_oom_reap = true;
> @@ -707,34 +761,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
>  		message, task_pid_nr(p), p->comm, points);
>  
> -	/*
> -	 * If any of p's children has a different mm and is eligible for kill,
> -	 * the one with the highest oom_badness() score is sacrificed for its
> -	 * parent.  This attempts to lose the minimal amount of work done while
> -	 * still freeing memory.
> -	 */
> -	read_lock(&tasklist_lock);
> -	for_each_thread(p, t) {
> -		list_for_each_entry(child, &t->children, sibling) {
> -			unsigned int child_points;
> -
> -			if (process_shares_mm(child, p->mm))
> -				continue;
> -			/*
> -			 * oom_badness() returns 0 if the thread is unkillable
> -			 */
> -			child_points = oom_badness(child, memcg, oc->nodemask,
> -								totalpages);
> -			if (child_points > victim_points) {
> -				put_task_struct(victim);
> -				victim = child;
> -				victim_points = child_points;
> -				get_task_struct(victim);
> -			}
> -		}
> -	}
> -	read_unlock(&tasklist_lock);
> -
> +	victim = try_to_sacrifice_child(oc, victim, totalpages, memcg);
>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
