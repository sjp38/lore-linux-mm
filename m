Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF1C4402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 08:02:27 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l126so20576071wml.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 05:02:27 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id d13si3822942wma.91.2015.12.17.05.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 05:02:26 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id l126so20359121wml.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 05:02:26 -0800 (PST)
Date: Thu, 17 Dec 2015 14:02:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151217130223.GE18625@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 16-12-15 16:50:35, Andrew Morton wrote:
> On Tue, 15 Dec 2015 19:36:15 +0100 Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > +static void oom_reap_vmas(struct mm_struct *mm)
> > +{
> > +	int attempts = 0;
> > +
> > +	while (attempts++ < 10 && !__oom_reap_vmas(mm))
> > +		schedule_timeout(HZ/10);
> 
> schedule_timeout() in state TASK_RUNNING doesn't do anything.  Use
> msleep() or msleep_interruptible().  I can't decide which is more
> appropriate - it only affects the load average display.

Ups. You are right. I will go with msleep_interruptible(100).
 
> Which prompts the obvious question: as the no-operativeness of this
> call wasn't noticed in testing, why do we have it there...

Well, the idea was that an interfering mmap_sem operation which holds
it for write might block us for a short time period - e.g. when not
depending on an allocation or accessing the memory reserves helps
to progress the allocation. If the holder of the semaphore is stuck
then the retry is pointless. On the other hand the retry shouldn't be
harmful. All in all this is just a heuristic and we do not depend on
it. I guess we can drop it and nobody would actually notice. Let me know
if you prefer that and I will respin the patch.


> I guess it means that the __oom_reap_vmas() success rate is nice anud
> high ;)

I had a debugging trace_printks around this and there were no reties
during my testing so I was probably lucky to not trigger the mmap_sem
contention.
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 48025a21f8c4..f53f87cfd899 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -469,7 +469,7 @@ static void oom_reap_vmas(struct mm_struct *mm)
 	int attempts = 0;
 
 	while (attempts++ < 10 && !__oom_reap_vmas(mm))
-		schedule_timeout(HZ/10);
+		msleep_interruptible(100);
 
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
