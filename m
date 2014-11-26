Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id A66F16B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 17:17:35 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so3374220igb.17
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 14:17:35 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id f4si4267840icx.73.2014.11.26.14.17.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Nov 2014 14:17:34 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id h15so7641138igd.2
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 14:17:34 -0800 (PST)
Date: Wed, 26 Nov 2014 14:17:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: remove gfp helper function
Message-ID: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Qiang Huang <h.huangqiang@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit b9921ecdee66 ("mm: add a helper function to check may oom
condition") was added because the gfp criteria for oom killing was
checked in both the page allocator and memcg.

That was true for about nine months, but then commit 0029e19ebf84 ("mm:
memcontrol: remove explicit OOM parameter in charge path") removed the
memcg usecase.

Fold the implementation into its only caller.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h | 5 -----
 mm/page_alloc.c     | 2 +-
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -85,11 +85,6 @@ static inline void oom_killer_enable(void)
 	oom_killer_disabled = false;
 }
 
-static inline bool oom_gfp_allowed(gfp_t gfp_mask)
-{
-	return (gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY);
-}
-
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 /* sysctls */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2706,7 +2706,7 @@ rebalance:
 	 * running out of options and have to consider going OOM
 	 */
 	if (!did_some_progress) {
-		if (oom_gfp_allowed(gfp_mask)) {
+		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
 			if (oom_killer_disabled)
 				goto nopage;
 			/* Coredumps can quickly deplete all memory reserves */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
