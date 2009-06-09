Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CCB576B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 05:45:51 -0400 (EDT)
Message-Id: <20090609094056.238393901@blue.kroah.org>
Date: Tue, 09 Jun 2009 02:39:06 -0700
From: Greg KH <gregkh@suse.de>
Subject: [patch 18/87] mm: SLUB fix reclaim_state
References: <20090609093848.204935043@blue.kroah.org>
Content-Disposition: inline; filename=mm-slub-fix-reclaim_state.patch
In-Reply-To: <20090609094451.GA26439@kroah.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, stable@kernel.org
Cc: Justin Forbes <jmforbes@linuxtx.org>, Zwane Mwaikambo <zwane@arm.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Randy Dunlap <rdunlap@xenotime.net>, Dave Jones <davej@redhat.com>, Chuck Wolber <chuckw@quantumlinux.com>, Chris Wedgwood <reviews@ml.cw.f00f.org>, Michael Krufky <mkrufky@linuxtv.org>, Chuck Ebbert <cebbert@redhat.com>, Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>, Rodrigo Rubira Branco <rbranco@la.checkpoint.com>, Jake Edge <jake@lwn.net>, Eugene Teo <eteo@redhat.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

2.6.29-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Nick Piggin <npiggin@suse.de>

commit 1eb5ac6466d4be7b15b38ce3ab709600f1bc891f upstream.

SLUB does not correctly account reclaim_state.reclaimed_slab, so it will
break memory reclaim. Account it like SLAB does.

Cc: linux-mm@kvack.org
Cc: Matt Mackall <mpm@selenic.com>
Acked-by: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 mm/slub.c |    3 +++
 1 file changed, 3 insertions(+)

--- a/mm/slub.c
+++ b/mm/slub.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/mm.h>
+#include <linux/swap.h> /* struct reclaim_state */
 #include <linux/module.h>
 #include <linux/bit_spinlock.h>
 #include <linux/interrupt.h>
@@ -1175,6 +1176,8 @@ static void __free_slab(struct kmem_cach
 
 	__ClearPageSlab(page);
 	reset_page_mapcount(page);
+	if (current->reclaim_state)
+		current->reclaim_state->reclaimed_slab += pages;
 	__free_pages(page, order);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
