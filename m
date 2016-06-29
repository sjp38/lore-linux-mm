Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6F306B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 20:13:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y77so81461112qkb.1
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 17:13:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t40si790417qtc.2.2016.06.28.17.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jun 2016 17:13:57 -0700 (PDT)
Date: Wed, 29 Jun 2016 02:13:53 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160629001353.GA9377@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160628101956.GA510@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

Michal,

I am already sleeping, I'll try to reply to other parts of your email
(and other emails) tomorrow, just some notes about the patch you propose.

And cough sorry for noise... I personally hate-hate-hate every new "oom"
member you and Tetsuo add into task/signal_struct ;) But not in this case,
because I _think_ we need signal_struct->mm anyway in the long term.

So at first glance this patch makes sense, but unless I missed something
(the patch doesn't apply I can be easily wrong),

On 06/28, Michal Hocko wrote:
>
> @@ -245,6 +245,8 @@ static inline void free_signal_struct(struct signal_struct *sig)
>  {
>  	taskstats_tgid_free(sig);
>  	sched_autogroup_exit(sig);
> +	if (sig->oom_mm)
> +		mmdrop(sig->oom_mm);
>  	kmem_cache_free(signal_cachep, sig);
>  }

OK, iiuc this is not that bad because only oom-killer can set it,

> +void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	WARN_ON(oom_killer_disabled);
>  	/* OOM killer might race with memcg OOM */
>  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
>  		return;
> +
>  	atomic_inc(&tsk->signal->oom_victims);
> +
> +	/* oom_mm is bound to the signal struct life time */
> +	if (!tsk->signal->oom_mm) {
> +		atomic_inc(&mm->mm_count);
> +		tsk->signal->oom_mm = mm;

Looks racy, but it is not because we rely on oom_lock? Perhaps a comment
makes sense.

> @@ -828,7 +816,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	struct task_struct *victim = p;
>  	struct task_struct *child;
>  	struct task_struct *t;
> -	struct mm_struct *mm;
> +	struct mm_struct *mm = READ_ONCE(p->mm);
>  	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
> @@ -838,8 +826,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
> -	if (task_will_free_mem(p)) {
> -		mark_oom_victim(p);
> +	if (mm && task_will_free_mem(p)) {
> +		mark_oom_victim(p, mm);

And this looks really racy at first glance. Suppose that this memory hog execs
(this changes its ->mm) and then exits so that task_will_free_mem() == T, in
this case "mm" has nothing to do with tsk->mm and it can be already freed.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
