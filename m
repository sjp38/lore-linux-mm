From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/3] slob: record page flag overlays explicitly
References: <exportbomb.1210871946@pinky>
Date: Thu, 15 May 2008 18:20:10 +0100
Message-Id: <1210872010.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

SLOB reuses two page bits for internal purposes, it overlays PG_active
and PG_private.  This is hidden away in slob.c.  Document these overlays
explicitly in the main page-flags enum along with all the others.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 include/linux/page-flags.h |    4 ++++
 mm/slob.c                  |   12 ++++++------
 2 files changed, 10 insertions(+), 6 deletions(-)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 2e88df6..71aec98 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -104,6 +104,10 @@ enum pageflags {
 	/* XEN */
 	PG_pinned = PG_owner_priv_1,
 
+	/* SLOB */
+	PG_slob_page = PG_active,
+	PG_slob_free = PG_private,
+
 	/* SLUB */
 	PG_slub_frozen = PG_active,
 	PG_slub_debug = PG_error,
diff --git a/mm/slob.c b/mm/slob.c
index 6038cba..9bc3147 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -130,17 +130,17 @@ static LIST_HEAD(free_slob_large);
  */
 static inline int slob_page(struct slob_page *sp)
 {
-	return test_bit(PG_active, &sp->flags);
+	return test_bit(PG_slob_page, &sp->flags);
 }
 
 static inline void set_slob_page(struct slob_page *sp)
 {
-	__set_bit(PG_active, &sp->flags);
+	__set_bit(PG_slob_page, &sp->flags);
 }
 
 static inline void clear_slob_page(struct slob_page *sp)
 {
-	__clear_bit(PG_active, &sp->flags);
+	__clear_bit(PG_slob_free, &sp->flags);
 }
 
 /*
@@ -148,19 +148,19 @@ static inline void clear_slob_page(struct slob_page *sp)
  */
 static inline int slob_page_free(struct slob_page *sp)
 {
-	return test_bit(PG_private, &sp->flags);
+	return test_bit(PG_slob_free, &sp->flags);
 }
 
 static void set_slob_page_free(struct slob_page *sp, struct list_head *list)
 {
 	list_add(&sp->list, list);
-	__set_bit(PG_private, &sp->flags);
+	__set_bit(PG_slob_free, &sp->flags);
 }
 
 static inline void clear_slob_page_free(struct slob_page *sp)
 {
 	list_del(&sp->list);
-	__clear_bit(PG_private, &sp->flags);
+	__clear_bit(PG_slob_free, &sp->flags);
 }
 
 #define SLOB_UNIT sizeof(slob_t)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
