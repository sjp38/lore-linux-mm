Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7168A6B464B
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 08:40:36 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z18-v6so1092916qki.22
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 05:40:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j3-v6sor439848qth.103.2018.08.28.05.40.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 05:40:33 -0700 (PDT)
Date: Tue, 28 Aug 2018 08:40:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, oom: OOM victims do not need to select next OOM
 victim unless __GFP_NOFAIL.
Message-ID: <20180828124030.GB12564@cmpxchg.org>
References: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

On Mon, Aug 20, 2018 at 07:37:45PM +0900, Tetsuo Handa wrote:
> Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") changed to select next OOM victim as soon as
> MMF_OOM_SKIP is set. But since OOM victims can try ALLOC_OOM allocation
> and then give up (if !memcg OOM) or can use forced charge and then retry
> (if memcg OOM), OOM victims do not need to select next OOM victim unless
> they are doing __GFP_NOFAIL allocations.

Can you outline the exact sequence here? After a task invokes the OOM
killer, it will retry and do ALLOC_OOM before invoking it again. If
that succeeds, OOM is not invoked another time.

If there is a race condition where the allocating task gets killed
right before it acquires the oom_lock itself, there is another attempt
to allocate under the oom lock to catch parallel kills. It's not using
ALLOC_OOM, but that's intentional because we want to restore the high
watermark, not just make a single allocation from reserves succeed.

If that doesn't succeed, then we are committed to killing something.
Racing with the OOM reaper then is no different than another task
voluntarily exiting or munmap()ing in parallel. I don't know why we
should special case your particular scenario.

Granted, the OOM reaper is not exactly like the others, because it can
be considered to be part of the OOM killer itself. But then we should
wait for it like we wait for any concurrent OOM kill, and not allow
another __alloc_pages_may_oom() while the reaper is still at work;
instead of more hard-to-understand special cases in this code.

> This is a quick mitigation because syzbot is hitting WARN(1) caused by
> this race window [1]. More robust fix (e.g. make it possible to reclaim
> more memory before MMF_OOM_SKIP is set, wait for some more after
> MMF_OOM_SKIP is set) is a future work.

As per the other email, the warning was already replaced.
