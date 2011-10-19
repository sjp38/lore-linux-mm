Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DF58A6B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 01:09:33 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p9J59Vfe017587
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 22:09:31 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by hpaq14.eem.corp.google.com with ESMTP id p9J57tBH002757
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 22:09:30 -0700
Received: by pzk1 with SMTP id 1so4556151pzk.5
        for <linux-mm@kvack.org>; Tue, 18 Oct 2011 22:09:30 -0700 (PDT)
Date: Tue, 18 Oct 2011 22:09:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] slab: introduce slab_max_order kernel parameter
In-Reply-To: <alpine.DEB.2.00.1110182207500.5907@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1110182208260.5907@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110182207500.5907@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Introduce new slab_max_order kernel parameter which is the equivalent of
slub_max_order.

For immediate purposes, allows users to override the heuristic that sets
the max order to 1 by default if they have more than 32MB of RAM.  This
may result in page allocation failures if there is substantial
fragmentation.

Another usecase would be to increase the max order for better
performance.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/kernel-parameters.txt |    6 ++++++
 mm/slab.c                           |   20 +++++++++++++++++---
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2318,6 +2318,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	slram=		[HW,MTD]
 
+	slab_max_order=	[MM, SLAB]
+			Determines the maximum allowed order for slabs.
+			A high setting may cause OOMs due to memory
+			fragmentation.  Defaults to 1 for systems with
+			more than 32MB of RAM, 0 otherwise.
+
 	slub_debug[=options[,slabs]]	[MM, SLUB]
 			Enabling slub_debug allows one to determine the
 			culprit if slab objects become corrupted. Enabling
diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -479,11 +479,13 @@ EXPORT_SYMBOL(slab_buffer_size);
 #endif
 
 /*
- * Do not go above this order unless 0 objects fit into the slab.
+ * Do not go above this order unless 0 objects fit into the slab or
+ * overridden on the command line.
  */
 #define	SLAB_MAX_ORDER_HI	1
 #define	SLAB_MAX_ORDER_LO	0
 static int slab_max_order = SLAB_MAX_ORDER_LO;
+static bool slab_max_order_set __initdata;
 
 /*
  * Functions for storing/retrieving the cachep and or slab from the page
@@ -851,6 +853,17 @@ static int __init noaliencache_setup(char *s)
 }
 __setup("noaliencache", noaliencache_setup);
 
+static int __init slab_max_order_setup(char *str)
+{
+	get_option(&str, &slab_max_order);
+	slab_max_order = slab_max_order < 0 ? 0 :
+				min(slab_max_order, MAX_ORDER - 1);
+	slab_max_order_set = true;
+
+	return 1;
+}
+__setup("slab_max_order=", slab_max_order_setup);
+
 #ifdef CONFIG_NUMA
 /*
  * Special reaping functions for NUMA systems called from cache_reap().
@@ -1499,9 +1512,10 @@ void __init kmem_cache_init(void)
 
 	/*
 	 * Fragmentation resistance on low memory - only use bigger
-	 * page orders on machines with more than 32MB of memory.
+	 * page orders on machines with more than 32MB of memory if
+	 * not overridden on the command line.
 	 */
-	if (totalram_pages > (32 << 20) >> PAGE_SHIFT)
+	if (!slab_max_order_set && totalram_pages > (32 << 20) >> PAGE_SHIFT)
 		slab_max_order = SLAB_MAX_ORDER_HI;
 
 	/* Bootstrap is tricky, because several objects are allocated

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
