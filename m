Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 31D654402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 16:13:58 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id jx14so19502265pad.2
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 13:13:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y63si14715037pfi.192.2015.12.17.13.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 13:13:57 -0800 (PST)
Date: Thu, 17 Dec 2015 13:13:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-Id: <20151217131356.83d920b7c250a785aa132139@linux-foundation.org>
In-Reply-To: <20151217130223.GE18625@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
	<20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
	<20151217130223.GE18625@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 17 Dec 2015 14:02:24 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > I guess it means that the __oom_reap_vmas() success rate is nice anud
> > high ;)
> 
> I had a debugging trace_printks around this and there were no reties
> during my testing so I was probably lucky to not trigger the mmap_sem
> contention.
> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 48025a21f8c4..f53f87cfd899 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -469,7 +469,7 @@ static void oom_reap_vmas(struct mm_struct *mm)
>  	int attempts = 0;
>  
>  	while (attempts++ < 10 && !__oom_reap_vmas(mm))
> -		schedule_timeout(HZ/10);
> +		msleep_interruptible(100);
>  
>  	/* Drop a reference taken by wake_oom_reaper */
>  	mmdrop(mm);

Timeliness matter here.  Over on the other CPU, direct reclaim is
pounding along, on its way to declaring oom.  Sometimes the oom_reaper
thread will end up scavenging memory on behalf of a caller who gave up
a long time ago.  But we shouldn't atempt to "fix" that unless we can
demonstrate that it's a problem.


Also, re-reading your description:

: It has been shown (e.g.  by Tetsuo Handa) that it is not that hard to
: construct workloads which break the core assumption mentioned above and
: the OOM victim might take unbounded amount of time to exit because it
: might be blocked in the uninterruptible state waiting for on an event
: (e.g.  lock) which is blocked by another task looping in the page
: allocator.

So the allocating task has done an oom-kill and is waiting for memory
to become available.  The killed task is stuck on some lock, unable to
free memory.

But the problematic lock will sometimes be the killed tasks's mmap_sem,
so the reaper won't reap anything.  This scenario requires that the
mmap_sem is held for writing, which sounds like it will be uncommon. 
hm.  sigh.  I hate the oom-killer.  Just buy some more memory already!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
