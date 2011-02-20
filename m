Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 010528D003A
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 10:17:34 -0500 (EST)
Received: by iyf13 with SMTP id 13so1913138iyf.14
        for <linux-mm@kvack.org>; Sun, 20 Feb 2011 07:17:33 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 1/2] memcg: remove unnecessary BUG_ON
Date: Mon, 21 Feb 2011 00:17:17 +0900
Message-Id: <b691a7be970d6aafcd12ccc32ba812ce39fcf027.1298214672.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1298214672.git.minchan.kim@gmail.com>
References: <cover.1298214672.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1298214672.git.minchan.kim@gmail.com>
References: <cover.1298214672.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>

Now memcg in unmap_and_move checks BUG_ON of charge.
But mem_cgroup_prepare_migration returns either 0 or -ENOMEM.
If it returns -ENOMEM, it jumps out unlock without the check.
If it returns 0, it can pass BUG_ON. So it's meaningless.
Let's remove it.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/migrate.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index eb083a6..2abc9c9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -683,7 +683,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		rc = -ENOMEM;
 		goto unlock;
 	}
-	BUG_ON(charge);
 
 	if (PageWriteback(page)) {
 		if (!force || !sync)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
