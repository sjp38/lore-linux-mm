Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id C623E6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 08:40:45 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id r129so69023270wmr.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:40:45 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id x10si22189021wjx.150.2016.01.29.05.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 05:40:44 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id l66so67842287wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:40:44 -0800 (PST)
Date: Fri, 29 Jan 2016 14:40:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmstat: fix wrong WQ sleep when memory reclaim
 doesn't make any progress
Message-ID: <20160129134042.GB32174@dhcp22.suse.cz>
References: <1454064552-5598-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454064552-5598-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, jstancek@redhat.com, torvalds@linux-foundation.org, Tejun Heo <tj@kernel.org>, Cristopher Lameter <clameter@sgi.com>, Joonsoo Kim <js1304@gmail.com>, Arkadiusz Miskiewicz <arekm@maven.pl>, stable@vger.kernel.org

On Fri 29-01-16 19:49:12, Tetsuo Handa wrote:
> Jan Stancek has reported that system occasionally hanging after
> "oom01" testcase from LTP triggers OOM. Guessing from a result that
> there is a kworker thread doing memory allocation and the values
> between "Node 0 Normal free:" and "Node 0 Normal:" differs when
> hanging, vmstat is not up-to-date for some reason.
> 
> According to commit 373ccbe59270 ("mm, vmstat: allow WQ concurrency to
> discover memory reclaim doesn't make any progress"), it meant to force
> the kworker thread to take a short sleep, but it by error used
> schedule_timeout(1). We missed that schedule_timeout() in state
> TASK_RUNNING doesn't do anything.

Dang... You are right of course. I've made the same mistake during
oom_reaper development but didn't realize that the same has been used
for the WQ thingy. My bad!

I am not sure this really fixes the issue mentioned above because I
didn't get to look at the report yet but we definitely have to change
the task state before calling schedule_timeout so this is obviously
correct. I would just argue that the interruptible sleep or TASK_IDLE
would be little bit better. But it shouldn't really matter much with
such a short timeout I guess.

> Fix it by using schedule_timeout_uninterruptible(1) which forces
> the kworker thread to take a short sleep in order to make sure
> that vmstat is up-to-date.
> 
> Fixes: 373ccbe59270 ("mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make any progress")
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Cristopher Lameter <clameter@sgi.com>
> Cc: Joonsoo Kim <js1304@gmail.com>
> Cc: Arkadiusz Miskiewicz <arekm@maven.pl>
> Cc: <stable@vger.kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> ---
>  mm/backing-dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 7340353..cbe6f0b 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -989,7 +989,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
>  		 * here rather than calling cond_resched().
>  		 */
>  		if (current->flags & PF_WQ_WORKER)
> -			schedule_timeout(1);
> +			schedule_timeout_uninterruptible(1);
>  		else
>  			cond_resched();
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
