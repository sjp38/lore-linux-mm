Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCB56B000C
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:34:59 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m3so1582454qte.2
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:34:59 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o102si562739qko.135.2018.03.23.08.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 08:34:58 -0700 (PDT)
Date: Fri, 23 Mar 2018 11:34:57 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] slab_common: remove test if cache name is accessible
Message-ID: <alpine.LRH.2.02.1803231133310.22626@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since the commit db265eca7700 ("mm/sl[aou]b: Move duping of slab name to
slab_common.c"), the kernel always duplicates the slab cache name when
creating a slab cache, so the test if the slab name is accessible is
useless.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 mm/slab_common.c |   19 -------------------
 1 file changed, 19 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2018-03-21 12:43:19.418416000 +0100
+++ linux-2.6/mm/slab_common.c	2018-03-21 12:51:32.619999000 +0100
@@ -83,31 +83,12 @@ EXPORT_SYMBOL(kmem_cache_size);
 #ifdef CONFIG_DEBUG_VM
 static int kmem_cache_sanity_check(const char *name, size_t size)
 {
-	struct kmem_cache *s = NULL;
-
 	if (!name || in_interrupt() || size < sizeof(void *) ||
 		size > KMALLOC_MAX_SIZE) {
 		pr_err("kmem_cache_create(%s) integrity check failed\n", name);
 		return -EINVAL;
 	}
 
-	list_for_each_entry(s, &slab_caches, list) {
-		char tmp;
-		int res;
-
-		/*
-		 * This happens when the module gets unloaded and doesn't
-		 * destroy its slab cache and no-one else reuses the vmalloc
-		 * area of the module.  Print a warning.
-		 */
-		res = probe_kernel_address(s->name, tmp);
-		if (res) {
-			pr_err("Slab cache with size %d has lost its name\n",
-			       s->object_size);
-			continue;
-		}
-	}
-
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
 	return 0;
 }
