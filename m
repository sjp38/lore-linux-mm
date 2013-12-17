Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC566B0055
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 10:45:52 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so2970080eak.2
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:45:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si4878122eel.91.2013.12.17.07.45.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 07:45:52 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 3/5] memcg: mm == NULL is not allowed for mem_cgroup_try_charge_mm
Date: Tue, 17 Dec 2013 16:45:28 +0100
Message-Id: <1387295130-19771-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
References: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

An ancient comment tries to explain that a given mm might be NULL when a
task is migrated. It has been introduced by 8a9f3ccd (Memory controller:
memory accounting) along with other bigger changes so it is not much
more specific about the conditions.

Anyway, Even if the task is migrated to another memcg there is no way we
can see NULL mm struct. So either this was not correct from the very
beginning or it is not true anymore.
The only remaining case would be seeing charges after exit_mm but that
would be a bug on its own as the task doesn't have an address space
anymore.

This patch replaces the check by VM_BUG_ON to make it obvious that we
really expect non-NULL mm_struct.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3f01dc9aa101..a122fde6cd54 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2745,14 +2745,7 @@ static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
 	struct task_struct *p;
 	int ret;
 
-	/*
-	 * We always charge the cgroup the mm_struct belongs to.
-	 * The mm_struct's mem_cgroup changes on task migration if the
-	 * thread group leader migrates. It's possible that mm is not
-	 * set, if so charge the root memcg (happens for pagecache usage).
-	 */
-	if (!mm)
-		goto bypass;
+	VM_BUG_ON(!mm);
 
 	do {
 		if (mem_cgroup_bypass_charge())
-- 
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
