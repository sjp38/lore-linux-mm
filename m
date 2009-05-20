Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4D2F06B0089
	for <linux-mm@kvack.org>; Wed, 20 May 2009 13:24:58 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH] mm/slub.c: Use print_hex_dump and remove unnecessary cast
Date: Wed, 20 May 2009 10:25:13 -0700
Message-Id: <1242840314-25635-1-git-send-email-joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: H Hartley Sweeten <hartleys@visionengravers.com>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, David Rientjes <rientjes@google.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/slub.c |   34 ++++------------------------------
 1 files changed, 4 insertions(+), 30 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 65ffda5..5b616d6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -328,36 +328,10 @@ static char *slub_debug_slabs;
 /*
  * Object debugging
  */
-static void print_section(char *text, u8 *addr, unsigned int length)
+static void print_section(const char *text, u8 *addr, unsigned int length)
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
@@ -794,7 +768,7 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
 			page->freelist);
 
 		if (!alloc)
-			print_section("Object", (void *)object, s->objsize);
+			print_section("Object", object, s->objsize);
 
 		dump_stack();
 	}
-- 
1.6.3.1.10.g659a0.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
