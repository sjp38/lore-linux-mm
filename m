Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F420CC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:41:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FF1F21738
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:41:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FF1F21738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDB906B0003; Wed, 24 Jul 2019 02:41:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8B286B0006; Wed, 24 Jul 2019 02:41:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C54D68E0002; Wed, 24 Jul 2019 02:41:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74E026B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:41:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e9so18476700edv.18
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:41:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Fiai8W3r2l8rxUSVOGL09d/nL8UMjKLO7kvhTx03fkY=;
        b=QARa2eNRI0Bj9aArxZX8gnRa0YVZBKOXs+8eDTcfF5RYppyrm9pKX/5IregBuj/mYV
         f0Fi2OLmw4WMD6/13FhH9T5YoVGkMaBgbT1d2yMBXEK+nU9DwKc0Ry4NrF6wAQHZN5Nl
         duIybedk06/LLG0WlzhOHIpYeCgYO5VBxlITgYRdO2nbVtjuFpkStdTOaZrUbWFoX7rP
         3T2smqkNpQwcRSeMARO8+WWGzw5lIzrKNDWj+XzJ2dhMSsYOKR4S3PJ6EuGx/3BTnZDn
         RzGKq/iSg8wMVdlfCaECV5cnPsI+5KqMeSoKC076QbtMfwIpcofEE4IcZRkHyjTdeFJa
         I1Lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUlZ2LmSQXf5f/w3tD5qWI5J1p6JZMMJLFwvPrpph7XLuoWHVUI
	5KmZahNiqXw/h1kwWFZxxTutUU26MXPt9YrhKT41t2ExWJ2wqLwINMxSG7rka8Ko6P5JPm9GpiE
	JrbVOse5uC2hIGXeUxiGloWady3fcb8ONkmhPGU/jCD/q4THdz2Vk9VKKHk7u66C8dQ==
X-Received: by 2002:a50:84a1:: with SMTP id 30mr70322856edq.44.1563950473007;
        Tue, 23 Jul 2019 23:41:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqV4I5QV5jbb4Krn2T0L824Bx5CruFPAfT1sDRmrrAxkIV/bXPkR86d8vMoN54eLpqDVYz
X-Received: by 2002:a50:84a1:: with SMTP id 30mr70322799edq.44.1563950471841;
        Tue, 23 Jul 2019 23:41:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563950471; cv=none;
        d=google.com; s=arc-20160816;
        b=Fh3uNaGVyvbXb9EChVBSMYy5IR5FhUDzo4EFhmiNStbTxmhkUxifcN4r8a0aUlMYjS
         KMxvoypgXm1yITyd0+EwSE/98rCI6koBwhGeRL20ELsXKxt6JxsSvpbZt3L+kjZcBGve
         Cu4mUibjD/uNDbXj1jhjrM59hMoIZS8wXf2ddpWBm4yaYrmHEc+OLMwibinit7Be5oPA
         BCLZnxqtTy0Yw83MdKrxlNmlB62OkdvMaYqOGsACKnFFLp3RerF8r64HaADyLJ41Lx0v
         DnRyRAij3nJ9jQgGrsGFS7vUnU+pCO63Rn4s8FVPTvD1Yiy1nDxsaUGdlbSzmd3fjpwG
         qs5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Fiai8W3r2l8rxUSVOGL09d/nL8UMjKLO7kvhTx03fkY=;
        b=0D/a2877jLiKl33UzTiN6LmFoQWcFyDc31ZduPklvrx58eY/ySgzltp/1FAPiD87np
         4ZvLMuhLokhRgUwJnVbIhVaroRecmtsl2SGjp6ZNkMFnhVk36ijHNKw8HVSmI6KE6aZG
         1wX3DoQ+VI6DVh8p8RSXpWHcYjioM3BEhPNp81hgDy+iudmOd+6+FAuNgrTyddqiISKH
         P6RR8scTfRvt+QQzy9e2RWdhlT8aGa4ARellNDEwYX+s2QyfQTTG2PPT1ueowrAQiaey
         Ym4FvOITnXRIYubByfsR6rA+2SXljCb32QS06mqV5C+iGXFYUHR880eQ5VmiOCV+BsaR
         Tk8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si8537862edz.269.2019.07.23.23.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 23:41:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1A98BAE3F;
	Wed, 24 Jul 2019 06:41:11 +0000 (UTC)
Date: Wed, 24 Jul 2019 08:41:10 +0200
From: Michal Hocko <mhocko@suse.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>
Subject: Re: [PATCH] mm, oom: simplify task's refcount handling
Message-ID: <20190724064110.GC10882@dhcp22.suse.cz>
References: <1563940476-6162-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563940476-6162-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-07-19 12:54:36, Tetsuo Handa wrote:
> Currently out_of_memory() is full of get_task_struct()/put_task_struct()
> calls. Since "mm, oom: avoid printk() iteration under RCU" introduced
> a list for holding a snapshot of all OOM victim candidates, let's share
> that list for select_bad_process() and oom_kill_process() in order to
> simplify task's refcount handling.
> 
> As a result of this patch, get_task_struct()/put_task_struct() calls
> in out_of_memory() are reduced to only 2 times respectively.

