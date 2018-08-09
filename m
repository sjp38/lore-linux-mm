Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 802596B026B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 11:31:33 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id z78-v6so7161802ywa.23
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 08:31:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u1-v6sor1546807ybo.140.2018.08.09.08.31.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 08:31:32 -0700 (PDT)
Date: Thu, 9 Aug 2018 11:34:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180809153430.GA17445@cmpxchg.org>
References: <0000000000005e979605729c1564@google.com>
 <e2869136-9f59-9ce8-8b9f-f75b157ee31d@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2869136-9f59-9ce8-8b9f-f75b157ee31d@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 09, 2018 at 10:57:43PM +0900, Tetsuo Handa wrote:
> From b1f38168f14397c7af9c122cd8207663d96e02ec Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 9 Aug 2018 22:49:40 +0900
> Subject: [PATCH] mm, oom: task_will_free_mem(current) should retry until
>  memory reserve fails
> 
> Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") changed to select next OOM victim as soon as
> MMF_OOM_SKIP is set. But we don't need to select next OOM victim as
> long as ALLOC_OOM allocation can succeed. And syzbot is hitting WARN(1)
> caused by this race window [1].

Huh? That's the memcg path, it has nothing to do with ALLOC_OOM.

> Since memcg OOM case uses forced charge if current thread is killed,
> out_of_memory() can return true without selecting next OOM victim.
> Therefore, this patch changes task_will_free_mem(current) to ignore
> MMF_OOM_SKIP unless ALLOC_OOM allocation failed.

I have no idea how the first and the second half of this paragraph go
together. They're completely independent code paths.
