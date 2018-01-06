Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84CBD280282
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 06:01:49 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 79so6891039ion.20
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 03:01:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 74si5688646ioo.56.2018.01.06.03.01.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Jan 2018 03:01:47 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Set ->signal->oom_mm to all thread groupssharingvictim's memory.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513682774-4416-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171219114012.GK2787@dhcp22.suse.cz>
	<201801061637.CCF78186.OOJFFtMVOLSHQF@I-love.SAKURA.ne.jp>
	<20180106093458.GA16576@dhcp22.suse.cz>
In-Reply-To: <20180106093458.GA16576@dhcp22.suse.cz>
Message-Id: <201801062001.HGH56212.VOFFLMOOHSFtQJ@I-love.SAKURA.ne.jp>
Date: Sat, 6 Jan 2018 20:01:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Sat 06-01-18 16:37:17, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 19-12-17 20:26:14, Tetsuo Handa wrote:
> > > > When the OOM reaper set MMF_OOM_SKIP on the victim's mm before threads
> > > > sharing that mm get ->signal->oom_mm, the comment "That thread will now
> > > > get access to memory reserves since it has a pending fatal signal." no
> > > > longer stands. Also, since we introduced ALLOC_OOM watermark, the comment
> > > > "They don't get access to memory reserves, though, to avoid depletion of
> > > > all memory." no longer stands.
> > > > 
> > > > This patch treats all thread groups sharing the victim's mm evenly,
> > > > and updates the outdated comment.
> > > 
> > > Nack with a real life example where this matters.
> > 
> > You did not respond to
> > http://lkml.kernel.org/r/201712232341.FGC64072.VFLOOJOtFSFMHQ@I-love.SAKURA.ne.jp ,
> 
> Yes I haven't because there is simply no point continuing this
> discussion. You are simply immune to any arguments.
> 
> > and I observed needless OOM-killing. Therefore, I push this patch again.
> 
> Yes, the life is tough and oom heuristic might indeed kill more tasks
> for some workloads. But as long as those needless oom killing happens
> for artificial workloads I am not all that much interested.  Show me
> some workload that is actually real and we can make the current code
> more complicated. Without that my position remains.

That is a catch-22 requirement. A workload that is actually real would be
a case which failed to take mmap_sem for read. But we won't be there when
that happened in a real system which we cannot involve.

Anyway, short version is shown below.

>From f053ed1430e94b5c371a26b8c3903d27bcdcb0a0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 6 Jan 2018 19:41:20 +0900
Subject: [PATCH] mm, oom: task_will_free_mem should skip oom_victim tasks

Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks") should check ->signal->oom_mm rather than
MMF_OOM_SKIP, for clone(CLONE_VM && !CLONE_SIGHAND) case causes premature
next OOM victim selection when the intention of that commit was to avoid
OOM lockup due to infinite retries.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8219001..9526ba8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -804,11 +804,8 @@ static bool task_will_free_mem(struct task_struct *task)
 	if (!__task_will_free_mem(task))
 		return false;
 
-	/*
-	 * This task has already been drained by the oom reaper so there are
-	 * only small chances it will free some more
-	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+	/* Skip tasks which tried ALLOC_OOM but still cannot make progress. */
+	if (tsk_is_oom_victim(task))
 		return false;
 
 	if (atomic_read(&mm->mm_users) <= 1)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
