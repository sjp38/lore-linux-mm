Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6530E82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:39:16 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so31901116pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:39:16 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id sg1si1211334pac.95.2015.11.04.07.39.15
        for <linux-mm@kvack.org>;
        Wed, 04 Nov 2015 07:39:15 -0800 (PST)
Date: Wed, 4 Nov 2015 15:39:10 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: Increase the max granular size
Message-ID: <20151104153910.GN7637@e104818-lin.cambridge.arm.com>
References: <CAMuHMdWQygbxMXoOsbwek6DzZcr7J-C23VCK4ubbgUr+zj=giw@mail.gmail.com>
 <20151103120504.GF7637@e104818-lin.cambridge.arm.com>
 <20151103143858.GI7637@e104818-lin.cambridge.arm.com>
 <CAMuHMdWk0fPzTSKhoCuS4wsOU1iddhKJb2SOpjo=a_9vCm_KXQ@mail.gmail.com>
 <20151103185050.GJ7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511031724010.8178@east.gentwo.org>
 <20151104123640.GK7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511040748590.17248@east.gentwo.org>
 <20151104145445.GL7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511040927510.18745@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511040927510.18745@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Robert Richter <rric@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Linux-sh list <linux-sh@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Robert Richter <rrichter@cavium.com>, linux-mm@kvack.org, Tirumalesh Chalamarla <tchalamarla@cavium.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Nov 04, 2015 at 09:28:34AM -0600, Christoph Lameter wrote:
> On Wed, 4 Nov 2015, Catalin Marinas wrote:
> 
> > BTW, assuming L1_CACHE_BYTES is 512 (I don't ever see this happening but
> > just in theory), we potentially have the same issue. What would save us
> > is that INDEX_NODE would match the first "kmalloc-512" cache, so we have
> > it pre-populated.
> 
> Ok maybe add some BUILD_BUG_ONs to ensure that builds fail until we have
> addressed that.

A BUILD_BUG_ON should be fine.

Thinking some more, I think if KMALLOC_MIN_SIZE is 128, there is no gain
with off-slab management since the freelist allocation would still be
128 bytes. An alternative to reverting while still having a little
benefit of off-slab for 256 bytes objects (rather than 512 as we would
get with the revert):

diff --git a/mm/slab.c b/mm/slab.c
index 4fcc5dd8d5a6..ac32b4a0f2ec 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2212,8 +2212,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * it too early on. Always use on-slab management when
 	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
 	 */
-	if ((size >= (PAGE_SIZE >> 5)) && !slab_early_init &&
-	    !(flags & SLAB_NOLEAKTRACE))
+	if ((size >= (PAGE_SIZE >> 5)) && (size > KMALLOC_MIN_SIZE) &&
+		!slab_early_init && !(flags & SLAB_NOLEAKTRACE))
 		/*
 		 * Size is large, assume best to place the slab management obj
 		 * off-slab (should allow better packing of objs).

Whichever you prefer.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
