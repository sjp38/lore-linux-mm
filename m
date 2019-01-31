Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E94DC282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 07:11:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0540820870
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 07:11:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0540820870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 896028E0002; Thu, 31 Jan 2019 02:11:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 817DE8E0001; Thu, 31 Jan 2019 02:11:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705658E0002; Thu, 31 Jan 2019 02:11:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 313CE8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:11:37 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b8so1830672pfe.10
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:11:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DF+/eutu90+l3P0SMmtgG0++bAKxFfsKgFoDnUQD4J0=;
        b=FYPwjXsshyVvzoff8O7lTrgKiyeKX2RtcieoF2xJhJjiGO6PysAZsIhPSSEoXtANPS
         9ErxEeKDKuuvgzudt6vh2gpvcIA6X14G60I/pg9hD0l/tlFo25wsQUEtPGIM1XV8adKe
         MDXwdfS4TeOYHIuWA++d42H3DKfMUX0h96Nomhk69oFRKjtL71qAib2kEChhSc8+ZiXa
         hr745EyYA4bO+O9ccsWamQ5D1ehjZT9r8wfOQWdwav7vxwIE3wBryhtm9Ns0/TfYxVYP
         JFosCGVsP7eqBqVY401YhEkpFYpxFjLVzxE/JAdSo/Si1HFkyVO2M6hJhRLjRoAAfio7
         6MYQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdwv2LDCdnOsBdhEdcSW0dcri0lXLx6LvqoQHbQGlY1xpMViCXt
	b63fes+y2xoX2u1MDRbHiu+jHRm1kol8Z0AAT47c4ZX1sI7QuG61HI8X+6cVV+NsouBmhnkCuAW
	QQHM+h51gTR1W1o45fhQDComibbUUCzZWJnmtDDMvxFx1ZYI6duiADEaxBX6Egt8=
X-Received: by 2002:a63:1408:: with SMTP id u8mr30632602pgl.271.1548918696750;
        Wed, 30 Jan 2019 23:11:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Vmkhy6jVEwdp0N2bfNX30Rl5H6R6hDD2actw952o3URZ4Zi4/cQifzliu0SJMtU3Wrtls
X-Received: by 2002:a63:1408:: with SMTP id u8mr30632571pgl.271.1548918695773;
        Wed, 30 Jan 2019 23:11:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548918695; cv=none;
        d=google.com; s=arc-20160816;
        b=jxhE59YeqTw7RbuLMnzknwgN+y3bimYoq3VcqeHiBSQ8jnq1vrCR6Gjg6FrOMXyNKD
         LrsCGHW3iJ7DMpBPe6aM4zR8gG4e7IY6sfpxtvpo9kFztrA+YYV+3kjBmtRxk4lh3Hb6
         t18Wek6fiCsjBff0yBSoIAHfVKUZUa3jZDDPlOnSgNbCUZSUeO7a7bIuSCIPmQK7taZz
         fWXga8OgzO5meV4WhM0dQDI6oY8uyx27FXBceN87gIYDZhwEK55fK2h/bS+o/DfSvwkO
         t2Hl8pNPQ2jnJRsmM3AhSTvICjRA6RHJQvlEpad575nIjhV7x+x6QiBx3AUdFxnJS3iG
         oeiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DF+/eutu90+l3P0SMmtgG0++bAKxFfsKgFoDnUQD4J0=;
        b=GTW6gAVJNB9+ZeK7cRTGepgTyK/vIzX7OyEAs3LbgmzMm0jBXd42hMWY75ifdEnutx
         cvwx/48S5l2P+6SXv0Mlx6c1xO0IQAic/WTRC+uYpQ8Y7ubrkV7xaaNvs/WMx7hkN7fe
         PKjsM1KP+QicpdF6REeli369DMUrnsnbCkRVAg9Y5HvZb9EXfjvGek8fRNHFeNqjCuI7
         /NLwK0tyIcq0sbUcmGvZJvUHpNtuaF6f2Y58tWINI8YdVtqMWVaSpGLaVKamaYp1cBX7
         FfGlwciAtCrMrG8yggZjFkQZm4c2lcWezE1NFL2jfK4VZvHh9d4aIwFWrTpYxwVURryP
         hKNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j35si3519200pgl.223.2019.01.30.23.11.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 23:11:35 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B2B03AF51;
	Thu, 31 Jan 2019 07:11:32 +0000 (UTC)
Date: Thu, 31 Jan 2019 08:11:30 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
	Yong-Taek Lee <ytk.lee@samsung.com>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm, oom: Tolerate processes sharing mm with different
 view of oom_score_adj.
Message-ID: <20190131071130.GM18811@dhcp22.suse.cz>
References: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190116110937.GI24149@dhcp22.suse.cz>
 <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
 <20190116121915.GJ24149@dhcp22.suse.cz>
 <6118fa8a-7344-b4b2-36ce-d77d495fba69@i-love.sakura.ne.jp>
 <20190116134131.GP24149@dhcp22.suse.cz>
 <20190117155159.GA4087@dhcp22.suse.cz>
 <edad66e0-1947-eb42-f4db-7f826d3157d7@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <edad66e0-1947-eb42-f4db-7f826d3157d7@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 07:49:35, Tetsuo Handa wrote:
