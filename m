Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C8B776B019B
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 00:32:38 -0400 (EDT)
Date: Mon, 15 Mar 2010 13:35:50 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: [PATCH -rc] memcg: disable move charge in no mmu case
Message-Id: <20100315133550.50e1393c.d-nishimura@mtf.biglobe.ne.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@in.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In commit 02491447(memcg: move charges of anonymous swap), I tried to disable
move charge feature in no mmu case by enclosing all the related functions
with "#ifdef CONFIG_MMU", but the commit places these ifdefs in wrong place.
(it seems that it's mangled while handling some fixes...)

This patch fixes it up.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   44 ++++++++++++++++++++++----------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7973b52..00dda35 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3946,28 +3946,6 @@ one_by_one:
 	}
 	return ret;
 }
-#else	/* !CONFIG_MMU */
-static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
-				struct cgroup *cgroup,
-				struct task_struct *p,
-				bool threadgroup)
-{
-	return 0;
-}
-static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
-				struct cgroup *cgroup,
-				struct task_struct *p,
-				bool threadgroup)
-{
-}
-static void mem_cgroup_move_task(struct cgroup_subsys *ss,
-				struct cgroup *cont,
-				struct cgroup *old_cont,
-				struct task_struct *p,
-				bool threadgroup)
-{
-}
-#endif
 
 /**
  * is_target_pte_for_mc - check a pte whether it is valid for move charge
@@ -4330,6 +4308,28 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 	}
 	mem_cgroup_clear_mc();
 }
+#else	/* !CONFIG_MMU */
+static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
+				struct cgroup *cgroup,
+				struct task_struct *p,
+				bool threadgroup)
+{
+	return 0;
+}
+static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
+				struct cgroup *cgroup,
+				struct task_struct *p,
+				bool threadgroup)
+{
+}
+static void mem_cgroup_move_task(struct cgroup_subsys *ss,
+				struct cgroup *cont,
+				struct cgroup *old_cont,
+				struct task_struct *p,
+				bool threadgroup)
+{
+}
+#endif
 
 struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
-- 
1.6.3.3




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
