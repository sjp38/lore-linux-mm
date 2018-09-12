Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EAADF8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 23:06:30 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e62-v6so1488770itb.3
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 20:06:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v23-v6si11829823iob.89.2018.09.11.20.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 20:06:29 -0700 (PDT)
Message-Id: <201809120306.w8C36JbS080965@www262.sakura.ne.jp>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. =?ISO-2022-JP?B?b29tX3JlYXBlciBo?=
 =?ISO-2022-JP?B?YW5kb3Zlcg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 12 Sep 2018 12:06:19 +0900
References: <7e123109-fe7d-65cf-883e-74850fd2cf86@i-love.sakura.ne.jp> <20180910164411.GN10951@dhcp22.suse.cz>
In-Reply-To: <20180910164411.GN10951@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

Michal Hocko wrote:
> On Tue 11-09-18 00:40:23, Tetsuo Handa wrote:
> > >> Also, why MMF_OOM_SKIP will not be set if the OOM reaper handed over?
> > > 
> > > The idea is that the mm is not visible to anybody (except for the oom
> > > reaper) anymore. So MMF_OOM_SKIP shouldn't matter.
> > > 
> > 
> > I think it absolutely matters. The OOM killer waits until MMF_OOM_SKIP is set
> > on a mm which is visible via task_struct->signal->oom_mm .
> 
> Hmm, I have to re-read the exit path once again and see when we unhash
> the task and how many dangerous things we do in the mean time. I might
> have been overly optimistic and you might be right that we indeed have
> to set MMF_OOM_SKIP after all.

What a foolhardy attempt!

Commit d7a94e7e11badf84 ("oom: don't count on mm-less current process") says

    out_of_memory() doesn't trigger the OOM killer if the current task is
    already exiting or it has fatal signals pending, and gives the task
    access to memory reserves instead.  However, doing so is wrong if
    out_of_memory() is called by an allocation (e.g. from exit_task_work())
    after the current task has already released its memory and cleared
    TIF_MEMDIE at exit_mm().  If we again set TIF_MEMDIE to post-exit_mm()
    current task, the OOM killer will be blocked by the task sitting in the
    final schedule() waiting for its parent to reap it.  It will trigger an
    OOM livelock if its parent is unable to reap it due to doing an
    allocation and waiting for the OOM killer to kill it.

and your

+               /*
+                * the exit path is guaranteed to finish without any unbound
+                * blocking at this stage so make it clear to the caller.
+                */

attempt is essentially same with "we keep TIF_MEMDIE of post-exit_mm() task".

That is, we can't expect that the OOM victim can finish without any unbound
blocking. We have no choice but timeout based heuristic if we don't want to
set MMF_OOM_SKIP even with your customized version of free_pgtables().