> This patch reverts both commit 44a70adec910d692 ("mm, oom_adj: make sure
> processes sharing mm have same view of oom_score_adj") and commit
> 97fd49c2355ffded ("mm, oom: kill all tasks sharing the mm") in order to
> close a race and reduce the latency at __set_oom_adj(), and reduces the
> warning at __oom_kill_process() in order to minimize the latency.
> 
> Commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper managed
> to unmap the address space") introduced the worst case mentioned in
> 44a70adec910d692. But since the OOM killer skips mm with MMF_OOM_SKIP set,
> only administrators can trigger the worst case.
> 
> Since 44a70adec910d692 did not take latency into account, we can "hold RCU
> for minutes and trigger RCU stall warnings" by calling printk() on many
> thousands of thread groups. Also, current code becomes a DoS attack vector
> which will allow "stalling for more than one month in unkillable state"
> simply printk()ing same messages when many thousands of thread groups
> tried to iterate __set_oom_adj() on each other.
> 
> I also noticed that 44a70adec910d692 is racy [1], and trying to fix the
> race will require a global lock which is too costly for rare events. And
> Michal Hocko is thinking to change the oom_score_adj implementation to per
> mm_struct (with shadowed score stored in per task_struct in order to
> support vfork() => __set_oom_adj() => execve() sequence) so that we don't
> need the global lock.
> 
> If the worst case in 44a70adec910d692 happened, it is an administrator's
> request. Therefore, before changing the oom_score_adj implementation,
> let's eliminate the DoS attack vector first.

This is really ridiculous. I have already nacked the previous version
and provided two ways around. The simplest one is to drop the printk.
The second one is to move oom_score_adj to the mm struct. Could you
explain why do you still push for this?

> [1] https://lkml.kernel.org/r/20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
> Nacked-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/proc/base.c     | 46 ----------------------------------------------
>  include/linux/mm.h |  2 --
>  mm/oom_kill.c      | 10 ++++++----
>  3 files changed, 6 insertions(+), 52 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 633a634..41ece8f 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1020,7 +1020,6 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
>  static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>  {
>  	static DEFINE_MUTEX(oom_adj_mutex);
> -	struct mm_struct *mm = NULL;
>  	struct task_struct *task;
>  	int err = 0;
>  
> @@ -1050,55 +1049,10 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>  		}
>  	}
>  
> -	/*
> -	 * Make sure we will check other processes sharing the mm if this is
> -	 * not vfrok which wants its own oom_score_adj.
> -	 * pin the mm so it doesn't go away and get reused after task_unlock
> -	 */
> -	if (!task->vfork_done) {
> -		struct task_struct *p = find_lock_task_mm(task);
> -
> -		if (p) {
> -			if (atomic_read(&p->mm->mm_users) > 1) {
> -				mm = p->mm;
> -				mmgrab(mm);
> -			}
> -			task_unlock(p);
> -		}
> -	}
> -
>  	task->signal->oom_score_adj = oom_adj;
>  	if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
>  		task->signal->oom_score_adj_min = (short)oom_adj;
>  	trace_oom_score_adj_update(task);
> -
> -	if (mm) {
> -		struct task_struct *p;
> -
> -		rcu_read_lock();
> -		for_each_process(p) {
> -			if (same_thread_group(task, p))
> -				continue;
> -
> -			/* do not touch kernel threads or the global init */
> -			if (p->flags & PF_KTHREAD || is_global_init(p))
> -				continue;
> -
> -			task_lock(p);
> -			if (!p->vfork_done && process_shares_mm(p, mm)) {
> -				pr_info("updating oom_score_adj for %d (%s) from %d to %d because it shares mm with %d (%s). Report if this is unexpected.\n",
> -						task_pid_nr(p), p->comm,
> -						p->signal->oom_score_adj, oom_adj,
> -						task_pid_nr(task), task->comm);
> -				p->signal->oom_score_adj = oom_adj;
> -				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
> -					p->signal->oom_score_adj_min = (short)oom_adj;
> -			}
> -			task_unlock(p);
> -		}
> -		rcu_read_unlock();
> -		mmdrop(mm);
> -	}
>  err_unlock:
>  	mutex_unlock(&oom_adj_mutex);
>  	put_task_struct(task);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb640..28879c1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2690,8 +2690,6 @@ static inline int in_gate_area(struct mm_struct *mm, unsigned long addr)
>  }
>  #endif	/* __HAVE_ARCH_GATE_AREA */
>  
> -extern bool process_shares_mm(struct task_struct *p, struct mm_struct *mm);
> -
>  #ifdef CONFIG_SYSCTL
>  extern int sysctl_drop_caches;
>  int drop_caches_sysctl_handler(struct ctl_table *, int,
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f0e8cd9..c7005b1 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -478,7 +478,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>   * task's threads: if one of those is using this mm then this task was also
>   * using it.
>   */
> -bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
> +static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
>  {
>  	struct task_struct *t;
>  
> @@ -896,12 +896,14 @@ static void __oom_kill_process(struct task_struct *victim)
>  			continue;
>  		if (same_thread_group(p, victim))
>  			continue;
> -		if (is_global_init(p)) {
> +		if (is_global_init(p) ||
> +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
>  			can_oom_reap = false;
> -			set_bit(MMF_OOM_SKIP, &mm->flags);
> -			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
> +			if (!test_bit(MMF_OOM_SKIP, &mm->flags))
> +				pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
>  					task_pid_nr(victim), victim->comm,
>  					task_pid_nr(p), p->comm);
> +			set_bit(MMF_OOM_SKIP, &mm->flags);
>  			continue;
>  		}
>  		/*
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

