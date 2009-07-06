Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 88AFB6B005C
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 06:16:14 -0400 (EDT)
Subject: [RFC PATCH 3/3] kmemleak: Remove alloc_bootmem annotations introduced
	in the past
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 06 Jul 2009 11:52:01 +0100
Message-ID: <20090706105200.16051.4972.stgit@pc1117.cambridge.arm.com>
In-Reply-To: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

kmemleak_alloc() calls were added in some places where alloc_bootmem was
called. Since now kmemleak tracks bootmem allocations, these explicit
calls should be run.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
---
 kernel/pid.c    |    7 -------
 mm/page_alloc.c |   14 +++-----------
 2 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/kernel/pid.c b/kernel/pid.c
index 5fa1db4..31310b5 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -36,7 +36,6 @@
 #include <linux/pid_namespace.h>
 #include <linux/init_task.h>
 #include <linux/syscalls.h>
-#include <linux/kmemleak.h>
 
 #define pid_hashfn(nr, ns)	\
 	hash_long((unsigned long)nr + (unsigned long)ns, pidhash_shift)
@@ -513,12 +512,6 @@ void __init pidhash_init(void)
 	pid_hash = alloc_bootmem(pidhash_size *	sizeof(*(pid_hash)));
 	if (!pid_hash)
 		panic("Could not alloc pidhash!\n");
-	/*
-	 * pid_hash contains references to allocated struct pid objects and it
-	 * must be scanned by kmemleak to avoid false positives.
-	 */
-	kmemleak_alloc(pid_hash, pidhash_size *	sizeof(*(pid_hash)), 0,
-		       GFP_KERNEL);
 	for (i = 0; i < pidhash_size; i++)
 		INIT_HLIST_HEAD(&pid_hash[i]);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e0f2cdf..202ef6b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4745,8 +4745,10 @@ void *__init alloc_large_system_hash(const char *tablename,
 			 * some pages at the end of hash table which
 			 * alloc_pages_exact() automatically does
 			 */
-			if (get_order(size) < MAX_ORDER)
+			if (get_order(size) < MAX_ORDER) {
 				table = alloc_pages_exact(size, GFP_ATOMIC);
+				kmemleak_alloc(table, size, 1, GFP_ATOMIC);
+			}
 		}
 	} while (!table && size > PAGE_SIZE && --log2qty);
 
@@ -4764,16 +4766,6 @@ void *__init alloc_large_system_hash(const char *tablename,
 	if (_hash_mask)
 		*_hash_mask = (1 << log2qty) - 1;
 
-	/*
-	 * If hashdist is set, the table allocation is done with __vmalloc()
-	 * which invokes the kmemleak_alloc() callback. This function may also
-	 * be called before the slab and kmemleak are initialised when
-	 * kmemleak simply buffers the request to be executed later
-	 * (GFP_ATOMIC flag ignored in this case).
-	 */
-	if (!hashdist)
-		kmemleak_alloc(table, size, 1, GFP_ATOMIC);
-
 	return table;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
