Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEA2440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 01:45:08 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p63so52862750wmp.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 22:45:08 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id br5si19541944wjb.69.2016.02.05.22.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 22:45:07 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id 128so6187417wmz.3
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 22:45:07 -0800 (PST)
Date: Sat, 6 Feb 2016 07:45:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160206064505.GB20537@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-4-git-send-email-mhocko@kernel.org>
 <201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
 <20160204144319.GD14425@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160204144319.GD14425@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 04-02-16 15:43:19, Michal Hocko wrote:
> On Thu 04-02-16 23:22:18, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > When oom_reaper manages to unmap all the eligible vmas there shouldn't
> > > be much of the freable memory held by the oom victim left anymore so it
> > > makes sense to clear the TIF_MEMDIE flag for the victim and allow the
> > > OOM killer to select another task.
> > 
> > Just a confirmation. Is it safe to clear TIF_MEMDIE without reaching do_exit()
> > with regard to freezing_slow_path()? Since clearing TIF_MEMDIE from the OOM
> > reaper confuses
> > 
> >     wait_event(oom_victims_wait, !atomic_read(&oom_victims));
> > 
> > in oom_killer_disable(), I'm worrying that the freezing operation continues
> > before the OOM victim which escaped the __refrigerator() actually releases
> > memory. Does this cause consistency problem?
> 
> This is a good question! At first sight it seems this is not safe and we
> might need to make the oom_reaper freezable so that it doesn't wake up
> during suspend and interfere. Let me think about that.

OK, I was thinking about it some more and it seems you are right here.
oom_reaper as a kernel thread is not freezable automatically and so it
might interfere after all the processes/kernel threads are considered
frozen. Then it really might shut down TIF_MEMDIE too early and wake out
oom_killer_disable. wait_event_freezable is not sufficient because the
oom_reaper might running while the PM freezer is freezing tasks and it
will miss it because it doesn't see it.

So I think we might need this. I am heading to vacation today and will
be offline for the next week so I will prepare the full patch with the
proper changelog after I get back:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ca61e6cfae52..7e9953a64489 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -521,6 +521,8 @@ static void oom_reap_task(struct task_struct *tsk)
 
 static int oom_reaper(void *unused)
 {
+	set_freezable();
+
 	while (true) {
 		struct task_struct *tsk = NULL;
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
