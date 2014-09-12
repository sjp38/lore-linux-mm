Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id C9DAC6B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 04:09:06 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id hi2so130615wib.0
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 01:09:06 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id i7si6027607wjz.36.2014.09.12.01.09.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 01:09:05 -0700 (PDT)
Received: by mail-wi0-f170.google.com with SMTP id em10so368111wid.3
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 01:09:05 -0700 (PDT)
Date: Fri, 12 Sep 2014 10:08:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: break after selecting process to kill
Message-ID: <20140912080853.GA12156@dhcp22.suse.cz>
References: <20140911213338.GA4098@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140911213338.GA4098@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Niv Yehezkel <executerx@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, oleg@redhat.com

On Thu 11-09-14 17:33:39, Niv Yehezkel wrote:
> There is no need to fallback and continue computing
> badness for each running process after we have found a
> process currently performing the swapoff syscall. We ought to
> immediately select this process for killing.

a) this is not only about swapoff. KSM (run_store) is currently
   considered oom origin as well.
b) you forgot to tell us what led you to this change. It sounds like a
   minor optimization to me. We can potentially skip scanning through
   many tasks but this is not guaranteed at all because our task might
   be at the very end of the tasks list as well.
c) finally this might select thread != thread_group_leader which is a
   minor issue affecting oom report

I am not saying the change is wrong but please make sure you first
describe your motivation. Does it fix any issue you are seeing?  Is this
just something that struck you while reading the code? Maybe it was 
/* always select this thread first */ comment for OOM_SCAN_SELECT.
Besides that your process_selected is not really needed. You could test
for chosen_points == ULONG_MAX as well. This would be even more
straightforward because any score like that is ultimate candidate.

> Signed-off-by: Niv Yehezkel <executerx@gmail.com>
> ---
>  mm/oom_kill.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1e11df8..68ac30e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -305,6 +305,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  	struct task_struct *g, *p;
>  	struct task_struct *chosen = NULL;
>  	unsigned long chosen_points = 0;
> +	bool process_selected = false;
>  
>  	rcu_read_lock();
>  	for_each_process_thread(g, p) {
> @@ -315,7 +316,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		case OOM_SCAN_SELECT:
>  			chosen = p;
>  			chosen_points = ULONG_MAX;
> -			/* fall through */
> +			process_selected = true;
> +			break;
>  		case OOM_SCAN_CONTINUE:
>  			continue;
>  		case OOM_SCAN_ABORT:
> @@ -324,6 +326,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		case OOM_SCAN_OK:
>  			break;
>  		};
> +		if (process_selected)
> +			break;
>  		points = oom_badness(p, NULL, nodemask, totalpages);
>  		if (!points || points < chosen_points)
>  			continue;
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
