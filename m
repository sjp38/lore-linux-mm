Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 89CC96B00AC
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 21:34:00 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rp16so7842756pbb.3
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 18:34:00 -0800 (PST)
Received: from psmtp.com ([74.125.245.178])
        by mx.google.com with SMTP id dj6si2050239pad.264.2013.11.12.18.33.58
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 18:33:59 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id ld10so3208321pab.20
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 18:33:57 -0800 (PST)
Date: Tue, 12 Nov 2013 18:33:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5] mm, oom: Fix race when selecting process to kill
In-Reply-To: <1384287812-3694-1-git-send-email-snanda@chromium.org>
Message-ID: <alpine.DEB.2.02.1311121829220.29891@chino.kir.corp.google.com>
References: <CANMivWZFXYGB_95WqToKEUyMsKMS2nQ4p5a_-Lte-=bhCC5u2g@mail.gmail.com> <1384287812-3694-1-git-send-email-snanda@chromium.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, rusty@rustcorp.com.au, semenzato@google.com, murzin.v@gmail.com, oleg@redhat.com, dserrg@gmail.com, msb@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 12 Nov 2013, Sameer Nanda wrote:

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
> Change-Id: I62f9652a780863467a8174e18ea5e19bbcd78c31

Is this needed?

> Signed-off-by: Sameer Nanda <snanda@chromium.org>
> ---
>  mm/oom_kill.c | 42 +++++++++++++++++++++++++++++-------------
>  1 file changed, 29 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 6738c47..5108c2b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -412,31 +412,40 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
>  
> +	if (__ratelimit(&oom_rs))
> +		dump_header(p, gfp_mask, order, memcg, nodemask);
> +
> +	task_lock(p);
> +	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
> +		message, task_pid_nr(p), p->comm, points);
> +	task_unlock(p);
> +
> +	/*
> +	 * while_each_thread is currently not RCU safe. Lets hold the
> +	 * tasklist_lock across all invocations of while_each_thread (including
> +	 * the one in find_lock_task_mm) in this function.
> +	 */
> +	read_lock(&tasklist_lock);
> +
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
> -	if (p->flags & PF_EXITING) {
> +	if (p->flags & PF_EXITING || !pid_alive(p)) {
> +		pr_info("%s: Not killing process %d, just setting TIF_MEMDIE\n",
> +			message, task_pid_nr(p));

That makes no sense in the kernel log to have

	Out of Memory: Kill process 1234 (comm) score 50 or sacrifice child
	Out of Memory: Not killing process 1234, just setting TIF_MEMDIE

Those are contradictory statements (and will actually mess with kernel log 
parsing at Google) and nobody other than kernel developers are going to 
know what TIF_MEMDIE is.

>  		set_tsk_thread_flag(p, TIF_MEMDIE);
>  		put_task_struct(p);
> +		read_unlock(&tasklist_lock);
>  		return;
>  	}
>  
> -	if (__ratelimit(&oom_rs))
> -		dump_header(p, gfp_mask, order, memcg, nodemask);
> -
> -	task_lock(p);
> -	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
> -		message, task_pid_nr(p), p->comm, points);
> -	task_unlock(p);
> -
>  	/*
>  	 * If any of p's children has a different mm and is eligible for kill,
>  	 * the one with the highest oom_badness() score is sacrificed for its
>  	 * parent.  This attempts to lose the minimal amount of work done while
>  	 * still freeing memory.
>  	 */
> -	read_lock(&tasklist_lock);
>  	do {
>  		list_for_each_entry(child, &t->children, sibling) {
>  			unsigned int child_points;
> @@ -456,12 +465,17 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			}
>  		}
>  	} while_each_thread(p, t);
> -	read_unlock(&tasklist_lock);
>  
> -	rcu_read_lock();
>  	p = find_lock_task_mm(victim);
> +
> +	/*
> +	 * Since while_each_thread is currently not RCU safe, this unlock of
> +	 * tasklist_lock may need to be moved further down if any additional
> +	 * while_each_thread loops get added to this function.
> +	 */

This comment should be moved to sched.h to indicate how 
while_each_thread() needs to be handled with respect to tasklist_lock, 
it's not specific to the oom killer.

> +	read_unlock(&tasklist_lock);
> +
>  	if (!p) {
> -		rcu_read_unlock();
>  		put_task_struct(victim);
>  		return;
>  	} else if (victim != p) {
> @@ -478,6 +492,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
>  	task_unlock(victim);
>  
> +	rcu_read_lock();
> +
>  	/*
>  	 * Kill all user processes sharing victim->mm in other thread groups, if
>  	 * any.  They don't get access to memory reserves, though, to avoid

Please move this rcu_read_lock() to be immediatley before the 
for_each_process() instead of before the comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
