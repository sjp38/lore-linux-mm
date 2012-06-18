Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id DE6296B0071
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 07:59:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CBB4F3EE0BD
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 20:59:35 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B261645DE50
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 20:59:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 978B545DD78
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 20:59:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88ED41DB8038
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 20:59:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 431451DB802C
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 20:59:35 +0900 (JST)
Message-ID: <4FDF17A3.9060202@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 20:57:23 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] memcg: remove -EINTR at rmdir()
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

2 follow-up patches for "memcg: move charges to root cgroup if use_hierarchy=0",
developped/tested onto memcg-devel tree. Maybe no HUNK with -next and -mm....
-Kame
==
memcg: remove -EINTR at rmdir()

By commit "memcg: move charges to root cgroup if use_hierarchy=0",
no memory reclaiming will occur at removing memory cgroup.

So, we don't need to take care of user interrupt by signal. This
patch removes it.
(*) If -EINTR is returned here, cgroup will show WARNING.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0623300..cf8a0f6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3890,9 +3890,6 @@ move_account:
 		ret = -EBUSY;
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
-		ret = -EINTR;
-		if (signal_pending(current))
-			goto out;
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
 		drain_all_stock_sync(memcg);
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
