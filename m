Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 995AD6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 08:22:32 -0500 (EST)
Received: by wmuu63 with SMTP id u63so172619692wmu.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 05:22:32 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id w126si35883400wmb.120.2015.12.01.05.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 05:22:31 -0800 (PST)
Received: by wmuu63 with SMTP id u63so172619153wmu.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 05:22:31 -0800 (PST)
Date: Tue, 1 Dec 2015 14:22:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
Message-ID: <20151201132230.GF4567@dhcp22.suse.cz>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <1448640772-30147-1-git-send-email-mhocko@kernel.org>
 <201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

On Sat 28-11-15 13:39:11, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > for write while write but the probability is reduced considerably wrt.
> 
> Is this "while write" garbage?

Fixed

> > Users of mmap_sem which need it for write should be carefully reviewed
> > to use _killable waiting as much as possible and reduce allocations
> > requests done with the lock held to absolute minimum to reduce the risk
> > even further.
> 
> It will be nice if we can have down_write_killable()/down_read_killable().

Yes that is an idea.

> > The API between oom killer and oom reaper is quite trivial. wake_oom_reaper
> > updates mm_to_reap with cmpxchg to guarantee only NUll->mm transition
> 
> NULL->mm

fixed

> > and oom_reaper clear this atomically once it is done with the work.
> 
> Can't oom_reaper() become as compact as below?

Good idea! I think we still need {READ,WRITE}_ONCE to prevent from any
potential mis optimizations, though.

Here is what I did:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 333953bf4968..b50ce41194b3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -477,21 +477,11 @@ static void oom_reap_vmas(struct mm_struct *mm)
 
 static int oom_reaper(void *unused)
 {
-	DEFINE_WAIT(wait);
-
 	while (true) {
 		struct mm_struct *mm;
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
+		wait_event_freezable(oom_reaper_wait, (mm = READ_ONCE(mm_to_reap)));
+		oom_reap_vmas(mm);
+		WRITE_ONCE(mm_to_reap, NULL);
 	}
 
 	return 0;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
