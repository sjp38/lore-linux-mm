Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2346B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 11:52:52 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id 191so56292945wmq.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 08:52:52 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id uc9si34985424wjc.194.2016.03.29.08.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 08:52:49 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 20so6661362wmh.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 08:52:49 -0700 (PDT)
Date: Tue, 29 Mar 2016 17:52:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
Message-ID: <20160329155247.GG4466@dhcp22.suse.cz>
References: <56F4E104.9090505@huawei.com>
 <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 25-03-16 12:22:37, Andrew Morton wrote:
[...]
> And can someone please explain mem_cgroup_select_victim_node() to me? 
> How can we hit the "node = numa_node_id()" path?  Only if
> memcg->scan_nodes is empty?

Yes, this seems to be the primary motivation.
mem_cgroup_may_update_nodemask might have seen all the pages on
unevictable LRU last time it checked something.

> is that even valid?

I suspect it is really rare but it seems possible

> The comment seems to have not much to do with the code?

I guess the comment tries to say that the code path is triggered when we
charge the page which happens _before_ it is added to the LRU list and
so last_scanned_node might contain the stale data. Would something like
the following be more clear?
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 17a847c96618..cff095318950 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1390,10 +1390,9 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 
 	node = next_node_in(node, memcg->scan_nodes);
 	/*
-	 * We call this when we hit limit, not when pages are added to LRU.
-	 * No LRU may hold pages because all pages are UNEVICTABLE or
-	 * memcg is too small and all pages are not on LRU. In that case,
-	 * we use curret node.
+	 * mem_cgroup_may_update_nodemask might have seen no reclaimmable pages
+	 * last time it really checked all the LRUs due to rate limiting.
+	 * Fallback to the current node in that case for simplicity.
 	 */
 	if (unlikely(node == MAX_NUMNODES))
 		node = numa_node_id();
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
