Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0AB6B0261
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 17:29:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j64so15278448pfj.6
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 14:29:23 -0700 (PDT)
Received: from out0-211.mail.aliyun.com (out0-211.mail.aliyun.com. [140.205.0.211])
        by mx.google.com with ESMTPS id g207si3155004pfb.460.2017.10.04.14.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 14:29:22 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 2/3] mm: slabinfo: dump CONFIG_SLABINFO
Date: Thu, 05 Oct 2017 05:29:09 +0800
Message-Id: <1507152550-46205-3-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
References: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

According to the discussion with Christoph [1], it sounds it is pointless
to keep CONFIG_SLABINFO around.

This patch just remove CONFIG_SLABINFO config option, but /proc/slabinfo
is still available.

[1] https://marc.info/?l=linux-kernel&m=150695909709711&w=2

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 init/Kconfig     | 6 ------
 mm/memcontrol.c  | 2 --
 mm/slab.c        | 2 --
 mm/slab_common.c | 3 ---
 mm/slub.c        | 2 --
 5 files changed, 15 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 78cb246..5d3c80a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1657,12 +1657,6 @@ config HAVE_GENERIC_DMA_COHERENT
 	bool
 	default n
 
-config SLABINFO
-	bool
-	depends on PROC_FS
-	depends on SLAB || SLUB_DEBUG
-	default y
-
 config RT_MUTEXES
 	bool
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d5f3a62..c741063 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4049,7 +4049,6 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
 		.write = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read_u64,
 	},
-#ifdef CONFIG_SLABINFO
 	{
 		.name = "kmem.slabinfo",
 		.seq_start = memcg_slab_start,
@@ -4057,7 +4056,6 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
 		.seq_stop = memcg_slab_stop,
 		.seq_show = memcg_slab_show,
 	},
-#endif
 	{
 		.name = "kmem.tcp.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_TCP, RES_LIMIT),
diff --git a/mm/slab.c b/mm/slab.c
index 04dec48..5743a51 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4096,7 +4096,6 @@ static void cache_reap(struct work_struct *w)
 	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_AC));
 }
 
-#ifdef CONFIG_SLABINFO
 void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 {
 	unsigned long active_objs, num_objs, active_slabs;
@@ -4404,7 +4403,6 @@ static int __init slab_proc_init(void)
 	return 0;
 }
 module_init(slab_proc_init);
-#endif
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8016459..c1629cb 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1183,8 +1183,6 @@ void cache_random_seq_destroy(struct kmem_cache *cachep)
 }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
-#ifdef CONFIG_SLABINFO
-
 #ifdef CONFIG_SLAB
 #define SLABINFO_RIGHTS (S_IWUSR | S_IRUSR)
 #else
@@ -1354,7 +1352,6 @@ static int __init slab_proc_init(void)
 	return 0;
 }
 module_init(slab_proc_init);
-#endif /* CONFIG_SLABINFO */
 
 static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 					   gfp_t flags)
diff --git a/mm/slub.c b/mm/slub.c
index 163352c..74a8776 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5851,7 +5851,6 @@ static int __init slab_sysfs_init(void)
 /*
  * The /proc/slabinfo ABI
  */
-#ifdef CONFIG_SLABINFO
 void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 {
 	unsigned long nr_slabs = 0;
@@ -5883,4 +5882,3 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 {
 	return -EIO;
 }
-#endif /* CONFIG_SLABINFO */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
