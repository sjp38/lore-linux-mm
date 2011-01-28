Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C23AB8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 22:32:10 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D8D0C3EE0B3
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:32:08 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDD1A45DE56
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:32:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E08745DE55
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:32:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F4C81DB8037
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:32:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C660E08001
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:32:08 +0900 (JST)
Date: Fri, 28 Jan 2011 12:26:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 2/4] memcg: fix charge path for THP and allow early
 retirement
Message-Id: <20110128122608.cf9be26b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When THP is used, Hugepage size charge can happen. It's not handled
correctly in mem_cgroup_do_charge(). For example, THP can fallback
to small page allocation when HUGEPAGE allocation seems difficult
or busy, but memory cgroup doesn't understand it and continue to
try HUGEPAGE charging. And the worst thing is memory cgroup
believes 'memory reclaim succeeded' if limit - usage > PAGE_SIZE.

By this, khugepaged etc...can goes into inifinite reclaim loop
if tasks in memcg are busy.

After this patch 
 - Hugepage allocation will fail if 1st trial of page reclaim fails.

Changelog:
 - make changes small. removed renaming codes.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

Index: mmotm-0125/mm/memcontrol.c
===================================================================
--- mmotm-0125.orig/mm/memcontrol.c
+++ mmotm-0125/mm/memcontrol.c
@@ -1827,10 +1827,14 @@ enum {
 	CHARGE_OK,		/* success */
 	CHARGE_RETRY,		/* need to retry but retry is not bad */
 	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
+	CHARGE_NEED_BREAK,	/* big size allocation failure */
 	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
 	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
 };
 
+/*
+ * Now we have 3 charge size as PAGE_SIZE, HPAGE_SIZE and batched allcation.
+ */
 static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 				int csize, bool oom_check)
 {
@@ -1854,9 +1858,6 @@ static int __mem_cgroup_do_charge(struct
 	} else
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
 
-	if (csize > PAGE_SIZE) /* change csize and retry */
-		return CHARGE_RETRY;
-
 	if (!(gfp_mask & __GFP_WAIT))
 		return CHARGE_WOULDBLOCK;
 
@@ -1880,6 +1881,13 @@ static int __mem_cgroup_do_charge(struct
 		return CHARGE_RETRY;
 
 	/*
+	 * if request size is larger than PAGE_SIZE, it's not OOM
+	 * and caller will do retry in smaller size.
+	 */
+	if (csize != PAGE_SIZE)
+		return CHARGE_NEED_BREAK;
+
+	/*
 	 * At task move, charge accounts can be doubly counted. So, it's
 	 * better to wait until the end of task_move if something is going on.
 	 */
@@ -1997,10 +2005,22 @@ again:
 		case CHARGE_OK:
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
-			csize = page_size;
 			css_put(&mem->css);
 			mem = NULL;
 			goto again;
+		case CHARGE_NEED_BREAK: /* page_size > PAGE_SIZE */
+			css_put(&mem->css);
+			/*
+			 * We'll come here in 2 caes, batched-charge and
+			 * hugetlb alloc. batched-charge can do retry
+			 * with smaller page size. hugepage should return
+			 * NOMEM. This doesn't mean OOM.
+			 */
+			if (page_size > PAGE_SIZE)
+				goto nomem;
+			csize = page_size;
+			mem = NULL;
+			goto again;
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
 			css_put(&mem->css);
 			goto nomem;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
