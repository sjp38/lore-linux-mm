Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 75B7B6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 13:09:33 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5TGvO3B026794
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 12:57:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5TH9m1a185046
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 13:09:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5TH9lfO001320
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 13:09:47 -0400
Date: Mon, 29 Jun 2009 22:39:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [BUGFIX] [mmotm] Reduce memory resource controller overhead fixes
Message-ID: <20090629170901.GB11273@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>


From: Balbir Singh <balbir@linux.vnet.ibm.com>

Fix an incorrect condition in memcg lru manipulation

The PageAcctLRU bit itself does not mean a lot without checking
if the mem cgroup is the same as the root cgroup. This patch
fixes a left over from the previous versions.

Reported-by:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---

 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4cc9d0d..0608719 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -414,7 +414,7 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 	 */
 	smp_rmb();
 	/* unused or root page is not rotated. */
-	if (!PageCgroupUsed(pc) || PageCgroupAcctLRU(pc))
+	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
 		return;
 	mz = page_cgroup_zoneinfo(pc);
 	list_move(&pc->lru, &mz->lists[lru]);

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
