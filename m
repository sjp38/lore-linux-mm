Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B98D6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 05:11:57 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id e11so23164102wra.0
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 02:11:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61si12666901wrl.157.2017.04.03.02.11.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 02:11:55 -0700 (PDT)
Date: Mon, 3 Apr 2017 11:11:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: oom: Bogus "sysrq: OOM request ignored because killer is
 disabled" message
Message-ID: <20170403091153.GH24661@dhcp22.suse.cz>
References: <201704021252.GIF21549.QFFOFOMVJtHSLO@I-love.SAKURA.ne.jp>
 <20170403083800.GF24661@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403083800.GF24661@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>

[Fixup Vladimir email address]

On Mon 03-04-17 10:38:00, Michal Hocko wrote:
> On Sun 02-04-17 12:52:55, Tetsuo Handa wrote:
> > I noticed that SysRq-f prints
> > 
> >   "sysrq: OOM request ignored because killer is disabled"
> > 
> > when no process was selected (rather than when oom killer was disabled).
> > This message was not printed until Linux 4.8 because commit 7c5f64f84483bd13
> > ("mm: oom: deduplicate victim selection code for memcg and global oom") changed
> >  from "return true;" to "return !!oc->chosen;" when is_sysrq_oom(oc) is true.
> > 
> > Is this what we meant?
> > 
> > [  713.805315] sysrq: SysRq : Manual OOM execution
> > [  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacrifice child
> > [  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1760kB, file-rss:0kB, shmem-rss:0kB
> > [  714.004805] sysrq: SysRq : Manual OOM execution
> > [  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 or sacrifice child
> > [  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
> > [  714.189310] sysrq: SysRq : Manual OOM execution
> > [  714.193425] sysrq: OOM request ignored because killer is disabled
> > [  714.381313] sysrq: SysRq : Manual OOM execution
> > [  714.385158] sysrq: OOM request ignored because killer is disabled
> > [  714.573320] sysrq: SysRq : Manual OOM execution
> > [  714.576988] sysrq: OOM request ignored because killer is disabled
> 
> So, what about this?
> ---
> From 6721932dba5b5143be0fa8110450231038af4238 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 3 Apr 2017 10:30:14 +0200
> Subject: [PATCH] oom: improve oom disable handling
> 
> Tetsuo has reported that sysrq triggered OOM killer will print a
> misleading information when no tasks are selected:
> 
> [  713.805315] sysrq: SysRq : Manual OOM execution
> [  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacrifice child
> [  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1760kB, file-rss:0kB, shmem-rss:0kB
> [  714.004805] sysrq: SysRq : Manual OOM execution
> [  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 or sacrifice child
> [  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
> [  714.189310] sysrq: SysRq : Manual OOM execution
> [  714.193425] sysrq: OOM request ignored because killer is disabled
> [  714.381313] sysrq: SysRq : Manual OOM execution
> [  714.385158] sysrq: OOM request ignored because killer is disabled
> [  714.573320] sysrq: SysRq : Manual OOM execution
> [  714.576988] sysrq: OOM request ignored because killer is disabled
> 
> The real reason is that there are no eligible tasks for the OOM killer
> to select but since 7c5f64f84483bd13 ("mm: oom: deduplicate victim
> selection code for memcg and global oom") the semantic of out_of_memory
> has changed without updating moom_callback.
> 
> This patch updates moom_callback to tell that no task was eligible
> which is the case for both oom killer disabled and no eligible tasks.
> In order to help distinguish first case from the second add printk to
> both oom_killer_{enable,disable}. This information is useful on its own
> because it might help debugging potential memory allocation failures.
> 
> Fixes: 7c5f64f84483bd13 ("mm: oom: deduplicate victim selection code for memcg and global oom")
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/tty/sysrq.c | 2 +-
>  mm/oom_kill.c       | 2 ++
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> index 71136742e606..a91f58dc2cb6 100644
> --- a/drivers/tty/sysrq.c
> +++ b/drivers/tty/sysrq.c
> @@ -370,7 +370,7 @@ static void moom_callback(struct work_struct *ignored)
>  
>  	mutex_lock(&oom_lock);
>  	if (!out_of_memory(&oc))
> -		pr_info("OOM request ignored because killer is disabled\n");
> +		pr_info("OOM request ignored. No task eligible\n");
>  	mutex_unlock(&oom_lock);
>  }
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 51c091849dcb..ad2b112cdf3e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -682,6 +682,7 @@ void exit_oom_victim(void)
>  void oom_killer_enable(void)
>  {
>  	oom_killer_disabled = false;
> +	pr_info("OOM killer enabled.\n");
>  }
>  
>  /**
> @@ -718,6 +719,7 @@ bool oom_killer_disable(signed long timeout)
>  		oom_killer_enable();
>  		return false;
>  	}
> +	pr_info("OOM killer disabled.\n");
>  
>  	return true;
>  }
> -- 
> 2.11.0
> 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
