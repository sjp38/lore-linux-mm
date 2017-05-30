Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88F6A6B02FD
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:17:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j27so1168107wre.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:17:47 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 21si13613642eds.84.2017.05.30.11.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 May 2017 11:17:46 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/6] mm: memcontrol: use the node-native slab memory counters
Date: Tue, 30 May 2017 14:17:21 -0400
Message-Id: <20170530181724.27197-4-hannes@cmpxchg.org>
In-Reply-To: <20170530181724.27197-1-hannes@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Now that the slab counters are moved from the zone to the node level
we can drop the private memcg node stats and use the official ones.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 2 --
 mm/memcontrol.c            | 8 ++++----
 mm/slab.h                  | 4 ++--
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 899949bbb2f9..7b8f0f239fd6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -44,8 +44,6 @@ enum memcg_stat_item {
 	MEMCG_SOCK,
 	/* XXX: why are these zone and not node counters? */
 	MEMCG_KERNEL_STACK_KB,
-	MEMCG_SLAB_RECLAIMABLE,
-	MEMCG_SLAB_UNRECLAIMABLE,
 	MEMCG_NR_STAT,
 };
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 94172089f52f..9c68a40c83e3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5197,8 +5197,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "kernel_stack %llu\n",
 		   (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
 	seq_printf(m, "slab %llu\n",
-		   (u64)(stat[MEMCG_SLAB_RECLAIMABLE] +
-			 stat[MEMCG_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
+		   (u64)(stat[NR_SLAB_RECLAIMABLE] +
+			 stat[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
 	seq_printf(m, "sock %llu\n",
 		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
 
@@ -5222,9 +5222,9 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	}
 
 	seq_printf(m, "slab_reclaimable %llu\n",
-		   (u64)stat[MEMCG_SLAB_RECLAIMABLE] * PAGE_SIZE);
+		   (u64)stat[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
 	seq_printf(m, "slab_unreclaimable %llu\n",
-		   (u64)stat[MEMCG_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
+		   (u64)stat[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
 
 	/* Accumulated memory events */
 
diff --git a/mm/slab.h b/mm/slab.h
index 9cfcf099709c..69f0579cb5aa 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -287,7 +287,7 @@ static __always_inline int memcg_charge_slab(struct page *page,
 
 	memcg_kmem_update_page_stat(page,
 			(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-			MEMCG_SLAB_RECLAIMABLE : MEMCG_SLAB_UNRECLAIMABLE,
+			NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 			1 << order);
 	return 0;
 }
@@ -300,7 +300,7 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 
 	memcg_kmem_update_page_stat(page,
 			(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-			MEMCG_SLAB_RECLAIMABLE : MEMCG_SLAB_UNRECLAIMABLE,
+			NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 			-(1 << order));
 	memcg_kmem_uncharge(page, order);
 }
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
