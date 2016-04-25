Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 088AC6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:47:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so40198036wme.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 04:47:37 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id k11si18929409wmg.101.2016.04.25.04.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 04:47:36 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id u206so122757086wme.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 04:47:36 -0700 (PDT)
Date: Mon, 25 Apr 2016 13:47:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160425114733.GF23933@dhcp22.suse.cz>
References: <201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp>
 <20160419200752.GA10437@dhcp22.suse.cz>
 <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
 <201604201937.AGB86467.MOFFOOQJVFHLtS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604201937.AGB86467.MOFFOOQJVFHLtS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Wed 20-04-16 19:37:30, Tetsuo Handa wrote:
[...]
> +static bool is_killable_memdie_task(struct task_struct *p)
> +{
> +	const unsigned long oom_start = p->signal->oom_start;
> +	struct task_struct *t;
> +	bool memdie_pending = false;
> +
> +	if (!oom_start)
> +		return false;
> +	rcu_read_lock();
> +	for_each_thread(p, t) {
> +		if (!test_tsk_thread_flag(t, TIF_MEMDIE))
> +			continue;
> +		memdie_pending = true;
> +		break;
> +	}
> +	rcu_read_unlock();
> +	if (!memdie_pending)
> +		return false;
> +	if (time_after(jiffies, oom_start +
> +		       sysctl_oom_victim_panic_secs * HZ)) {
> +		sched_show_task(p);
> +		panic("Out of memory and %u (%s) can not die...\n",
> +		      p->pid, p->comm);
> +	}
> +	return time_after(jiffies, oom_start +
> +			  sysctl_oom_victim_skip_secs * HZ);
> +}
> +
>  /* return true if the task is not adequate as candidate victim task. */
>  static bool oom_unkillable_task(struct task_struct *p,
>  		struct mem_cgroup *memcg, const nodemask_t *nodemask)
> @@ -149,7 +179,8 @@ static bool oom_unkillable_task(struct task_struct *p,
>  	if (!has_intersects_mems_allowed(p, nodemask))
>  		return true;
>  
> -	return false;
> +	/* Already OOM-killed p might get stuck at unkillable wait */
> +	return is_killable_memdie_task(p);
>  }

Hmm, I guess we have already discussed that in the past but I might
misremember. The above relies on oom killer to be triggered after the
previous victim was selected. There is no guarantee this will happen.
Why cannot we get back to the timer based solution at least for the
panic timeout?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
