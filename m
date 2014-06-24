Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id A036A6B006E
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 04:09:36 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so6931573pbc.12
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 01:09:36 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id e10si25181581pat.80.2014.06.24.01.09.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 01:09:35 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 24 Jun 2014 18:09:32 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 6F1A42BB0047
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:09:29 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5O7lCY212714390
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 17:47:12 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5O89SeN012715
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:09:28 +1000
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] slub: reduce duplicate creation on the first object
Date: Tue, 24 Jun 2014 16:08:55 +0800
Message-Id: <1403597335-5465-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: clameter@sgi.com, cl@linux.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>

When a kmem_cache is created with ctor, each object in the kmem_cache will be
initialized before ready to use. While in slub implementation, the first
object will be initialized twice.

This patch reduces the duplication of initialization of the first object.

Fix commit 7656c72b: SLUB: add macros for scanning objects in a slab.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index b2b0473..beefd45 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1433,7 +1433,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		memset(start, POISON_INUSE, PAGE_SIZE << order);
 
 	last = start;
-	for_each_object(p, s, start, page->objects) {
+	for_each_object(p, s, start + s->size, page->objects - 1) {
 		setup_object(s, page, last);
 		set_freepointer(s, last, p);
 		last = p;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
