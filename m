Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6B36B0036
	for <linux-mm@kvack.org>; Sat, 10 May 2014 19:48:47 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id g10so5204285pdj.3
        for <linux-mm@kvack.org>; Sat, 10 May 2014 16:48:47 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id ps1si4283784pbc.164.2014.05.10.16.48.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 May 2014 16:48:46 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id y10so5129293pdj.18
        for <linux-mm@kvack.org>; Sat, 10 May 2014 16:48:46 -0700 (PDT)
Date: Sat, 10 May 2014 16:48:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [mmotm:master 58/459] mm/slub.c:4356:5: error: implicit declaration
 of function 'count_partial'
In-Reply-To: <536d7abc.eM6MEPh4YAKjplYf%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.02.1405101623220.5545@chino.kir.corp.google.com>
References: <536d7abc.eM6MEPh4YAKjplYf%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1644748617-1399764287=:5545"
Content-ID: <alpine.DEB.2.02.1405101625080.5545@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1644748617-1399764287=:5545
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.02.1405101625081.5545@chino.kir.corp.google.com>

On Sat, 10 May 2014, kbuild test robot wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   9567896580328249f6519fda78cf9fe185a8486d
> commit: 6301f243bb76ad3d8e7b742ca8cfc74e5c63b0be [58/459] mm-slab-suppress-out-of-memory-warning-unless-debug-is-enabled-fix
> config: x86_64-randconfig-c2-0510 (attached as .config)
> 
> All error/warnings:
> 
>    mm/slub.c: In function 'show_slab_objects':
> >> mm/slub.c:4356:5: error: implicit declaration of function 'count_partial' [-Werror=implicit-function-declaration]
>         x = count_partial(n, count_total);
>         ^
>    cc1: some warnings being treated as errors
> 
> vim +/count_partial +4356 mm/slub.c
> 
> ab4d5ed5 Christoph Lameter 2010-10-05  4350  #endif
> ab4d5ed5 Christoph Lameter 2010-10-05  4351  	if (flags & SO_PARTIAL) {
> 205ab99d Christoph Lameter 2008-04-14  4352  		for_each_node_state(node, N_NORMAL_MEMORY) {
> 205ab99d Christoph Lameter 2008-04-14  4353  			struct kmem_cache_node *n = get_node(s, node);
> 81819f0f Christoph Lameter 2007-05-06  4354  
> 205ab99d Christoph Lameter 2008-04-14  4355  			if (flags & SO_TOTAL)
> 205ab99d Christoph Lameter 2008-04-14 @4356  				x = count_partial(n, count_total);
> 205ab99d Christoph Lameter 2008-04-14  4357  			else if (flags & SO_OBJECTS)
> 205ab99d Christoph Lameter 2008-04-14  4358  				x = count_partial(n, count_inuse);
> 81819f0f Christoph Lameter 2007-05-06  4359  			else
> 

Hmm, I'm not sure that 
mm-slab-suppress-out-of-memory-warning-unless-debug-is-enabled-fix.patch 
is the correct fix.  The changelog indicates that CONFIG_SLUB=n, but then 
we're building mm/slub.o?

With my original patch, 
mm-slab-suppress-out-of-memory-warning-unless-debug-is-enabled.patch, I 
get a

	mm/slub.c:2130:12: warning: a??count_freea?? defined but not used [-Wunused-function]

but I can't reproduce the reported

	mm/slub.c:2122: warning: 'count_free' defined but not used

without CONFIG_SLABINFO=n.

I think 
mm-slab-suppress-out-of-memory-warning-unless-debug-is-enabled-fix.patch 
should be withdrawn and we should just do the following.



mm, slab: suppress out of memory warning unless debug is enabled fix

Only define count_free() when CONFIG_SLUB_DEBUG since that's the only 
context in which it is referenced.  Only define count_partial() when 
CONFIG_SLUB_DEBUG or CONFIG_SYSFS since the sysfs interface still uses it 
for partial slab counts.

Also only define node_nr_objs() when CONFIG_SLUB_DEBUG since that's the 
only context in which it is referenced.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2127,11 +2127,19 @@ static inline int node_match(struct page *page, int node)
 	return 1;
 }
 
+#ifdef CONFIG_SLUB_DEBUG
 static int count_free(struct page *page)
 {
 	return page->objects - page->inuse;
 }
 
+static inline unsigned long node_nr_objs(struct kmem_cache_node *n)
+{
+	return atomic_long_read(&n->total_objects);
+}
+#endif /* CONFIG_SLUB_DEBUG */
+
+#if defined(CONFIG_SLUB_DEBUG) || defined(CONFIG_SYSFS)
 static unsigned long count_partial(struct kmem_cache_node *n,
 					int (*get_count)(struct page *))
 {
@@ -2145,15 +2153,7 @@ static unsigned long count_partial(struct kmem_cache_node *n,
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return x;
 }
-
-static inline unsigned long node_nr_objs(struct kmem_cache_node *n)
-{
-#ifdef CONFIG_SLUB_DEBUG
-	return atomic_long_read(&n->total_objects);
-#else
-	return 0;
-#endif
-}
+#endif /* CONFIG_SLUB_DEBUG || CONFIG_SYSFS */
 
 static noinline void
 slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
--531381512-1644748617-1399764287=:5545--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
