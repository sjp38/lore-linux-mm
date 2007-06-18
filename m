Message-Id: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:38 -0700
From: clameter@sgi.com
Subject: [patch 00/26] Current slab allocator / SLUB patch queue
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

These contain the following groups of patches:

1. Slab allocator code consolidation and fixing of inconsistencies

This makes ZERO_SIZE_PTR generic so that it works in all
slab allocators.

It adds __GFP_ZERO support to all slab allocators and
cleans up the zeroing in the slabs and provides modifications
to remove explicit zeroing following kmalloc_node and
kmem_cache_alloc_node calls.

2. SLUB improvements

Inline some small functions to reduce code size. Some more memory
optimizations using CONFIG_SLUB_DEBUG. Changes to handling of the
slub_lock and an optimization of runtime determination of kmalloc slabs
(replaces ilog2 patch that failed with gcc 3.3 on powerpc).

3. Slab defragmentation

This is V3 of the patchset with the one fix for the locking problem that
showed up during testing.

4. Performance optimizations

These patches have a long history since the early drafts of SLUB. The
problem with these patches is that they require the touching of additional
cachelines (only for read) and SLUB was designed for minimal cacheline
touching. In doing so we may be able to remove cacheline bouncing in
particular for remote alloc/ free situations where I have had reports of
issues that I was not able to confirm for lack of specificity. The tradeoffs
here are not clear. Certainly the larger cacheline footprint will hurt the
casual slab user somewhat but it will benefit processes that perform these
local/remote alloc/free operations.

I'd appreciate if someone could evaluate these.

The complete patchset against 2.6.22-rc4-mm2 is available at

http://ftp.kernel.org/pub/linux/kernel/people/christoph/slub/2.6.22-rc4-mm2

Tested on

x86_64 SMP
x86_64 NUMA emulation
IA64 emulator
Altix 64p/128G NUMA system.
Altix 8p/6G asymmetric NUMA system.


-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
