Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1E06B025F
	for <linux-mm@kvack.org>; Tue, 24 May 2016 13:07:56 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id fs8so19322216obb.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 10:07:56 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0105.outbound.protection.outlook.com. [157.55.234.105])
        by mx.google.com with ESMTPS id h203si2606866oib.228.2016.05.24.10.07.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 10:07:55 -0700 (PDT)
Date: Tue, 24 May 2016 20:07:46 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: oom_kill_process: do not abort if the victim is
 exiting
Message-ID: <20160524170746.GC11150@esperanza>
References: <1464092642-10363-1-git-send-email-vdavydov@virtuozzo.com>
 <20160524135042.GK8259@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160524135042.GK8259@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 24, 2016 at 03:50:42PM +0200, Michal Hocko wrote:
> On Tue 24-05-16 15:24:02, Vladimir Davydov wrote:
> > After selecting an oom victim, we first check if it's already exiting
> > and if it is, we don't bother killing tasks sharing its mm. We do try to
> > reap its mm though, but we abort if any of the processes sharing it is
> > still alive. This might result in oom deadlock if an exiting task got
> > stuck trying to acquire a lock held by another task sharing the same mm
> > which needs memory to continue: if oom killer happens to keep selecting
> > the stuck task, we won't even try to kill other processes or reap the
> > mm.
> 
> I plan to extend task_will_free_mem to catch this case because we will
> need it for other changes.
> 
> > The check in question was first introduced by commit 50ec3bbffbe8 ("oom:
> > handle current exiting"). Initially it worked in conjunction with
> > another check in select_bad_process() which forced selecting exiting
> > task. The goal of that patch was selecting the current task on oom if it
> > was exiting. Now, we select the current task if it's exiting or was
> > killed anyway. And the check in select_bad_process() was removed by
> > commit 6a618957ad17 ("mm: oom_kill: don't ignore oom score on exiting
> > tasks"), because it prevented oom reaper. This just makes the remaining
> > hunk in oom_kill_process pointless.
> 
> It is not really pointless. The original intention was to not spam the
> log and alarm the administrator when in fact the memory hog is exiting
> already and will free the memory.

IMO the fact that a process, even an exiting one enters oom, is
abnormal, indicates that the system is misconfigured, and hence should
be reported to the admin.

> Those races is quite unlikely but not impossible.

If this case is unlikely, how can it spam the log?

> The original check was much more optimistic as you said
> above we have even removed one part of this heuristic. We can still end
> up selecting an exiting task which is stuck and we could invoke the oom
> reaper for it without excessive oom report. I agree that the current
> check is still little bit optimistic but processes sharing the mm
> (CLONE_VM without CLONE_THREAD/CLONE_SIGHAND) are really rare so I
> wouldn't bother with them with a high priority.
> 
> That being said I would prefer to keep the check for now. After the
> merge windlow closes I will send other oom enhancements which I have
> half baked locally and that should make task_will_free_mem much more
> reliable and the check would serve as a last resort to reduce oom noise.

I don't agree that a message about oom killing an exiting process is
noise, because that shouldn't happen on a properly configured system.
To me this racy check looks more like noise in the kernel code. By the
time we enter oom we should have scanned lru several times to find no
reclaimable pages. The system must be really sluggish. What's the point
in deceiving the admin by suppressing the warning?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
