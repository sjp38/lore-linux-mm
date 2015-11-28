Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA4A6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 23:39:45 -0500 (EST)
Received: by padhx2 with SMTP id hx2so129916241pad.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 20:39:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g73si13038324pfd.168.2015.11.27.20.39.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Nov 2015 20:39:44 -0800 (PST)
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
	<1448640772-30147-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1448640772-30147-1-git-send-email-mhocko@kernel.org>
Message-Id: <201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
Date: Sat, 28 Nov 2015 13:39:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> for write while write but the probability is reduced considerably wrt.

Is this "while write" garbage?

> Users of mmap_sem which need it for write should be carefully reviewed
> to use _killable waiting as much as possible and reduce allocations
> requests done with the lock held to absolute minimum to reduce the risk
> even further.

It will be nice if we can have down_write_killable()/down_read_killable().

> The API between oom killer and oom reaper is quite trivial. wake_oom_reaper
> updates mm_to_reap with cmpxchg to guarantee only NUll->mm transition

NULL->mm

> and oom_reaper clear this atomically once it is done with the work.

Can't oom_reaper() become as compact as below?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3f22efc..c2ab7f9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -472,21 +472,10 @@ static void oom_reap_vmas(struct mm_struct *mm)
 
 static int oom_reaper(void *unused)
 {
-	DEFINE_WAIT(wait);
-
 	while (true) {
-		struct mm_struct *mm;
-
-		prepare_to_wait(&oom_reaper_wait, &wait, TASK_UNINTERRUPTIBLE);
-		mm = READ_ONCE(mm_to_reap);
-		if (!mm) {
-			freezable_schedule();
-			finish_wait(&oom_reaper_wait, &wait);
-		} else {
-			finish_wait(&oom_reaper_wait, &wait);
-			oom_reap_vmas(mm);
-			WRITE_ONCE(mm_to_reap, NULL);
-		}
+		wait_event_freezable(oom_reaper_wait, mm_to_reap);
+		oom_reap_vmas(mm_to_reap);
+		mm_to_reap = NULL;
 	}
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
