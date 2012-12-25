Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 695548D0002
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 12:27:43 -0500 (EST)
Received: by mail-da0-f44.google.com with SMTP id z20so3551565dae.31
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 09:27:42 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V3 6/8] memcg: Don't account root_mem_cgroup page statistics
Date: Wed, 26 Dec 2012 01:27:27 +0800
Message-Id: <1356456447-14740-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

If memcg is enabled and no non-root memcg exists, all allocated pages
belongs to root_mem_cgroup and go through root memcg statistics routines
which brings some overheads. So for the sake of performance, we can give
up accounting stats of root memcg for MEM_CGROUP_STAT_FILE_MAPPED/FILE_DIRTY
/WRITEBACK and instead we pay special attention while showing root
memcg numbers in memcg_stat_show(): as we don't account root memcg stats
anymore, the root_mem_cgroup->stat numbers are actually 0. But because of
hierachy, figures of root_mem_cgroup may just represent numbers of pages
used by its own tasks(not belonging to any other child cgroup). So here we
fake these root numbers by using stats of global state and all other memcg.
That is for root memcg:
	nr(MEM_CGROUP_STAT_FILE_MAPPED) = global_page_state(NR_FILE_MAPPED) -
                              sum_of_all_memcg(MEM_CGROUP_STAT_FILE_MAPPED);
Dirty/Writeback pages accounting are in the similar way.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 68 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fc20ac9..728349d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2230,6 +2230,16 @@ void mem_cgroup_update_page_stat(struct page *page,
 		return;
 
 	memcg = pc->mem_cgroup;
+
+	/*
+	 * For the sake of performance, we don't account stats of root memcg
+	 * for MEM_CGROUP_STAT_FILE_MAPPED/FILE_DIRTY/WRITEBACK.
+	 * So we need to pay special attention while showing root memcg numbers.
+	 * See memcg_stat_show().
+	 */
+	if (memcg == root_mem_cgroup)
+		return;
+
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
 
@@ -5396,18 +5406,70 @@ static inline void mem_cgroup_lru_names_not_uptodate(void)
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
 }
 
+long long root_memcg_local_stat(unsigned int i, long long val,
+					long long nstat[])
+{
+	long long res = 0;
+
+	switch (i) {
+	case MEM_CGROUP_STAT_FILE_MAPPED:
+		res = global_page_state(NR_FILE_MAPPED);
+		break;
+	case MEM_CGROUP_STAT_FILE_DIRTY:
+		res = global_page_state(NR_FILE_DIRTY);
+		break;
+	case MEM_CGROUP_STAT_WRITEBACK:
+		res = global_page_state(NR_WRITEBACK);
+		break;
+	default:
+		break;
+	}
+
+	res = (res <= val) ? 0 : (res - val) * PAGE_SIZE;
+	nstat[i] = res;
+
+	return res;
+}
+
 static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct seq_file *m)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct mem_cgroup *mi;
 	unsigned int i;
+	long long nstat[MEM_CGROUP_STAT_NSTATS] = {0};
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+		long long val = 0, res = 0;
+
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
-		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
-			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
+		if (i == MEM_CGROUP_STAT_SWAP || i == MEM_CGROUP_STAT_CACHE ||
+			i == MEM_CGROUP_STAT_RSS) {
+			seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
+				   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
+			continue;
+		}
+
+		/* As we don't account root memcg stats anymore, the
+		 * root_mem_cgroup->stat numbers are actually 0. But because of
+		 * hierachy, figures of root_mem_cgroup may just represent
+		 * numbers of pages used by its own tasks(not belonging to any
+		 * other child cgroup). So here we fake these root numbers by
+		 * using stats of global state and all other memcg. That is for
+		 * root memcg:
+		 * nr(MEM_CGROUP_STAT_FILE_MAPPED) = global_page_state(NR_FILE_
+		 * 	MAPPED) - sum_of_all_memcg(MEM_CGROUP_STAT_FILE_MAPPED)
+		 * Dirty/Writeback pages accounting are in the similar way.
+		 */
+		if (memcg == root_mem_cgroup) {
+			for_each_mem_cgroup(mi)
+				val += mem_cgroup_read_stat(mi, i);
+			res = root_memcg_local_stat(i, val, nstat);
+		} else
+			res = mem_cgroup_read_stat(memcg, i) * PAGE_SIZE;
+
+		seq_printf(m, "%s %lld\n", mem_cgroup_stat_names[i], res);
 	}
 
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
@@ -5435,6 +5497,10 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 			continue;
 		for_each_mem_cgroup_tree(mi, memcg)
 			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
+
+		/* Adding local stats of root memcg */
+		if (memcg == root_mem_cgroup)
+			val += nstat[i];
 		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
 	}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
