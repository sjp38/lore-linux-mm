Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 309E4900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 11:41:41 -0400 (EDT)
Subject: BUILD_BUG_ON() breaks sparse gfp_t checks
From: Dave Hansen <dave@sr71.net>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 14 Apr 2011 08:41:35 -0700
Message-ID: <1302795695.14658.6801.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Jan Beulich <JBeulich@novell.com>, Christoph Lameter <cl@linux.com>, akpm <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Running sparse on page_alloc.c today, it errors out:
        
        mm/page_alloc.c:96:5: warning: symbol 'percpu_pagelist_fraction' was not declared. Should it be static?
        mm/page_alloc.c:175:5: warning: symbol 'min_free_kbytes' was not declared. Should it be static?
        include/linux/gfp.h:254:17: error: bad constant expression
        include/linux/gfp.h:254:17: error: cannot size expression

which is a line in gfp_zone():

	BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);

That's really unfortunate, because it ends up hiding all of the other
legitimate sparse messages (like I introduced with the appended patch):

        mm/page_alloc.c:96:5: warning: symbol 'percpu_pagelist_fraction' was not declared. Should it be static?
        mm/page_alloc.c:175:5: warning: symbol 'min_free_kbytes' was not declared. Should it be static?
        mm/page_alloc.c:3692:15: warning: symbol '__early_pfn_to_nid' was not declared. Should it be static?
        mm/page_alloc.c:5315:59: warning: incorrect type in argument 1 (different base types)
        mm/page_alloc.c:5315:59:    expected unsigned long [unsigned] [usertype] size
        mm/page_alloc.c:5315:59:    got restricted gfp_t [usertype] <noident>
...

Is sparse broken, or is that ?  Even if it is, should we be working
around this somehow?  It looks like we've basically crippled sparse in
some spots.

---

 linux-2.6.git-dave/include/linux/gfp.h |    3 ++-
 linux-2.6.git-dave/mm/page_alloc.c     |    1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff -puN include/linux/gfp.h~fix-gfp_h-sparse include/linux/gfp.h
--- linux-2.6.git/include/linux/gfp.h~fix-gfp_h-sparse	2011-04-14 08:23:33.402280424 -0700
+++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-14 08:32:33.782224008 -0700
@@ -249,7 +249,7 @@ static inline enum zone_type gfp_zone(gf
 
 	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
 					 ((1 << ZONES_SHIFT) - 1);
-
+/*
 	if (__builtin_constant_p(bit))
 		BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
 	else {
@@ -257,6 +257,7 @@ static inline enum zone_type gfp_zone(gf
 		BUG_ON((GFP_ZONE_BAD >> bit) & 1);
 #endif
 	}
+	*/
 	return z;
 }
 
diff -puN mm/page_alloc.c~fix-gfp_h-sparse mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~fix-gfp_h-sparse	2011-04-14 08:24:20.806271357 -0700
+++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-14 08:24:35.554268529 -0700
@@ -5312,6 +5312,7 @@ void *__init alloc_large_system_hash(con
 			 */
 			if (get_order(size) < MAX_ORDER) {
 				table = alloc_pages_exact(size, GFP_ATOMIC);
+				table = alloc_pages_exact(GFP_ATOMIC, size);
 				kmemleak_alloc(table, size, 1, GFP_ATOMIC);
 			}
 		}
_


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
