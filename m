Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 70F606B0125
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:53:34 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id y20so12647989ier.39
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:53:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cx3si26888855icb.79.2014.11.11.16.53.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Nov 2014 16:53:33 -0800 (PST)
Date: Tue, 11 Nov 2014 16:53:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-Id: <20141111165331.152562c12f03716334e2cfa0@linux-foundation.org>
In-Reply-To: <20141112004419.GA8075@js1304-P5Q-DELUXE>
References: <bug-87891-27@https.bugzilla.kernel.org/>
	<20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
	<20141112004419.GA8075@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Wed, 12 Nov 2014 09:44:19 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> > 
> > And it's quite infuriating to go BUG when the code could easily warn
> > and fix it up.
> 
> If user wants memory on HIGHMEM, it can be easily fixed by following
> change because all memory is compatible for HIGHMEM. But, if user wants
> memory on DMA32, it's not easy to fix because memory on NORMAL isn't
> compatible with DMA32. slab could return object from another slab page
> even if cache_grow() is successfully called. So BUG_ON() here
> looks right thing to me. We cannot know in advance whether ignoring this
> flag cause more serious result or not.

Well, attempting to fix it up and continue is nice, but we can live
with the BUG.

Not knowing which bit was set is bad.

diff -puN mm/slab.c~slab-improve-checking-for-invalid-gfp_flags mm/slab.c
--- a/mm/slab.c~slab-improve-checking-for-invalid-gfp_flags
+++ a/mm/slab.c
@@ -2590,7 +2590,10 @@ static int cache_grow(struct kmem_cache
 	 * Be lazy and only check for valid flags here,  keeping it out of the
 	 * critical path in kmem_cache_alloc().
 	 */
-	BUG_ON(flags & GFP_SLAB_BUG_MASK);
+	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
+		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
+		BUG();
+	}
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 	/* Take the node list lock to change the colour_next on this node */
--- a/mm/slub.c~slab-improve-checking-for-invalid-gfp_flags
+++ a/mm/slub.c
@@ -1377,7 +1377,10 @@ static struct page *new_slab(struct kmem
 	int order;
 	int idx;
 
-	BUG_ON(flags & GFP_SLAB_BUG_MASK);
+	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
+		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
+		BUG();
+	}
 
 	page = allocate_slab(s,
 		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
