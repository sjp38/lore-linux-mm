Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2852C900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 03:59:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0795D3EE0AE
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:59:21 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E257445DE5B
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:59:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C922045DE56
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:59:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9BA3EF8007
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:59:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78973EF8004
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:59:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: (resend) [PATCH] vmscan,memcg: memcg aware swap token
Message-Id: <20110426170146.F396.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Apr 2011 16:59:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
Cc: kosaki.motohiro@jp.fujitsu.com

Currently, memcg reclaim can disable swap token even if the swap token
mm doesn't belong in its memory cgroup. It's slightly riskly. If an
admin makes very small mem-cgroup and silly guy runs contenious heavy
memory pressure workloa, whole tasks in the system are going to lose
swap-token and then system may become unresponsive. That's bad.

This patch adds 'memcg' parameter into disable_swap_token(). and if
the parameter doesn't match swap-token, VM doesn't put swap-token.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 ++++++
 include/linux/swap.h       |   24 +++++++++++++++++-------
 mm/memcontrol.c            |    2 +-
 mm/thrash.c                |   17 +++++++++++++++++
 mm/vmscan.c                |    4 ++--
 5 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6a0cffd..df572af 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -84,6 +84,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
+extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
@@ -244,6 +245,11 @@ static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	return NULL;
 }
 
+static inline struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
+{
+	return NULL;
+}
+
 static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
 {
 	return 1;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 384eb5f..ccea15d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -358,21 +358,31 @@ struct backing_dev_info;
 extern struct mm_struct *swap_token_mm;
 extern void grab_swap_token(struct mm_struct *);
 extern void __put_swap_token(struct mm_struct *);
+extern int has_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg);
 
-static inline int has_swap_token(struct mm_struct *mm)
+static inline
+int has_swap_token(struct mm_struct *mm)
 {
-	return (mm == swap_token_mm);
+	return has_swap_token_memcg(mm, NULL);
 }
 
-static inline void put_swap_token(struct mm_struct *mm)
+static inline
+void put_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
 {
-	if (has_swap_token(mm))
+	if (has_swap_token_memcg(mm, memcg))
 		__put_swap_token(mm);
 }
 
-static inline void disable_swap_token(void)
+static inline
+void put_swap_token(struct mm_struct *mm)
+{
+	return put_swap_token_memcg(mm, NULL);
+}
+
+static inline
+void disable_swap_token(struct mem_cgroup *memcg)
 {
-	put_swap_token(swap_token_mm);
+	put_swap_token_memcg(swap_token_mm, memcg);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
@@ -500,7 +510,7 @@ static inline int has_swap_token(struct mm_struct *mm)
 	return 0;
 }
 
-static inline void disable_swap_token(void)
+static inline void disable_swap_token(struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c2776f1..5683c7a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -735,7 +735,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 				struct mem_cgroup, css);
 }
 
-static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
+struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *mem = NULL;
 
diff --git a/mm/thrash.c b/mm/thrash.c
index 2372d4e..f892a6e 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -21,6 +21,7 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/swap.h>
+#include <linux/memcontrol.h>
 
 static DEFINE_SPINLOCK(swap_token_lock);
 struct mm_struct *swap_token_mm;
@@ -75,3 +76,19 @@ void __put_swap_token(struct mm_struct *mm)
 		swap_token_mm = NULL;
 	spin_unlock(&swap_token_lock);
 }
+
+int has_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
+{
+	if (memcg) {
+		struct mem_cgroup *swap_token_memcg;
+
+		/*
+		 * memcgroup reclaim can disable swap token only if token task
+		 * is in the same cgroup.
+		 */
+		swap_token_memcg = try_get_mem_cgroup_from_mm(swap_token_mm);
+		return ((mm == swap_token_mm) && (memcg == swap_token_memcg));
+	} else
+		return (mm == swap_token_mm);
+}
+
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b3a569f..19e179b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2044,7 +2044,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
 		if (!priority)
-			disable_swap_token();
+			disable_swap_token(sc->mem_cgroup);
 		shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
@@ -2353,7 +2353,7 @@ loop_again:
 
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
-			disable_swap_token();
+			disable_swap_token(NULL);
 
 		all_zones_ok = 1;
 		balanced = 0;
-- 
1.7.3.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
