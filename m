Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E7E056B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 08:28:22 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b2-v6so1026405plz.17
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 05:28:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z9si1127571pgo.720.2018.03.20.05.28.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 05:28:21 -0700 (PDT)
Date: Tue, 20 Mar 2018 13:28:18 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim
 thread.
Message-ID: <20180320122818.GL23100@dhcp22.suse.cz>
References: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue 20-03-18 20:57:55, Tetsuo Handa wrote:
> I found that it is not difficult to hit "oom_reaper: unable to reap pid:"
> messages if the victim thread is doing copy_process(). Since I noticed
> that it is likely helpful to show trace of unable to reap victim thread
> for finding locations which should use killable wait, this patch does so.
> 
> [  226.608508] oom_reaper: unable to reap pid:9261 (a.out)
> [  226.611971] a.out           D13056  9261   6927 0x00100084
> [  226.615879] Call Trace:
> [  226.617926]  ? __schedule+0x25f/0x780
> [  226.620559]  schedule+0x2d/0x80
> [  226.623356]  rwsem_down_write_failed+0x2bb/0x440
> [  226.626426]  ? rwsem_down_write_failed+0x55/0x440
> [  226.629458]  ? anon_vma_fork+0x124/0x150
> [  226.632679]  call_rwsem_down_write_failed+0x13/0x20
> [  226.635884]  down_write+0x49/0x60
> [  226.638867]  ? copy_process.part.41+0x12f2/0x1fe0
> [  226.642042]  copy_process.part.41+0x12f2/0x1fe0 /* i_mmap_lock_write() in dup_mmap() */
> [  226.645087]  ? _do_fork+0xe6/0x560
> [  226.647991]  _do_fork+0xe6/0x560
> [  226.650495]  ? syscall_trace_enter+0x1a9/0x240
> [  226.653443]  ? retint_user+0x18/0x18
> [  226.656601]  ? page_fault+0x2f/0x50
> [  226.659159]  ? trace_hardirqs_on_caller+0x11f/0x1b0
> [  226.662399]  do_syscall_64+0x74/0x230
> [  226.664989]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

A single stack trace in the changelog would be sufficient IMHO.
Appart from that. What do you expect users will do about this trace?
Sure they will see a path which holds mmap_sem, we will see a bug report
but we can hardly do anything about that. We simply cannot drop the lock
from that path in 99% of situations. So _why_ do we want to add more
information to the log?

[...]

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5336985..900300c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -41,6 +41,7 @@
>  #include <linux/kthread.h>
>  #include <linux/init.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/sched/debug.h>
>  
>  #include <asm/tlb.h>
>  #include "internal.h"
> @@ -596,6 +597,7 @@ static void oom_reap_task(struct task_struct *tsk)
>  
>  	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
>  		task_pid_nr(tsk), tsk->comm);
> +	sched_show_task(tsk);
>  	debug_show_all_locks();
>  
>  done:
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
