Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD906B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 16:10:43 -0400 (EDT)
Date: Tue, 14 Jun 2011 22:10:31 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH] slob: push the min alignment to long long
Message-ID: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org

In SLOB ARCH_KMALLOC_MINALIGN is 4 on 32bit platforms by default. On
powerpc and some other architectures except x86 the default alignment of
u64 is 8. The leads to __alignof__(struct ipt_entry) being 8 instead of 4
which is enforced by SLOB.
This leads funny behavior where "iptables -nvL -t nat" does not work on
the first invocation but on the second. The network code has more than one
check of this kind for the correct alignment of the allocated struct.
I personally don't understand why u64 needs 8byte alignment on a 32bit
platform since all access happens via two 4byte reads/writes. I know that
x86_32 has a 64bit cmpxchg instruction but they have also the 4byte
alignment of u64, remember?
David S. Miller says "An allocator needs to provide memory with the maximum
alignment that might be required for types on a given architecture. " [0]
and the fact that gcc on x86 doesn't do it is actually gcc's fault.
Therefore I'm changing the default alignment of SLOB to 8. This fixes my
netfilter problems (and probably other) and we have consistent behavior
across all SL*B allocators.

[0]  http://www.spinics.net/lists/netfilter/msg51123.html

Cc: stable@kernel.org
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
 include/linux/slob_def.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
index 4382db0..019f713 100644
--- a/include/linux/slob_def.h
+++ b/include/linux/slob_def.h
@@ -4,11 +4,11 @@
 #ifdef ARCH_DMA_MINALIGN
 #define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
 #else
-#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long)
+#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
 #endif
 
 #ifndef ARCH_SLAB_MINALIGN
-#define ARCH_SLAB_MINALIGN __alignof__(unsigned long)
+#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif
 
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
