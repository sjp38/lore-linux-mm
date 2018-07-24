Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCFF66B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 17:46:00 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 70-v6so3816606plc.1
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 14:46:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n8-v6sor3325737pfi.124.2018.07.24.14.45.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 14:46:00 -0700 (PDT)
Date: Tue, 24 Jul 2018 14:45:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v4] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <f8d24892-b05e-73a8-36d5-4fe278f84c44@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807241444370.206335@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com> <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com> <alpine.DEB.2.21.1807201314230.231119@chino.kir.corp.google.com> <ca34b123-5c81-569f-85ea-4851bc569962@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807201505550.38399@chino.kir.corp.google.com>
 <f8d24892-b05e-73a8-36d5-4fe278f84c44@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 21 Jul 2018, Tetsuo Handa wrote:

> You can't apply "[patch v4] mm, oom: fix unnecessary killing of additional processes"
> because Michal's patch which removes oom_lock serialization was added to -mm tree.
> 

I've rebased the patch to linux-next and posted a v5.

> You might worry about situations where __oom_reap_task_mm() is a no-op.
> But that is not always true. There is no point with emitting
> 
>   pr_info("oom_reaper: unable to reap pid:%d (%s)\n", ...);
>   debug_show_all_locks();
> 
> noise and doing
> 
>   set_bit(MMF_OOM_SKIP, &mm->flags);
> 
> because exit_mmap() will not release oom_lock until __oom_reap_task_mm()
> completes. That is, except extra noise, there is no difference with
> current behavior which sets set_bit(MMF_OOM_SKIP, &mm->flags) after
> returning from __oom_reap_task_mm().
> 

v5 has restructured how exit_mmap() serializes its unmapping with the oom 
reaper.  It sets MMF_OOM_SKIP while holding mm->mmap_sem.
