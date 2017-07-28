Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4526B054B
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:29:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x43so38685849wrb.9
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:29:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f40si18017140wra.464.2017.07.28.06.29.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 06:29:54 -0700 (PDT)
Date: Fri, 28 Jul 2017 15:29:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible race condition in oom-killer
Message-ID: <20170728132952.GQ2274@dhcp22.suse.cz>
References: <e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com>
 <20170728123235.GN2274@dhcp22.suse.cz>
 <46e1e3ee-af9a-4e67-8b4b-5cf21478ad21@I-love.SAKURA.ne.jp>
 <20170728130723.GP2274@dhcp22.suse.cz>
 <201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 28-07-17 22:15:01, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > 4578 is consuming memory as mlocked pages. But the OOM reaper cannot reclaim
> > > mlocked pages (i.e. can_madv_dontneed_vma() returns false due to VM_LOCKED), can it?
> > 
> > You are absolutely right. I am pretty sure I've checked mlocked counter
> > as the first thing but that must be from one of the earlier oom reports.
> > My fault I haven't checked it in the critical one
> > 
> > [  365.267347] oom_reaper: reaped process 4578 (oom02), now anon-rss:131559616kB, file-rss:0kB, shmem-rss:0kB
> > [  365.282658] oom_reaper: reaped process 4583 (oom02), now anon-rss:131561664kB, file-rss:0kB, shmem-rss:0kB
> > 
> > and the above screemed about the fact I was just completely blind.
> > 
> > mlock pages handling is on my todo list for quite some time already but
> > I didn't get around it to implement that. mlock code is very tricky.
> 
> task_will_free_mem(current) in out_of_memory() returning false due to
> MMF_OOM_SKIP already set allowed each thread sharing that mm to select a new
> OOM victim. If task_will_free_mem(current) in out_of_memory() did not return
> false, threads sharing MMF_OOM_SKIP mm would not have selected new victims
> to the level where all OOM killable processes are killed and calls panic().

I am not sure I understand. Do you mean this?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f030c1c..671e4a4107d0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -779,13 +779,6 @@ static bool task_will_free_mem(struct task_struct *task)
 	if (!__task_will_free_mem(task))
 		return false;
 
-	/*
-	 * This task has already been drained by the oom reaper so there are
-	 * only small chances it will free some more
-	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
-		return false;
-
 	if (atomic_read(&mm->mm_users) <= 1)
 		return true;
 
If yes I would have to think about this some more because that might
have weird side effects (e.g. oom_victims counting after threads passed
exit_oom_victim).

Anyway the proper fix for this is to allow reaping mlocked pages. Is
something other than the LTP test affected to give this more priority?
Do we have other usecases where something mlocks the whole memory?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
