Subject: [PATCH] slub: reduce total stack usage of slab_err & object_err
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain
Date: Tue, 30 Sep 2008 16:15:36 +0100
Message-Id: <1222787736.2995.24.camel@castor.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, penberg <penberg@cs.helsinki.fi>, mpm <mpm@selenic.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

reduce the total stack usage of slab_err & object_err.

Introduce a new function to display a simple slab bug message, and call
this when vprintk is not needed.

before: (stack size as reported by checkstack on x86_64)
	slab_err/object_err -> slab_bug(328)->printk
after:
	slab_err/object_err -> slab_bug_message(8) -> printk

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>

----
I've been trying to build a tool to estimate the maximum stack usage in
the kernel, & noticed that most of the biggest stack users are the error
handling routines.
This simple change will reduced the stack used handling some slub errors
on both 64 & 32 bit platforms, although I haven't measured it on 32 bit
it will save at least 100 bytes. 
I haven't spotted anywhere that overflows the stack but this change
should reduce the chance of it happening.

It boots & run successfully on my AMD x86_64 desktop -- but I haven't
seen any slub errors so the new code hasn't been run.

regards
Richard


diff --git a/mm/slub.c b/mm/slub.c
index 0c83e6a..0646452 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -419,6 +419,15 @@ static void print_page_info(struct page *page)
 
 }
 
+static void slab_bug_message(struct kmem_cache *s, char *msg)
+{
+	printk(KERN_ERR "========================================"
+			"=====================================\n");
+	printk(KERN_ERR "BUG %s: %s\n", s->name, msg);
+	printk(KERN_ERR "----------------------------------------"
+			"-------------------------------------\n\n");
+}
+
 static void slab_bug(struct kmem_cache *s, char *fmt, ...)
 {
 	va_list args;
@@ -427,11 +436,7 @@ static void slab_bug(struct kmem_cache *s, char *fmt, ...)
 	va_start(args, fmt);
 	vsnprintf(buf, sizeof(buf), fmt, args);
 	va_end(args);
-	printk(KERN_ERR "========================================"
-			"=====================================\n");
-	printk(KERN_ERR "BUG %s: %s\n", s->name, buf);
-	printk(KERN_ERR "----------------------------------------"
-			"-------------------------------------\n\n");
+	slab_bug_message(s, buf);
 }
 
 static void slab_fix(struct kmem_cache *s, char *fmt, ...)
@@ -484,7 +489,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 static void object_err(struct kmem_cache *s, struct page *page,
 			u8 *object, char *reason)
 {
-	slab_bug(s, "%s", reason);
+	slab_bug_message(s, reason);
 	print_trailer(s, page, object);
 }
 
@@ -496,7 +501,7 @@ static void slab_err(struct kmem_cache *s, struct page *page, char *fmt, ...)
 	va_start(args, fmt);
 	vsnprintf(buf, sizeof(buf), fmt, args);
 	va_end(args);
-	slab_bug(s, "%s", buf);
+	slab_bug_message(s, buf);
 	print_page_info(page);
 	dump_stack();
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
