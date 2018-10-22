Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1C366B0007
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:13:43 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w12-v6so17638894plp.9
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 00:13:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e2-v6sor20005698pfb.55.2018.10.22.00.13.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 00:13:42 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/2] mm, oom: marks all killed tasks as oom victims
Date: Mon, 22 Oct 2018 09:13:22 +0200
Message-Id: <20181022071323.9550-2-mhocko@kernel.org>
In-Reply-To: <20181022071323.9550-1-mhocko@kernel.org>
References: <20181022071323.9550-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Historically we have called mark_oom_victim only to the main task
selected as the oom victim because oom victims have access to memory
reserves and granting the access to all killed tasks could deplete
memory reserves very quickly and cause even larger problems.

Since only a partial access to memory reserves is allowed there is no
longer this risk and so all tasks killed along with the oom victim
can be considered as well.

The primary motivation for that is that process groups which do not
shared signals would behave more like standard thread groups wrt oom
handling (aka tsk_is_oom_victim will work the same way for them).

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa5360616..188ae490cf3e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -898,6 +898,7 @@ static void __oom_kill_process(struct task_struct *victim)
 		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, PIDTYPE_TGID);
+		mark_oom_victim(p);
 	}
 	rcu_read_unlock();
 
-- 
2.19.1
