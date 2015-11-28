Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDF26B0038
	for <linux-mm@kvack.org>; Sat, 28 Nov 2015 11:10:30 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so100853179obd.3
        for <linux-mm@kvack.org>; Sat, 28 Nov 2015 08:10:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id vw13si565710oeb.82.2015.11.28.08.10.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 Nov 2015 08:10:29 -0800 (PST)
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
	<1448640772-30147-1-git-send-email-mhocko@kernel.org>
	<201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
In-Reply-To: <201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
Message-Id: <201511290110.FJB87096.OHJLVQOSFFtMFO@I-love.SAKURA.ne.jp>
Date: Sun, 29 Nov 2015 01:10:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Tetsuo Handa wrote:
> > Users of mmap_sem which need it for write should be carefully reviewed
> > to use _killable waiting as much as possible and reduce allocations
> > requests done with the lock held to absolute minimum to reduce the risk
> > even further.
> 
> It will be nice if we can have down_write_killable()/down_read_killable().

It will be nice if we can also have __GFP_KILLABLE. Although currently it can't
be perfect because reclaim functions called from __alloc_pages_slowpath() use
unkillable waits, starting from just bail out as with __GFP_NORETRY when
fatal_signal_pending(current) is true will be helpful.

So far I'm hitting no problem with testers except the one using mmap()/munmap().

I think that cmpxchg() was not needed.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c2ab7f9..1a65739 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -483,8 +483,6 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct mm_struct *mm)
 {
-	struct mm_struct *old_mm;
-
 	if (!oom_reaper_th)
 		return;
 
@@ -492,14 +490,15 @@ static void wake_oom_reaper(struct mm_struct *mm)
 	 * Make sure that only a single mm is ever queued for the reaper
 	 * because multiple are not necessary and the operation might be
 	 * disruptive so better reduce it to the bare minimum.
+	 * Caller is serialized by oom_lock mutex.
 	 */
-	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
-	if (!old_mm) {
+	if (!mm_to_reap) {
 		/*
 		 * Pin the given mm. Use mm_count instead of mm_users because
 		 * we do not want to delay the address space tear down.
 		 */
 		atomic_inc(&mm->mm_count);
+		mm_to_reap = mm;
 		wake_up(&oom_reaper_wait);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
