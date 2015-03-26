Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 642596B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:57:43 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so18937741wia.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:57:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wh5si9552908wjb.85.2015.03.26.04.57.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 04:57:42 -0700 (PDT)
Date: Thu, 26 Mar 2015 12:57:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/12] mm: oom_kill: switch test-and-clear of known
 TIF_MEMDIE to clear
Message-ID: <20150326115740.GE15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:07, Johannes Weiner wrote:
> exit_oom_victim() already knows that TIF_MEMDIE is set, and nobody
> else can clear it concurrently.  Use clear_thread_flag() directly.

Yeah. This is a left over from the review process. I originally did
unmarking unconditionally but Tejun suggested calling test_thread_flag
before calling here. So the test_and_clear is safe here.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/oom_kill.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b2f081fe4b1a..4b9547be9170 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -435,8 +435,7 @@ void mark_oom_victim(struct task_struct *tsk)
>   */
>  void exit_oom_victim(void)
>  {
> -	if (!test_and_clear_thread_flag(TIF_MEMDIE))
> -		return;
> +	clear_thread_flag(TIF_MEMDIE);
>  
>  	down_read(&oom_sem);
>  	/*
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
