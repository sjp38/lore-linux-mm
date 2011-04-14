Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 583FE900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 19:42:25 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3ENSutF001380
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:28:56 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3ENgH4g088636
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:42:17 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3ENgHI1006606
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:42:17 -0600
Subject: [PATCH] make sparse happy with gfp.h
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 14 Apr 2011 16:42:17 -0700
Message-Id: <20110414234216.9E31DBD9@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>


Running sparse on page_alloc.c today, it errors out:
        include/linux/gfp.h:254:17: error: bad constant expression
        include/linux/gfp.h:254:17: error: cannot size expression

which is a line in gfp_zone():

        BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);

That's really unfortunate, because it ends up hiding all of the other
legitimate sparse messages like this:
        mm/page_alloc.c:5315:59: warning: incorrect type in argument 1 (different base types)
        mm/page_alloc.c:5315:59:    expected unsigned long [unsigned] [usertype] size
        mm/page_alloc.c:5315:59:    got restricted gfp_t [usertype] <noident>
...

Having sparse be able to catch these very oopsable bugs is a lot more
important than keeping a BUILD_BUG_ON().  Kill the BUILD_BUG_ON().

Compiles on x86_64 with and without CONFIG_DEBUG_VM=y.  defconfig
boots fine for me.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/linux/gfp.h |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff -puN include/linux/gfp.h~make-sparse-happy-with-gfp_h include/linux/gfp.h
--- linux-2.6.git/include/linux/gfp.h~make-sparse-happy-with-gfp_h	2011-04-14 14:47:02.629275904 -0700
+++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-14 14:47:38.813272674 -0700
@@ -249,14 +249,9 @@ static inline enum zone_type gfp_zone(gf
 
 	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
 					 ((1 << ZONES_SHIFT) - 1);
-
-	if (__builtin_constant_p(bit))
-		BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
-	else {
 #ifdef CONFIG_DEBUG_VM
-		BUG_ON((GFP_ZONE_BAD >> bit) & 1);
+	BUG_ON((GFP_ZONE_BAD >> bit) & 1);
 #endif
-	}
 	return z;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
