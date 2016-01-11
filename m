Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id D7329828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 09:49:31 -0500 (EST)
Received: by mail-lf0-f41.google.com with SMTP id h129so19305607lfh.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 06:49:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u7si11378693lbw.3.2016.01.11.06.49.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 06:49:30 -0800 (PST)
Date: Mon, 11 Jan 2016 15:49:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: What is oom_killer_disable() for?
Message-ID: <20160111144924.GF27317@dhcp22.suse.cz>
References: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201601100202.DHE57897.OVLJOMHFOtFFSQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601100202.DHE57897.OVLJOMHFOtFFSQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>

[CCing Rafael]

On Sun 10-01-16 02:02:32, Tetsuo Handa wrote:
> I wonder what oom_killer_disable() wants to do.
> 
> (1) We need to save a consistent memory snapshot image when suspending,
>     is this correct?

Yes

> (2) To obtain a consistent memory snapshot image, we need to freeze all
>     but current thread in order to avoid modifying on-memory data while
>     saving to disk, is this correct?

Yes, the system has to enter a quiescent state where no further user
space activity can interfere with the PM suspend.
 
> (3) Then, what is the purpose of disabling the OOM killer? Why do we
>     need to disable the OOM killer? Is it because the OOM killer thaws
>     already frozen threads?

Yes. We have to be able to thaw frozen tasks if they are chosen as an
OOM victim otherwise you could hide processes into the fridge and lockup
the system. oom_killer_disable is then needed for pm freezer because the
OOM killer might be invoked even after all the userspace is considered
in the quiescent state. We cannot wake any task anymore during the later
pm freezer processing AFAIU. oom_killer_disable then acts as a hard
barrier after which we know that even OOM killer won't wake any user
space tasks.

> (4) Then, why do we wait for TIF_MEMDIE threads to terminate? We can
>     freeze thawed threads again without waiting for TIF_MEMDIE threads,
>     can't we? Is it because we need free memory for saving to disk?

It is preferable to finish the OOM killer handling before entering the
quiescent state. As only TIF_MEMDIE tasks are thawed we do not wait for
all killed task. If this alone doesn't help to resolve the OOM condition
then we will likely fail later in the process when a memory allocation
is required and ENOMEM terminate the whole process.

> (5) Then, why waiting for only TIF_MEMDIE threads is sufficient? There
>     is no TIF_MEMDIE threads does not guarantee that we have free memory,
>     for there might be !TIF_MEMDIE threads which are still sharing memory
>     used by TIF_MEMDIE threads.

see above. We are trying to be as good as possible but not perfect. The
only hard requirement is that an unexpected OOM victim won't interfere
with a code which doesn't expect userspace to run.

> (6) Since oom_killer_disable() already disabled the OOM killer,
>     !TIF_MEMDIE threads which are sharing memory used by TIF_MEMDIE
>     threads cannot get TIF_MEMDIE by calling out_of_memory().

They shouldn't be running at all because the whole userspace has been
frozen. Only TIF_MEMDIE tasks are running at the time we are disabling
the oom killer and we are waiting for them. Please go and read through
c32b3cbe0d06 ("oom, PM: make OOM detection in the freezer path raceless")

>     Also, since out_of_memory() returns false after oom_killer_disable()
>     disabled the OOM killer, allocation requests by these !TIF_MEMDIE
>     threads start failing. Why do we need to give up with accepting
>     undesirable errors (e.g. failure of syscalls which modify an object's
>     attribute)?

Userspace shouldn't see unexpected errors due to OOM being disabled
because it is not runable at that time.

>     Why don't we abort suspend operation by marking that
>     re-enabling of the OOM killer might caused modification of on-memory
>     data (like patch shown below)? We can make final decision after memory
>     image snapshot is saved to disk, can't we?

I am not sure I am following you here but how do you detect that the
userspace has corrupted your image or accesses an already (half)
suspended device or something similar?

I am not saying disabling the OOM killer is the greatest solution. It
took quite some time to make it work reliably. But I fail to see how can
we guarantee no userspace interference when an OOM victim might be woken
by any allocation deep inside the PM code path. I believe we simply
need a point of no userspace activity to proceed with further PM steps
reasonably.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
