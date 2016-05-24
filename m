Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6959A6B007E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 09:50:46 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o70so9705962lfg.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 06:50:46 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id c5si4349787wjm.164.2016.05.24.06.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 06:50:44 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id n129so131431163wmn.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 06:50:44 -0700 (PDT)
Date: Tue, 24 May 2016 15:50:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: oom_kill_process: do not abort if the victim is
 exiting
Message-ID: <20160524135042.GK8259@dhcp22.suse.cz>
References: <1464092642-10363-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464092642-10363-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 24-05-16 15:24:02, Vladimir Davydov wrote:
> After selecting an oom victim, we first check if it's already exiting
> and if it is, we don't bother killing tasks sharing its mm. We do try to
> reap its mm though, but we abort if any of the processes sharing it is
> still alive. This might result in oom deadlock if an exiting task got
> stuck trying to acquire a lock held by another task sharing the same mm
> which needs memory to continue: if oom killer happens to keep selecting
> the stuck task, we won't even try to kill other processes or reap the
> mm.

I plan to extend task_will_free_mem to catch this case because we will
need it for other changes.

> The check in question was first introduced by commit 50ec3bbffbe8 ("oom:
> handle current exiting"). Initially it worked in conjunction with
> another check in select_bad_process() which forced selecting exiting
> task. The goal of that patch was selecting the current task on oom if it
> was exiting. Now, we select the current task if it's exiting or was
> killed anyway. And the check in select_bad_process() was removed by
> commit 6a618957ad17 ("mm: oom_kill: don't ignore oom score on exiting
> tasks"), because it prevented oom reaper. This just makes the remaining
> hunk in oom_kill_process pointless.

It is not really pointless. The original intention was to not spam the
log and alarm the administrator when in fact the memory hog is exiting
already and will free the memory. Those races is quite unlikely but not
impossible. The original check was much more optimistic as you said
above we have even removed one part of this heuristic. We can still end
up selecting an exiting task which is stuck and we could invoke the oom
reaper for it without excessive oom report. I agree that the current
check is still little bit optimistic but processes sharing the mm
(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND) are really rare so I
wouldn't bother with them with a high priority.

That being said I would prefer to keep the check for now. After the
merge windlow closes I will send other oom enhancements which I have
half baked locally and that should make task_will_free_mem much more
reliable and the check would serve as a last resort to reduce oom noise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
