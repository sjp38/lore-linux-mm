Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 939216B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 19:28:23 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y13so341883pdi.14
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 16:28:23 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ng4si1462606pbc.405.2014.04.23.16.28.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 16:28:22 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id kq14so612332pab.18
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 16:28:22 -0700 (PDT)
Date: Wed, 23 Apr 2014 16:28:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm -repost] memcg: do not hang on OOM when killed by
 userspace OOM access to memory reserves
In-Reply-To: <1398247922-2374-1-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.02.1404231627410.11506@chino.kir.corp.google.com>
References: <1398247922-2374-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, stable@vger.kernel.org

On Wed, 23 Apr 2014, Michal Hocko wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

I think we should wait for a Tested-by from Eric if this is going to be 
backported to stable, though, to meet the criteria.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
