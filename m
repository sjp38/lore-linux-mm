Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D116B6B03B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:56:26 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x43so31986376wrb.9
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:56:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8si8603843wra.351.2017.07.26.06.56.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 06:56:25 -0700 (PDT)
Date: Wed, 26 Jul 2017 15:56:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 1/4] mm, oom: refactor the TIF_MEMDIE usage
Message-ID: <20170726135622.GS2981@dhcp22.suse.cz>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726132718.14806-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 26-07-17 14:27:15, Roman Gushchin wrote:
[...]
> @@ -656,13 +658,24 @@ static void mark_oom_victim(struct task_struct *tsk)
>  	struct mm_struct *mm = tsk->mm;
>  
>  	WARN_ON(oom_killer_disabled);
> -	/* OOM killer might race with memcg OOM */
> -	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> +
> +	if (!cmpxchg(&tif_memdie_owner, NULL, current)) {
> +		struct task_struct *t;
> +
> +		rcu_read_lock();
> +		for_each_thread(current, t)
> +			set_tsk_thread_flag(t, TIF_MEMDIE);
> +		rcu_read_unlock();
> +	}

I would realy much rather see we limit the amount of memory reserves oom
victims can consume rather than build on top of the current hackish
approach of limiting the number of tasks because the fundamental problem
is still there (a heavy multithreaded process can still deplete the
reserves completely).

Is there really any reason to not go with the existing patch I've
pointed to the last time around? You didn't seem to have any objects
back then.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
