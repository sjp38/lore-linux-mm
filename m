Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 08DD96B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 04:47:17 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so8873732pde.7
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 01:47:17 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id ht5si11230415pbc.46.2013.12.27.01.47.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 01:47:16 -0800 (PST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 27 Dec 2013 15:17:09 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 1D6FBE0053
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 15:19:42 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBR9l2I757737266
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 15:17:03 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBR9l5UQ023798
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 15:17:05 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH] mm/slub: fix accumulate per cpu partial cache objects
Date: Fri, 27 Dec 2013 17:46:59 +0800
Message-Id: <1388137619-14741-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

SLUB per cpu partial cache is a list of slab caches to accelerate objects 
allocation. However, current codes just accumulate the objects number of 
the first slab cache of per cpu partial cache instead of traverse the whole 
list.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slub.c |   32 +++++++++++++++++++++++---------
 1 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 545a170..799bfdc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4280,7 +4280,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab,
 							       cpu);
 			int node;
-			struct page *page;
+			struct page *page, *p;
 
 			page = ACCESS_ONCE(c->page);
 			if (!page)
@@ -4298,8 +4298,9 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			nodes[node] += x;
 
 			page = ACCESS_ONCE(c->partial);
-			if (page) {
-				x = page->pobjects;
+			while ((p = page)) {
+				page = p->next;
+				x = p->pobjects;
 				total += x;
 				nodes[node] += x;
 			}
@@ -4520,13 +4521,15 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 	int pages = 0;
 	int cpu;
 	int len;
+	struct page *p;
 
 	for_each_online_cpu(cpu) {
 		struct page *page = per_cpu_ptr(s->cpu_slab, cpu)->partial;
 
-		if (page) {
-			pages += page->pages;
-			objects += page->pobjects;
+		while ((p = page)) {
+			page = p->next;
+			pages += p->pages;
+			objects += p->pobjects;
 		}
 	}
 
@@ -4535,10 +4538,21 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 #ifdef CONFIG_SMP
 	for_each_online_cpu(cpu) {
 		struct page *page = per_cpu_ptr(s->cpu_slab, cpu) ->partial;
+		objects = 0;
+		pages = 0;
+
+		if (!page)
+			continue;
+
+		while ((p = page)) {
+			page = p->next;
+			pages += p->pages;
+			objects += p->pobjects;
+		}
 
-		if (page && len < PAGE_SIZE - 20)
-			len += sprintf(buf + len, " C%d=%d(%d)", cpu,
-				page->pobjects, page->pages);
+		if (len < PAGE_SIZE - 20)
+			len += sprintf(buf + len, " C%d=%d(%d)", cpu,
+				objects, pages);
 	}
 #endif
 	return len + sprintf(buf + len, "\n");
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
