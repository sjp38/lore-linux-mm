Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0316B025E
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 13:15:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 6so14067pgh.0
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 10:15:14 -0700 (PDT)
Received: from out0-211.mail.aliyun.com (out0-211.mail.aliyun.com. [140.205.0.211])
        by mx.google.com with ESMTPS id y1si11302710pgo.565.2017.09.14.10.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 10:15:13 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 1/3] mm: slab: output reclaimable flag in /proc/slabinfo
Date: Fri, 15 Sep 2017 01:14:47 +0800
Message-Id: <1505409289-57031-2-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com>
References: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Although slabinfo in tools can print out the flag of slabs to show which
one is reclaimable, it sounds nice to have reclaimable flag shows in
/proc/slabinfo too since /proc should be still the first place to check
those slab info.

Add a new column called "reclaim" in /proc/slabinfo, "1" means
reclaimable, "0" means unreclaimable.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/slab.c        | 1 +
 mm/slab.h        | 6 ++++++
 mm/slab_common.c | 2 ++
 mm/slub.c        | 1 +
 4 files changed, 10 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 04dec48..4f4971c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4132,6 +4132,7 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 	sinfo->shared = cachep->shared;
 	sinfo->objects_per_slab = cachep->num;
 	sinfo->cache_order = cachep->gfporder;
+	sinfo->reclaim = is_reclaimable(cachep);
 }
 
 void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
diff --git a/mm/slab.h b/mm/slab.h
index 0733628..cf01a6e 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -186,6 +186,7 @@ struct slabinfo {
 	unsigned int shared;
 	unsigned int objects_per_slab;
 	unsigned int cache_order;
+	unsigned int reclaim;
 };
 
 void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo);
@@ -352,6 +353,11 @@ static inline void memcg_link_cache(struct kmem_cache *s)
 
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
+static inline bool is_reclaimable(struct kmem_cache *s)
+{
+	return (s->flags & SLAB_RECLAIM_ACCOUNT) ? true : false;
+}
+
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
 	struct kmem_cache *cachep;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 904a83b..8a55730 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1201,6 +1201,7 @@ static void print_slabinfo_header(struct seq_file *m)
 	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> <error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
 	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
 #endif
+	seq_puts(m, " : reclaim");
 	seq_putc(m, '\n');
 }
 
@@ -1259,6 +1260,7 @@ static void cache_show(struct kmem_cache *s, struct seq_file *m)
 	seq_printf(m, " : slabdata %6lu %6lu %6lu",
 		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
 	slabinfo_show_stats(m, s);
+	seq_printf(m, " : %u", sinfo.reclaim);
 	seq_putc(m, '\n');
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index d39a5d3..c8526c0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5872,6 +5872,7 @@ void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 	sinfo->num_slabs = nr_slabs;
 	sinfo->objects_per_slab = oo_objects(s->oo);
 	sinfo->cache_order = oo_order(s->oo);
+	sinfo->reclaim = is_reclaimable(s);
 }
 
 void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *s)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
