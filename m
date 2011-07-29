Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7E96B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 08:11:00 -0400 (EDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/2] mm/slab: use print_hex_dump
Date: Fri, 29 Jul 2011 14:10:19 +0200
Message-Id: <1311941420-2463-1-git-send-email-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

less code and the advantage of ascii dump.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/slab.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d96e223..63ed525 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1810,15 +1810,15 @@ static void dump_line(char *data, int offset, int limit)
 	unsigned char error = 0;
 	int bad_count = 0;
 
-	printk(KERN_ERR "%03x:", offset);
+	printk(KERN_ERR "%03x: ", offset);
 	for (i = 0; i < limit; i++) {
 		if (data[offset + i] != POISON_FREE) {
 			error = data[offset + i];
 			bad_count++;
 		}
-		printk(" %02x", (unsigned char)data[offset + i]);
 	}
-	printk("\n");
+	print_hex_dump(KERN_CONT, "", 0, 16, 1,
+			&data[offset], limit, 1);
 
 	if (bad_count == 1) {
 		error ^= POISON_FREE;
@@ -2987,14 +2987,9 @@ bad:
 		printk(KERN_ERR "slab: Internal list corruption detected in "
 				"cache '%s'(%d), slabp %p(%d). Hexdump:\n",
 			cachep->name, cachep->num, slabp, slabp->inuse);
-		for (i = 0;
-		     i < sizeof(*slabp) + cachep->num * sizeof(kmem_bufctl_t);
-		     i++) {
-			if (i % 16 == 0)
-				printk("\n%03x:", i);
-			printk(" %02x", ((unsigned char *)slabp)[i]);
-		}
-		printk("\n");
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 16, 1, slabp,
+			sizeof(*slabp) + cachep->num * sizeof(kmem_bufctl_t),
+			1);
 		BUG();
 	}
 }
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
