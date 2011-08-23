Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 71A006B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 20:35:36 -0400 (EDT)
Subject: [patch 1/2]slub: add slab with one free object to partial list tail
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Aug 2011 08:36:59 +0800
Message-ID: <1314059819.29510.18.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, cl@linux.com, penberg@kernel.org, "Shi, Alex" <alex.shi@intel.com>, "Chen,
 Tim C" <tim.c.chen@intel.com>

The slab has just one free object, adding it to partial list head doesn't make
sense. And it can cause lock contentation. For example,
1. CPU takes the slab from partial list
2. fetch an object
3. switch to another slab
4. free an object, then the slab is added to partial list again
In this way n->list_lock will be heavily contended.
In fact, Alex had a hackbench regression. 3.1-rc1 performance drops about 70%
against 3.0. This patch fixes it.

Reported-by: Alex Shi <alex.shi@intel.com>
Signed-off-by: Shaohua Li <shli@kernel.org>
Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2011-08-15 09:55:21.000000000 +0800
+++ linux/mm/slub.c	2011-08-23 08:13:54.000000000 +0800
@@ -2377,7 +2377,7 @@ static void __slab_free(struct kmem_cach
 		 */
 		if (unlikely(!prior)) {
 			remove_full(s, page);
-			add_partial(n, page, 0);
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
