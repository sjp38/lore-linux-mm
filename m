Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 56C196B0006
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 06:54:58 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l126so61912511wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 03:54:58 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id h76si11632482wmd.76.2015.12.18.03.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 03:54:57 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id p187so60346730wmp.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 03:54:56 -0800 (PST)
Date: Fri, 18 Dec 2015 12:54:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151218115454.GE28443@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
 <20151217130223.GE18625@dhcp22.suse.cz>
 <CA+55aFxkzeqtxDY8KyR_FA+WKNkQXEHVA_zO8XhW6rqRr778Zw@mail.gmail.com>
 <20151217120004.b5f849e1613a3a367482b379@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151217120004.b5f849e1613a3a367482b379@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 17-12-15 12:00:04, Andrew Morton wrote:
> On Thu, 17 Dec 2015 11:55:11 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Thu, Dec 17, 2015 at 5:02 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > Ups. You are right. I will go with msleep_interruptible(100).
> > 
> > I don't think that's right.
> > 
> > If a signal happens, that loop is now (again) just busy-looping.
> 
> It's called only by a kernel thread so no signal_pending().

Yes that was the thinking.

> This relationship is a bit unobvious and fragile, but we do it in
> quite a few places.

I guess Linus is right and __set_task_state(current, TASK_IDLE) would be
better and easier to read.
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4b0a5d8b92e1..eed99506b891 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -472,8 +472,10 @@ static void oom_reap_vmas(struct mm_struct *mm)
 	int attempts = 0;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < 10 && !__oom_reap_vmas(mm))
-		msleep_interruptible(100);
+	while (attempts++ < 10 && !__oom_reap_vmas(mm)) {
+		__set_task_state(current, TASK_IDLE);
+		schedule_timeout(HZ/10);
+	}
 
 	/* Drop a reference taken by wake_oom_reaper */
 	mmdrop(mm);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
