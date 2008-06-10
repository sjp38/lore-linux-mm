Date: Mon, 9 Jun 2008 18:22:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Collision of SLUB unique ID
In-Reply-To: <200806100106.m5A16iKl025150@po-mbox304.hop.2iij.net>
Message-ID: <Pine.LNX.4.64.0806091821080.12465@schroedinger.engr.sgi.com>
References: <20080604234622.4b73289c.yoichi_yuasa@tripeaks.co.jp>
 <Pine.LNX.4.64.0806090706230.29723@schroedinger.engr.sgi.com>
 <200806100106.m5A16iKl025150@po-mbox304.hop.2iij.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

> I got same error on these version.

Duh.

Does this patch fix it?


Subject: slub: Do not use 192 byte sized cache if minimum alignment is 128 byte

The 192 byte cache is not necessary if we have a basic alignment of 128
byte. If it would be used then the 192 would be aligned and result in
another 256 byte cache which causes trouble for sysfs.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-06-09 18:08:50.000000000 -0700
+++ linux-2.6/mm/slub.c	2008-06-09 18:17:26.000000000 -0700
@@ -2995,8 +2995,7 @@ void __init kmem_cache_init(void)
 		create_kmalloc_cache(&kmalloc_caches[1],
 				"kmalloc-96", 96, GFP_KERNEL);
 		caches++;
-	}
-	if (KMALLOC_MIN_SIZE <= 128) {
+
 		create_kmalloc_cache(&kmalloc_caches[2],
 				"kmalloc-192", 192, GFP_KERNEL);
 		caches++;
@@ -3026,6 +3025,16 @@ void __init kmem_cache_init(void)
 	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8)
 		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;
 
+	if (KMALLOC_MIN_SIZE == 128) {
+		/*
+		 * The 192 byte sized kmalloc cache is not properly
+		 * aligned if the minimum alignment is 128 bytes.
+		 * Use the 256 sized kmalloc cache instead.
+		 */
+		for (i = 128; i < 192; i += 8)
+			size_index[(i - 1) / 8] = 8;
+	}
+
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
