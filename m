From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/3] slob: record page flag overlays explicitly
References: <exportbomb.1211560342@pinky>
Date: Fri, 23 May 2008 17:33:32 +0100
Message-Id: <1211560412.0@pinky>
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
 include/linux/page-flags.h |    7 +++++++
 mm/slob.c                  |   12 ++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index dfd0a26..43b3598 100644
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
@@ -171,6 +175,9 @@ PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)
 
+__PAGEFLAG(SlobPage, slob_page)
+__PAGEFLAG(SlobFree, slob_free)
+
 __PAGEFLAG(SlubFrozen, slub_frozen)
 __PAGEFLAG(SlubDebug, slub_debug)
 
diff --git a/mm/slob.c b/mm/slob.c
index 6038cba..2d18d89 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -130,17 +130,17 @@ static LIST_HEAD(free_slob_large);
  */
 static inline int slob_page(struct slob_page *sp)
 {
-	return test_bit(PG_active, &sp->flags);
+	return PageSlobPage((struct page *)sp);
 }
 
 static inline void set_slob_page(struct slob_page *sp)
 {
-	__set_bit(PG_active, &sp->flags);
+	__SetPageSlobPage((struct page *)sp);
 }
 
 static inline void clear_slob_page(struct slob_page *sp)
 {
-	__clear_bit(PG_active, &sp->flags);
+	__ClearPageSlobPage((struct page *)sp);
 }
 
 /*
@@ -148,19 +148,19 @@ static inline void clear_slob_page(struct slob_page *sp)
  */
 static inline int slob_page_free(struct slob_page *sp)
 {
-	return test_bit(PG_private, &sp->flags);
+	return PageSlobFree((struct page *)sp);
 }
 
 static void set_slob_page_free(struct slob_page *sp, struct list_head *list)
 {
 	list_add(&sp->list, list);
-	__set_bit(PG_private, &sp->flags);
+	__SetPageSlobFree((struct page *)sp);
 }
 
 static inline void clear_slob_page_free(struct slob_page *sp)
 {
 	list_del(&sp->list);
-	__clear_bit(PG_private, &sp->flags);
+	__ClearPageSlobFree((struct page *)sp);
 }
 
 #define SLOB_UNIT sizeof(slob_t)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
