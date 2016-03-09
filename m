Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 124B96B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 17:22:05 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id r187so47118993oih.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 14:22:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id js8si405435obc.39.2016.03.09.14.22.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 14:22:03 -0800 (PST)
Subject: Re: [PATCH 2/2] oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
	<1457442737-8915-3-git-send-email-mhocko@kernel.org>
	<20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
In-Reply-To: <20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
Message-Id: <201603100721.CDC86433.OMFOVOHSJFLFQt@I-love.SAKURA.ne.jp>
Date: Thu, 10 Mar 2016 07:21:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.com, hannes@cmpxchg.org

Andrew Morton wrote:
> I found the below patch lying around but I didn't queue it properly. 
> Is it legit?

I think that patch wants patch description updated.
Not testing pure noise, but causing possible livelock.
http://lkml.kernel.org/r/20160217143917.GP29196@dhcp22.suse.cz

> 
> 
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
> 
> When the OOM killer scans tasks and encounters a PF_EXITING one, it
> force-selects that one regardless of the score. Is there a possibility
> that the task might hang after it has set PF_EXITING? In that case the
> OOM killer should be able to move on to the next task.
> 
> Frankly, I don't even know why we check for exiting tasks in the OOM
> killer. We've tried direct reclaim at least 15 times by the time we
> decide the system is OOM, there was plenty of time to exit and free
> memory; and a task might exit voluntarily right after we issue a kill.
> This is testing pure noise.
> 
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrea Argangeli <andrea@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/oom_kill.c |    3 ---
>  1 file changed, 3 deletions(-)
> 
> diff -puN mm/oom_kill.c~oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix mm/oom_kill.c
> --- a/mm/oom_kill.c~oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
> +++ a/mm/oom_kill.c
> @@ -292,9 +292,6 @@ enum oom_scan_t oom_scan_process_thread(
>  	if (oom_task_origin(task))
>  		return OOM_SCAN_SELECT;
>  
> -	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
> -		return OOM_SCAN_ABORT;
> -
>  	return OOM_SCAN_OK;
>  }
>  
> _
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
