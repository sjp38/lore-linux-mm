Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D3EEF6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 08:53:52 -0400 (EDT)
Received: by wibg7 with SMTP id g7so147339022wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 05:53:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9si9730880wjs.200.2015.03.26.05.53.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 05:53:51 -0700 (PDT)
Date: Thu, 26 Mar 2015 13:53:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 04/12] mm: oom_kill: remove unnecessary locking in
 exit_oom_victim()
Message-ID: <20150326125348.GF15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:08, Johannes Weiner wrote:
> Disabling the OOM killer needs to exclude allocators from entering,
> not existing victims from exiting.

The idea was that exit_oom_victim doesn't miss a waiter.

exit_oom_victim is doing
	atomic_dec_return(&oom_victims) && oom_killer_disabled)

so there is a full (implicit) memory barrier befor oom_killer_disabled
check. The other part is trickier. oom_killer_disable does:
	oom_killer_disabled = true;
        up_write(&oom_sem);

        wait_event(oom_victims_wait, !atomic_read(&oom_victims));

up_write doesn't guarantee a full memory barrier AFAICS in
Documentation/memory-barriers.txt (although the generic and x86
implementations seem to implement it as a full barrier) but wait_event
implies the full memory barrier (prepare_to_wait_event does spin
lock&unlock) before checking the condition in the slow path. This should
be sufficient and docummented...

	/*
	 * We do not need to hold oom_sem here because oom_killer_disable
	 * guarantees that oom_killer_disabled chage is visible before
	 * the waiter is put into sleep (prepare_to_wait_event) so
	 * we cannot miss a wake up.
	 */

in unmark_oom_victim()

> Right now the only waiter is suspend code, which achieves quiescence
> by disabling the OOM killer.  But later on we want to add waits that
> hold the lock instead to stop new victims from showing up.

It is not entirely clear what you mean by this from the current context.
exit_oom_victim is not called from any context which would be locked by
any OOM internals so it should be safe to use the locking.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I have nothing against the change as it seems correct but it would be
good to get a better clarification and also document the implicit memory
barriers.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/oom_kill.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4b9547be9170..88aa9ba40fa5 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -437,14 +437,12 @@ void exit_oom_victim(void)
>  {
>  	clear_thread_flag(TIF_MEMDIE);
>  
> -	down_read(&oom_sem);
>  	/*
>  	 * There is no need to signal the lasst oom_victim if there
>  	 * is nobody who cares.
>  	 */
>  	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
>  		wake_up_all(&oom_victims_wait);
> -	up_read(&oom_sem);
>  }
>  
>  /**
> -- 
> 2.3.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
