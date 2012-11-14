Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 959F76B00B8
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:12:43 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 01/11] zcache: Provide accessory functions for counter increase
Date: Wed, 14 Nov 2012 14:12:09 -0500
Message-Id: <1352920339-10183-2-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
References: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

This is the first step in moving the debugfs code out of the
main file in-to another file. And will also allow the code to
run without CONFIG_DEBUG_FS set.

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |  103 ++++++++++++++++++++++-----------
 1 files changed, 68 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index b5c811e..24adcbd 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -137,32 +137,88 @@ static DEFINE_PER_CPU(struct zcache_preload, zcache_preloads) = { 0, };
 static long zcache_obj_count;
 static atomic_t zcache_obj_atomic = ATOMIC_INIT(0);
 static long zcache_obj_count_max;
+static inline void inc_zcache_obj_count(void)
+{
+	zcache_obj_count = atomic_inc_return(&zcache_obj_atomic);
+	if (zcache_obj_count > zcache_obj_count_max)
+		zcache_obj_count_max = zcache_obj_count;
+}
+
 static long zcache_objnode_count;
 static atomic_t zcache_objnode_atomic = ATOMIC_INIT(0);
 static long zcache_objnode_count_max;
+static inline void inc_zcache_objnode_count(void)
+{
+	zcache_objnode_count = atomic_inc_return(&zcache_objnode_atomic);
+	if (zcache_objnode_count > zcache_objnode_count_max)
+		zcache_objnode_count_max = zcache_objnode_count;
+};
 static u64 zcache_eph_zbytes;
 static atomic_long_t zcache_eph_zbytes_atomic = ATOMIC_INIT(0);
 static u64 zcache_eph_zbytes_max;
+static inline void inc_zcache_eph_zbytes(unsigned clen)
+{
+	zcache_eph_zbytes = atomic_long_add_return(clen, &zcache_eph_zbytes_atomic);
+	if (zcache_eph_zbytes > zcache_eph_zbytes_max)
+		zcache_eph_zbytes_max = zcache_eph_zbytes;
+};
 static u64 zcache_pers_zbytes;
 static atomic_long_t zcache_pers_zbytes_atomic = ATOMIC_INIT(0);
 static u64 zcache_pers_zbytes_max;
+static inline void inc_zcache_pers_zbytes(unsigned clen)
+{
+	zcache_pers_zbytes = atomic_long_add_return(clen, &zcache_pers_zbytes_atomic);
+	if (zcache_pers_zbytes > zcache_pers_zbytes_max)
+		zcache_pers_zbytes_max = zcache_pers_zbytes;
+}
 static long zcache_eph_pageframes;
 static atomic_t zcache_eph_pageframes_atomic = ATOMIC_INIT(0);
 static long zcache_eph_pageframes_max;
+static inline void inc_zcache_eph_pageframes(void)
+{
+	zcache_eph_pageframes = atomic_inc_return(&zcache_eph_pageframes_atomic);
+	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
+		zcache_eph_pageframes_max = zcache_eph_pageframes;
+};
 static long zcache_pers_pageframes;
 static atomic_t zcache_pers_pageframes_atomic = ATOMIC_INIT(0);
 static long zcache_pers_pageframes_max;
+static inline void inc_zcache_pers_pageframes(void)
+{
+	zcache_pers_pageframes = atomic_inc_return(&zcache_pers_pageframes_atomic);
+	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
+		zcache_pers_pageframes_max = zcache_pers_pageframes;
+}
 static long zcache_pageframes_alloced;
 static atomic_t zcache_pageframes_alloced_atomic = ATOMIC_INIT(0);
+static inline void inc_zcache_pageframes_alloced(void)
+{
+	zcache_pageframes_alloced = atomic_inc_return(&zcache_pageframes_alloced_atomic);
+};
 static long zcache_pageframes_freed;
 static atomic_t zcache_pageframes_freed_atomic = ATOMIC_INIT(0);
+static inline void inc_zcache_pageframes_freed(void)
+{
+	zcache_pageframes_freed = atomic_inc_return(&zcache_pageframes_freed_atomic);
+}
 static long zcache_eph_zpages;
 static atomic_t zcache_eph_zpages_atomic = ATOMIC_INIT(0);
 static long zcache_eph_zpages_max;
+static inline void inc_zcache_eph_zpages(void)
+{
+	zcache_eph_zpages = atomic_inc_return(&zcache_eph_zpages_atomic);
+	if (zcache_eph_zpages > zcache_eph_zpages_max)
+		zcache_eph_zpages_max = zcache_eph_zpages;
+}
 static long zcache_pers_zpages;
 static atomic_t zcache_pers_zpages_atomic = ATOMIC_INIT(0);
 static long zcache_pers_zpages_max;
