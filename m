Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C60776B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 09:18:50 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d4so55930416iod.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 06:18:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e9si3105489otb.6.2016.06.09.06.18.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 06:18:50 -0700 (PDT)
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
	<1465473137-22531-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465473137-22531-8-git-send-email-mhocko@kernel.org>
Message-Id: <201606092218.FCC48987.MFQLVtSHJFOOFO@I-love.SAKURA.ne.jp>
Date: Thu, 9 Jun 2016 22:18:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> @@ -766,15 +797,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
> -	task_lock(p);
> -	if (p->mm && task_will_free_mem(p)) {
> +	if (task_will_free_mem(p)) {

I think it is possible that p->mm becomes NULL here.

Also, I think setting TIF_MEMDIE on p when find_lock_task_mm(p) != p is
wrong. While oom_reap_task() will anyway clear TIF_MEMDIE even if we set
TIF_MEMDIE on p when p->mm == NULL, it is not true for CONFIG_MMU=n case.

>  		mark_oom_victim(p);
> -		try_oom_reaper(p);
> -		task_unlock(p);
> +		wake_oom_reaper(p);
>  		put_task_struct(p);
>  		return;
>  	}
> -	task_unlock(p);
>  
>  	if (__ratelimit(&oom_rs))
>  		dump_header(oc, p);
> @@ -940,14 +968,10 @@ bool out_of_memory(struct oom_control *oc)
>  	 * If current has a pending SIGKILL or is exiting, then automatically
>  	 * select it.  The goal is to allow it to allocate so that it may
>  	 * quickly exit and free its memory.
> -	 *
> -	 * But don't select if current has already released its mm and cleared
> -	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
>  	 */
> -	if (current->mm &&
> -	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> +	if (task_will_free_mem(current)) {

Setting TIF_MEMDIE on current when current->mm == NULL and
find_lock_task_mm(current) != NULL is wrong.

>  		mark_oom_victim(current);
> -		try_oom_reaper(current);
> +		wake_oom_reaper(current);
>  		return true;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
