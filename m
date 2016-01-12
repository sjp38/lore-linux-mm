Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDA04403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:00:42 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id b14so340813953wmb.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:00:42 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id kq9si51532100wjc.90.2016.01.12.13.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 13:00:38 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u188so33314208wmu.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:00:38 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 3/3] oom: Do not try to sacrifice small children
Date: Tue, 12 Jan 2016 22:00:25 +0100
Message-Id: <1452632425-20191-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

try_to_sacrifice_child will select the largest child of the selected OOM
victim to protect it and potentially save some work done by the parent.
We can however select a small child which has barely touched any memory
and killing it wouldn't lead to OOM recovery and only prolong the OOM
condition which is not desirable.

This patch simply ignores the largest child selection and falls back to
the parent (original victim) if the child hasn't accumulated even 1MB
worth of oom score. We are not checking the memory consumption directly
as we want to honor the oom_score_adj here because this would be the
only way to protect children from this heuristic in case they are more
important than the parent.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8bca0b1e97f7..b5c0021c6462 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -721,8 +721,16 @@ try_to_sacrifice_child(struct oom_control *oc, struct task_struct *victim,
 	if (!child_victim)
 		goto out;
 
-	put_task_struct(victim);
-	victim = child_victim;
+	/*
+	 * Protecting the parent makes sense only if killing the child
+	 * would release at least some memory (at least 1MB).
+	 */
+	if (K(victim_points) >= 1024) {
+		put_task_struct(victim);
+		victim = child_victim;
+	} else {
+		put_task_struct(child_victim);
+	}
 
 out:
 	return victim;
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
