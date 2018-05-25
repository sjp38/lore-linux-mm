Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83C216B027A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 20:49:57 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id p19-v6so1972661plo.14
        for <linux-mm@kvack.org>; Thu, 24 May 2018 17:49:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 94-v6si19775962pla.500.2018.05.24.17.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 17:49:56 -0700 (PDT)
Message-Id: <201805250019.w4P0J3Dl018566@www262.sakura.ne.jp>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional processes
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 25 May 2018 09:19:03 +0900
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David Rientjes wrote:
> The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> it cannot reap an mm.  This can happen for a variety of reasons,
> including:
> 
>  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> 
>  - when the mm has blockable mmu notifiers that could cause the oom reaper
>    to stall indefinitely,
> 
> but we can also add a third when the oom reaper can "reap" an mm but doing
> so is unlikely to free any amount of memory:
> 
>  - when the mm's memory is fully mlocked.

   - when the mm's memory is fully mlocked (needs privilege) or
     fully shared (does not need privilege)

> 
> When all memory is mlocked, the oom reaper will not be able to free any
> substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
> unmap and free its memory in exit_mmap() and subsequent oom victims are
> chosen unnecessarily.  This is trivial to reproduce if all eligible
> processes on the system have mlocked their memory: the oom killer calls
> panic() even though forward progress can be made.

s/mlocked/mlocked or shared/g

> 
> This is the same issue where the exit path sets MMF_OOM_SKIP before
> unmapping memory and additional processes can be chosen unnecessarily
> because the oom killer is racing with exit_mmap().
> 
> We can't simply defer setting MMF_OOM_SKIP, however, because if there is
> a true oom livelock in progress, it never gets set and no additional
> killing is possible.
> 
> To fix this, this patch introduces a per-mm reaping timeout, initially set
> at 10s.  It requires that the oom reaper's list becomes a properly linked
> list so that other mm's may be reaped while waiting for an mm's timeout to
> expire.

I already proposed more simpler one at https://patchwork.kernel.org/patch/9877991/ .

> 
> The exit path will now set MMF_OOM_SKIP only after all memory has been
> freed, so additional oom killing is justified, and rely on MMF_UNSTABLE to
> determine when it can race with the oom reaper.
> 
> The oom reaper will now set MMF_OOM_SKIP only after the reap timeout has
> lapsed because it can no longer guarantee forward progress.
> 
> The reaping timeout is intentionally set for a substantial amount of time
> since oom livelock is a very rare occurrence and it's better to optimize
> for preventing additional (unnecessary) oom killing than a scenario that
> is much more unlikely.

But before thinking about your proposal, please think about how to guarantee
that the OOM reaper and the exit path can run discussed at
http://lkml.kernel.org/r/201805122318.HJG81246.MFVFLFJOOQtSHO@I-love.SAKURA.ne.jp .
