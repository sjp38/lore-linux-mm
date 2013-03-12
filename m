Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 66E626B0036
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 06:09:05 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id ma3so4819966pbc.25
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:09:04 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 1/6] memcg: use global stat directly for root memcg usage
Date: Tue, 12 Mar 2013 18:08:40 +0800
Message-Id: <1363082920-3711-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@parallels.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

Since mem_cgroup_recursive_stat(root_mem_cgroup, INDEX) will sum up
all memcg stats without regard to root's use_hierarchy, we may use
global stats instead for simplicity.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 669d16a..735cd41 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4987,11 +4987,11 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
 	}
 
-	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
-	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
+	val = global_page_state(NR_FILE_PAGES);
+	val += global_page_state(NR_ANON_PAGES);
 
 	if (swap)
-		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAP);
+		val += total_swap_pages - atomic_long_read(&nr_swap_pages);
 
 	return val << PAGE_SHIFT;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
