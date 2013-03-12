Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id AF9636B0037
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 06:10:58 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rp2so4840293pbb.20
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:10:57 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 4/6] memcg: Don't account root memcg swap stats
Date: Tue, 12 Mar 2013 18:10:39 +0800
Message-Id: <1363083039-3830-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@parallels.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

Similar with root memcg's CACHE/RSS, we don't account its swap stats
to improve performance.

And for root memcg memcg_stat_show():
	nr(MEM_CGROUP_STAT_SWAP) = total_swap_pages - nr_swap_pages
				- sum_of_all_memcg(MEM_CGROUP_STAT_SWAP);

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 24ce5e6d..b73758e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -934,7 +934,9 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
+
+	if (!mem_cgroup_is_root(memcg))
+		this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
 }
 
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
@@ -5460,10 +5462,13 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
 
-		if (mem_cgroup_is_root(memcg) && (i != MEM_CGROUP_STAT_SWAP)) {
-			val = global_page_state(global_stat[i]) -
-				mem_cgroup_recursive_stat(memcg, i);
-			root_stat[i] = val = val < 0 ? 0 : val;
+		if (mem_cgroup_is_root(memcg)) {
+			if (i == MEM_CGROUP_STAT_SWAP)
+				val = total_swap_pages -
+					atomic_long_read(&nr_swap_pages);
+			else
+				val = global_page_state(global_stat[i]);
+			val = val - mem_cgroup_recursive_stat(memcg, i);
 		} else
 			val = mem_cgroup_read_stat(memcg, i);
 		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
