Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 66CB06B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 09:49:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h68so24612407lfh.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 06:49:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dm2si827650wjb.137.2016.06.02.06.49.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 06:49:16 -0700 (PDT)
Date: Thu, 2 Jun 2016 15:49:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom_reaper: don't call mmput_async() without
 atomic_inc_not_zero()
Message-ID: <20160602134913.GR1995@dhcp22.suse.cz>
References: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160601155313.dc3aa18eb6ad0e163d44b355@linux-foundation.org>
 <20160602064804.GF1995@dhcp22.suse.cz>
 <201606022120.FAG39003.OFFtHOVMFSJQLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606022120.FAG39003.OFFtHOVMFSJQLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, arnd@arndb.de

On Thu 02-06-16 21:20:03, Tetsuo Handa wrote:
[...]
> Also, dmesg.xz in the crash report http://lkml.kernel.org/r/20160601080209.GA7190@yexl-desktop
> includes an interesting race.
> 
[...]
> The consecutive oom_reaper message on the same thread
> 
> ----------
> [   82.706724] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26488kB
> [   82.715540] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
> [   82.717662] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
> [   82.725804] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:27296kB
> [   82.739091] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:28148kB
> ----------
> 
> suggests that it repeated race that trinity-c0 called out_of_memory()
> and hit the shortcut
> 
> 	if (current->mm &&
> 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> 		mark_oom_victim(current);
> 		try_oom_reaper(current);
> 		return true;
> 	}
> 
> and got TIF_MEMDIE and woke up the OOM reaper. But the OOM reaper started
> oom_reap_task() and cleared TIF_MEMDIE from trinity-c0 BEFORE trinity-c0
> tries to allocate using ALLOC_NO_WATERMARKS via TIF_MEMDIE.
> 
> As a result, trinity-c0 was unable to use ALLOC_NO_WATERMARKS and had to call
> out_of_memory() again. And again hit the shortcut and got TIF_MEMDIE and woke
> up the OOM reaper, the OOM reaper cleared TIF_MEMDIE. So, this set TIF_MEMDIE
> followed by clear TIF_MEMDIE repetition lasted for several times. Maybe we
> should not try to clear TIF_MEMDIE from the OOM reaper.

If we do not clear TIF_MEMDIE then we risk other issues. What we can do
instead is to check for MMF_OOM_REAPED in task_will_free_mem and do not
allow to bypass the oom killer. I will enahance the series which hammers
that code path with that check. Thanks for pointing this out!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
