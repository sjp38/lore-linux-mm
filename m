Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 31C496B006E
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 03:43:29 -0500 (EST)
Received: by pdev10 with SMTP id v10so4220492pde.13
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 00:43:28 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id f3si8545010pdd.80.2015.03.05.00.43.27
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 00:43:28 -0800 (PST)
Message-ID: <54F81322.8010202@cn.fujitsu.com>
Date: Thu, 5 Mar 2015 16:26:10 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com>
In-Reply-To: <54F52ACF.4030103@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>

Hi Xishi,
Could you please try the following one?
It postpones the reset of obsolete pgdat from try_offline_node() to
hotadd_new_pgdat(), and just resetting pgdat->nr_zones and
pgdat->classzone_idx to be 0 rather than the whole reset by memset()
as Kame suggested.

Regards,
Gu

---
 mm/memory_hotplug.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1778628..c17eebf 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1092,6 +1092,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 			return NULL;
 
 		arch_refresh_nodedata(nid, pgdat);
+	} else {
+		/* Reset the nr_zones and classzone_idx to 0 before reuse */
+		pgdat->nr_zones = 0;
+		pgdat->classzone_idx = 0;
 	}
 
 	/* we can use NODE_DATA(nid) from here */
@@ -2021,15 +2025,6 @@ void try_offline_node(int nid)
 
 	/* notify that the node is down */
 	call_node_notify(NODE_DOWN, (void *)(long)nid);
-
-	/*
-	 * Since there is no way to guarentee the address of pgdat/zone is not
-	 * on stack of any kernel threads or used by other kernel objects
-	 * without reference counting or other symchronizing method, do not
-	 * reset node_data and free pgdat here. Just reset it to 0 and reuse
-	 * the memory when the node is online again.
-	 */
-	memset(pgdat, 0, sizeof(*pgdat));
 }
 EXPORT_SYMBOL(try_offline_node);
 
-- 
1.7.7



On 03/03/2015 11:30 AM, Xishi Qiu wrote:

> When hot-remove a numa node, we will clear pgdat,
> but is memset 0 safe in try_offline_node()?
> 
> process A:			offline node XX:
> for_each_populated_zone()
> find online node XX
> cond_resched()
> 				offline cpu and memory, then try_offline_node()
> 				node_set_offline(nid), and memset(pgdat, 0, sizeof(*pgdat))
> access node XX's pgdat
> NULL pointer access error
> 
> Thanks,
> Xishi Qiu
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
