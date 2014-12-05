Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id EF3D06B0074
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 11:41:55 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so1997586wiv.2
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 08:41:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wo10si50305100wjc.32.2014.12.05.08.41.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 08:41:54 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 2/5] OOM: thaw the OOM victim if it is frozen
Date: Fri,  5 Dec 2014 17:41:44 +0100
Message-Id: <1417797707-31699-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1417797707-31699-1-git-send-email-mhocko@suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

oom_kill_process only sets TIF_MEMDIE flag and sends a signal to the
victim. This is basically noop when the task is frozen though because
the task sleeps in uninterruptible sleep. The victim is eventually
thawed later when oom_scan_process_thread meets the task again in a
later OOM invocation so the OOM killer doesn't live lock. But this is
less than optimal. Let's add the frozen check and thaw the task right
before we send SIGKILL to the victim.

The check and thawing in oom_scan_process_thread has to stay because the
task might got access to memory reserves even without an explicit
SIGKILL from oom_kill_process (e.g. it already has fatal signal pending
or it is exiting already).

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c75b37d59a32..8874058d62db 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -545,6 +545,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	rcu_read_unlock();
 
 	mark_tsk_oom_victim(victim);
+	if (frozen(victim))
+		__thaw_task(victim);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);
 }
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
