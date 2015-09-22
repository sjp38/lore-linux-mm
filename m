Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2DF6B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:43:38 -0400 (EDT)
Received: by oiev17 with SMTP id v17so69587094oie.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 20:43:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a80si13796693oih.138.2015.09.21.20.43.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 20:43:37 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm,oom: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442714685-14002-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20150921145958.434bdb12c91e5300c27576f5@linux-foundation.org>
	<201509221239.EGD05714.JFSOOOtVLFHFQM@I-love.SAKURA.ne.jp>
In-Reply-To: <201509221239.EGD05714.JFSOOOtVLFHFQM@I-love.SAKURA.ne.jp>
Message-Id: <201509221243.GBC34820.OVJFMOLSOFHFtQ@I-love.SAKURA.ne.jp>
Date: Tue, 22 Sep 2015 12:43:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Re-sending [PATCH 2/2] due to context changes in [PATCH 1/2].
------------------------------------------------------------
>From 33cdde028dbd65543e4946ee9ec1a08b712c708c Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 22 Sep 2015 12:16:02 +0900
Subject: [PATCH 2/2] mm,oom: Fix potentially killing unrelated process.

At the for_each_process() loop in oom_kill_process(), we are comparing
address of OOM victim's mm without holding a reference to that mm.  If
there are a lot of processes to compare or a lot of "Kill process %d (%s)
sharing same memory" messages to print, for_each_process() loop could take
very long time.

It is possible that meanwhile the OOM victim exits and releases its mm,
and then mm is allocated with the same address and assigned to some
unrelated process.  When we hit such race, the unrelated process will be
killed by error.  To make sure that the OOM victim's mm does not go away
until for_each_process() loop finishes, get a reference on the OOM
victim's mm before calling task_unlock(victim).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 97c376c..0b70965 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -561,8 +561,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		victim = p;
 	}
 
-	/* mm cannot safely be dereferenced after task_unlock(victim) */
+	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
+	atomic_inc(&mm->mm_users);
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
@@ -600,6 +601,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		}
 	rcu_read_unlock();
 
+	mmput(mm);
 	put_task_struct(victim);
 }
 #undef K
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
