Message-ID: <1167153681.45915a11a02fb@imp3-g19.free.fr>
Date: Tue, 26 Dec 2006 18:21:21 +0100
From: dimitri.gorokhovik@free.fr
Subject: [PATCH 1/1 2.6.20-rc2] MM: SLOB is broken by recent cleanup of slab.h
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
From: Dimitri Gorokhovik <dimitri.gorokhovik@free.fr>
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com, linux-mm@kvack.org
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Recent cleanup of slab.h broke SLOB allocator: the routine kmem_cache_init
has now the __init attribute for both slab.c and slob.c. This routine cannot
be removed after init in the case of slob.c -- it serves as a timer callback.

Provide a separate timer callback routine, call it once from kmem_cache_init,
keep the __init attribute on the latter.

Signed-off-by: Dimitri Gorokhovik <dimitri.gorokhovik@free.fr>

---

--- linux-2.6.20-rc2-orig/mm/slob.c	2006-12-26 15:12:21.000000000 +0100
+++ linux-2.6.20-rc2/mm/slob.c	2006-12-26 18:02:28.000000000 +0100
@@ -60,6 +60,8 @@ static DEFINE_SPINLOCK(slob_lock);
 static DEFINE_SPINLOCK(block_lock);

 static void slob_free(void *b, int size);
+static void slob_timer_cbk(void);
+

 static void *slob_alloc(size_t size, gfp_t gfp, int align)
 {
@@ -326,7 +328,7 @@ const char *kmem_cache_name(struct kmem_
 EXPORT_SYMBOL(kmem_cache_name);

 static struct timer_list slob_timer = TIMER_INITIALIZER(
-	(void (*)(unsigned long))kmem_cache_init, 0, 0);
+	(void (*)(unsigned long))slob_timer_cbk, 0, 0);

 int kmem_cache_shrink(struct kmem_cache *d)
 {
@@ -339,7 +341,12 @@ int kmem_ptr_validate(struct kmem_cache
 	return 0;
 }

-void kmem_cache_init(void)
+void __init kmem_cache_init(void)
+{
+	slob_timer_cbk();
+}
+
+static void slob_timer_cbk(void)
 {
 	void *p = slob_alloc(PAGE_SIZE, 0, PAGE_SIZE-1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
