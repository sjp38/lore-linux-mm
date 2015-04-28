Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id C973E6B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:18:54 -0400 (EDT)
Received: by wgen6 with SMTP id n6so151010460wge.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 06:18:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id br1si17950153wib.75.2015.04.28.06.18.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 06:18:52 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:18:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 8/9] mm: page_alloc: wait for OOM killer progress before
 retrying
Message-ID: <20150428131850.GC2659@dhcp22.suse.cz>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
 <1430161555-6058-9-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430161555-6058-9-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 27-04-15 15:05:54, Johannes Weiner wrote:
> There is not much point in rushing back to the freelists and burning
> CPU cycles in direct reclaim when somebody else is in the process of
> OOM killing, or right after issuing a kill ourselves, because it could
> take some time for the OOM victim to release memory.
> 
> This is a very cold error path, so there is not much hurry.  Use the
> OOM victim waitqueue to wait for victims to actually exit, which is a
> solid signal that the memory pinned by those tasks has been released.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good to me. One minor thing/suggestion below.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/oom_kill.c   | 11 +++++++----
>  mm/page_alloc.c | 43 ++++++++++++++++++++++++++-----------------
>  2 files changed, 33 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5cfda39..823f87e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -711,12 +711,15 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		killed = 1;
>  	}
>  out:
> +	if (test_thread_flag(TIF_MEMDIE))
> +		return true;
>  	/*
> -	 * Give the killed threads a good chance of exiting before trying to
> -	 * allocate memory again.
> +	 * Wait for any outstanding OOM victims to die.  In rare cases
> +	 * victims can get stuck behind the allocating tasks, so the
> +	 * wait needs to be bounded.  It's crude alright, but cheaper
> +	 * than keeping a global dependency tree between all tasks.
>  	 */
> -	if (killed)
> -		schedule_timeout_killable(1);
> +	wait_event_timeout(oom_victims_wait, !atomic_read(&oom_victims), 5*HZ);

WARN(!wait_event_timeout(...), "OOM victim has hard time to finish. OOM deadlock?")

or something along those lines? It would tell the admin that something
fishy is going here.

>  
>  	return true;
>  }
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
