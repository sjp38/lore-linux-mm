Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id CF80D6B012F
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 20:02:46 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id h3so2058151igd.13
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 17:02:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id om6si21696651igb.15.2014.11.11.17.02.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Nov 2014 17:02:45 -0800 (PST)
Date: Tue, 11 Nov 2014 17:02:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-Id: <20141111170243.c24ce5fdb5efaf0814071847@linux-foundation.org>
In-Reply-To: <201411120054.04651.luke@dashjr.org>
References: <bug-87891-27@https.bugzilla.kernel.org/>
	<alpine.DEB.2.11.1411111833220.8762@gentwo.org>
	<20141111164913.3616531c21c91499871c46de@linux-foundation.org>
	<201411120054.04651.luke@dashjr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luke Dashjr <luke@dashjr.org>
Cc: Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Wed, 12 Nov 2014 00:54:01 +0000 Luke Dashjr <luke@dashjr.org> wrote:

> On Wednesday, November 12, 2014 12:49:13 AM Andrew Morton wrote:
> > But anyway - Luke, please attach your .config to
> > https://bugzilla.kernel.org/show_bug.cgi?id=87891?
> 
> Done: https://bugzilla.kernel.org/attachment.cgi?id=157381
> 

OK, thanks.  No CONFIG_HIGHMEM of course.  I'm stumped.

It might just have been a random memory bitflip or other corruption of
course.  Is it repeatable at all?

If it is, please add the below and retest?

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
diff -puN mm/slub.c~slab-improve-checking-for-invalid-gfp_flags mm/slub.c
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
