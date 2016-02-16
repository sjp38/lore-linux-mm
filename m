Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7916B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:53:30 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id a4so106676375wme.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:53:30 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id g133si34258671wma.66.2016.02.16.07.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 07:53:28 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id g62so159005182wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:53:28 -0800 (PST)
Date: Tue, 16 Feb 2016 16:53:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/5] mm, oom_reaper: implement OOM victims queuing
Message-ID: <20160216155322.GC23437@dhcp22.suse.cz>
References: <20160204145357.GE14425@dhcp22.suse.cz>
 <201602061454.GDG43774.LSHtOOMFOFVJQF@I-love.SAKURA.ne.jp>
 <20160206083757.GB25220@dhcp22.suse.cz>
 <201602070033.GFC13307.MOJQtFHOFOVLFS@I-love.SAKURA.ne.jp>
 <20160215201535.GB9223@dhcp22.suse.cz>
 <201602162011.ECG52697.VOLJFtOQHFMSFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602162011.ECG52697.VOLJFtOQHFMSFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 16-02-16 20:11:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Unless we are under global OOM then this doesn't matter much because the
> > allocation request should succeed at some point in time and memcg
> > charges are bypassed for tasks with pending fatal signals. So we can
> > make a forward progress.
> 
> Hmm, then I wonder how memcg OOM livelock occurs. Anyway, OK for now.
> 
> But current OOM reaper forgot a protection for list item "double add" bug.
> Precisely speaking, this is not a OOM reaper's bug.
[...]
> For oom_kill_allocating_task = 1 case (despite the name, it still tries to kill
> children first),

Yes this is a long term behavior and I cannot say I would be happy about
that because it clearly breaks the defined semantic.

> the OOM killer does not wait for OOM victim to clear TIF_MEMDIE
> because select_bad_process() is not called. Therefore, if an OOM victim fails to
> terminate because the OOM reaper failed to reap enough memory, the kernel is
> flooded with OOM killer messages trying to kill that stuck victim (with OOM
> reaper lockup due to list corruption).

Hmmm, I didn't consider this possibility. For now I would simply disable
oom_reaper for sysctl_oom_kill_allocating_task. oom_kill_allocating_task
needs some more changes IMO. a) we shouldn't kill children as a
heuristic b) we should go and panic if the current task is TIF_MEMDIE
already because that means that we cannot do anything about OOM. But I
think this should be handled separately.

Whould be the following acceptable for now?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7e9953a64489..357cee067950 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -678,7 +678,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
+	bool can_oom_reap;
+	
+	/*
+	 * oom_kill_allocating_task doesn't follow normal OOM exclusion
+	 * and so the same task might enter oom_kill_process which oom_reaper
+	 * cannot handle currently.
+	 */
+	can_oom_reap = !sysctl_oom_kill_allocating_task;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
