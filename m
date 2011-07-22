Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A0CA56B00F4
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:49:24 -0400 (EDT)
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6M0nNLZ023371
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:49:23 -0400
Received: from gelk.kernelslacker.org (ovpn-113-43.phx2.redhat.com [10.3.113.43])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p6M0nMN9030956
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:49:22 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.4) with ESMTP id p6M0nLj2020748
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:49:21 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id p6M0nLhx020747
	for linux-mm@kvack.org; Thu, 21 Jul 2011 20:49:21 -0400
Date: Thu, 21 Jul 2011 20:49:21 -0400
From: Dave Jones <davej@redhat.com>
Subject: Add taint flag outputting to slab debug paths.
Message-ID: <20110722004921.GA20700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

When we get corruption reports, it's useful to see if the kernel
was tainted, to rule out problems we can't do anything about.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/mm/slab.c b/mm/slab.c
index e74a16e..7bc287e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1803,8 +1803,8 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
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
@@ -2902,8 +2902,8 @@ static void check_slabp(struct kmem_cache *cachep, struct slab *slabp)
 	if (entries != cachep->num - slabp->inuse) {
 bad:
 		printk(KERN_ERR "slab: Internal list corruption detected in "
-				"cache '%s'(%d), slabp %p(%d). Hexdump:\n",
-			cachep->name, cachep->num, slabp, slabp->inuse);
+				"cache '%s'(%d), slabp %p(%d). Tainted(%s). Hexdump:\n",
+			cachep->name, cachep->num, slabp, slabp->inuse, print_tainted());
 		for (i = 0;
 		     i < sizeof(*slabp) + cachep->num * sizeof(kmem_bufctl_t);
 		     i++) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
