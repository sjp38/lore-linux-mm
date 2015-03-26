Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 17F3E6B006E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 09:03:53 -0400 (EDT)
Received: by wibg7 with SMTP id g7so147682793wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 06:03:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bs17si9811455wjb.133.2015.03.26.06.03.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 06:03:51 -0700 (PDT)
Date: Thu, 26 Mar 2015 14:03:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 05/12] mm: oom_kill: generalize OOM progress waitqueue
Message-ID: <20150326130350.GH15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:09, Johannes Weiner wrote:
> It turns out that the mechanism to wait for exiting OOM victims is
> less generic than it looks: it won't issue wakeups unless the OOM
> killer is disabled.
> 
> The reason this check was added was the thought that, since only the
> OOM disabling code would wait on this queue, wakeup operations could
> be saved when that specific consumer is known to be absent.
> 
> However, this is quite the handgrenade.  Later attempts to reuse the
> waitqueue for other purposes will lead to completely unexpected bugs
> and the failure mode will appear seemingly illogical.  Generally,
> providers shouldn't make unnecessary assumptions about consumers.
> 
> This could have been replaced with waitqueue_active(), but it only
> saves a few instructions in one of the coldest paths in the kernel.
> Simply remove it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/oom_kill.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 88aa9ba40fa5..d3490b019d46 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -437,11 +437,7 @@ void exit_oom_victim(void)
>  {
>  	clear_thread_flag(TIF_MEMDIE);
>  
> -	/*
> -	 * There is no need to signal the lasst oom_victim if there
> -	 * is nobody who cares.
> -	 */
> -	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
> +	if (!atomic_dec_return(&oom_victims))
>  		wake_up_all(&oom_victims_wait);
>  }
>  
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
