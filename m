Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 03B626B006A
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 23:47:17 -0400 (EDT)
Subject: mm: Move pgtable_cache_init() earlier
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Wed, 17 Jun 2009 13:48:39 +1000
Message-Id: <1245210519.21602.16.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, linuxppc-dev list <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

Some architectures need to initialize SLAB caches to be able
to allocate page tables. They do that from pgtable_cache_init()
so the later should be called earlier now, best is before
vmalloc_init().

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Note: Only powerpc, sparc and xtensa use this and only to
call kmem_cache_create() so with a bit of luck it should
just work... 

Index: linux-work/init/main.c
===================================================================
--- linux-work.orig/init/main.c	2009-06-17 13:41:33.000000000 +1000
+++ linux-work/init/main.c	2009-06-17 13:41:45.000000000 +1000
@@ -546,6 +546,7 @@ static void __init mm_init(void)
 	page_cgroup_init_flatmem();
 	mem_init();
 	kmem_cache_init();
+	pgtable_cache_init();
 	vmalloc_init();
 }
 
@@ -684,7 +685,6 @@ asmlinkage void __init start_kernel(void
 		late_time_init();
 	calibrate_delay();
 	pidmap_init();
-	pgtable_cache_init();
 	anon_vma_init();
 #ifdef CONFIG_X86
 	if (efi_enabled)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
