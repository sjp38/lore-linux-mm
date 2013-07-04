Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 40F426B0036
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 20:33:44 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 4 Jul 2013 10:23:55 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 053132BB0051
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 10:33:34 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r640IYNY62259378
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 10:18:34 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r640XXne018611
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 10:33:33 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 2/5] mm/slab: Sharing s_next and s_stop between slab and slub
Date: Thu,  4 Jul 2013 08:33:23 +0800
Message-Id: <1372898006-6308-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1372898006-6308-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1372898006-6308-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

This patch shares s_next and s_stop between slab and slub.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slab.c        | 10 ----------
 mm/slab.h        |  3 +++
 mm/slab_common.c |  4 ++--
 3 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3002771..59c78b1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4436,16 +4436,6 @@ static int leaks_show(struct seq_file *m, void *p)
 	return 0;
 }
 
-static void *s_next(struct seq_file *m, void *p, loff_t *pos)
-{
-	return seq_list_next(p, &slab_caches, pos);
-}
-
-static void s_stop(struct seq_file *m, void *p)
-{
-	mutex_unlock(&slab_mutex);
-}
-
 static const struct seq_operations slabstats_op = {
 	.start = leaks_start,
 	.next = s_next,
diff --git a/mm/slab.h b/mm/slab.h
index f96b49e..95c8860 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -271,3 +271,6 @@ struct kmem_cache_node {
 #endif
 
 };
+
+void *s_next(struct seq_file *m, void *p, loff_t *pos);
+void s_stop(struct seq_file *m, void *p);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2d41450..d161b81 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -531,12 +531,12 @@ static void *s_start(struct seq_file *m, loff_t *pos)
 	return seq_list_start(&slab_caches, *pos);
 }
 
-static void *s_next(struct seq_file *m, void *p, loff_t *pos)
+void *s_next(struct seq_file *m, void *p, loff_t *pos)
 {
 	return seq_list_next(p, &slab_caches, pos);
 }
 
-static void s_stop(struct seq_file *m, void *p)
+void s_stop(struct seq_file *m, void *p)
 {
 	mutex_unlock(&slab_mutex);
 }
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
