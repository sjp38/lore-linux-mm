Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 157DA6B009F
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 07:43:38 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id gi9so845969lab.5
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 04:43:37 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id w5si16092955lae.80.2014.10.21.04.43.34
        for <linux-mm@kvack.org>;
        Tue, 21 Oct 2014 04:43:35 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 1/4] freezer: Do not freeze tasks killed by OOM killer
Date: Tue, 21 Oct 2014 14:04 +0200
Message-ID: <9905383.BtpdXJVm1V@vostro.rjw.lan>
In-Reply-To: <1413876435-11720-2-git-send-email-mhocko@suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz> <1413876435-11720-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Tuesday, October 21, 2014 09:27:12 AM Michal Hocko wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Since f660daac474c6f (oom: thaw threads if oom killed thread is frozen
> before deferring) OOM killer relies on being able to thaw a frozen task
> to handle OOM situation but a3201227f803 (freezer: make freezing() test
> freeze conditions in effect instead of TIF_FREEZE) has reorganized the
> code and stopped clearing freeze flag in __thaw_task. This means that
> the target task only wakes up and goes into the fridge again because the
> freezing condition hasn't changed for it. This reintroduces the bug
> fixed by f660daac474c6f.
> 
> Fix the issue by checking for TIF_MEMDIE thread flag in
> freezing_slow_path and exclude the task from freezing completely. If a
> task was already frozen it would get woken by __thaw_task from OOM killer
> and get out of freezer after rechecking freezing().
> 
> Changes since v1
> - put TIF_MEMDIE check into freezing_slowpath rather than in __refrigerator
>   as per Oleg
> - return __thaw_task into oom_scan_process_thread because
>   oom_kill_process will not wake task in the fridge because it is
>   sleeping uninterruptible
> 
> [mhocko@suse.cz: rewrote the changelog]
> Fixes: a3201227f803 (freezer: make freezing() test freeze conditions in effect instead of TIF_FREEZE)
> Cc: stable@vger.kernel.org # 3.3+
> Cc: David Rientjes <rientjes@google.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Oleg Nesterov <oleg@redhat.com>

ACK

> ---
>  kernel/freezer.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/kernel/freezer.c b/kernel/freezer.c
> index aa6a8aadb911..8f9279b9c6d7 100644
> --- a/kernel/freezer.c
> +++ b/kernel/freezer.c
> @@ -42,6 +42,9 @@ bool freezing_slow_path(struct task_struct *p)
>  	if (p->flags & (PF_NOFREEZE | PF_SUSPEND_TASK))
>  		return false;
>  
> +	if (test_thread_flag(TIF_MEMDIE))
> +		return false;
> +
>  	if (pm_nosig_freezing || cgroup_freezing(p))
>  		return true;
>  
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
