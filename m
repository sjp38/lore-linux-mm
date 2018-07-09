Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 079A86B0010
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 03:47:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v26-v6so521105eds.9
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 00:47:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7-v6sor6611704edq.24.2018.07.09.00.47.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 00:47:11 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom: remove sleep from under oom_lock
Date: Mon,  9 Jul 2018 09:47:06 +0200
Message-Id: <20180709074706.30635-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has pointed out that since 27ae357fa82b ("mm, oom: fix concurrent
munlock and oom reaper unmap, v3") we have a strong synchronization
between the oom_killer and victim's exiting because both have to take
the oom_lock. Therefore the original heuristic to sleep for a short time
in out_of_memory doesn't serve the original purpose.

Moreover Tetsuo has noticed that the short sleep can be more harmful
than actually useful. Hammering the system with many processes can lead
to a starvation when the task holding the oom_lock can block for a
long time (minutes) and block any further progress because the
oom_reaper depends on the oom_lock as well.

Drop the short sleep from out_of_memory when we hold the lock. Keep the
sleep when the trylock fails to throttle the concurrent OOM paths a bit.
This should be solved in a more reasonable way (e.g. sleep proportional
to the time spent in the active reclaiming etc.) but this is much more
complex thing to achieve. This is a quick fixup to remove a stale code.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb88cf58..ed9d473c571e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1077,15 +1077,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL) {
+	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return !!oc->chosen;
 }
 
-- 
2.18.0
