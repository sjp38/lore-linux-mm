Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B94536B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 10:10:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q22-v6so993951pgv.22
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 07:10:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h3-v6si30304246pld.114.2018.06.05.07.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 07:10:45 -0700 (PDT)
Subject: Re: [RFC] Getting rid of INFLIGHT_VICTIM
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <10e40484-66e2-d879-e9b7-f50fdc5846ac@i-love.sakura.ne.jp>
Message-ID: <8da59f92-8de5-99e9-c62e-c972e2a66ac4@i-love.sakura.ne.jp>
Date: Tue, 5 Jun 2018 23:10:20 +0900
MIME-Version: 1.0
In-Reply-To: <10e40484-66e2-d879-e9b7-f50fdc5846ac@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>

On 2018/06/05 22:31, Tetsuo Handa wrote:
> @@ -639,15 +618,18 @@ static int oom_reaper(void *unused)
>  
>  static void wake_oom_reaper(struct task_struct *tsk)
>  {
> -	/* tsk is already queued? */
> -	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
> -		return;
> -
> -	get_task_struct(tsk);
> +	struct task_struct *p = oom_reaper_th;
>  
>  	spin_lock(&oom_reaper_lock);
> -	tsk->oom_reaper_list = oom_reaper_list;
> -	oom_reaper_list = tsk;
> +	while (p != tsk && p->oom_reaper_list)
> +		p = p->oom_reaper_list;
> +	if (p != tsk) {

Oops. This is "if (p == tsk) {".

> +		spin_unlock(&oom_reaper_lock);
> +		return;
> +	}
> +	p->oom_reaper_list = tsk;
> +	tsk->oom_reaper_list = NULL;
> +	get_task_struct(tsk);
>  	spin_unlock(&oom_reaper_lock);
>  	trace_wake_reaper(tsk->pid);
>  	wake_up(&oom_reaper_wait);
