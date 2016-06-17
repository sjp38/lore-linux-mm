Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF4616B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:35:54 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y82so132509824oig.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:35:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j15si6797020ote.140.2016.06.17.04.35.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 04:35:54 -0700 (PDT)
Subject: Re: [PATCH 08/10] mm, oom: task_will_free_mem should skip oom_reaped tasks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
	<1465473137-22531-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465473137-22531-9-git-send-email-mhocko@kernel.org>
Message-Id: <201606172035.BCG92033.HtSOFOOMVLJFFQ@I-love.SAKURA.ne.jp>
Date: Fri, 17 Jun 2016 20:35:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 0-day robot has encountered the following:
> [   82.694232] Out of memory: Kill process 3914 (trinity-c0) score 167 or sacrifice child
> [   82.695110] Killed process 3914 (trinity-c0) total-vm:55864kB, anon-rss:1512kB, file-rss:1088kB, shmem-rss:25616kB
> [   82.706724] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26488kB
> [   82.715540] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
> [   82.717662] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
> [   82.725804] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:27296kB
> [   82.739091] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:28148kB
> 
> oom_reaper is trying to reap the same task again and again. This
> is possible only when the oom killer is bypassed because of
> task_will_free_mem because we skip over tasks with MMF_OOM_REAPED
> already set during select_bad_process. Teach task_will_free_mem to skip
> over MMF_OOM_REAPED tasks as well because they will be unlikely to free
> anything more.

I agree that we need to prevent same mm from being selected forever. But I
feel worried about this patch. We are reaching a stage what purpose we set
TIF_MEMDIE for. mark_oom_victim() sets TIF_MEMDIE on a thread with oom_lock
held. Thus, if a mm which the TIF_MEMDIE thread is using is reapable (likely
yes), __oom_reap_task() will likely be the next thread which will get that lock
because __oom_reap_task() uses mutex_lock(&oom_lock) whereas other threads
using that mm use mutex_trylock(&oom_lock). As a result, regarding CONFIG_MMU=y
kernels, I guess that

	if (task_will_free_mem(current)) {

shortcut in out_of_memory() likely becomes an useless condition. Since the OOM
reaper will quickly reap mm and set MMF_OOM_REAPED on that mm and clear
TIF_MEMDIE, other threads using that mm will fail to get TIF_MEMDIE (because
task_will_free_mem() will start returning false due to this patch) and proceed
to next OOM victim selection. The comment

         * That thread will now get access to memory reserves since it has a
         * pending fatal signal.

in oom_kill_process() became almost dead. Since we need a short delay in order
to allow get_page_from_freelist() to allocate from memory reclaimed by
__oom_reap_task(), this patch might increase possibility of excessively
preventing OOM-killed threads from using ALLOC_NO_WATERMARKS via TIF_MEMDIE
and increase possibility of needlessly selecting next OOM victim.

So, maybe we shouldn't let this shortcut to return false as soon as
MMF_OOM_REAPED is set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