This is probably a matter of taste but the diffstat suggests to me that the
simplification is not all that great. On the other hand this makes the
oom handling even more tricky and harder for potential further
development - e.g. if we ever need to break the global lock down in the
future this would be another obstacle on the way. While potential
development might be too theoretical the benefit of the patch is not
really clear to me. The task_struct reference counting is not really
unusual operations and there is nothing really scary that we do with it
here. We already have to to extra mile wrt. task_lock so careful
reference count doesn't really jump out.

That being said, I do not think this patch gives any improvement.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  include/linux/sched.h |   2 +-
>  mm/oom_kill.c         | 122 ++++++++++++++++++++++++--------------------------
>  2 files changed, 60 insertions(+), 64 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 48c1a4c..4062999 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1247,7 +1247,7 @@ struct task_struct {
>  #ifdef CONFIG_MMU
>  	struct task_struct		*oom_reaper_list;
>  #endif
> -	struct list_head		oom_victim_list;
> +	struct list_head		oom_candidate;
>  #ifdef CONFIG_VMAP_STACK
>  	struct vm_struct		*stack_vm_area;
>  #endif
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 110f948..311e0e9 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -63,6 +63,7 @@
>   * and mark_oom_victim
>   */
>  DEFINE_MUTEX(oom_lock);
> +static LIST_HEAD(oom_candidate_list);
>  
>  static inline bool is_memcg_oom(struct oom_control *oc)
>  {
> @@ -167,6 +168,41 @@ static bool oom_unkillable_task(struct task_struct *p)
>  	return false;
>  }
>  
> +static int add_candidate_task(struct task_struct *p, void *unused)
> +{
> +	if (!oom_unkillable_task(p)) {
> +		get_task_struct(p);
> +		list_add_tail(&p->oom_candidate, &oom_candidate_list);
> +	}
> +	return 0;
> +}
> +
> +static void link_oom_candidates(struct oom_control *oc)
> +{
> +	struct task_struct *p;
> +
> +	if (is_memcg_oom(oc))
> +		mem_cgroup_scan_tasks(oc->memcg, add_candidate_task, NULL);
> +	else {
> +		rcu_read_lock();
> +		for_each_process(p)
> +			add_candidate_task(p, NULL);
> +		rcu_read_unlock();
> +	}
> +
> +}
> +
> +static void unlink_oom_candidates(void)
> +{
> +	struct task_struct *p;
> +	struct task_struct *t;
> +
> +	list_for_each_entry_safe(p, t, &oom_candidate_list, oom_candidate) {
> +		list_del(&p->oom_candidate);
> +		put_task_struct(p);
> +	}
> +}
> +
>  /*
>   * Print out unreclaimble slabs info when unreclaimable slabs amount is greater
>   * than all user memory (LRU pages)
> @@ -344,16 +380,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  		goto next;
>  
>  select:
> -	if (oc->chosen)
> -		put_task_struct(oc->chosen);
> -	get_task_struct(task);
>  	oc->chosen = task;
>  	oc->chosen_points = points;
>  next:
>  	return 0;
>  abort:
> -	if (oc->chosen)
> -		put_task_struct(oc->chosen);
>  	oc->chosen = (void *)-1UL;
>  	return 1;
>  }
> @@ -364,27 +395,13 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>   */
>  static void select_bad_process(struct oom_control *oc)
>  {
> -	if (is_memcg_oom(oc))
> -		mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
> -	else {
> -		struct task_struct *p;
> -
> -		rcu_read_lock();
> -		for_each_process(p)
> -			if (oom_evaluate_task(p, oc))
> -				break;
> -		rcu_read_unlock();
> -	}
> -}
> -
> +	struct task_struct *p;
>  
> -static int add_candidate_task(struct task_struct *p, void *arg)
> -{
> -	if (!oom_unkillable_task(p)) {
> -		get_task_struct(p);
> -		list_add_tail(&p->oom_victim_list, (struct list_head *) arg);
> +	list_for_each_entry(p, &oom_candidate_list, oom_candidate) {
> +		cond_resched();
> +		if (oom_evaluate_task(p, oc))
> +			break;
>  	}
> -	return 0;
>  }
>  
>  /**
> @@ -399,21 +416,12 @@ static int add_candidate_task(struct task_struct *p, void *arg)
>   */
>  static void dump_tasks(struct oom_control *oc)
>  {
> -	static LIST_HEAD(list);
>  	struct task_struct *p;
>  	struct task_struct *t;
>  
> -	if (is_memcg_oom(oc))
> -		mem_cgroup_scan_tasks(oc->memcg, add_candidate_task, &list);
> -	else {
> -		rcu_read_lock();
> -		for_each_process(p)
> -			add_candidate_task(p, &list);
> -		rcu_read_unlock();
> -	}
>  	pr_info("Tasks state (memory values in pages):\n");
>  	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> -	list_for_each_entry(p, &list, oom_victim_list) {
> +	list_for_each_entry(p, &oom_candidate_list, oom_candidate) {
>  		cond_resched();
>  		/* p may not have freeable memory in nodemask */
>  		if (!is_memcg_oom(oc) && !oom_cpuset_eligible(p, oc))
> @@ -430,10 +438,6 @@ static void dump_tasks(struct oom_control *oc)
>  			t->signal->oom_score_adj, t->comm);
>  		task_unlock(t);
>  	}
> -	list_for_each_entry_safe(p, t, &list, oom_victim_list) {
> -		list_del(&p->oom_victim_list);
> -		put_task_struct(p);
> -	}
>  }
>  
>  static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
> @@ -859,17 +863,11 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
>  	bool can_oom_reap = true;
>  
>  	p = find_lock_task_mm(victim);
> -	if (!p) {
> -		put_task_struct(victim);
> +	if (!p)
>  		return;
> -	} else if (victim != p) {
> -		get_task_struct(p);
> -		put_task_struct(victim);
> -		victim = p;
> -	}
>  
> -	/* Get a reference to safely compare mm after task_unlock(victim) */
> -	mm = victim->mm;
> +	/* Get a reference to safely compare mm after task_unlock(p) */
> +	mm = p->mm;
>  	mmgrab(mm);
>  
>  	/* Raise event before sending signal: task reaper must see this */
> @@ -881,16 +879,15 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
>  	 * in order to prevent the OOM victim from depleting the memory
>  	 * reserves from the user space under its control.
>  	 */
> -	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
> -	mark_oom_victim(victim);
> +	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, p, PIDTYPE_TGID);
> +	mark_oom_victim(p);
>  	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB, UID:%u\n",
> -		message, task_pid_nr(victim), victim->comm,
> -		K(victim->mm->total_vm),
> -		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> -		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> -		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
> -		from_kuid(&init_user_ns, task_uid(victim)));
> -	task_unlock(victim);
> +	       message, task_pid_nr(p), p->comm, K(mm->total_vm),
> +	       K(get_mm_counter(mm, MM_ANONPAGES)),
> +	       K(get_mm_counter(mm, MM_FILEPAGES)),
> +	       K(get_mm_counter(mm, MM_SHMEMPAGES)),
> +	       from_kuid(&init_user_ns, task_uid(p)));
> +	task_unlock(p);
>  
>  	/*
>  	 * Kill all user processes sharing victim->mm in other thread groups, if
> @@ -929,7 +926,6 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
>  		wake_oom_reaper(victim);
>  
>  	mmdrop(mm);
> -	put_task_struct(victim);
>  }
>  #undef K
>  
> @@ -940,10 +936,8 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
>  static int oom_kill_memcg_member(struct task_struct *task, void *message)
>  {
>  	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN &&
> -	    !is_global_init(task)) {
> -		get_task_struct(task);
> +	    !is_global_init(task))
>  		__oom_kill_process(task, message);
> -	}
>  	return 0;
>  }
>  
> @@ -964,7 +958,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  		mark_oom_victim(victim);
>  		wake_oom_reaper(victim);
>  		task_unlock(victim);
> -		put_task_struct(victim);
>  		return;
>  	}
>  	task_unlock(victim);
> @@ -1073,6 +1066,8 @@ bool out_of_memory(struct oom_control *oc)
>  	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
>  		return true;
>  
> +	link_oom_candidates(oc);
> +
>  	/*
>  	 * Check if there were limitations on the allocation (only relevant for
>  	 * NUMA and memcg) that may require different handling.
> @@ -1086,10 +1081,9 @@ bool out_of_memory(struct oom_control *oc)
>  	    current->mm && !oom_unkillable_task(current) &&
>  	    oom_cpuset_eligible(current, oc) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> -		get_task_struct(current);
>  		oc->chosen = current;
>  		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
> -		return true;
> +		goto done;
>  	}
>  
>  	select_bad_process(oc);
> @@ -1108,6 +1102,8 @@ bool out_of_memory(struct oom_control *oc)
>  	if (oc->chosen && oc->chosen != (void *)-1UL)
>  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
>  				 "Memory cgroup out of memory");
> + done:
> +	unlink_oom_candidates();
>  	return !!oc->chosen;
>  }
>  
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