-
+static inline void inc_zcache_pers_zpages(void)
+{
+	zcache_pers_zpages = atomic_inc_return(&zcache_pers_zpages_atomic);
+	if (zcache_pers_zpages > zcache_pers_zpages_max)
+		zcache_pers_zpages_max = zcache_pers_zpages;
+}
 /* but for the rest of these, counting races are ok */
 static unsigned long zcache_flush_total;
 static unsigned long zcache_flush_found;
@@ -400,9 +456,7 @@ static struct tmem_objnode *zcache_objnode_alloc(struct tmem_pool *pool)
 		}
 	}
 	BUG_ON(objnode == NULL);
-	zcache_objnode_count = atomic_inc_return(&zcache_objnode_atomic);
-	if (zcache_objnode_count > zcache_objnode_count_max)
-		zcache_objnode_count_max = zcache_objnode_count;
+	inc_zcache_objnode_count();
 	return objnode;
 }
 
@@ -424,9 +478,7 @@ static struct tmem_obj *zcache_obj_alloc(struct tmem_pool *pool)
 	obj = kp->obj;
 	BUG_ON(obj == NULL);
 	kp->obj = NULL;
-	zcache_obj_count = atomic_inc_return(&zcache_obj_atomic);
-	if (zcache_obj_count > zcache_obj_count_max)
-		zcache_obj_count_max = zcache_obj_count;
+	inc_zcache_obj_count();
 	return obj;
 }
 
@@ -450,16 +502,14 @@ static struct page *zcache_alloc_page(void)
 	struct page *page = alloc_page(ZCACHE_GFP_MASK);
 
 	if (page != NULL)
-		zcache_pageframes_alloced =
-			atomic_inc_return(&zcache_pageframes_alloced_atomic);
+		inc_zcache_pageframes_alloced();
 	return page;
 }
 
 #ifdef FRONTSWAP_HAS_UNUSE
 static void zcache_unacct_page(void)
 {
-	zcache_pageframes_freed =
-		atomic_inc_return(&zcache_pageframes_freed_atomic);
+	inc_zcache_pageframes_freed();
 }
 #endif
 
@@ -471,8 +521,7 @@ static void zcache_free_page(struct page *page)
 	if (page == NULL)
 		BUG();
 	__free_page(page);
-	zcache_pageframes_freed =
-		atomic_inc_return(&zcache_pageframes_freed_atomic);
+	inc_zcache_pageframes_freed();
 	curr_pageframes = zcache_pageframes_alloced -
 			atomic_read(&zcache_pageframes_freed_atomic) -
 			atomic_read(&zcache_eph_pageframes_atomic) -
@@ -537,19 +586,11 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 create_in_new_page:
 	pampd = (void *)zbud_create_prep(th, true, cdata, clen, newpage);
 	BUG_ON(pampd == NULL);
-	zcache_eph_pageframes =
-		atomic_inc_return(&zcache_eph_pageframes_atomic);
-	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
-		zcache_eph_pageframes_max = zcache_eph_pageframes;
+	inc_zcache_eph_pageframes();
 
 got_pampd:
-	zcache_eph_zbytes =
-		atomic_long_add_return(clen, &zcache_eph_zbytes_atomic);
-	if (zcache_eph_zbytes > zcache_eph_zbytes_max)
-		zcache_eph_zbytes_max = zcache_eph_zbytes;
-	zcache_eph_zpages = atomic_inc_return(&zcache_eph_zpages_atomic);
-	if (zcache_eph_zpages > zcache_eph_zpages_max)
-		zcache_eph_zpages_max = zcache_eph_zpages;
+	inc_zcache_eph_zbytes(clen);
+	inc_zcache_eph_zpages();
 	if (ramster_enabled && raw)
 		ramster_count_foreign_pages(true, 1);
 out:
@@ -619,19 +660,11 @@ create_pampd:
 create_in_new_page:
 	pampd = (void *)zbud_create_prep(th, false, cdata, clen, newpage);
 	BUG_ON(pampd == NULL);
-	zcache_pers_pageframes =
-		atomic_inc_return(&zcache_pers_pageframes_atomic);
-	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
-		zcache_pers_pageframes_max = zcache_pers_pageframes;
+	inc_zcache_pers_pageframes();
 
 got_pampd:
-	zcache_pers_zpages = atomic_inc_return(&zcache_pers_zpages_atomic);
-	if (zcache_pers_zpages > zcache_pers_zpages_max)
-		zcache_pers_zpages_max = zcache_pers_zpages;
-	zcache_pers_zbytes =
-		atomic_long_add_return(clen, &zcache_pers_zbytes_atomic);
-	if (zcache_pers_zbytes > zcache_pers_zbytes_max)
-		zcache_pers_zbytes_max = zcache_pers_zbytes;
+	inc_zcache_pers_zpages();
+	inc_zcache_pers_zbytes(clen);
 	if (ramster_enabled && raw)
 		ramster_count_foreign_pages(false, 1);
 out:
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
