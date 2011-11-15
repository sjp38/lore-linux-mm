Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 708856B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 18:04:02 -0500 (EST)
Received: by vws10 with SMTP id 10so152613vws.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 15:04:00 -0800 (PST)
Message-Id: <201111152303.pAFN3r4Q026247@wpaz9.hot.corp.google.com>
Subject: [patch 1/2] slab: add taint flag outputting to debug paths.
From: akpm@linux-foundation.org
Date: Tue, 15 Nov 2011 15:03:52 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, davej@redhat.com

From: Dave Jones <davej@redhat.com>
Subject: slab: add taint flag outputting to debug paths.

When we get corruption reports, it's useful to see if the kernel was
tainted, to rule out problems we can't do anything about.

Signed-off-by: Dave Jones <davej@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/slab.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff -puN mm/slab.c~slab-add-taint-flag-outputting-to-debug-paths mm/slab.c
--- a/mm/slab.c~slab-add-taint-flag-outputting-to-debug-paths
+++ a/mm/slab.c
@@ -1941,8 +1941,8 @@ static void check_poison_obj(struct kmem
 			/* Print header */
 			if (lines == 0) {
 				printk(KERN_ERR
-					"Slab corruption: %s start=%p, len=%d\n",
-					cachep->name, realobj, size);
+					"Slab corruption (%s): %s start=%p, len=%d\n",
+					print_tainted(), cachep->name, realobj, size);
 				print_objinfo(cachep, objp, 0);
 			}
 			/* Hexdump the affected line */
@@ -3051,8 +3051,9 @@ static void check_slabp(struct kmem_cach
 	if (entries != cachep->num - slabp->inuse) {
 bad:
 		printk(KERN_ERR "slab: Internal list corruption detected in "
-				"cache '%s'(%d), slabp %p(%d). Hexdump:\n",
-			cachep->name, cachep->num, slabp, slabp->inuse);
+			"cache '%s'(%d), slabp %p(%d). Tainted(%s). Hexdump:\n",
+			cachep->name, cachep->num, slabp, slabp->inuse,
+			print_tainted());
 		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 16, 1, slabp,
 			sizeof(*slabp) + cachep->num * sizeof(kmem_bufctl_t),
 			1);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
