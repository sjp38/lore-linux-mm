Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D19896B016A
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 08:11:00 -0400 (EDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/2] mm/slub: use print_hex_dump
Date: Fri, 29 Jul 2011 14:10:20 +0200
Message-Id: <1311941420-2463-2-git-send-email-bigeasy@linutronix.de>
In-Reply-To: <1311941420-2463-1-git-send-email-bigeasy@linutronix.de>
References: <1311941420-2463-1-git-send-email-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

less code and same functionality. The output would be:

| Object c7428000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
| Object c7428010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
| Object c7428020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
| Object c7428030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5              kkkkkkkkkkk.
| Redzone c742803c: bb bb bb bb                                      ....
| Padding c7428064: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
| Padding c7428074: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a              ZZZZZZZZZZZZ

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/slub.c |   44 +++++++++-----------------------------------
 1 files changed, 9 insertions(+), 35 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 35f351f..0e11a8a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -371,34 +371,8 @@ static int disable_higher_order_debug;
  */
 static void print_section(char *text, u8 *addr, unsigned int length)
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
+	print_hex_dump(KERN_ERR, text, DUMP_PREFIX_ADDRESS, 16, 1, addr,
+			length, 1);
 }
 
 static struct track *get_track(struct kmem_cache *s, void *object,
@@ -501,12 +475,12 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 			p, p - addr, get_freepointer(s, p));
 
 	if (p > addr + 16)
-		print_section("Bytes b4", p - 16, 16);
-
-	print_section("Object", p, min_t(unsigned long, s->objsize, PAGE_SIZE));
+		print_section("Bytes b4 ", p - 16, 16);
 
+	print_section("Object ", p, min_t(unsigned long, s->objsize,
+				PAGE_SIZE));
 	if (s->flags & SLAB_RED_ZONE)
-		print_section("Redzone", p + s->objsize,
+		print_section("Redzone ", p + s->objsize,
 			s->inuse - s->objsize);
 
 	if (s->offset)
@@ -519,7 +493,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 
 	if (off != s->size)
 		/* Beginning of the filler is the free pointer */
-		print_section("Padding", p + off, s->size - off);
+		print_section("Padding ", p + off, s->size - off);
 
 	dump_stack();
 }
@@ -682,7 +656,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		end--;
 
 	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
-	print_section("Padding", end - remainder, remainder);
+	print_section("Padding ", end - remainder, remainder);
 
 	restore_bytes(s, "slab padding", POISON_INUSE, end - remainder, end);
 	return 0;
@@ -830,7 +804,7 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
 			page->freelist);
 
 		if (!alloc)
-			print_section("Object", (void *)object, s->objsize);
+			print_section("Object ", (void *)object, s->objsize);
 
 		dump_stack();
 	}
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
