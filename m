Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFD866B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:29:34 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y200so11665202itc.7
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 05:29:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 1si1739784itj.89.2018.02.20.05.29.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Feb 2018 05:29:33 -0800 (PST)
Subject: [PATCH] mm,vmscan: don't pretend forward progress upon shrinker_rwsem contention
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1518184544-3293-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180213101329.GN3443@dhcp22.suse.cz>
In-Reply-To: <20180213101329.GN3443@dhcp22.suse.cz>
Message-Id: <201802202229.GGF26507.LVFtMSOOHFJOQF@I-love.SAKURA.ne.jp>
Date: Tue, 20 Feb 2018 22:29:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mhocko@suse.com, dchinner@redhat.com, mgorman@suse.de, glommer@gmail.com

Since we no longer use return value of shrink_slab() for normal reclaim,
the comment is no longer true. If some do_shrink_slab() call takes
unexpectedly long (root cause of stall is currently unknown) when
register_shrinker()/unregister_shrinker() is pending, trying to drop
caches via /proc/sys/vm/drop_caches could become infinite cond_resched()
loop if many mem_cgroup are defined. For safety, let's not pretend forward
progress.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.ccom>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4447496..17da5a5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -442,16 +442,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
 		return 0;
 
-	if (!down_read_trylock(&shrinker_rwsem)) {
-		/*
-		 * If we would return 0, our callers would understand that we
-		 * have nothing else to shrink and give up trying. By returning
-		 * 1 we keep it going and assume we'll be able to shrink next
-		 * time.
-		 */
-		freed = 1;
+	if (!down_read_trylock(&shrinker_rwsem))
 		goto out;
-	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
