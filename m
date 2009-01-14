Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 55F316B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 03:57:55 -0500 (EST)
Date: Wed, 14 Jan 2009 17:51:21 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

This is a new one. Please review.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

mem_cgroup_get ensures that the memcg that has been got can be accessed
even after the directory has been removed, but it doesn't ensure that parents
of it can be accessed: parents might have been freed already by rmdir.

This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
climb up the tree.

Check if the memcg is obsolete, and don't call res_counter_uncharge when obsole.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb62b43..4ee95a8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1182,7 +1182,8 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 		/* avoid double counting */
 		mem = swap_cgroup_record(ent, NULL);
 		if (mem) {
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			if (!mem_cgroup_is_obsolete(mem))
+				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 			mem_cgroup_put(mem);
 		}
 	}
@@ -1252,7 +1253,8 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 		struct mem_cgroup *memcg;
 		memcg = swap_cgroup_record(ent, NULL);
 		if (memcg) {
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			if (!mem_cgroup_is_obsolete(memcg))
+				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 			mem_cgroup_put(memcg);
 		}
 
@@ -1397,7 +1399,8 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 
 	memcg = swap_cgroup_record(ent, NULL);
 	if (memcg) {
-		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		if (!mem_cgroup_is_obsolete(memcg))
+			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 		mem_cgroup_put(memcg);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
