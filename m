Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 51C886B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 22:20:03 -0400 (EDT)
Date: Fri, 22 Jul 2011 11:17:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH] memcg: fix behavior of mem_cgroup_resize_limit()
Message-Id: <20110722111703.241caf72.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

commit:22a668d7 introduced "memsw_is_minimum" flag, which becomes true when
mem_limit == memsw_limit. The flag is checked at the beginning of reclaim,
and "noswap" is set if the flag is true, because using swap is meaningless
in this case.

This works well in most cases, but when we try to shrink mem_limit, which
is the same as memsw_limit now, we might fail to shrink mem_limit because
swap doesn't used.

This patch fixes this behavior by:
- check MEM_CGROUP_RECLAIM_SHRINK at the begining of reclaim
- If it is set, don't set "noswap" flag even if memsw_is_minimum is true.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ce0d617..cf6bae8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1649,7 +1649,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
 	/* If memsw_is_minimum==1, swap-out is of-no-use. */
-	if (!check_soft && root_mem->memsw_is_minimum)
+	if (!check_soft && !shrink && root_mem->memsw_is_minimum)
 		noswap = true;
 
 	while (1) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
