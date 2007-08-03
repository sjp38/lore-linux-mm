Date: Thu, 2 Aug 2007 17:47:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix two potential mem leaks in MPT Fusion (mpt_attach())
In-Reply-To: <9a8748490708021626s58f0f7cew54932e523800e982@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708021738050.13312@schroedinger.engr.sgi.com>
References: <200708020155.33690.jesper.juhl@gmail.com>
 <20070801172653.1fd44e99.akpm@linux-foundation.org>
 <9a8748490708020120w4bbfe6d1n6f6986aec507316@mail.gmail.com>
 <200708030053.45297.jesper.juhl@gmail.com>  <20070802160406.5c5b5ff6.akpm@linux-foundation.org>
  <9a8748490708021610k31a86c17y58fb631a36dfdb6a@mail.gmail.com>
 <20070802161730.1d5bb55b.akpm@linux-foundation.org>
 <9a8748490708021626s58f0f7cew54932e523800e982@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@steeleye.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Mempools do not want to wait if there is an allocation failure. Its like 
GFP_THISNODE in that we want a failure.

I had to add a

if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
                goto nopage;

in page_alloc.c to make GFP_THISNODE fail.

Maybe add a GFP_FAIL and check for that?


diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index bc68dd9..41b6aa3 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -43,6 +43,7 @@ struct vm_area_struct;
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* Retry the allocation.  Might fail */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* Retry for ever.  Cannot fail */
 #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* Do not retry.  Might fail */
+#define __GFP_FAIL	((__force gfp_t)0x2000u)/* Fail immediately if there is a problem */
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
@@ -81,7 +82,8 @@ struct vm_area_struct;
 				 __GFP_MOVABLE)
 
 #ifdef CONFIG_NUMA
-#define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
+#define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY |\
+				__GFP_FAIL)
 #else
 #define GFP_THISNODE	((__force gfp_t)0)
 #endif
diff --git a/mm/mempool.c b/mm/mempool.c
index 02d5ec3..c1ac622 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -211,8 +211,9 @@ void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	gfp_mask |= __GFP_NOMEMALLOC;	/* don't allocate emergency reserves */
 	gfp_mask |= __GFP_NORETRY;	/* don't loop in __alloc_pages */
 	gfp_mask |= __GFP_NOWARN;	/* failures are OK */
+	gfp_mask |= __GFP_FAIL;
 
-	gfp_temp = gfp_mask & ~(__GFP_WAIT|__GFP_IO);
+	gfp_temp = gfp_mask & ~__GFP_IO;
 
 repeat_alloc:
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3da85b8..58c1a4d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1250,15 +1250,7 @@ restart:
 	if (page)
 		goto got_pg;
 
-	/*
-	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
-	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
-	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
-	 * using a larger set of nodes after it has established that the
-	 * allowed per node queues are empty and that nodes are
-	 * over allocated.
-	 */
-	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+	if (gfp_mask & __GFP_FAIL)
 		goto nopage;
 
 	for (z = zonelist->zones; *z; z++)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
