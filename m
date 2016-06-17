Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id F14626B025F
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:56:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a2so37476152lfe.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:56:56 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id y4si11962835wjh.3.2016.06.17.05.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 05:56:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 187so16547504wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:56:55 -0700 (PDT)
Date: Fri, 17 Jun 2016 14:56:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/10] mm, oom: task_will_free_mem should skip oom_reaped
 tasks
Message-ID: <20160617125653.GG21670@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-9-git-send-email-mhocko@kernel.org>
 <201606172035.BCG92033.HtSOFOOMVLJFFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606172035.BCG92033.HtSOFOOMVLJFFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 17-06-16 20:35:38, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > 0-day robot has encountered the following:
> > [   82.694232] Out of memory: Kill process 3914 (trinity-c0) score 167 or sacrifice child
> > [   82.695110] Killed process 3914 (trinity-c0) total-vm:55864kB, anon-rss:1512kB, file-rss:1088kB, shmem-rss:25616kB
> > [   82.706724] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26488kB
> > [   82.715540] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
> > [   82.717662] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
> > [   82.725804] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:27296kB
> > [   82.739091] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:28148kB
> > 
> > oom_reaper is trying to reap the same task again and again. This
> > is possible only when the oom killer is bypassed because of
> > task_will_free_mem because we skip over tasks with MMF_OOM_REAPED
> > already set during select_bad_process. Teach task_will_free_mem to skip
> > over MMF_OOM_REAPED tasks as well because they will be unlikely to free
> > anything more.
> 
> I agree that we need to prevent same mm from being selected forever. But I
> feel worried about this patch. We are reaching a stage what purpose we set
> TIF_MEMDIE for. mark_oom_victim() sets TIF_MEMDIE on a thread with oom_lock
> held. Thus, if a mm which the TIF_MEMDIE thread is using is reapable (likely
> yes), __oom_reap_task() will likely be the next thread which will get that lock
> because __oom_reap_task() uses mutex_lock(&oom_lock) whereas other threads
> using that mm use mutex_trylock(&oom_lock). As a result, regarding CONFIG_MMU=y
> kernels, I guess that
> 
> 	if (task_will_free_mem(current)) {
> 
> shortcut in out_of_memory() likely becomes an useless condition. Since the OOM
> reaper will quickly reap mm and set MMF_OOM_REAPED on that mm and clear
> TIF_MEMDIE, other threads using that mm will fail to get TIF_MEMDIE (because
> task_will_free_mem() will start returning false due to this patch) and proceed
> to next OOM victim selection.

I suspect you are overthinking this. Just try to imagine what would have
to happen in order to get another victim:

CPU1					CPU2
__alloc_pages_slowpath
  __alloc_pages_may_oom
    mutex_lock(oom_lock)
    out_of_memory
      task_will_free_mem
        mark_oom_victim
	wake_oom_reaper
					__oom_reap_task
    mutex_unlock(oom_lock)
    					  mutex_lock(oom_lock)
					  unmap_page_range # For all VMAs
					  tlb_finish_mmu
					  set_bit(MMF_OOM_REAPED)
					  mutex_unlock(oom_lock)

  <back in allocator with access to memory reserves>

  __alloc_pages_may_oom
    mutex_lock()
    out_of_memory
    					exit_oom_victim
      task_will_free_mem # False

There will a large window when the current will have TIF_MEMDIE and
there will be memory freed by the oom reaper to get us out of the
mess. Even if that wasn't the case and the address space is not really
reapable then the victim had quite some time to use memory reserves and
move on. And if even that didn't help then it is really hard to judge
whether the victim would benefit from more time.

That being said even if the TIF_MEMDIE wouldn't be used (which is
unlikely because tearing down the address space is likely to take some
time) then the reaper will be freeing memory in the background to help
get away from OOM.

Or did you have any other scenario in mind?

> The comment

>          * That thread will now get access to memory reserves since it has a
>          * pending fatal signal.
> 
> in oom_kill_process() became almost dead. Since we need a short delay in order
> to allow get_page_from_freelist() to allocate from memory reclaimed by
> __oom_reap_task(), this patch might increase possibility of excessively
> preventing OOM-killed threads from using ALLOC_NO_WATERMARKS via TIF_MEMDIE
> and increase possibility of needlessly selecting next OOM victim.

It seems that you are assuming that the oom reaper will not reclaim much
memory. Even if that was the case (e.g. large amount of memory which is
not not directly bound to mm like socket and other kernel buffers but
even then this would be hardly a new problem introduced by this patch
because many of those resources are deallocated past exit_mm).

> So, maybe we shouldn't let this shortcut to return false as soon as
> MMF_OOM_REAPED is set.

What would be an alternative?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
