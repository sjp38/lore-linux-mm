Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B189D6B0088
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 23:02:43 -0500 (EST)
Date: Wed, 5 Jan 2011 13:00:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
Message-Id: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

This is a fix for a problem which has bothered me for a month.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

In current implimentation, mem_cgroup_end_migration() decides whether the page
migration has succeeded or not by checking "oldpage->mapping".

But if we are tring to migrate a shmem swapcache, the page->mapping of it is
NULL from the begining, so the check would be invalid.
As a result, mem_cgroup_end_migration() assumes the migration has succeeded
even if it's not, so "newpage" would be freed while it's not uncharged.

This patch fixes it by passing mem_cgroup_end_migration() the result of the
page migration.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/memcontrol.h |    5 ++---
 mm/memcontrol.c            |    5 ++---
 mm/migrate.c               |    2 +-
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 159a076..275157b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -93,7 +93,7 @@ extern int
 mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr);
 extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
-	struct page *oldpage, struct page *newpage);
+	struct page *oldpage, struct page *newpage, int result);
 
 /*
  * For memory reclaim.
@@ -231,8 +231,7 @@ mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 }
 
 static inline void mem_cgroup_end_migration(struct mem_cgroup *mem,
-					struct page *oldpage,
-					struct page *newpage)
+		struct page *oldpage, struct page *newpage, int result)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 61678be..632d3bc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2856,7 +2856,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 
 /* remove redundant charge if migration failed*/
 void mem_cgroup_end_migration(struct mem_cgroup *mem,
-	struct page *oldpage, struct page *newpage)
+	struct page *oldpage, struct page *newpage, int result)
 {
 	struct page *used, *unused;
 	struct page_cgroup *pc;
@@ -2865,8 +2865,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 		return;
 	/* blocks rmdir() */
 	cgroup_exclude_rmdir(&mem->css);
-	/* at migration success, oldpage->mapping is NULL. */
-	if (oldpage->mapping) {
+	if (result) {
 		used = oldpage;
 		unused = newpage;
 	} else {
diff --git a/mm/migrate.c b/mm/migrate.c
index 6ae8a66..9a5704a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -756,7 +756,7 @@ rcu_unlock:
 		rcu_read_unlock();
 uncharge:
 	if (!charge)
-		mem_cgroup_end_migration(mem, page, newpage);
+		mem_cgroup_end_migration(mem, page, newpage, rc);
 unlock:
 	unlock_page(page);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
