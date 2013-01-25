Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 29FD26B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 07:17:52 -0500 (EST)
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
Subject: [PATCH] memcg: fix typo in kmemcg cache walk macro
Date: Fri, 25 Jan 2013 16:17:55 +0400
Message-Id: <1359116275-25298-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Glauber Costa <glommer@parallels.com>

The macro for_each_memcg_cache_index contains a silly yet potentially
deadly mistake. Although the macro parameter is _idx, the loop tests are
done over i, not _idx.

This hasn't generated any problems so far, because all users use i as a
loop index. However, while playing with an extension of the code I
ended using another loop index and the compiler was quick to complain.

Unfortunately, this is not the kind of thing that testing reveals =(

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 904084f..2a876a3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -424,7 +424,7 @@ extern int memcg_limited_groups_array_size;
  * the slab_mutex must be held when looping through those caches
  */
 #define for_each_memcg_cache_index(_idx)	\
-	for ((_idx) = 0; i < memcg_limited_groups_array_size; (_idx)++)
+	for ((_idx) = 0; (_idx) < memcg_limited_groups_array_size; (_idx)++)
 
 static inline bool memcg_kmem_enabled(void)
 {
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
