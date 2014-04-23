Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 17DE26B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 08:55:05 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so745135eek.35
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 05:55:05 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id d5si3107830eei.58.2014.04.23.05.55.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 05:55:04 -0700 (PDT)
Date: Wed, 23 Apr 2014 08:54:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -repost] memcg: do not hang on OOM when killed by
 userspace OOM access to memory reserves
Message-ID: <20140423125455.GA31836@cmpxchg.org>
References: <1398247922-2374-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398247922-2374-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, stable@vger.kernel.org

On Wed, Apr 23, 2014 at 12:12:02PM +0200, Michal Hocko wrote:
> Eric has reported that he can see task(s) stuck in memcg OOM handler
> regularly.  The only way out is to
> 
> 	echo 0 > $GROUP/memory.oom_controll
> 
> His usecase is:
> 
> - Setup a hierarchy with memory and the freezer (disable kernel oom and
>   have a process watch for oom).
> 
> - In that memory cgroup add a process with one thread per cpu.
> 
> - In one thread slowly allocate once per second I think it is 16M of ram
>   and mlock and dirty it (just to force the pages into ram and stay
>   there).
> 
> - When oom is achieved loop:
>   * attempt to freeze all of the tasks.
>   * if frozen send every task SIGKILL, unfreeze, remove the directory in
>     cgroupfs.
> 
> Eric has then pinpointed the issue to be memcg specific.
> 
> All tasks are sitting on the memcg_oom_waitq when memcg oom is disabled.
> Those that have received fatal signal will bypass the charge and should
> continue on their way out.  The tricky part is that the exit path might
> trigger a page fault (e.g.  exit_robust_list), thus the memcg charge,
> while its memcg is still under OOM because nobody has released any charges
> yet.
> 
> Unlike with the in-kernel OOM handler the exiting task doesn't get
> TIF_MEMDIE set so it doesn't shortcut further charges of the killed task
> and falls to the memcg OOM again without any way out of it as there are no
> fatal signals pending anymore.
> 
> This patch fixes the issue by checking PF_EXITING early in
> mem_cgroup_try_charge and bypass the charge same as if it had fatal
> signal pending or TIF_MEMDIE set.
> 
> Normally exiting tasks (aka not killed) will bypass the charge now but
> this should be OK as the task is leaving and will release memory and
> increasing the memory pressure just to release it in a moment seems
> dubious wasting of cycles.  Besides that charges after exit_signals should
> be rare.
> 
> Reported-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

We're allowing fatal_signal_pending() tasks to bypass the limit
already, so I don't see why we shouldn't do the same for tasks that
cleared the signal and are in fact exiting.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
