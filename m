Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 37E8B6B0007
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 03:44:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f8-v6so9125089eds.6
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 00:44:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o34-v6si2108466eda.43.2018.07.16.00.44.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 00:44:12 -0700 (PDT)
Date: Mon, 16 Jul 2018 09:44:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: remove oom_lock from exit_mmap
Message-ID: <20180716074410.GB17280@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
 <20180713142612.GD19960@dhcp22.suse.cz>
 <44d26c25-6e09-49de-5e90-3c16115eb337@i-love.sakura.ne.jp>
 <20180716061317.GA17280@dhcp22.suse.cz>
 <916d7e1d-66ea-00d9-c943-ef3d2e082584@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <916d7e1d-66ea-00d9-c943-ef3d2e082584@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-07-18 16:04:26, Tetsuo Handa wrote:
> On 2018/07/16 15:13, Michal Hocko wrote:
> > On Sat 14-07-18 06:18:58, Tetsuo Handa wrote:
> >>> @@ -3073,9 +3073,7 @@ void exit_mmap(struct mm_struct *mm)
> >>>  		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> >>>  		 * reliably test it.
> >>>  		 */
> >>> -		mutex_lock(&oom_lock);
> >>>  		__oom_reap_task_mm(mm);
> >>> -		mutex_unlock(&oom_lock);
> >>>  
> >>>  		set_bit(MMF_OOM_SKIP, &mm->flags);
> >>
> >> David and Michal are using different version as a baseline here.
> >> David is making changes using timeout based back off (in linux-next.git)
> >> which is inappropriately trying to use MMF_UNSTABLE for two purposes.
> >>
> >> Michal is making changes using current code (in linux.git) which does not
> >> address David's concern.
> > 
> > Yes I have based it on top of Linus tree because the point of this patch
> > is to get rid of the locking which is no longer needed. I do not see
> > what concern are you talking about.
> 
> I'm saying that applying your patch does not work on linux-next.git
> because David's patch already did s/MMF_OOM_SKIP/MMF_UNSTABLE/ .

This patch has been nacked by me AFAIR so I assume it should be dropped
from the mmotm tree.
 
> >> My version ( https://marc.info/?l=linux-mm&m=153119509215026 ) is
> >> making changes using current code which also provides oom-badness
> >> based back off in order to address David's concern.
> >>
> >>>  		down_write(&mm->mmap_sem);
> >>
> >> Anyway, I suggest doing
> >>
> >>   mutex_lock(&oom_lock);
> >>   set_bit(MMF_OOM_SKIP, &mm->flags);
> >>   mutex_unlock(&oom_lock);
> > 
> > Why do we need it?
> > 
> >> like I mentioned at
> >> http://lkml.kernel.org/r/201807130620.w6D6KiAJ093010@www262.sakura.ne.jp
> >> even if we make changes on top of linux-next's timeout based back off.
> > 
> > says
> > : (3) Prevent from selecting new OOM victim when there is an !MMF_OOM_SKIP mm
> > :     which current thread should wait for.
> > [...]
> > : Regarding (A), we can reduce the range oom_lock serializes from
> > : "__oom_reap_task_mm()" to "setting MMF_OOM_SKIP", for oom_lock is useful for (3).
> > 
> > But why there is a lock needed for this? This doesn't make much sense to
> > me. If we do not have MMF_OOM_SKIP set we still should have mm_is_oom_victim
> > so no new task should be selected. If we race with the oom reaper than
> > ok, we would just not select a new victim and retry later.
> > 
> 
> How mm_is_oom_victim() helps? mm_is_oom_victim() is used by exit_mmap() whether
> current thread should call __oom_reap_task_mm().
> 
> I'm talking about below sequence (i.e. after returning from __oom_reap_task_mm()).
> 
>   CPU 0                                   CPU 1
>   
>   mutex_trylock(&oom_lock) in __alloc_pages_may_oom() succeeds.
>   get_page_from_freelist() fails.
>   Enters out_of_memory().
> 
>                                           __oom_reap_task_mm() reclaims some memory.
>                                           Sets MMF_OOM_SKIP.
> 
>   select_bad_process() selects new victim because MMF_OOM_SKIP is already set.
>   Kills a new OOM victim without retrying last second allocation attempt.
>   Leaves out_of_memory().
>   mutex_unlock(&oom_lock) in __alloc_pages_may_oom() is called.

OK, that wasn't clear from your above wording. As you explicitly
mentioned !MMF_OOM_SKIP mm.

> If setting MMF_OOM_SKIP is guarded by oom_lock, we can enforce
> last second allocation attempt like below.
>
>   CPU 0                                   CPU 1
>   
>   mutex_trylock(&oom_lock) in __alloc_pages_may_oom() succeeds.
>   get_page_from_freelist() fails.
>   Enters out_of_memory().
> 
>                                           __oom_reap_task_mm() reclaims some memory.
>                                           mutex_lock(&oom_lock);
> 
>   select_bad_process() does not select new victim because MMF_OOM_SKIP is not yet set.
>   Leaves out_of_memory().
>   mutex_unlock(&oom_lock) in __alloc_pages_may_oom() is called.
> 
>                                           Sets MMF_OOM_SKIP.
>                                           mutex_unlock(&oom_lock);
> 
>   get_page_from_freelist() likely succeeds before reaching __alloc_pages_may_oom() again.
>   Saved one OOM victim from being needlessly killed.
> 
> That is, guarding setting MMF_OOM_SKIP works as if synchronize_rcu(); it waits for anybody
> who already acquired (or started waiting for) oom_lock to release oom_lock, in order to
> prevent select_bad_process() from needlessly selecting new OOM victim.

Hmm, is this a practical problem though? Do we really need to have a
broader locking context just to defeat this race? How about this goes
into a separate patch with some data justifying it?
-- 
Michal Hocko
SUSE Labs
