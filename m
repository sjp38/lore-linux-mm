Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8782E6B0036
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 06:10:23 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ro8so4830813pbb.32
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:10:22 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 3/6] memcg: Don't account root memcg MEM_CGROUP_STAT_FILE_MAPPED stats
Date: Tue, 12 Mar 2013 18:10:03 +0800
Message-Id: <1363083003-3791-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@parallels.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

Similar with root memcg's CACHE/RSS, we don't account its stats counted
by mem_cgroup_update_page_stat() (now MEM_CGROUP_STAT_FILE_MAPPED only)
to improve performance.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e89204f..24ce5e6d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2277,6 +2277,10 @@ void mem_cgroup_update_page_stat(struct page *page,
 		return;
 
 	memcg = pc->mem_cgroup;
+
+	if (mem_cgroup_is_root(memcg))
+		return;
+
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
 
@@ -5446,7 +5450,8 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct mem_cgroup *mi;
 	unsigned int i;
-	enum zone_stat_item global_stat[] = {NR_FILE_PAGES, NR_ANON_PAGES};
+	enum zone_stat_item global_stat[] = {NR_FILE_PAGES, NR_ANON_PAGES,
+					NR_FILE_MAPPED};
 	long root_stat[MEM_CGROUP_STAT_NSTATS] = {0};
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
@@ -5455,8 +5460,7 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
 
-		if (mem_cgroup_is_root(memcg) && (i == MEM_CGROUP_STAT_CACHE
-					|| i == MEM_CGROUP_STAT_RSS)) {
+		if (mem_cgroup_is_root(memcg) && (i != MEM_CGROUP_STAT_SWAP)) {
 			val = global_page_state(global_stat[i]) -
 				mem_cgroup_recursive_stat(memcg, i);
 			root_stat[i] = val = val < 0 ? 0 : val;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
