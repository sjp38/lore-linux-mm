Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 385CD6B00D7
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 10:13:14 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y13so4193151pdi.0
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 07:13:13 -0800 (PST)
Received: from psmtp.com ([74.125.245.128])
        by mx.google.com with SMTP id kg8si20247480pad.96.2013.11.12.07.13.11
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 07:13:12 -0800 (PST)
Date: Tue, 12 Nov 2013 16:13:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4] mm, oom: Fix race when selecting process to kill
Message-ID: <20131112151308.GD6049@dhcp22.suse.cz>
References: <20131109151639.GB14249@redhat.com>
 <1384215717-2389-1-git-send-email-snanda@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384215717-2389-1-git-send-email-snanda@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, rusty@rustcorp.com.au, semenzato@google.com, murzin.v@gmail.com, oleg@redhat.com, dserrg@gmail.com, msb@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 11-11-13 16:21:57, Sameer Nanda wrote:
> The selection of the process to be killed happens in two spots:
> first in select_bad_process and then a further refinement by
> looking for child processes in oom_kill_process. Since this is
> a two step process, it is possible that the process selected by
> select_bad_process may get a SIGKILL just before oom_kill_process
> executes. If this were to happen, __unhash_process deletes this
> process from the thread_group list. This results in oom_kill_process
> getting stuck in an infinite loop when traversing the thread_group
> list of the selected process.
> 
> Fix this race by adding a pid_alive check for the selected process
> with tasklist_lock held in oom_kill_process.
> 
> Signed-off-by: Sameer Nanda <snanda@chromium.org>
> ---
>  mm/oom_kill.c | 24 +++++++++++++++++++-----
>  1 file changed, 19 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 6738c47..57638ef 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -413,12 +413,20 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  					      DEFAULT_RATELIMIT_BURST);
>  
>  	/*
> +	 * while_each_thread is currently not RCU safe. Lets hold the
> +	 * tasklist_lock across all invocations of while_each_thread (including
> +	 * the one in find_lock_task_mm) in this function.
> +	 */
> +	read_lock(&tasklist_lock);
> +
> +	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
> -	if (p->flags & PF_EXITING) {
> +	if (p->flags & PF_EXITING || !pid_alive(p)) {
>  		set_tsk_thread_flag(p, TIF_MEMDIE);
>  		put_task_struct(p);
> +		read_unlock(&tasklist_lock);
>  		return;
>  	}

show_mem used to be one of a bottleneck but now that we have Mel's "mm:
do not walk all of system memory during show_mem" it shouldn't be a big
deal anymore.
The real trouble is with dump_tasks which might be zillions of tasks and
we do not want to hold tasklist_lock for that long.

So no this would regress on the huge machines and yes we have seen
reports like that and explicit requests to backport 6b0c81b3be114 (mm,
oom: reduce dependency on tasklist_lock) so this would be a step
backwards although I see there is a real problem that it tries to fix.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
