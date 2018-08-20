Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE4436B193E
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 09:15:42 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u11-v6so14040510oif.22
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 06:15:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t62-v6si7786938oih.223.2018.08.20.06.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 06:15:41 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, oom: OOM victims do not need to select next OOM victim unless __GFP_NOFAIL.
Date: Mon, 20 Aug 2018 19:37:45 +0900
Message-Id: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks") changed to select next OOM victim as soon as
MMF_OOM_SKIP is set. But since OOM victims can try ALLOC_OOM allocation
and then give up (if !memcg OOM) or can use forced charge and then retry
(if memcg OOM), OOM victims do not need to select next OOM victim unless
they are doing __GFP_NOFAIL allocations.

This is a quick mitigation because syzbot is hitting WARN(1) caused by
this race window [1]. More robust fix (e.g. make it possible to reclaim
more memory before MMF_OOM_SKIP is set, wait for some more after
MMF_OOM_SKIP is set) is a future work.

[1] https://syzkaller.appspot.com/bug?id=ea8c7912757d253537375e981b61749b2da69258

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-and-tested-by: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
---
 mm/oom_kill.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 412f434..421c0f6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1031,6 +1031,9 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+	if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
+		return true;
+
 	if (oom_killer_disabled)
 		return false;
 
-- 
1.8.3.1
