Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0C56B0265
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:50:15 -0400 (EDT)
Received: by igxx6 with SMTP id x6so46864475igx.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 04:50:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q31si10468867ioi.93.2015.09.24.04.50.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Sep 2015 04:50:14 -0700 (PDT)
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509192333.AGJ30797.OQOFLFSMJVFOtH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509211628050.27715@chino.kir.corp.google.com>
	<201509221433.ICI00012.VFOQMFHLFJtSOO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509221631040.7794@chino.kir.corp.google.com>
	<CAEPKNTK3DOBApeVDpwJ_B7jkLVp4GQ0ihM1PwAusyc8TWQyB_A@mail.gmail.com>
In-Reply-To: <CAEPKNTK3DOBApeVDpwJ_B7jkLVp4GQ0ihM1PwAusyc8TWQyB_A@mail.gmail.com>
Message-Id: <201509242050.EHE95837.FVFOOtMQHLJOFS@I-love.SAKURA.ne.jp>
Date: Thu, 24 Sep 2015 20:50:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kwalker@redhat.com, rientjes@google.com
Cc: mhocko@kernel.org, cl@linux.com, oleg@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Kyle Walker wrote:
> I agree, in lieu of treating TASK_UNINTERRUPTIBLE tasks as unkillable,
> and omitting them from the oom selection process, continuing the
> carnage is likely to result in more unpredictable results. At this
> time, I believe Oleg's solution of zapping the process memory use
> while it sleeps with the fatal signal enroute is ideal.

I cannot help thinking about the worst case.

(1) If memory zapping code successfully reclaimed some memory from
    the mm struct used by the OOM victim, what guarantees that the
    reclaimed memory is used by OOM victims (and processes which
    are blocking OOM victims)?

    David's "global access to memory reserves" allows a local unprivileged
    user to deplete memory reserves; could allow that user to deplete the
    reclaimed memory as well.

    I think that my "Favor kthread and dying threads over normal threads"
    ( http://lkml.kernel.org/r/1442939668-4421-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp )
    would allow the reclaimed memory to be used by OOM victims and kernel
    threads if the reclaimed memory is added to free list bit by bit
    in a way that watermark remains low enough to prevent normal threads
    from allocating the reclaimed memory.

    But my patch still fails if normal threads are blocking the OOM
    victims or unrelated kernel threads consume the reclaimed memory.

(2) If memory zapping code failed to reclaim enough memory from the mm
    struct needed for the OOM victim, what mechanism can solve the OOM
    stalls?

    Some administrator sets /proc/pid/oom_score_adj to -1000 to most of
    enterprise processes (e.g. java) and as a consequence only trivial
    processes (e.g. grep / sed) are candidates for OOM victims.

    Moreover, a local unprivileged user can easily fool the OOM killer using
    decoy tasks (which consumes little memory and /proc/pid/oom_score_adj is
    set to 999).

(3) If memory zapping code reclaimed no memory due to ->mmap_sem contention,
    what mechanism can solve the OOM stalls?

    While we don't allocate much memory with ->mmap_sem held for writing,
    the task which is holding ->mmap_sem for writing can be chosen as
    one of OOM victims. If such task receives SIGKILL but TIF_MEMDIE is not
    set, it can form OOM-livelock unless all memory allocations with
    ->mmap_sem held for writing are __GFP_FS allocations and that task can
    reach out_of_memory() (i.e. not blocked by unexpected factors such as
    waiting for filesystem's writeback).

After all I think we have to consider what to do if memory zapping code
failed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
