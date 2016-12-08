Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A40586B025E
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 03:20:04 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id he10so52491475wjc.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 00:20:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c133si12252517wme.54.2016.12.08.00.20.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 00:20:03 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
References: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161207081555.GB17136@dhcp22.suse.cz>
 <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5c3ddf50-ca19-2cae-a3ce-b10eafe8363c@suse.cz>
Date: Thu, 8 Dec 2016 09:20:01 +0100
MIME-Version: 1.0
In-Reply-To: <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com
Cc: linux-mm@kvack.org

On 12/07/2016 04:29 PM, Tetsuo Handa wrote:
>>> As a result, the OOM killer is unable to send SIGKILL to OOM
>>> victims and/or wake up the OOM reaper by releasing oom_lock for minutes
>>> because other threads consume a lot of CPU time for pointless direct
>>> reclaim.
>>>
>>> ----------
>>> [ 2802.635229] Killed process 7267 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
>>> [ 2802.644296] oom_reaper: reaped process 7267 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
>>> [ 2802.650237] Out of memory: Kill process 7268 (a.out) score 999 or sacrifice child
>>> [ 2803.653052] Killed process 7268 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
>>> [ 2804.426183] oom_reaper: reaped process 7268 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
>>> [ 2804.432524] Out of memory: Kill process 7269 (a.out) score 999 or sacrifice child
>>> [ 2805.349380] a.out: page allocation stalls for 10047ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
>>> [ 2805.349383] CPU: 2 PID: 7243 Comm: a.out Not tainted 4.9.0-rc8 #62
>>> (...snipped...)
>>> [ 3540.977499]           a.out  7269     22716.893359      5272   120
>>> [ 3540.977499]         0.000000      1447.601063         0.000000
>>> [ 3540.977499]  0 0
>>> [ 3540.977500]  /autogroup-155
>>> ----------
>>>
>>> This patch adds extra sleeps which is effectively equivalent to
>>>
>>>   if (mutex_lock_killable(&oom_lock) == 0)
>>>     mutex_unlock(&oom_lock);
>>>
>>> before retrying allocation at __alloc_pages_may_oom() so that the
>>> OOM killer is not preempted by other threads waiting for the OOM
>>> killer/reaper to reclaim memory. Since the OOM reaper grabs oom_lock
>>> due to commit e2fe14564d3316d1 ("oom_reaper: close race with exiting
>>> task"), waking up other threads before the OOM reaper is woken up by
>>> directly waiting for oom_lock might not help so much.
>>
>> So, why don't you simply s@mutex_trylock@mutex_lock_killable@ then?
>> The trylock is simply an optimistic heuristic to retry while the memory
>> is being freed. Making this part sync might help for the case you are
>> seeing.
>
> May I? Something like below? With patch below, the OOM killer can send
> SIGKILL smoothly and printk() can report smoothly (the frequency of
> "** XXX printk messages dropped **" messages is significantly reduced).
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2c6d5f6..ee0105b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3075,7 +3075,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  	 * Acquire the oom lock.  If that fails, somebody else is
>  	 * making progress for us.
>  	 */

The comment above could use some updating then. Although maybe "somebody 
killed us" is also technically "making progress for us" :)

> -	if (!mutex_trylock(&oom_lock)) {
> +	if (mutex_lock_killable(&oom_lock)) {
>  		*did_some_progress = 1;
>  		schedule_timeout_uninterruptible(1);

I think if we get here, it means somebody killed us, so we should not do 
this uninterruptible sleep anymore? (maybe also the caller could need 
some check to expedite the kill?).

>  		return NULL;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
