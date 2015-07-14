Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 736EF6B0256
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 09:17:10 -0400 (EDT)
Received: by lbbpo10 with SMTP id po10so5930111lbb.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 06:17:09 -0700 (PDT)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id e3si905562laa.104.2015.07.14.06.17.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 06:17:08 -0700 (PDT)
Subject: [PATCH 2/2] mm/slub: disable merging after enabling debug in runtime
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 14 Jul 2015 16:17:05 +0300
Message-ID: <20150714131705.21442.99279.stgit@buzz>
In-Reply-To: <20150714131704.21442.17939.stgit@buzz>
References: <20150714131704.21442.17939.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

Enabling debug in runtime breaks creation of new kmem caches:
they have incompatible flags thus cannot be merged but unique
names are taken by existing caches.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/slab.h        |    2 ++
 mm/slab_common.c |    2 +-
 mm/slub.c        |    9 ++++++++-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 8da63e4e470f..c8998f1d270f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -66,6 +66,8 @@ extern struct list_head slab_caches;
 /* The slab cache that manages slab cache information */
 extern struct kmem_cache *kmem_cache;
 
+extern int slab_nomerge;
+
 unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align, unsigned long size);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3e5f8f29c286..eae96f0e7f29 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -44,7 +44,7 @@ struct kmem_cache *kmem_cache;
  * Merge control. If this is set then no merging of slab caches will occur.
  * (Could be removed. This was introduced to pacify the merge skeptics.)
  */
-static int slab_nomerge;
+int slab_nomerge __read_mostly;
 
 static int __init setup_slab_nomerge(char *str)
 {
diff --git a/mm/slub.c b/mm/slub.c
index 4497cae6a914..94300ced4c96 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4610,6 +4610,7 @@ static ssize_t sanity_checks_store(struct kmem_cache *s,
 	if (buf[0] == '1') {
 		s->flags &= ~__CMPXCHG_DOUBLE;
 		s->flags |= SLAB_DEBUG_FREE;
+		slab_nomerge = 1;
 	}
 	return length;
 }
@@ -4635,6 +4636,7 @@ static ssize_t trace_store(struct kmem_cache *s, const char *buf,
 	if (buf[0] == '1') {
 		s->flags &= ~__CMPXCHG_DOUBLE;
 		s->flags |= SLAB_TRACE;
+		slab_nomerge = 1;
 	}
 	return length;
 }
@@ -4655,6 +4657,7 @@ static ssize_t red_zone_store(struct kmem_cache *s,
 	if (buf[0] == '1') {
 		s->flags &= ~__CMPXCHG_DOUBLE;
 		s->flags |= SLAB_RED_ZONE;
+		slab_nomerge = 1;
 	}
 	calculate_sizes(s, -1);
 	return length;
@@ -4676,6 +4679,7 @@ static ssize_t poison_store(struct kmem_cache *s,
 	if (buf[0] == '1') {
 		s->flags &= ~__CMPXCHG_DOUBLE;
 		s->flags |= SLAB_POISON;
+		slab_nomerge = 1;
 	}
 	calculate_sizes(s, -1);
 	return length;
@@ -4697,6 +4701,7 @@ static ssize_t store_user_store(struct kmem_cache *s,
 	if (buf[0] == '1') {
 		s->flags &= ~__CMPXCHG_DOUBLE;
 		s->flags |= SLAB_STORE_USER;
+		slab_nomerge = 1;
 	}
 	calculate_sizes(s, -1);
 	return length;
@@ -4752,8 +4757,10 @@ static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
 		return -EINVAL;
 
 	s->flags &= ~SLAB_FAILSLAB;
-	if (buf[0] == '1')
+	if (buf[0] == '1') {
 		s->flags |= SLAB_FAILSLAB;
+		slab_nomerge = 1;
+	}
 	return length;
 }
 SLAB_ATTR(failslab);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
