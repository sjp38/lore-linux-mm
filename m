Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0585F6B0055
	for <linux-mm@kvack.org>; Thu, 21 May 2009 15:28:18 -0400 (EDT)
Date: Fri, 22 May 2009 04:58:22 +0930
From: Ron <ron@debian.org>
Subject: [PATCH] slab: fix generic PAGE_POISONING conflict with
	SLAB_RED_ZONE
Message-ID: <20090521192822.GB4448@homer.shelbyville.oz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


A generic page poisoning mechanism was added with commit:
 6a11f75b6a17b5d9ac5025f8d048382fd1f47377
which destructively poisons full pages with a bitpattern.

On arches where PAGE_POISONING is used, this conflicts with the slab
redzone checking enabled by DEBUG_SLAB, scribbling bits all over its
magic words and making it complain about that quite emphatically.

On x86 (and I presume at present all the other arches which set
ARCH_SUPPORTS_DEBUG_PAGEALLOC too), the kernel_map_pages() operation
is non destructive so it can coexist with the other DEBUG_SLAB
mechanisms just fine.

This patch favours the expensive full page destruction test for
cases where there is a collision and it is explicitly selected.

Signed-off-by: Ron Lee <ron@debian.org>


diff --git a/mm/slab.c b/mm/slab.c
index 9a90b00..b5e5b27 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2353,6 +2353,15 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		/* really off slab. No need for manual alignment */
 		slab_size =
 		    cachep->num * sizeof(kmem_bufctl_t) + sizeof(struct slab);
+
+#ifdef CONFIG_PAGE_POISONING
+		/* If we're going to use the generic kernel_map_pages()
+		 * poisoning, then it's going to smash the contents of
+		 * the redzone and userword anyhow, so switch them off.
+		 */
+		if (size % PAGE_SIZE == 0 && flags & SLAB_POISON)
+			flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
+#endif
 	}
 
 	cachep->colour_off = cache_line_size();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
