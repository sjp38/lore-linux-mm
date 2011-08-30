Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A98BB900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 21:51:56 -0400 (EDT)
Subject: [patch 1/2]slub: add slab with one free object to partial list
 tail - v2
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Aug 2011 09:54:01 +0800
Message-ID: <1314669241.29510.47.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "Shi, Alex" <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, linux-mm <linux-mm@kvack.org>

The slab has just one free object, adding it to partial list head doesn't make
sense. And it can cause lock contentation. For example,
1. CPU takes the slab from partial list
2. fetch an object
3. switch to another slab
4. free an object, then the slab is added to partial list again
In this way n->list_lock will be heavily contended.
In fact, Alex had a hackbench regression. 3.1-rc1 performance drops about 70%
against 3.0. This patch fixes it. Thanks Alex to bisect the issue to be a slub
regression and collect perf data. Add comments in the code as suggested by Alex.

Reported-by: Alex Shi <alex.shi@intel.com>
Signed-off-by: Shaohua Li <shli@kernel.org>
Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Acked-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2011-08-24 08:59:06.000000000 +0800
+++ linux/mm/slub.c	2011-08-30 09:45:03.000000000 +0800
@@ -2377,7 +2377,12 @@ static void __slab_free(struct kmem_cach
 		 */
 		if (unlikely(!prior)) {
 			remove_full(s, page);
-			add_partial(n, page, 0);
+			/*
+			 * The slab has just one free object, add it to the
+			 * partial list tail so it will not be used
+			 * immediately.
+			 */
+			add_partial(n, page, 1);
 			stat(s, FREE_ADD_PARTIAL);
 		}
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
