Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A51F06B004D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:03:21 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o1GM3ECM002393
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 22:03:14 GMT
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by spaceape11.eur.corp.google.com with ESMTP id o1GM3Ccs021024
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:03:13 -0800
Received: by pxi10 with SMTP id 10so480520pxi.13
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:03:12 -0800 (PST)
Date: Tue, 16 Feb 2010 14:03:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] Kill existing current task quickly
In-Reply-To: <1266335957.1709.67.camel@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1002161357170.23037@chino.kir.corp.google.com>
References: <1266335957.1709.67.camel@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, Minchan Kim wrote:

> If we found current task is existing but didn't set TIF_MEMDIE
> during OOM victim selection, let's stop unnecessary looping for
> getting high badness score task and go ahead for killing current.
> 
> This patch would make side effect skip OOM_DISABLE test.
> But It's okay since the task is existing and oom_kill_process
> doesn't show any killing message since __oom_kill_task will
> interrupt it in oom_kill_process.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Nick Piggin <npiggin@suse.de>
> ---
>  mm/oom_kill.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3618be3..5c21398 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -295,6 +295,7 @@ static struct task_struct
> *select_bad_process(unsigned long *ppoints,
>  
>  			chosen = p;
>  			*ppoints = ULONG_MAX;
> +			break;
>  		}
>  
>  		if (p->signal->oom_adj == OOM_DISABLE)

No, we don't want to break because there may be other candidate tasks that 
have TIF_MEMDIE set that will be detected if we keep scanning.  Returning 
ERR_PTR(-1UL) from select_bad_process() has a special meaning: it means we 
return to the page allocator without doing anything.  We don't want more 
than one candidate task to ever have TIF_MEMDIE at a time, otherwise they 
can deplete all memory reserves and not make any forward progress.  So we 
always have to iterate the entire tasklist unless we find an already oom 
killed task with access to memory reserves (to prevent needlessly killing 
additional tasks before the first had a chance to exit and free its 
memory) or a different candidate task is exiting so we'll be freeing 
memory shortly (or it will be invoking the oom killer itself as current 
and then get chosen as the victim).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
