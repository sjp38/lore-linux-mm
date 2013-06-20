From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
Date: Thu, 20 Jun 2013 10:53:36 +0800
Message-ID: <35826.1526715525$1371696835@news.gmane.org>
References: <20130614195500.373711648@linux.com>
 <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
 <20130619052203.GA12231@lge.com>
 <0000013f5cd71dac-5c834a4e-c521-4d79-aecc-3e7a6671fb8c-000000@email.amazonses.com>
 <20130620015056.GC13026@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UpV0O-0007W8-2P
	for glkm-linux-mm-2@m.gmane.org; Thu, 20 Jun 2013 04:53:48 +0200
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 751F56B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 22:53:45 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 20 Jun 2013 08:17:37 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 68747394004E
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 08:23:39 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5K2rjZh27197442
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 08:23:46 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5K2rcWo025312
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 12:53:38 +1000
Content-Disposition: inline
In-Reply-To: <20130620015056.GC13026@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, Jun 20, 2013 at 10:50:56AM +0900, Joonsoo Kim wrote:
>On Wed, Jun 19, 2013 at 02:29:29PM +0000, Christoph Lameter wrote:
>> On Wed, 19 Jun 2013, Joonsoo Kim wrote:
>> 
>> > How about maintaining cpu_partial when !CONFIG_SLUB_CPU_PARTIAL?
>> > It makes code less churn and doesn't have much overhead.
>> > At bottom, my implementation with cpu_partial is attached. It uses less '#ifdef'.
>> 
>> Looks good. I am fine with it.
>> 
>> Acked-by: Christoph Lameter <cl@linux.com>
>
>Thanks!
>
>Hello, Pekka.
>I attach a right formatted patch with acked by Christoph and
>signed off by me.
>
>It is based on v3.10-rc6 and top of a patch
>"slub: do not put a slab to cpu partial list when cpu_partial is 0".
>
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>
>-----------------8<-----------------------------------------------
>>From a3257adcff89fd89a7ecb26c1247eec511302807 Mon Sep 17 00:00:00 2001
>From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>Date: Wed, 19 Jun 2013 14:05:52 +0900
>Subject: [PATCH] slub: Make cpu partial slab support configurable
>
>cpu partial support can introduce level of indeterminism that is not
>wanted in certain context (like a realtime kernel). Make it configurable.
>
>This patch is based on Christoph Lameter's
>"slub: Make cpu partial slab support configurable V2".
>

As you know, actually cpu_partial is the maximum number of objects kept 
in the per cpu slab and cpu partial lists of a processor instead of 
just the maximum number of objects kept in cpu partial lists of a
processor. The allocation will always fallback to slow path if not 
config SLUB_CPU_PARTIAL, whether it will lead to more latency?

Regards,
Wanpeng Li 

>Acked-by: Christoph Lameter <cl@linux.com>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/init/Kconfig b/init/Kconfig
>index 2d9b831..a7ec1ec 100644
>--- a/init/Kconfig
>+++ b/init/Kconfig
>@@ -1559,6 +1559,17 @@ config SLOB
>
> endchoice
>
>+config SLUB_CPU_PARTIAL
>+	default y
>+	depends on SLUB
>+	bool "SLUB per cpu partial cache"
>+	help
>+	  Per cpu partial caches accellerate objects allocation and freeing
>+	  that is local to a processor at the price of more indeterminism
>+	  in the latency of the free. On overflow these caches will be cleared
>+	  which requires the taking of locks that may cause latency spikes.
>+	  Typically one would choose no for a realtime system.
>+
> config MMAP_ALLOW_UNINITIALIZED
> 	bool "Allow mmapped anonymous memory to be uninitialized"
> 	depends on EXPERT && !MMU
>diff --git a/mm/slub.c b/mm/slub.c
>index 7033b4f..a670d22 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -123,6 +123,15 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
> #endif
> }
>
>+static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
>+{
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
>+	return !kmem_cache_debug(s);
>+#else
>+	return false;
>+#endif
>+}
>+
> /*
>  * Issues still to be resolved:
>  *
>@@ -1573,7 +1582,8 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
> 			put_cpu_partial(s, page, 0);
> 			stat(s, CPU_PARTIAL_NODE);
> 		}
>-		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
>+		if (!kmem_cache_has_cpu_partial(s)
>+			|| available > s->cpu_partial / 2)
> 			break;
>
> 	}
>@@ -1884,6 +1894,7 @@ redo:
> static void unfreeze_partials(struct kmem_cache *s,
> 		struct kmem_cache_cpu *c)
> {
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
> 	struct kmem_cache_node *n = NULL, *n2 = NULL;
> 	struct page *page, *discard_page = NULL;
>
>@@ -1938,6 +1949,7 @@ static void unfreeze_partials(struct kmem_cache *s,
> 		discard_slab(s, page);
> 		stat(s, FREE_SLAB);
> 	}
>+#endif
> }
>
> /*
>@@ -1951,6 +1963,7 @@ static void unfreeze_partials(struct kmem_cache *s,
>  */
> static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> {
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
> 	struct page *oldpage;
> 	int pages;
> 	int pobjects;
>@@ -1990,6 +2003,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> 		page->next = oldpage;
>
> 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
>+#endif
> }
>
> static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
>@@ -2498,7 +2512,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
> 		new.inuse--;
> 		if ((!new.inuse || !prior) && !was_frozen) {
>
>-			if (!kmem_cache_debug(s) && !prior)
>+			if (kmem_cache_has_cpu_partial(s) && !prior)
>
> 				/*
> 				 * Slab was on no list before and will be partially empty
>@@ -3062,7 +3076,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
> 	 *    per node list when we run out of per cpu objects. We only fetch 50%
> 	 *    to keep some capacity around for frees.
> 	 */
>-	if (kmem_cache_debug(s))
>+	if (!kmem_cache_has_cpu_partial(s))
> 		s->cpu_partial = 0;
> 	else if (s->size >= PAGE_SIZE)
> 		s->cpu_partial = 2;
>@@ -4459,7 +4473,7 @@ static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
> 	err = strict_strtoul(buf, 10, &objects);
> 	if (err)
> 		return err;
>-	if (objects && kmem_cache_debug(s))
>+	if (objects && !kmem_cache_has_cpu_partial(s))
> 		return -EINVAL;
>
> 	s->cpu_partial = objects;
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
