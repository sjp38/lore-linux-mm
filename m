Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED6A56B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 15:48:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a7so50563635pfj.3
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 12:48:26 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTPS id f30si5366256plf.657.2017.10.08.12.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Oct 2017 12:48:25 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH -mmotm] mm: slab: exclude slabinfo dump for slob
Date: Mon, 09 Oct 2017 03:48:05 +0800
Message-Id: <1507492085-42264-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

CONFIG_SLABINFO is removed, but slabinfo dump is not applicable to slob,
protect slbinfo stats from !CONFIG_SLOB to avoid the below compile
error reported by 0-DAY kernel test:

   mm/slab_common.o: In function `dump_unreclaimable_slab':
>> mm/slab_common.c:1298: undefined reference to `get_slabinfo'

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
Andrew,
This should be able to be fold into mm-oom-show-unreclaimable-slab-info-when-unreclaimable-slabs-user-memory.patch in -mm tree.

 mm/slab.h        | 6 ++++++
 mm/slab_common.c | 4 +++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/slab.h b/mm/slab.h
index 6fc4d5d..8dc504a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -505,7 +505,13 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 void memcg_slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
+#ifdef CONFIG_SLOB
+static void inline dump_unreclaimable_slab(void)
+{
+}
+#else
 void dump_unreclaimable_slab(void);
+#endif
 
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 5c8fac5..edc5f5f 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1183,6 +1183,7 @@ void cache_random_seq_destroy(struct kmem_cache *cachep)
 }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
+#ifndef CONFIG_SLOB
 #ifdef CONFIG_SLAB
 #define SLABINFO_RIGHTS (S_IWUSR | S_IRUSR)
 #else
@@ -1313,7 +1314,7 @@ void dump_unreclaimable_slab(void)
 	mutex_unlock(&slab_mutex);
 }
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#if defined(CONFIG_MEMCG)
 void *memcg_slab_start(struct seq_file *m, loff_t *pos)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -1387,6 +1388,7 @@ static int __init slab_proc_init(void)
 	return 0;
 }
 module_init(slab_proc_init);
+#endif /* !CONFIG_SLOB */
 
 static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 					   gfp_t flags)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
