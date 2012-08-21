Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id EB5366B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 02:43:56 -0400 (EDT)
Message-ID: <50332B37.2000500@cn.fujitsu.com>
Date: Tue, 21 Aug 2012 14:31:19 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memory hotplug: reset pgdat->kswapd to NULL if creating kernel
 thread fails
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hughd@google.com, minchan@kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

If kthread_run() fails, pgdat->kswapd contains errno. When we stop
this thread, we only check whether pgdat->kswapd is NULL and access
it. If it contains errno, it will cause page fault. Reset pgdat->kswapd
to NULL when creating kernel thread fails can avoid this problem.

Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/vmscan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 347b3ff..1e8e2aa 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2953,6 +2953,7 @@ int kswapd_run(int nid)
 		/* failure at boot is fatal */
 		BUG_ON(system_state == SYSTEM_BOOTING);
 		printk("Failed to start kswapd on node %d\n",nid);
+		pgdat->kswapd = NULL;
 		ret = -1;
 	}
 	return ret;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
