Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC2F6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 01:07:55 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id a143so108157296oii.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 22:07:55 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id w191si2596310ita.11.2016.05.25.22.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 22:07:53 -0700 (PDT)
Date: Thu, 26 May 2016 15:07:48 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] mm/cma: silence warnings due to max() usage
Message-ID: <20160526150748.5be38a4f@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

pageblock_order can be (at least) an unsigned int or an unsigned long
depending on the kernel config and architecture, so use max_t(unsigned
long, ...) when comparing it.

fixes these warnings:

In file included from include/asm-generic/bug.h:13:0,
                 from arch/powerpc/include/asm/bug.h:127,
                 from include/linux/bug.h:4,
                 from include/linux/mmdebug.h:4,
                 from include/linux/mm.h:8,
                 from include/linux/memblock.h:18,
                 from mm/cma.c:28:
mm/cma.c: In function 'cma_init_reserved_mem':
include/linux/kernel.h:748:17: warning: comparison of distinct pointer types lacks a cast
  (void) (&_max1 == &_max2);  \
                 ^
mm/cma.c:186:27: note: in expansion of macro 'max'
  alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
                           ^
mm/cma.c: In function 'cma_declare_contiguous':
include/linux/kernel.h:748:17: warning: comparison of distinct pointer types lacks a cast
  (void) (&_max1 == &_max2);  \
                 ^
include/linux/kernel.h:747:9: note: in definition of macro 'max'
  typeof(y) _max2 = (y);   \
         ^
mm/cma.c:270:29: note: in expansion of macro 'max'
   (phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
                             ^
include/linux/kernel.h:748:17: warning: comparison of distinct pointer types lacks a cast
  (void) (&_max1 == &_max2);  \
                 ^
include/linux/kernel.h:747:21: note: in definition of macro 'max'
  typeof(y) _max2 = (y);   \
                     ^
mm/cma.c:270:29: note: in expansion of macro 'max'
   (phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
                             ^

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 mm/cma.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

These warnings have been irking me for some time now ... applies to
Linus' tree and linux-next (and so to the mmotm tree).

diff --git a/mm/cma.c b/mm/cma.c
index ea506eb18cd6..fa823dc2ff15 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -183,7 +183,7 @@ int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 		return -EINVAL;
 
 	/* ensure minimal alignment required by mm core */
-	alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
+	alignment = PAGE_SIZE << max_t(unsigned long, MAX_ORDER - 1, pageblock_order);
 
 	/* alignment should be aligned with order_per_bit */
 	if (!IS_ALIGNED(alignment >> PAGE_SHIFT, 1 << order_per_bit))
@@ -267,7 +267,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	 * you couldn't get a contiguous memory, which is not what we want.
 	 */
 	alignment = max(alignment,
-		(phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
+		(phys_addr_t)PAGE_SIZE << max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
 	base = ALIGN(base, alignment);
 	size = ALIGN(size, alignment);
 	limit &= ~(alignment - 1);
-- 
2.8.1



-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
