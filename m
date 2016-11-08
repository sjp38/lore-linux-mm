Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D70806B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 23:52:51 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id b66so83879729ywh.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 20:52:51 -0800 (PST)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id e128si10244299oih.159.2016.11.07.20.52.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 20:52:51 -0800 (PST)
Message-ID: <582157E5.8000106@huawei.com>
Date: Tue, 8 Nov 2016 12:43:17 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] mem-hotplug: shall we skip unmovable node when doing numa balance?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "robert.liu@huawei.com" <robert.liu@huawei.com>

On mem-hotplug system, there is a problem, please see the following case.

memtester xxG, the memory will be alloced on a movable node. And after numa
balancing, the memory may be migrated to the other node, it may be a unmovable
node. This will reduce the free memory of the unmovable node, and may be oom
later.

My question is that shall we skip unmovable node when doing numa balance?
or just let the manager set some numa policies?

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 057964d..f0954ac 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2334,6 +2334,13 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 out:
 	mpol_cond_put(pol);
 
+	/* Skip unmovable nodes when do numa balancing */
+	if (movable_node_enabled && ret != -1) {
+		zone = NODE_DATA(ret)->node_zones + MAX_NR_ZONES - 1;
+		if (!populated_zone(zone))
+			ret = -1;
+	}
+
 	return ret;
 }

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
