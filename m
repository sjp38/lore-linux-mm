Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 6099D6B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 10:38:37 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 25 Aug 2012 00:37:53 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7OEcXaN29032478
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 00:38:33 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7OEcWZf031642
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 00:38:33 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm/vmscan: fix error number for failed kthread
Date: Fri, 24 Aug 2012 22:37:56 +0800
Message-Id: <1345819076-12545-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1345819076-12545-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1345819076-12545-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

From: Gavin Shan <shangw@linux.vnet.ibm.com>

The patch fixes the return value while failing to create the kswapd
kernel thread. Also, the error message is prioritized as KERN_ERR.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmscan.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d01243..ddf00a7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3101,9 +3101,10 @@ int kswapd_run(int nid)
 	if (IS_ERR(pgdat->kswapd)) {
 		/* failure at boot is fatal */
 		BUG_ON(system_state == SYSTEM_BOOTING);
-		printk("Failed to start kswapd on node %d\n",nid);
-		ret = -1;
+		pr_err("Failed to start kswapd on node %d\n", nid);
+		ret = PTR_ERR(pgdat->kswapd);
 	}
+
 	return ret;
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
