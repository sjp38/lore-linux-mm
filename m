Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A50966810B5
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:15:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 99so410872wrl.6
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 04:15:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p17si3169230wrg.213.2017.08.24.04.15.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 04:15:45 -0700 (PDT)
Date: Thu, 24 Aug 2017 13:15:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 1/4] mm, oom: refactor the oom_kill_process() function
Message-ID: <20170824111542.GE5943@dhcp22.suse.cz>
References: <20170823165201.24086-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170823165201.24086-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

This patch fails to apply on top of the mmotm tree. It seems the only
reason is the missing
http://lkml.kernel.org/r/20170810075019.28998-2-mhocko@kernel.org

On Wed 23-08-17 17:51:57, Roman Gushchin wrote:
> The oom_kill_process() function consists of two logical parts:
> the first one is responsible for considering task's children as
> a potential victim and printing the debug information.
> The second half is responsible for sending SIGKILL to all
> tasks sharing the mm struct with the given victim.
> 
> This commit splits the oom_kill_process() function with
> an intention to re-use the the second half: __oom_kill_process().

Yes this makes some sense even without further changes.

> The cgroup-aware OOM killer will kill multiple tasks
> belonging to the victim cgroup. We don't need to print
> the debug information for the each task, as well as play
> with task selection (considering task's children),
> so we can't use the existing oom_kill_process().
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

I do agree with the patch there is just one thing to fix up.

> ---
>  mm/oom_kill.c | 123 +++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 65 insertions(+), 58 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 53b44425ef35..5c29a3dd591b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -817,67 +817,12 @@ static bool task_will_free_mem(struct task_struct *task)
>  	return ret;
>  }
>  
> -static void oom_kill_process(struct oom_control *oc, const char *message)
> +static void __oom_kill_process(struct task_struct *victim)
>  {
[...]
>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);

The context doesn't tell us but there is return right after this.

	p = find_lock_task_mm(victim);
	if (!p) {
		put_task_struct(victim);
		return;
	} else if (victim != p) {
		get_task_struct(p);
		put_task_struct(victim);
		victim = p;
	}

So we return with the reference dropped. Moreover we can change
the victim, drop the reference on old one...

> +static void oom_kill_process(struct oom_control *oc, const char *message)
> +{
[...]
> +	__oom_kill_process(victim);
> +	put_task_struct(victim);

while we drop it here again and won't drop the changed one. If we race
with the exiting task and there is no mm then we we double drop as well.
So I think that __oom_kill_process should really drop the reference for
all cases and oom_kill_process shouldn't care. Or if you absolutely
need a guarantee that the victim won't go away after __oom_kill_process
then you need to return the real victim and let the caller to deal with
put_task_struct.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
