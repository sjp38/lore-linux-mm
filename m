Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C60EB6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 01:15:22 -0400 (EDT)
Date: Fri, 10 Jun 2011 14:06:16 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
Message-Id: <20110610140616.9f627080.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110609212956.GA2319@redhat.com>
	<BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
	<BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
	<20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106091812030.4904@sister.anvils>
	<20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thank you for your investigation and a patch.

I've not been able to replicate this issue on my machine, I think it would be
better to push this patch to -stable, if it can fix the issue.

Thanks,
Daisuke Nishimura.

On Fri, 10 Jun 2011 13:30:21 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> I think this can be a fix. 
> maybe good to CC Oleg.
> ==
> From dff52fb35af0cf36486965d19ee79e04b59f1dc4 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 10 Jun 2011 13:15:14 +0900
> Subject: [PATCH] [BUGFIX] update mm->owner even if no next owner.
> 
> A panic is reported.
> 
> > Call Trace:
> > A [<ffffffff81139792>] mem_cgroup_from_task+0x15/0x17
> > A [<ffffffff8113a75a>] __mem_cgroup_try_charge+0x148/0x4b4
> > A [<ffffffff810493f3>] ? need_resched+0x23/0x2d
> > A [<ffffffff814cbf43>] ? preempt_schedule+0x46/0x4f
> > A [<ffffffff8113afe8>] mem_cgroup_charge_common+0x9a/0xce
> > A [<ffffffff8113b6d1>] mem_cgroup_newpage_charge+0x5d/0x5f
> > A [<ffffffff81134024>] khugepaged+0x5da/0xfaf
> > A [<ffffffff81078ea0>] ? __init_waitqueue_head+0x4b/0x4b
> > A [<ffffffff81133a4a>] ? add_mm_counter.constprop.5+0x13/0x13
> > A [<ffffffff81078625>] kthread+0xa8/0xb0
> > A [<ffffffff814d13e8>] ? sub_preempt_count+0xa1/0xb4
> > A [<ffffffff814d5664>] kernel_thread_helper+0x4/0x10
> > A [<ffffffff814ce858>] ? retint_restore_args+0x13/0x13
> > A [<ffffffff8107857d>] ? __init_kthread_worker+0x5a/0x5a
> 
> The code is.
> >         return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
> >                                 struct mem_cgroup, css);
> 
> 
> What happens here is accssing a freed task struct "p" from mm->owner.
> So, it's doubtful that mm->owner points to freed task struct.
> 
> At thread exit, we need to handle mm->owner. If exitting-thread == mm->owner,
> we modify mm->owner to points to other exisiting task. But, we do not update
> mm->owner when there are no more threads. But if a kernel thread, like khugepaged,
> picks up a mm_struct without updating mm->users, there is a trouble.
> 
> When mm_users shows that the task is the last task belongs to mm.
> mm->owner is not updated and remained to point to the task. So, in this case,
> mm->owner points to a not exisiting task.  This was good because if there
> are no thread, no charge happens in old days. But now, we have ksm and
> khugepaged.
> 
> rcu_read_lock() used in memcg is of no use because mm->owner can be
> freed before we take rcu_read_lock.
> Then, mm->owner should be cleared if there are no next owner.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  kernel/exit.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 20a4064..dbc3736 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -582,8 +582,10 @@ void mm_update_next_owner(struct mm_struct *mm)
>  	struct task_struct *c, *g, *p = current;
>  
>  retry:
> -	if (!mm_need_new_owner(mm, p))
> +	if (!mm_need_new_owner(mm, p)) {
> +		rcu_assign_pointer(mm->owner, NULL);
>  		return;
> +	}
>  
>  	read_lock(&tasklist_lock);
>  	/*
> @@ -617,7 +619,7 @@ retry:
>  	 * most likely racing with swapoff (try_to_unuse()) or /proc or
>  	 * ptrace or page migration (get_task_mm()).  Mark owner as NULL.
>  	 */
> -	mm->owner = NULL;
> +	rcu_assign_pointer(mm->owner, NULL);
>  	return;
>  
>  assign_new_owner:
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
