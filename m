Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EB6D26B00E9
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 03:51:24 -0500 (EST)
Received: by gyf3 with SMTP id 3so5029457gyf.2
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 00:51:21 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 1/2] memcg: remove unnecessary BUG_ON
Date: Tue, 11 Jan 2011 17:51:11 +0900
Message-Id: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Now memcg in unmap_and_move checks BUG_ON of charge.
mem_cgroup_prepare_migration returns either 0 or -ENOMEM.
If it returns -ENOMEM, it jumps out unlock without the check.
If it returns 0, it can pass BUG_ON. So it's meaningless.
Let's remove it.

Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/migrate.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index b8a32da..8f0f131 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -667,7 +667,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		rc = -ENOMEM;
 		goto unlock;
 	}
-	BUG_ON(charge);
 
 	if (PageWriteback(page)) {
 		if (!force || !sync)
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
