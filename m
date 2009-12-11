Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 81FC16B00AE
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 02:46:13 -0500 (EST)
Message-ID: <4B21F8AE.6020804@cn.fujitsu.com>
Date: Fri, 11 Dec 2009 15:45:50 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] tracing: Fix no callsite ifndef CONFIG_KMEMTRACE
References: <4B21F89A.7000801@cn.fujitsu.com>
In-Reply-To: <4B21F89A.7000801@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

For slab, if CONFIG_KMEMTRACE and CONFIG_DEBUG_SLAB are not set,
__do_kmalloc() will not track callers:

 # ./perf record -f -a -R -e kmem:kmalloc
 ^C
 # ./perf trace
 ...
          perf-2204  [000]   147.376774: kmalloc: call_site=c0529d2d ...
          perf-2204  [000]   147.400997: kmalloc: call_site=c0529d2d ...
          Xorg-1461  [001]   147.405413: kmalloc: call_site=0 ...
          Xorg-1461  [001]   147.405609: kmalloc: call_site=0 ...
       konsole-1776  [001]   147.405786: kmalloc: call_site=0 ...

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/slab.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9733bb4..c3d092d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3649,7 +3649,7 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
 	return ret;
 }
 
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_KMEMTRACE)
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return __do_kmalloc_node(size, flags, node,
@@ -3669,7 +3669,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 	return __do_kmalloc_node(size, flags, node, NULL);
 }
 EXPORT_SYMBOL(__kmalloc_node);
-#endif /* CONFIG_DEBUG_SLAB */
+#endif /* CONFIG_DEBUG_SLAB || CONFIG_TRACING */
 #endif /* CONFIG_NUMA */
 
 /**
@@ -3701,7 +3701,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 }
 
 
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_KMEMTRACE)
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
 void *__kmalloc(size_t size, gfp_t flags)
 {
 	return __do_kmalloc(size, flags, __builtin_return_address(0));
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
