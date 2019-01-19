Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5CA88E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 22:36:04 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id k133so5275301ite.4
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 19:36:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g11si3526044ioa.104.2019.01.18.19.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 19:36:03 -0800 (PST)
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
References: <20190119005022.61321-1-shakeelb@google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <02f74c47-4f35-3d59-f767-268844cb875e@i-love.sakura.ne.jp>
Date: Sat, 19 Jan 2019 12:35:47 +0900
MIME-Version: 1.0
In-Reply-To: <20190119005022.61321-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2019/01/19 9:50, Shakeel Butt wrote:
> On looking further it seems like the process selected to be oom-killed
> has exited even before reaching read_lock(&tasklist_lock) in
> oom_kill_process(). More specifically the tsk->usage is 1 which is due
> to get_task_struct() in oom_evaluate_task() and the put_task_struct
> within for_each_thread() frees the tsk and for_each_thread() tries to
> access the tsk. The easiest fix is to do get/put across the
> for_each_thread() on the selected task.

Good catch. p->usage can become 1 while printk()ing a lot at dump_header().

> @@ -981,6 +981,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	 * still freeing memory.
>  	 */
>  	read_lock(&tasklist_lock);
> +
> +	/*
> +	 * The task 'p' might have already exited before reaching here. The
> +	 * put_task_struct() will free task_struct 'p' while the loop still try
> +	 * to access the field of 'p', so, get an extra reference.
> +	 */
> +	get_task_struct(p);
>  	for_each_thread(p, t) {
>  		list_for_each_entry(child, &t->children, sibling) {
>  			unsigned int child_points;
> @@ -1000,6 +1007,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  			}
>  		}
>  	}
> +	put_task_struct(p);

Moving put_task_struct(p) to after read_unlock(&tasklist_lock) will reduce
latency of a write_lock(&tasklist_lock) waiter.

>  	read_unlock(&tasklist_lock);
>  
>  	/*
> 

By the way, p->usage is already 1 implies that p->mm == NULL due to already
completed exit_mm(p). Then, process_shares_mm(child, p->mm) might fail to
return true for some of children. Not critical but might lead to unnecessary
oom_badness() calls for child selection. Maybe we want to use same logic
__oom_kill_process() uses (i.e. bail out if find_task_lock_mm(p) failed)?
