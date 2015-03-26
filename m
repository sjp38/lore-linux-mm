Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 66C7B6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:51:34 -0400 (EDT)
Received: by igcau2 with SMTP id au2so116940759igc.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:51:34 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id i17si3633552icm.95.2015.03.25.17.51.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 17:51:33 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so117196724igb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:51:33 -0700 (PDT)
Date: Wed, 25 Mar 2015 17:51:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 01/12] mm: oom_kill: remove unnecessary locking in
 oom_enable()
In-Reply-To: <1427264236-17249-2-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1503251744290.32157@chino.kir.corp.google.com>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org> <1427264236-17249-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Wed, 25 Mar 2015, Johannes Weiner wrote:

> Setting oom_killer_disabled to false is atomic, there is no need for
> further synchronization with ongoing allocations trying to OOM-kill.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/oom_kill.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 2b665da1b3c9..73763e489e86 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -488,9 +488,7 @@ bool oom_killer_disable(void)
>   */
>  void oom_killer_enable(void)
>  {
> -	down_write(&oom_sem);
>  	oom_killer_disabled = false;
> -	up_write(&oom_sem);
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))

I haven't looked through the new disable-oom-killer-for-pm patchset that 
was merged, but this oom_killer_disabled thing already looks improperly 
handled.  I think any correctness or cleanups in this area would be very 
helpful.

I think mark_tsk_oom_victim() in mem_cgroup_out_of_memory() is just 
luckily not racing with a call to oom_killer_enable() and triggering the 
WARN_ON(oom_killer_disabled) since there's no "oom_sem" held here, and 
it's an improper context based on the comment of mark_tsk_oom_victim().  
There might be something else that is intended but not implemented 
correctly that I'm unaware of, but I know of no reason why setting of 
oom_killer_disabled would need to take a semaphore?

I'm thinking it has something to do with the remainder of that comment, 
specifically the "never after oom has been disabled already."

Michal?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
