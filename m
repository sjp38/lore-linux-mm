Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4CA66B0253
	for <linux-mm@kvack.org>; Mon, 23 May 2016 06:20:40 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id yu3so250500970obb.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 03:20:40 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0116.outbound.protection.outlook.com. [157.56.112.116])
        by mx.google.com with ESMTPS id d6si14441427oia.39.2016.05.23.03.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 03:20:39 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 1/8] mm: remove pointless struct in struct page definition
Date: Mon, 23 May 2016 13:20:22 +0300
Message-ID: <f34ffe70fce2b0b9220856437f77972d67c14275.1463997354.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1463997354.git.vdavydov@virtuozzo.com>
References: <cover.1463997354.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

... to reduce indentation level thus leaving more space for comments.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/mm_types.h | 68 +++++++++++++++++++++++-------------------------
 1 file changed, 32 insertions(+), 36 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d553855503e6..3cc5977a9cab 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -60,51 +60,47 @@ struct page {
 	};
 
 	/* Second double word */
-	struct {
-		union {
-			pgoff_t index;		/* Our offset within mapping. */
-			void *freelist;		/* sl[aou]b first free object */
-			/* page_deferred_list().prev	-- second tail page */
-		};
+	union {
+		pgoff_t index;		/* Our offset within mapping. */
+		void *freelist;		/* sl[aou]b first free object */
+		/* page_deferred_list().prev	-- second tail page */
+	};
 
-		union {
+	union {
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
 	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-			/* Used for cmpxchg_double in slub */
-			unsigned long counters;
+		/* Used for cmpxchg_double in slub */
+		unsigned long counters;
 #else
-			/*
-			 * Keep _refcount separate from slub cmpxchg_double
-			 * data.  As the rest of the double word is protected by
-			 * slab_lock but _refcount is not.
-			 */
-			unsigned counters;
+		/*
+		 * Keep _refcount separate from slub cmpxchg_double data.
+		 * As the rest of the double word is protected by slab_lock
+		 * but _refcount is not.
+		 */
+		unsigned counters;
 #endif
+		struct {
 
-			struct {
-
-				union {
-					/*
-					 * Count of ptes mapped in mms, to show
-					 * when page is mapped & limit reverse
-					 * map searches.
-					 */
-					atomic_t _mapcount;
-
-					struct { /* SLUB */
-						unsigned inuse:16;
-						unsigned objects:15;
-						unsigned frozen:1;
-					};
-					int units;	/* SLOB */
-				};
+			union {
 				/*
-				 * Usage count, *USE WRAPPER FUNCTION*
-				 * when manual accounting. See page_ref.h
+				 * Count of ptes mapped in mms, to show when
+				 * page is mapped & limit reverse map searches.
 				 */
-				atomic_t _refcount;
+				atomic_t _mapcount;
+
+				unsigned int active;		/* SLAB */
+				struct {			/* SLUB */
+					unsigned inuse:16;
+					unsigned objects:15;
+					unsigned frozen:1;
+				};
+				int units;			/* SLOB */
 			};
-			unsigned int active;	/* SLAB */
+			/*
+			 * Usage count, *USE WRAPPER FUNCTION* when manual
+			 * accounting. See page_ref.h
+			 */
+			atomic_t _refcount;
 		};
 	};
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
