Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2592A8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:55:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g15-v6so7119821edm.11
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:55:55 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v50-v6sor14916499edm.17.2018.09.10.05.55.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 05:55:53 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Date: Mon, 10 Sep 2018 14:55:10 +0200
Message-Id: <20180910125513.311-1-mhocko@kernel.org>
In-Reply-To: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

I am sending this as a follow up to yet-another timeout based proposal
by Tetsuo because I was accused that I am pushing for a solution which
I am not working on.

This is a very coarse implementation of the idea I've had before.
Please note that I haven't tested it yet. It is mostly to show the
direction I would wish to go for.

I have already explained why I hate timeout based retry loop and why
I believe a more direct feedback based approach is much better.

The locking protocol between the oom_reaper and the exit path is as
follows.

All parts which cannot race should use the exclusive lock on the exit
path. Once the exit path has passed the moment when no blocking locks
are taken then it clears mm->mmap under the exclusive lock. It is
trivial to use a MMF_$FOO for this purpose if people think this is safer
or better for any other reason.

The oom proper is the only one which sets MMF_OOM_SKIP with these
patches which is IMHO better because it is much easier understand the
interaction this way.

Last but not least, this is a core of the implementation. We might
want to tune the number of oom_reaper retries or to think about a more
effective tear down when there are multiple oom victims in the queue. I
would simply care about those later once we see a clear evidence that
this is needed. Ideally with a workload description and some numbers.

If this looks like a feasible idea I can spend on this more time and
turn it into something meargable.
