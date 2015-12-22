Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 31CED6B0006
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 22:40:59 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 78so26138290pfw.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:40:59 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id z12si8519221pfa.155.2015.12.21.19.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 19:40:58 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id cy9so27686923pac.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:40:58 -0800 (PST)
From: Laura Abbott <laura@labbott.name>
Subject: [RFC][PATCH 1/7] mm/slab_common.c: Add common support for slab saniziation
Date: Mon, 21 Dec 2015 19:40:35 -0800
Message-Id: <1450755641-7856-2-git-send-email-laura@labbott.name>
In-Reply-To: <1450755641-7856-1-git-send-email-laura@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com


Each of the different allocators (SLAB/SLUB/SLOB) handles
clearing of objects differently depending on configuration.
Add common infrastructure for selecting sanitization levels
(off, slow path only, partial, full) and marking caches as
appropriate.

All credit for the original work should be given to Brad Spengler and
the PaX Team.

Signed-off-by: Laura Abbott <laura@labbott.name>
---
 include/linux/slab.h     |  7 +++++++
 include/linux/slab_def.h |  4 ++++
 mm/slab.h                | 22 ++++++++++++++++++++
 mm/slab_common.c         | 53 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 86 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 2037a86..35c1e2d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -23,6 +23,13 @@
 #define SLAB_DEBUG_FREE		0x00000100UL	/* DEBUG: Perform (expensive) checks on free */
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
+
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+#define SLAB_NO_SANITIZE        0x00001000UL    /* Do not sanitize objs on free */
+#else
+#define SLAB_NO_SANITIZE        0x00000000UL
+#endif
+
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 33d0490..4c3fb93 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -69,6 +69,10 @@ struct kmem_cache {
 	 */
 	int obj_offset;
 #endif /* CONFIG_DEBUG_SLAB */
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+	atomic_t sanitized;
+	atomic_t not_sanitized;
+#endif
 #ifdef CONFIG_MEMCG_KMEM
 	struct memcg_cache_params memcg_params;
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index 7b60871..b54b636 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -66,6 +66,28 @@ extern struct list_head slab_caches;
 /* The slab cache that manages slab cache information */
 extern struct kmem_cache *kmem_cache;
 
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+#ifdef CONFIG_X86_64
+#define SLAB_MEMORY_SANITIZE_VALUE       '\xfe'
+#else
+#define SLAB_MEMORY_SANITIZE_VALUE       '\xff'
+#endif
+enum slab_sanitize_mode {
+	/* No sanitization */
+	SLAB_SANITIZE_OFF = 0,
+
+	/* Partial sanitization happens only on the slow path */
+	SLAB_SANITIZE_PARTIAL_SLOWPATH = 1,
+
+	/* Partial sanitization happens everywhere */
+	SLAB_SANITIZE_PARTIAL = 2,
+
+	/* Sanitization happens on all slabs, all paths */
+	SLAB_SANITIZE_FULL = 3,
+};
+extern enum slab_sanitize_mode sanitize_slab;
+#endif
+
 unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align, unsigned long size);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3c6a86b..4b28f70 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -30,6 +30,42 @@ LIST_HEAD(slab_caches);
 DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;
 
+
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+enum slab_sanitize_mode sanitize_slab = SLAB_SANITIZE_PARTIAL;
+static int __init sanitize_slab_setup(char *str)
+{
+	if (!str)
+		return 0;
+
+	if (!strcmp(str, "0") || !strcmp(str, "off")) {
+		pr_info("slab sanitization disabled");
+		sanitize_slab = SLAB_SANITIZE_OFF;
+	} else if (!strcmp(str, "1") || !strcmp(str, "slow")) {
+		pr_info("slab sanitization partial slow path");
+		sanitize_slab = SLAB_SANITIZE_PARTIAL_SLOWPATH;
+	} else if (!strcmp(str, "2") || !strcmp(str, "partial")) {
+		pr_info("slab sanitization partial");
+		sanitize_slab = SLAB_SANITIZE_PARTIAL;
+	} else if (!strcmp(str, "3") || !strcmp(str, "full")) {
+		pr_info("slab sanitization full");
+		sanitize_slab = SLAB_SANITIZE_FULL;
+	} else
+		pr_err("slab sanitization: unsupported option '%s'\n", str);
+
+	return 0;
+}
+early_param("sanitize_slab", sanitize_slab_setup);
+
+static inline bool sanitize_mergeable(unsigned long flags)
+{
+	return (sanitize_slab == SLAB_SANITIZE_OFF) || (flags & SLAB_NO_SANITIZE);
+}
+#else
+static inline bool sanitize_mergeable(unsigned long flags) { return true; }
+#endif
+
+
 /*
  * Set of flags that will prevent slab merging
  */
@@ -227,6 +263,9 @@ static inline void destroy_memcg_params(struct kmem_cache *s)
  */
 int slab_unmergeable(struct kmem_cache *s)
 {
+	if (!sanitize_mergeable(s->flags))
+		return 1;
+
 	if (slab_nomerge || (s->flags & SLAB_NEVER_MERGE))
 		return 1;
 
@@ -250,6 +289,9 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
 {
 	struct kmem_cache *s;
 
+	if (!sanitize_mergeable(flags))
+		return NULL;
+
 	if (slab_nomerge || (flags & SLAB_NEVER_MERGE))
 		return NULL;
 
@@ -407,6 +449,13 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 	 */
 	flags &= CACHE_CREATE_MASK;
 
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+	if (sanitize_slab == SLAB_SANITIZE_OFF || (flags & SLAB_DESTROY_BY_RCU))
+		flags |= SLAB_NO_SANITIZE;
+	else if (sanitize_slab == SLAB_SANITIZE_FULL)
+		flags &= ~SLAB_NO_SANITIZE;
+#endif
+
 	s = __kmem_cache_alias(name, size, align, flags, ctor);
 	if (s)
 		goto out_unlock;
@@ -1050,6 +1099,10 @@ static void print_slabinfo_header(struct seq_file *m)
 		 "<error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
 	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
 #endif
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+	seq_puts(m, " : sanitization <sanitized> <not_sanitized>");
+#endif
+
 	seq_putc(m, '\n');
 }
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
