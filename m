Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D60976B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 05:48:02 -0400 (EDT)
From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCHv4 09/11] memcg: Use *_dec_not_zero instead of *_add_unless
Date: Wed, 27 Jul 2011 11:47:48 +0200
Message-Id: <1311760070-21532-9-git-send-email-sven@narfation.org>
In-Reply-To: <1311760070-21532-1-git-send-email-sven@narfation.org>
References: <1311760070-21532-1-git-send-email-sven@narfation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Sven Eckelmann <sven@narfation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

atomic_dec_not_zero is defined for each architecture through
<linux/atomic.h> to provide the functionality of
atomic_add_unless(x, -1, 0).

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5f84d23..00a7580 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1909,10 +1909,10 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *mem)
 	/*
 	 * When a new child is created while the hierarchy is under oom,
 	 * mem_cgroup_oom_lock() may not be called. We have to use
-	 * atomic_add_unless() here.
+	 * atomic_dec_not_zero() here.
 	 */
 	for_each_mem_cgroup_tree(iter, mem)
-		atomic_add_unless(&iter->under_oom, -1, 0);
+		atomic_dec_not_zero(&iter->under_oom);
 }
 
 static DEFINE_SPINLOCK(memcg_oom_lock);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
