Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9066B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 12:47:51 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id hs14so1203170lab.31
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:47:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si3495150lax.37.2014.10.23.09.47.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 09:47:49 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] memcg: Fix NULL pointer deref in task_in_mem_cgroup()
Date: Thu, 23 Oct 2014 18:47:45 +0200
Message-Id: <1414082865-4091-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

'curr' pointer in task_in_mem_cgroup() can be NULL when we race with
somebody clearing task->mm. Check for it before dereferencing the
pointer.

Coverity-id: 1198369
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memcontrol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 23976fd885fd..18ab127a0767 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1469,7 +1469,8 @@ bool task_in_mem_cgroup(struct task_struct *task,
 	 * hierarchy(even if use_hierarchy is disabled in "memcg").
 	 */
 	ret = mem_cgroup_same_or_subtree(memcg, curr);
-	css_put(&curr->css);
+	if (curr)
+		css_put(&curr->css);
 	return ret;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
