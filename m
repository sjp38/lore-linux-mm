Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8C07B6B0070
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 10:23:51 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so4089383pde.32
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 07:23:51 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id c4si8312082pds.247.2014.10.26.07.23.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Oct 2014 07:23:49 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/2] slab: print slabinfo header in seq show
Date: Sun, 26 Oct 2014 17:23:29 +0300
Message-ID: <21c195b795ce734d413042d3974e4d26ae2dafdf.1414332926.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently we print the slabinfo header in the seq start method, which
makes it unusable for showing leaks, so we have leaks_show, which does
practically the same as s_show except it doesn't show the header.
However, we can print the header in the seq show method - we only need
to check if the current element is the first on the list. This will
allow us to use the same set of seq iterators for both leaks and
slabinfo reporting, which is nice.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.c        |    8 +-------
 mm/slab.h        |    1 +
 mm/slab_common.c |   15 ++++++---------
 3 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 06182bede8ac..458613d75533 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4043,12 +4043,6 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 
-static void *leaks_start(struct seq_file *m, loff_t *pos)
-{
-	mutex_lock(&slab_mutex);
-	return seq_list_start(&slab_caches, *pos);
-}
-
 static inline int add_caller(unsigned long *n, unsigned long v)
 {
 	unsigned long *p;
@@ -4170,7 +4164,7 @@ static int leaks_show(struct seq_file *m, void *p)
 }
 
 static const struct seq_operations slabstats_op = {
-	.start = leaks_start,
+	.start = slab_start,
 	.next = slab_next,
 	.stop = slab_stop,
 	.show = leaks_show,
diff --git a/mm/slab.h b/mm/slab.h
index ab019e63e3c2..53a55c70c409 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -357,6 +357,7 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 
 #endif
 
+void *slab_start(struct seq_file *m, loff_t *pos);
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 406944207b61..d8b266750985 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -830,14 +830,9 @@ void print_slabinfo_header(struct seq_file *m)
 	seq_putc(m, '\n');
 }
 
-static void *s_start(struct seq_file *m, loff_t *pos)
+void *slab_start(struct seq_file *m, loff_t *pos)
 {
-	loff_t n = *pos;
-
 	mutex_lock(&slab_mutex);
-	if (!n)
-		print_slabinfo_header(m);
-
 	return seq_list_start(&slab_caches, *pos);
 }
 
@@ -899,10 +894,12 @@ int cache_show(struct kmem_cache *s, struct seq_file *m)
 	return 0;
 }
 
-static int s_show(struct seq_file *m, void *p)
+static int slab_show(struct seq_file *m, void *p)
 {
 	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
 
+	if (p == slab_caches.next)
+		print_slabinfo_header(m);
 	if (!is_root_cache(s))
 		return 0;
 	return cache_show(s, m);
@@ -922,10 +919,10 @@ static int s_show(struct seq_file *m, void *p)
  * + further values on SMP and with statistics enabled
  */
 static const struct seq_operations slabinfo_op = {
-	.start = s_start,
+	.start = slab_start,
 	.next = slab_next,
 	.stop = slab_stop,
-	.show = s_show,
+	.show = slab_show,
 };
 
 static int slabinfo_open(struct inode *inode, struct file *file)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
