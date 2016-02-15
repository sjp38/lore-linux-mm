Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id C3632828DF
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 13:44:37 -0500 (EST)
Received: by mail-qk0-f180.google.com with SMTP id x1so58190794qkc.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 10:44:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j7si35596205qgf.83.2016.02.15.10.44.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 10:44:37 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv2 4/4] slub: Relax CMPXCHG consistency restrictions
Date: Mon, 15 Feb 2016 10:44:24 -0800
Message-Id: <1455561864-4217-5-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>


When debug options are enabled, cmpxchg on the page is disabled. This is
because the page must be locked to ensure there are no false positives
when performing consistency checks. Some debug options such as poisoning
and red zoning only act on the object itself. There is no need to
protect other CPUs from modification on only the object. Allow cmpxchg
to happen with poisoning and red zoning are set on a slab.

Credit to Mathias Krause for the original work which inspired this series

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
 mm/slub.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 01606ff..0323e53 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -164,6 +164,14 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 				SLAB_POISON | SLAB_STORE_USER)
 
 /*
+ * These debug flags cannot use CMPXCHG because there might be consistency
+ * issues when checking or reading debug information
+ */
+#define SLAB_NO_CMPXCHG (SLAB_CONSISTENCY_CHECKS | SLAB_STORE_USER | \
+				SLAB_TRACE)
+
+
+/*
  * Debugging flags that require metadata to be stored in the slab.  These get
  * disabled when slub_debug=O is used and a cache's min order increases with
  * metadata.
@@ -3377,7 +3385,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-	if (system_has_cmpxchg_double() && (s->flags & SLAB_DEBUG_FLAGS) == 0)
+	if (system_has_cmpxchg_double() && (s->flags & SLAB_NO_CMPXCHG) == 0)
 		/* Enable fast mode */
 		s->flags |= __CMPXCHG_DOUBLE;
 #endif
@@ -4889,7 +4897,6 @@ static ssize_t red_zone_store(struct kmem_cache *s,
 
 	s->flags &= ~SLAB_RED_ZONE;
 	if (buf[0] == '1') {
-		s->flags &= ~__CMPXCHG_DOUBLE;
 		s->flags |= SLAB_RED_ZONE;
 	}
 	calculate_sizes(s, -1);
@@ -4910,7 +4917,6 @@ static ssize_t poison_store(struct kmem_cache *s,
 
 	s->flags &= ~SLAB_POISON;
 	if (buf[0] == '1') {
-		s->flags &= ~__CMPXCHG_DOUBLE;
 		s->flags |= SLAB_POISON;
 	}
 	calculate_sizes(s, -1);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
