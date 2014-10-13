Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8B06B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 01:58:27 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so5353338pad.11
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 22:58:27 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id mq9si9520796pdb.91.2014.10.12.22.58.25
        for <linux-mm@kvack.org>;
        Sun, 12 Oct 2014 22:58:26 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH for v3.18-rc1] mm/slab: fix unaligned access on sparc64
Date: Mon, 13 Oct 2014 14:58:47 +0900
Message-Id: <1413179927-10533-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>, mroos@linux.ee, sparclinux@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

commit bf0dea23a9c0 ("mm/slab: use percpu allocator for cpu cache") changes
allocation method for cpu cache array from slab allocator to percpu allocator.
Alignment should be provided for aligned memory in percpu allocator case, but,
that commit mistakenly set this alignment to 0. So, percpu allocator returns
unaligned memory address. It doesn't cause any problem on x86 which permits
unaligned access, but, it causes the problem on sparc64 which needs strong
guarantee of alignment.

Following bug report is reported from David Miller.

  I'm getting tons of the following on sparc64:

  [603965.383447] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
  [603965.396987] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
  [603965.410523] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
  [603965.424061] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
  [603965.437617] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
  [603970.554394] log_unaligned: 333 callbacks suppressed
  [603970.564041] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
  [603970.577576] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
  [603970.591122] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
  [603970.604669] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
  [603970.618216] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
  [603976.515633] log_unaligned: 31 callbacks suppressed
  snip...

This patch provides proper alignment parameter when allocating cpu cache to
fix this unaligned memory access problem on sparc64.

Reported-by: David Miller <davem@davemloft.net>
Tested-by: David Miller <davem@davemloft.net>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 154aac8..eb2b2ea 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1992,7 +1992,7 @@ static struct array_cache __percpu *alloc_kmem_cache_cpus(
 	struct array_cache __percpu *cpu_cache;
 
 	size = sizeof(void *) * entries + sizeof(struct array_cache);
-	cpu_cache = __alloc_percpu(size, 0);
+	cpu_cache = __alloc_percpu(size, sizeof(void *));
 
 	if (!cpu_cache)
 		return NULL;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
