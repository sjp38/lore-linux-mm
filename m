Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 832FE6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 10:48:09 -0400 (EDT)
Received: by wgra20 with SMTP id a20so177096034wgr.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 07:48:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fi5si6826471wib.86.2015.03.30.07.48.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 07:48:07 -0700 (PDT)
Date: Mon, 30 Mar 2015 16:48:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/12] mm: oom_kill: switch test-and-clear of known
 TIF_MEMDIE to clear
Message-ID: <20150330144804.GD3909@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-4-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.10.1503252025230.16714@chino.kir.corp.google.com>
 <20150326110532.GB18560@cmpxchg.org>
 <alpine.DEB.2.10.1503261231440.9410@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503261231440.9410@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Thu 26-03-15 12:50:20, David Rientjes wrote:
[...]
> android, lmk: avoid setting TIF_MEMDIE if process has already exited
> 
> TIF_MEMDIE should not be set on a process if it does not have a valid 
> ->mm, and this is protected by task_lock().
> 
> If TIF_MEMDIE gets set after the mm has detached, and the process fails to 
> exit, then the oom killer will defer forever waiting for it to exit.
> 
> Make sure that the mm is still valid before setting TIF_MEMDIE by way of 
> mark_tsk_oom_victim().

I would prefer if lmk didn't abuse mark_tsk_oom_victim much more. But
this is correct as well.

> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -156,20 +156,27 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
>  			     p->pid, p->comm, oom_score_adj, tasksize);
>  	}
>  	if (selected) {
> -		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
> -			     selected->pid, selected->comm,
> -			     selected_oom_score_adj, selected_tasksize);
> -		lowmem_deathpending_timeout = jiffies + HZ;
> +		task_lock(selected);
> +		if (!selected->mm) {
> +			/* Already exited, cannot do mark_tsk_oom_victim() */
> +			task_unlock(selected);
> +			goto out;
> +		}
>  		/*
>  		 * FIXME: lowmemorykiller shouldn't abuse global OOM killer
>  		 * infrastructure. There is no real reason why the selected
>  		 * task should have access to the memory reserves.
>  		 */
>  		mark_tsk_oom_victim(selected);
> +		task_unlock(selected);
> +		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
> +			     selected->pid, selected->comm,
> +			     selected_oom_score_adj, selected_tasksize);
> +		lowmem_deathpending_timeout = jiffies + HZ;
>  		send_sig(SIGKILL, selected, 0);
>  		rem += selected_tasksize;
>  	}
> -
> +out:
>  	lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
>  		     sc->nr_to_scan, sc->gfp_mask, rem);
>  	rcu_read_unlock();

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
