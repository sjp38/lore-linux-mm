Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C99DC6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 08:29:30 -0500 (EST)
Received: by wmuu63 with SMTP id u63so172878539wmu.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 05:29:30 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id y63si35896133wmc.28.2015.12.01.05.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 05:29:29 -0800 (PST)
Received: by wmvv187 with SMTP id v187so206667935wmv.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 05:29:29 -0800 (PST)
Date: Tue, 1 Dec 2015 14:29:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
Message-ID: <20151201132927.GG4567@dhcp22.suse.cz>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <1448640772-30147-1-git-send-email-mhocko@kernel.org>
 <201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
 <201511290110.FJB87096.OHJLVQOSFFtMFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511290110.FJB87096.OHJLVQOSFFtMFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

On Sun 29-11-15 01:10:10, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > > Users of mmap_sem which need it for write should be carefully reviewed
> > > to use _killable waiting as much as possible and reduce allocations
> > > requests done with the lock held to absolute minimum to reduce the risk
> > > even further.
> > 
> > It will be nice if we can have down_write_killable()/down_read_killable().
> 
> It will be nice if we can also have __GFP_KILLABLE.

Well, we already do this implicitly because OOM killer will
automatically do mark_oom_victim if it has fatal_signal_pending and then
__alloc_pages_slowpath fails the allocation if the memory reserves do
not help to finish the allocation.

> Although currently it can't
> be perfect because reclaim functions called from __alloc_pages_slowpath() use
> unkillable waits, starting from just bail out as with __GFP_NORETRY when
> fatal_signal_pending(current) is true will be helpful.
> 
> So far I'm hitting no problem with testers except the one using mmap()/munmap().
> 
> I think that cmpxchg() was not needed.

It is not needed right now but I would rather not depend on the oom
mutex here. This is not a hot path where an atomic would add an
overhead.

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index c2ab7f9..1a65739 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -483,8 +483,6 @@ static int oom_reaper(void *unused)
>  
>  static void wake_oom_reaper(struct mm_struct *mm)
>  {
> -	struct mm_struct *old_mm;
> -
>  	if (!oom_reaper_th)
>  		return;
>  
> @@ -492,14 +490,15 @@ static void wake_oom_reaper(struct mm_struct *mm)
>  	 * Make sure that only a single mm is ever queued for the reaper
>  	 * because multiple are not necessary and the operation might be
>  	 * disruptive so better reduce it to the bare minimum.
> +	 * Caller is serialized by oom_lock mutex.
>  	 */
> -	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
> -	if (!old_mm) {
> +	if (!mm_to_reap) {
>  		/*
>  		 * Pin the given mm. Use mm_count instead of mm_users because
>  		 * we do not want to delay the address space tear down.
>  		 */
>  		atomic_inc(&mm->mm_count);
> +		mm_to_reap = mm;
>  		wake_up(&oom_reaper_wait);
>  	}
>  }

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
