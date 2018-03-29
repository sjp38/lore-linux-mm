Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD626B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 11:52:26 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id g36-v6so3514461ote.14
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 08:52:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c14-v6si1697357oic.298.2018.03.29.08.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 08:52:24 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Do not unfreeze OOM victim thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522334218-4268-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180329145055.GH31039@dhcp22.suse.cz>
In-Reply-To: <20180329145055.GH31039@dhcp22.suse.cz>
Message-Id: <201803300052.AHJ43293.HLVOtOFSQOFFJM@I-love.SAKURA.ne.jp>
Date: Fri, 30 Mar 2018 00:52:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-pm@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, pavel@ucw.cz, rjw@rjwysocki.net

Michal Hocko wrote:
> On Thu 29-03-18 23:36:58, Tetsuo Handa wrote:
> > Currently, mark_oom_victim() calls __thaw_task() on the OOM victim
> > threads and freezing_slow_path() unfreezes the OOM victim thread.
> > But I think this exceptional behavior makes little sense nowadays.
> 
> Well, I would like to see this happen because it would allow more
> changes on top. E.g. get rid of TIF_MEMDIE finally.

I'm planning to change mark_oom_victim(tsk) to set TIF_MEMDIE only if
tsk == current. That is, "do not set TIF_MEMDIE on remote thread", for
setting TIF_MEMDIE on a thread which might not be doing memory allocation
is not helpful. Setting TIF_MEMDIE on current thread via
task_will_free_mem(current) in out_of_memory() path is always helpful
because current thread is exactly doing memory allocation.

>                                                     But I am not really
> sure we are there yet. OOM reaper is useful tool but it still cannot
> help in some cases (shared memory, a lot of metadata allocated on behalf
> of the process etc...).

I consider the OOM reaper as a useful tool for give up waiting for the OOM
victims after 1 second. Reclaiming memory is optional.

>                         Considering that the freezing can be an
> unprivileged operation (think cgroup freezer) then I am worried that
> one container can cause the global oom killer and hide oom victims to
> the fridge and spill over to other containers.

The OOM reaper will give up after 1 second. What is wrong with keeping
TIF_MEMDIE threads frozen? How does that differ from TIF_MEMDIE threads
being stuck at unkillable waits (e.g. i_mmap_lock_write()).

My understanding is that frozen threads are not holding locks. In this
aspect, frozen TIF_MEMDIE threads are less painful than TIF_MEMDIE threads
being stuck at unkillable waits.

>                                                Maybe I am overly
> paranoid and this scenario is not even all that interesting but I would
> like to hear a better justification which explains all these cases
> rather than "we have oom reaper so we are good to go" rationale.

I'm trying to simplify situations where oom_killer_disable() is called.
You are worrying about situations where oom_killer_disable() is not
called, aren't you?
