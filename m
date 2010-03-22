Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 97C616B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 19:26:00 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [C/R v20][PATCH 15/96] cgroup freezer: Fix buggy resume test for tasks frozen with cgroup freezer
Date: Tue, 23 Mar 2010 00:28:40 +0100
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu> <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu> <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Message-Id: <201003230028.40915.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Matt Helsley <matthltc@us.ibm.com>, Cedric Le Goater <legoater@free.fr>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Pavel Machek <pavel@ucw.cz>, linux-pm@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wednesday 17 March 2010, Oren Laadan wrote:
> From: Matt Helsley <matthltc@us.ibm.com>
> 
> When the cgroup freezer is used to freeze tasks we do not want to thaw
> those tasks during resume. Currently we test the cgroup freezer
> state of the resuming tasks to see if the cgroup is FROZEN.  If so
> then we don't thaw the task. However, the FREEZING state also indicates
> that the task should remain frozen.
> 
> This also avoids a problem pointed out by Oren Ladaan: the freezer state
> transition from FREEZING to FROZEN is updated lazily when userspace reads
> or writes the freezer.state file in the cgroup filesystem. This means that
> resume will thaw tasks in cgroups which should be in the FROZEN state if
> there is no read/write of the freezer.state file to trigger this
> transition before suspend.
> 
> NOTE: Another "simple" solution would be to always update the cgroup
> freezer state during resume. However it's a bad choice for several reasons:
> Updating the cgroup freezer state is somewhat expensive because it requires
> walking all the tasks in the cgroup and checking if they are each frozen.
> Worse, this could easily make resume run in N^2 time where N is the number
> of tasks in the cgroup. Finally, updating the freezer state from this code
> path requires trickier locking because of the way locks must be ordered.
> 
> Instead of updating the freezer state we rely on the fact that lazy
> updates only manage the transition from FREEZING to FROZEN. We know that
> a cgroup with the FREEZING state may actually be FROZEN so test for that
> state too. This makes sense in the resume path even for partially-frozen
> cgroups -- those that really are FREEZING but not FROZEN.
> 
> Reported-by: Oren Ladaan <orenl@cs.columbia.edu>
> Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
> Cc: Cedric Le Goater <legoater@free.fr>
> Cc: Paul Menage <menage@google.com>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Rafael J. Wysocki <rjw@sisk.pl>
> Cc: Pavel Machek <pavel@ucw.cz>
> Cc: linux-pm@lists.linux-foundation.org

Looks reasonable.

Is anyone handling that already or do you want me to take it to my tree?

Rafael


> Seems like a candidate for -stable.
> ---
>  include/linux/freezer.h |    7 +++++--
>  kernel/cgroup_freezer.c |    9 ++++++---
>  kernel/power/process.c  |    2 +-
>  3 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
> index 5a361f8..da7e52b 100644
> --- a/include/linux/freezer.h
> +++ b/include/linux/freezer.h
> @@ -64,9 +64,12 @@ extern bool freeze_task(struct task_struct *p, bool sig_only);
>  extern void cancel_freezing(struct task_struct *p);
>  
>  #ifdef CONFIG_CGROUP_FREEZER
> -extern int cgroup_frozen(struct task_struct *task);
> +extern int cgroup_freezing_or_frozen(struct task_struct *task);
>  #else /* !CONFIG_CGROUP_FREEZER */
> -static inline int cgroup_frozen(struct task_struct *task) { return 0; }
> +static inline int cgroup_freezing_or_frozen(struct task_struct *task)
> +{
> +	return 0;
> +}
>  #endif /* !CONFIG_CGROUP_FREEZER */
>  
>  /*
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 59e9ef6..eb3f34d 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -47,17 +47,20 @@ static inline struct freezer *task_freezer(struct task_struct *task)
>  			    struct freezer, css);
>  }
>  
> -int cgroup_frozen(struct task_struct *task)
> +int cgroup_freezing_or_frozen(struct task_struct *task)
>  {
>  	struct freezer *freezer;
>  	enum freezer_state state;
>  
>  	task_lock(task);
>  	freezer = task_freezer(task);
> -	state = freezer->state;
> +	if (!freezer->css.cgroup->parent)
> +		state = CGROUP_THAWED; /* root cgroup can't be frozen */
> +	else
> +		state = freezer->state;
>  	task_unlock(task);
>  
> -	return state == CGROUP_FROZEN;
> +	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
>  }
>  
>  /*
> diff --git a/kernel/power/process.c b/kernel/power/process.c
> index 5ade1bd..de53015 100644
> --- a/kernel/power/process.c
> +++ b/kernel/power/process.c
> @@ -145,7 +145,7 @@ static void thaw_tasks(bool nosig_only)
>  		if (nosig_only && should_send_signal(p))
>  			continue;
>  
> -		if (cgroup_frozen(p))
> +		if (cgroup_freezing_or_frozen(p))
>  			continue;
>  
>  		thaw_process(p);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
