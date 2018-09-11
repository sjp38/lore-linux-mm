Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4DCE8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 21:00:20 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id e126-v6so11243329ybb.3
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 18:00:20 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o14-v6si4000423ybe.678.2018.09.10.18.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 18:00:19 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 8/8] mm: enable concurrent LRU adds
Date: Mon, 10 Sep 2018 20:59:49 -0400
Message-Id: <20180911005949.5635-5-daniel.m.jordan@oracle.com>
In-Reply-To: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com

Switch over to holding lru_lock as reader when splicing pages onto the
front of an LRU.  The main benefit of doing this is to allow LRU adds
and removes to happen concurrently.  Before this patch, an add blocks
all removing threads.

Suggested-by: Yosef Lev <levyossi@icloud.com>
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/swap.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index fe3098c09815..ccd82ef3c217 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -999,9 +999,9 @@ void __pagevec_lru_add(struct pagevec *pvec)
 		 */
 		if (pagepgdat != pgdat) {
 			if (pgdat)
-				write_unlock_irqrestore(&pgdat->lru_lock, flags);
+				read_unlock_irqrestore(&pgdat->lru_lock, flags);
 			pgdat = pagepgdat;
-			write_lock_irqsave(&pgdat->lru_lock, flags);
+			read_lock_irqsave(&pgdat->lru_lock, flags);
 		}
 
 		lruvec = mem_cgroup_page_lruvec(page, pagepgdat);
@@ -1016,12 +1016,16 @@ void __pagevec_lru_add(struct pagevec *pvec)
 
 		if (splice->pgdat != pgdat) {
 			if (pgdat)
-				write_unlock_irqrestore(&pgdat->lru_lock, flags);
+				read_unlock_irqrestore(&pgdat->lru_lock, flags);
 			pgdat = splice->pgdat;
-			write_lock_irqsave(&pgdat->lru_lock, flags);
+			read_lock_irqsave(&pgdat->lru_lock, flags);
 		}
 		smp_list_splice(&splice->list, splice->lru);
 	}
+	if (pgdat) {
+		read_unlock_irqrestore(&pgdat->lru_lock, flags);
+		pgdat = NULL;
+	}
 
 	while (!list_empty(&singletons)) {
 		page = list_first_entry(&singletons, struct page, lru);
-- 
2.18.0
