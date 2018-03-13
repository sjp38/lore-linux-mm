Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE7F16B000E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:39:50 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id a5-v6so10234614plp.0
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:39:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x27si149912pgc.4.2018.03.13.06.39.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Mar 2018 06:39:49 -0700 (PDT)
Date: Tue, 13 Mar 2018 14:39:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: remove 3% bonus for CAP_SYS_ADMIN processes
Message-ID: <20180313133946.GT12772@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1803071548510.6996@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803071548510.6996@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gaurav Kohli <gkohli@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On Wed 07-03-18 15:52:15, David Rientjes wrote:
> Since the 2.6 kernel, the oom killer has slightly biased away from 
> CAP_SYS_ADMIN processes by discounting some of its memory usage in 
> comparison to other processes.
> 
> This has always been implicit and nothing exactly relies on the behavior.
> 
> Gaurav notices that __task_cred() can dereference a potentially freed 
> pointer if the task under consideration is exiting because a reference to 
> the task_struct is not held.
> 
> Remove the CAP_SYS_ADMIN bias so that all processes are treated equally.
> 
> If any CAP_SYS_ADMIN process would like to be biased against, it is always 
> allowed to adjust /proc/pid/oom_score_adj.
> 
> Reported-by: Gaurav Kohli <gkohli@codeaurora.org>
> Signed-off-by: David Rientjes <rientjes@google.com>

This is simpler than playing reference counting tricks and whatnot.
Moreover I do agree that this heuristic is questionable on its own. The
bias is basically random and invisible to the userspace. We already have
a way to tune the same thing by oom_score_adj

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 7 -------
>  1 file changed, 7 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -224,13 +224,6 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
>  	task_unlock(p);
>  
> -	/*
> -	 * Root processes get 3% bonus, just like the __vm_enough_memory()
> -	 * implementation used by LSMs.
> -	 */
> -	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> -		points -= (points * 3) / 100;
> -
>  	/* Normalize to oom_score_adj units */
>  	adj *= totalpages / 1000;
>  	points += adj;

-- 
Michal Hocko
SUSE Labs
