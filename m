Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id DE3F66B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 15:03:03 -0400 (EDT)
Received: by dakp5 with SMTP id p5so11374517dak.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 12:03:03 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: fix a memory leak in get_partial_node()
Date: Wed, 16 May 2012 04:01:38 +0900
Message-Id: <1337108498-4104-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

In the case which is below,

1. acquire slab for cpu partial list
2. free object to it by remote cpu
3. page->freelist = t

then memory leak is occurred.

Change acquire_slab() not to zap freelist when it works for cpu partial list.
I think it is a sufficient solution for fixing a memory leak.

Below is output of 'slabinfo -r kmalloc-256'
when './perf stat -r 30 hackbench 50 process 4000 > /dev/null' is done.

***Vanilla***
Sizes (bytes)     Slabs              Debug                Memory
------------------------------------------------------------------------
Object :     256  Total  :     468   Sanity Checks : Off  Total: 3833856
SlabObj:     256  Full   :     111   Redzoning     : Off  Used : 2004992
SlabSiz:    8192  Partial:     302   Poisoning     : Off  Loss : 1828864
Loss   :       0  CpuSlab:      55   Tracking      : Off  Lalig:       0
Align  :       8  Objects:      32   Tracing       : Off  Lpadd:       0

***Patched***
Sizes (bytes)     Slabs              Debug                Memory
------------------------------------------------------------------------
Object :     256  Total  :     300   Sanity Checks : Off  Total: 2457600
SlabObj:     256  Full   :     204   Redzoning     : Off  Used : 2348800
SlabSiz:    8192  Partial:      33   Poisoning     : Off  Loss :  108800
Loss   :       0  CpuSlab:      63   Tracking      : Off  Lalig:       0
Align  :       8  Objects:      32   Tracing       : Off  Lpadd:       0

Total and loss number is the impact of this patch.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index ffe13fd..a7a766a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1514,15 +1514,19 @@ static inline void *acquire_slab(struct kmem_cache *s,
 		freelist = page->freelist;
 		counters = page->counters;
 		new.counters = counters;
-		if (mode)
+		if (mode) {
 			new.inuse = page->objects;
+			new.freelist = NULL;
+		} else {
+			new.freelist = freelist;
+		}
 
 		VM_BUG_ON(new.frozen);
 		new.frozen = 1;
 
 	} while (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
-			NULL, new.counters,
+			new.freelist, new.counters,
 			"lock and freeze"));
 
 	remove_partial(n, page);
@@ -1564,7 +1568,6 @@ static void *get_partial_node(struct kmem_cache *s,
 			object = t;
 			available =  page->objects - page->inuse;
 		} else {
-			page->freelist = t;
 			available = put_cpu_partial(s, page, 0);
 			stat(s, CPU_PARTIAL_NODE);
 		}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
