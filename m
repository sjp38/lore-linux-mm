Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8254E6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 13:21:56 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so42083531pac.13
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:21:56 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g12si10944208pat.3.2015.01.29.10.21.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 10:21:55 -0800 (PST)
Date: Thu, 29 Jan 2015 21:21:41 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
Message-ID: <20150129182141.GA25158@esperanza>
References: <cover.1422461573.git.vdavydov@parallels.com>
 <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
 <20150128135752.afcb196d6ded7c16a79ed6fd@linux-foundation.org>
 <20150129080726.GB11463@esperanza>
 <alpine.DEB.2.11.1501290954230.7725@gentwo.org>
 <20150129161739.GE11463@esperanza>
 <alpine.DEB.2.11.1501291021370.7986@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501291021370.7986@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 29, 2015 at 10:22:16AM -0600, Christoph Lameter wrote:
> On Thu, 29 Jan 2015, Vladimir Davydov wrote:
> 
> > Yeah, but the tool just writes 1 to /sys/kernel/slab/cache/shrink, i.e.
> > invokes shrink_store(), and I don't propose to remove slab placement
> > optimization from there. What I propose is to move slab placement
> > optimization from kmem_cache_shrink() to shrink_store(), because other
> > users of kmem_cache_shrink() don't seem to need it at all - they just
> > want to release empty slabs. Such a change wouldn't affect the behavior
> > of `slabinfo -s` at all.
> 
> Well we have to go through the chain of partial slabs anyways so its easy
> to do the optimization at that point.

That's true, but we can introduce a separate function that would both
release empty slabs and optimize slab placement, like the patch below
does. It would increase the code size a bit though, so I don't insist.

diff --git a/mm/slub.c b/mm/slub.c
index 1562955fe099..2cd401d82a41 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3359,7 +3359,7 @@ void kfree(const void *x)
 EXPORT_SYMBOL(kfree);
 
 /*
- * kmem_cache_shrink removes empty slabs from the partial lists and sorts
+ * shrink_slab_cache removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
  * most items in use come first. New allocations will then fill those up
  * and thus they can be removed from the partial lists.
@@ -3368,7 +3368,7 @@ EXPORT_SYMBOL(kfree);
  * being allocated from last increasing the chance that the last objects
  * are freed in them.
  */
-int __kmem_cache_shrink(struct kmem_cache *s)
+static int shrink_slab_cache(struct kmem_cache *s)
 {
 	int node;
 	int i;
@@ -3423,6 +3423,32 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 	return 0;
 }
 
+static int __kmem_cache_shrink(struct kmem_cache *s)
+{
+	int node;
+	struct kmem_cache_node *n;
+	struct page *page, *t;
+	LIST_HEAD(discard);
+	unsigned long flags;
+	int ret = 0;
+
+	flush_all(s);
+	for_each_kmem_cache_node(s, node, n) {
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry_safe(page, t, &n->partial, lru)
+			if (!page->inuse)
+				list_move(&page->lru, &discard);
+		spin_unlock_irqrestore(&n->list_lock, flags);
+
+		list_for_each_entry_safe(page, t, &discard, lru)
+			discard_slab(s, page);
+
+		if (slabs_node(s, node))
+			ret = 1;
+	}
+	return ret;
+}
+
 static int slab_mem_going_offline_callback(void *arg)
 {
 	struct kmem_cache *s;
@@ -4683,7 +4709,7 @@ static ssize_t shrink_store(struct kmem_cache *s,
 			const char *buf, size_t length)
 {
 	if (buf[0] == '1') {
-		int rc = kmem_cache_shrink(s);
+		int rc = shrink_slab_cache(s);
 
 		if (rc)
 			return rc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
