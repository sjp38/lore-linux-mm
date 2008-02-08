Subject: [PATCH] mm/slub.c - Use print_hex_dump
From: Joe Perches <joe@perches.com>
Content-Type: text/plain
Date: Fri, 08 Feb 2008 10:03:28 -0800
Message-Id: <1202493808.27394.76.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Use the library function to dump memory

old:
$ size mm/slub.o
   text    data     bss     dec     hex filename
  16165    5782      80   22027    560b mm/slub.o


new:
$ size mm/slub.o
   text    data     bss     dec     hex filename
  15990    5782      80   21852    555c mm/slub.o

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/mm/slub.c b/mm/slub.c
index e2989ae..5f1a5e5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -378,36 +378,10 @@ static char *slub_debug_slabs;
 /*
  * Object debugging
  */
-static void print_section(char *text, u8 *addr, unsigned int length)
+static void print_section(const char *text, const u8 *addr, size_t length)
 {
-	int i, offset;
-	int newline = 1;
-	char ascii[17];
-
-	ascii[16] = 0;
-
-	for (i = 0; i < length; i++) {
-		if (newline) {
-			printk(KERN_ERR "%8s 0x%p: ", text, addr + i);
-			newline = 0;
-		}
-		printk(KERN_CONT " %02x", addr[i]);
-		offset = i % 16;
-		ascii[offset] = isgraph(addr[i]) ? addr[i] : '.';
-		if (offset == 15) {
-			printk(KERN_CONT " %s\n", ascii);
-			newline = 1;
-		}
-	}
-	if (!newline) {
-		i %= 16;
-		while (i < 16) {
-			printk(KERN_CONT "   ");
-			ascii[i] = ' ';
-			i++;
-		}
-		printk(KERN_CONT " %s\n", ascii);
-	}
+	print_hex_dump(KERN_ERR, text, DUMP_PREFIX_ADDRESS, 16, 1,
+		       addr, length, true);
 }
 
 static struct track *get_track(struct kmem_cache *s, void *object,
@@ -517,12 +491,12 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 			p, p - addr, get_freepointer(s, p));
 
 	if (p > addr + 16)
-		print_section("Bytes b4", p - 16, 16);
+		print_section("Bytes b4: ", p - 16, 16);
 
-	print_section("Object", p, min(s->objsize, 128));
+	print_section("Object:   ", p, min(s->objsize, 128));
 
 	if (s->flags & SLAB_RED_ZONE)
-		print_section("Redzone", p + s->objsize,
+		print_section("Redzone:  ", p + s->objsize,
 			s->inuse - s->objsize);
 
 	if (s->offset)
@@ -535,7 +509,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 
 	if (off != s->size)
 		/* Beginning of the filler is the free pointer */
-		print_section("Padding", p + off, s->size - off);
+		print_section("Padding: ", p + off, s->size - off);
 
 	dump_stack();
 }
@@ -699,7 +673,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		end--;
 
 	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
-	print_section("Padding", start, length);
+	print_section("Padding: ", start, length);
 
 	restore_bytes(s, "slab padding", POISON_INUSE, start, end);
 	return 0;
@@ -829,7 +803,7 @@ static void trace(struct kmem_cache *s, struct page *page, void *object, int all
 			page->freelist);
 
 		if (!alloc)
-			print_section("Object", (void *)object, s->objsize);
+			print_section("Object: ", (void *)object, s->objsize);
 
 		dump_stack();
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
