Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4036B0007
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 14:55:24 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 39-v6so13039943ple.6
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 11:55:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h1-v6sor4467247pgf.292.2018.07.10.11.55.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 11:55:22 -0700 (PDT)
Date: Tue, 10 Jul 2018 11:55:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: remove sleep from under oom_lock
In-Reply-To: <20180710094341.GD14284@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1807101152410.9234@chino.kir.corp.google.com>
References: <20180709074706.30635-1-mhocko@kernel.org> <alpine.DEB.2.21.1807091548280.125566@chino.kir.corp.google.com> <20180710094341.GD14284@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 10 Jul 2018, Michal Hocko wrote:

> What do you think about the following?
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ed9d473c571e..32e6f7becb40 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -53,6 +53,14 @@ int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
>  int sysctl_oom_dump_tasks = 1;
>  
> +/*
> + * Serializes oom killer invocations (out_of_memory()) from all contexts to
> + * prevent from over eager oom killing (e.g. when the oom killer is invoked
> + * from different domains).
> + *
> + * oom_killer_disable() relies on this lock to stabilize oom_killer_disabled
> + * and mark_oom_victim
> + */
>  DEFINE_MUTEX(oom_lock);
>  
>  #ifdef CONFIG_NUMA

I think it's better, thanks.  However, does it address the question about 
why __oom_reap_task_mm() needs oom_lock protection?  Perhaps it would be 
helpful to mention synchronization between reaping triggered from 
oom_reaper and by exit_mmap().
