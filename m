Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CAA048E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 02:09:37 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so5775792edz.15
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 23:09:37 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si5857754eda.325.2019.01.18.23.09.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 23:09:36 -0800 (PST)
Date: Sat, 19 Jan 2019 08:09:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
Message-ID: <20190119070934.GD4087@dhcp22.suse.cz>
References: <20190119005022.61321-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190119005022.61321-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 18-01-19 16:50:22, Shakeel Butt wrote:
[...]
> On looking further it seems like the process selected to be oom-killed
> has exited even before reaching read_lock(&tasklist_lock) in
> oom_kill_process(). More specifically the tsk->usage is 1 which is due
> to get_task_struct() in oom_evaluate_task() and the put_task_struct
> within for_each_thread() frees the tsk and for_each_thread() tries to
> access the tsk. The easiest fix is to do get/put across the
> for_each_thread() on the selected task.

Very well spotted! The code seems safe because we are careful to
transfer the victim along with reference counting but I've totally
missed that the loop itself needs a reference. It seems that this has
been broken since the heuristic has been introduced. But I haven't
checked it closely. I am still on vacation.

> Now the next question is should we continue with the oom-kill as the
> previously selected task has exited? However before adding more
> complexity and heuristics, let's answer why we even look at the
> children of oom-kill selected task?

The objective was the work protection assuming that children did less
work than their parrent. I find this argument a bit questionable because
it highly depends a specific workload while it opens doors for
problematic behavior at the same time. If you have a fork bomb like
workload then it is basically hard to resolve the OOM condition as
children have barely any memory so we keep looping killing tasks which
will not free up much. So I am all for removing this heuristic.

> The select_bad_process() has already
> selected the worst process in the system/memcg. Due to race, the
> selected process might not be the worst at the kill time but does that
> matter matter?

No, we don't I believe. The aim of the oom killer is to kill something.
We will never be ideal here because this is a land of races.

> The userspace can play with oom_score_adj to prefer
> children to be killed before the parent. I looked at the history but it
> seems like this is there before git history.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Fixes: 5e9d834a0e0c ("oom: sacrifice child with highest badness score for parent")
Cc: stable

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> ---
>  mm/oom_kill.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0930b4365be7..1a007dae1e8f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
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
>  	read_unlock(&tasklist_lock);
>  
>  	/*
> -- 
> 2.20.1.321.g9e740568ce-goog

-- 
Michal Hocko
SUSE Labs
