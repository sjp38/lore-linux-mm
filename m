Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C45B26B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 06:48:36 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p187so61545631wmp.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 03:48:36 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id i7si25001532wjw.174.2015.12.18.03.48.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 03:48:35 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id l126so60761298wml.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 03:48:35 -0800 (PST)
Date: Fri, 18 Dec 2015 12:48:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151218114832.GD28443@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <20151217161521.57fb536085aca377cb93fe1e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151217161521.57fb536085aca377cb93fe1e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 17-12-15 16:15:21, Andrew Morton wrote:
> On Tue, 15 Dec 2015 19:36:15 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > This patch reduces the probability of such a lockup by introducing a
> > specialized kernel thread (oom_reaper) 
> 
> CONFIG_MMU=n:
> 
> slub.c:(.text+0x4184): undefined reference to `tlb_gather_mmu'
> slub.c:(.text+0x41bc): undefined reference to `unmap_page_range'
> slub.c:(.text+0x41d8): undefined reference to `tlb_finish_mmu'
> 
> I did the below so I can get an mmotm out the door, but hopefully
> there's a cleaner way.

Sorry about that and thanks for your fixup! I am not very familiar with
!MMU world and haven't heard about issues with the OOM deadlocks yet. So
I guess making this MMU only makes some sense. I would just get rid of
ifdefs in oom_kill_process and provide an empty wake_oom_reaper for
!CONFIG_MMU.  The following on top of yours:
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4b0a5d8b92e1..56ff1ff18c0e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -537,6 +537,10 @@ static int __init oom_init(void)
 	return 0;
 }
 module_init(oom_init)
+#else
+static void wake_oom_reaper(struct mm_struct *mm)
+{
+}
 #endif
 
 /**
@@ -648,9 +652,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-#ifdef CONFIG_MMU
 	bool can_oom_reap = true;
-#endif
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -743,7 +745,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (is_global_init(p))
 			continue;
-#ifdef CONFIG_MMU
 		if (unlikely(p->flags & PF_KTHREAD) ||
 		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
 			/*
@@ -754,15 +755,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			can_oom_reap = false;
 			continue;
 		}
-#endif
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
-#ifdef CONFIG_MMU
 	if (can_oom_reap)
 		wake_oom_reaper(mm);
-#endif
 
 	mmdrop(mm);
 	put_task_struct(victim);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
