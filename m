Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 37D8F6B0390
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 16:16:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 21so48229086pgg.4
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 13:16:27 -0700 (PDT)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id h84si2631535pfj.16.2017.04.06.13.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 13:16:26 -0700 (PDT)
Received: by mail-pg0-x232.google.com with SMTP id 21so45421204pgg.1
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 13:16:26 -0700 (PDT)
Date: Thu, 6 Apr 2017 13:16:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, swap_cgroup: reschedule when neeed in
 swap_cgroup_swapoff()
Message-ID: <alpine.DEB.2.10.1704061315270.80559@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We got need_resched() warnings in swap_cgroup_swapoff() because
swap_cgroup_ctrl[type].length is particularly large.

Reschedule when needed.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/swap_cgroup.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -201,6 +201,8 @@ void swap_cgroup_swapoff(int type)
 			struct page *page = map[i];
 			if (page)
 				__free_page(page);
+			if (!(i % SWAP_CLUSTER_MAX))
+				cond_resched();
 		}
 		vfree(map);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
