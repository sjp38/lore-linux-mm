Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2789A6B0266
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:55:36 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e93-v6so3717059plb.5
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:55:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p128-v6sor3470170pga.26.2018.07.24.13.55.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 13:55:35 -0700 (PDT)
Date: Tue, 24 Jul 2018 13:55:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: remove oom_lock from oom_reaper
In-Reply-To: <20180719075922.13784-1-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.21.1807241355200.191886@chino.kir.corp.google.com>
References: <20180719075922.13784-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, 19 Jul 2018, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> oom_reaper used to rely on the oom_lock since e2fe14564d33 ("oom_reaper:
> close race with exiting task"). We do not really need the lock anymore
> though. 212925802454 ("mm: oom: let oom_reap_task and exit_mmap run
> concurrently") has removed serialization with the exit path based on the
> mm reference count and so we do not really rely on the oom_lock anymore.
> 
> Tetsuo was arguing that at least MMF_OOM_SKIP should be set under the
> lock to prevent from races when the page allocator didn't manage to get
> the freed (reaped) memory in __alloc_pages_may_oom but it sees the flag
> later on and move on to another victim. Although this is possible in
> principle let's wait for it to actually happen in real life before we
> make the locking more complex again.
> 
> Therefore remove the oom_lock for oom_reaper paths (both exit_mmap and
> oom_reap_task_mm). The reaper serializes with exit_mmap by mmap_sem +
> MMF_OOM_SKIP flag. There is no synchronization with out_of_memory path
> now.
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>
