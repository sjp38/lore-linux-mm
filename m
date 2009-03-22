Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9C5606B004D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 10:18:00 -0400 (EDT)
Date: Mon, 23 Mar 2009 00:02:38 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: [BUGFIX][PATCH mmotm] memcg: try_get_mem_cgroup_from_swapcache fix
Message-Id: <20090323000238.e650c65e.d-nishimura@mtf.biglobe.ne.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

css_tryget can be called twice in !PageCgroupUsed case.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
This is a fix for cgroups-use-css-id-in-swap-cgroup-for-saving-memory-v5.patch

 mm/memcontrol.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5de6be9..55dea59 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1027,9 +1027,11 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 	/*
 	 * Used bit of swapcache is solid under page lock.
 	 */
-	if (PageCgroupUsed(pc))
+	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
-	else {
+		if (mem && !css_tryget(&mem->css))
+			mem = NULL;
+	} else {
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup(ent);
 		rcu_read_lock();
@@ -1038,10 +1040,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 			mem = NULL;
 		rcu_read_unlock();
 	}
-	if (!mem)
-		return NULL;
-	if (!css_tryget(&mem->css))
-		return NULL;
 	return mem;
 }
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
