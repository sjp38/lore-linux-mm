Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C4C8B6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 18:28:05 -0400 (EDT)
Received: by padck2 with SMTP id ck2so12319170pad.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 15:28:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id iv9si12396970pac.228.2015.07.29.15.28.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 15:28:04 -0700 (PDT)
Date: Wed, 29 Jul 2015 15:28:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slab:Fix the unexpected index mapping result of
 kmalloc_size(INDEX_NODE + 1)
Message-Id: <20150729152803.67f593847050419a8696fe28@linux-foundation.org>
In-Reply-To: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liu.hailong6@zte.com.cn
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, jiang.xuexin@zte.com.cn, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>


That patch is a bit of a mess.  Below is a cleaned up version.

It appears that the regression you've identified was caused by

commit e33660165c901d18e7d3df2290db070d3e4b46df
Author: Christoph Lameter <cl@linux.com>
Date:   Thu Jan 10 19:14:18 2013 +0000

    slab: Use common kmalloc_index/kmalloc_size functions


Reviewers sought, please.



From: Liuhailong <liu.hailong6@zte.com.cn>
Subject: slab: fix unexpected index mapping result of kmalloc_size(INDEX_NODE + 1)

Kernels after v3.9 use kmalloc_size(INDEX_NODE + 1) to get the next larger
cache size than the size index INDEX_NODE mapping.  In kernels 3.9 and
earlier we used malloc_sizes[INDEX_L3 + 1].cs_size.

However, sometimes we can't get the right output we expected via
kmalloc_size(INDEX_NODE + 1), causing a BUG().

The mapping table in the latest kernel is like:
    index = {0,   1,  2 ,  3,  4,   5,   6,   n}
     size = {0,   96, 192, 8, 16,  32,  64,   2^n}
The mapping table before 3.10 is like this:
    index = {0 , 1 , 2,   3,  4 ,  5 ,  6,   n}
    size  = {32, 64, 96, 128, 192, 256, 512, 2^(n+3)}

The problem on my mips64 machine is as follows:

(1) When configured DEBUG_SLAB && DEBUG_PAGEALLOC && DEBUG_LOCK_ALLOC
    && DEBUG_SPINLOCK, the sizeof(struct kmem_cache_node) will be "150",
    and the macro INDEX_NODE turns out to be "2": #define INDEX_NODE
    kmalloc_index(sizeof(struct kmem_cache_node))

(2) Then the result of kmalloc_size(INDEX_NODE + 1) is 8.

(3) Then "if(size >= kmalloc_size(INDEX_NODE + 1)" will lead to "size
    = PAGE_SIZE".

(4) Then "if ((size >= (PAGE_SIZE >> 3))" test will be satisfied and
    "flags |= CFLGS_OFF_SLAB" will be covered.

(5) if (flags & CFLGS_OFF_SLAB)" test will be satisfied and will go to
    "cachep->slabp_cache = kmalloc_slab(slab_size, 0u)", and the result
    here may be NULL while kernel bootup.

(6) Finally,"BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));" causes the
    BUG info as the following shows (may be only mips64 has this problem):

 #20
task: ffffffffc072cdc0 ti: ffffffffc06b4000 task.ti: ffffffffc06b4000
$ 0   : 0000000000000000 0000000000000018 0000000000000001 0000000100000fff
$ 4   : 0000000000000030 0000000000000000 0000000000001004 0000000000001000
$ 8   : ffffffff80002800 000000000000000b 0000000000000000 0000000000000000
$12   : 0000000080000000 0000000000000000 c0000000bf818ebc c0000000bf818eb8
$16   : c0000000bf818ea0 0000000080002800 0000000000000000 0000000000001000
$20   : 0000000000000034 0000000080000000 0000000000000000 0000000000000006
$24   : ffffffffc1160000 00000000000003f4
$28   : ffffffffc06b4000 ffffffffc06b7d40 0000000000002000 ffffffffc01d077c
Hi    : 0000000000000fff
Lo    : 0000000000100000
epc   : ffffffffc01d0784 __kmem_cache_create+0x2ac/0x530
    Not tainted
ra    : ffffffffc01d077c __kmem_cache_create+0x2a4/0x530
Status: 141000e2        KX SX UX KERNEL EXL
Cause : 40808034
PrId  : 000c1300 (Broadcom XLPII)
Process swapper (pid: 0, threadinfo=ffffffffc06b4000, task=ffffffffc072cdc
        0,tls=0000000000000000)
*HwTLS: fffffffffadebeef
Stack : 00000000c073b018 c0000000bf818ea0 0000000000000040 0000000000000000
        ffffffffc115b360 ffffffffc115b360 0000000000000017 0000000000000007
        0000000000000006 ffffffffc0780f54 0000000000002000 0000000000000040
        c0000000bf818ea0 0000000000000000 0000000000000040 ffffffffc0780fec
        0000000000002000 c0000000bf810fc0 ffffffffc115b390 0000000000000006
        ffffffffc1160000 ffffffffc07810b0 0000000000000001 c0000000bf809000
        ffffffffc0a30000 ffffffffc07a0000 ffffffffc07a1758 ffffffffc0a30000
        ffffffff8c190000 ffffffff8bd02983 0000000000000000 ffffffff8c18f798
        0000000000000000 ffffffffc07746e0 ffffffffc07a1758 0000000000000000
        0000000000000000 ffffffff805c5580 0000000000000000 0000000000000000
          ...
Call Trace:
[<ffffffffc01d0784>] __kmem_cache_create+0x2ac/0x530
[<ffffffffc0780f54>] create_boot_cache+0x54/0x90
[<ffffffffc0780fec>] create_kmalloc_cache+0x5c/0x94
[<ffffffffc07810b0>] create_kmalloc_caches+0x8c/0x1b0
[<ffffffffc07746e0>] start_kernel+0x1a0/0x408

This patch fixes the problem of kmalloc_size(INDEX_NODE + 1) removes the
BUG.  I tested it on my mips64 mechine.

Signed-off-by: Liuhailong <liu.hailong6@zte.com.cn>
Reviewed-by: Jianxuexin <jiang.xuexin@zte.com.cn>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/slab.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/slab.c~slab-fix-the-unexpected-index-mapping-result-of-kmalloc_sizeindex_node-1 mm/slab.c
--- a/mm/slab.c~slab-fix-the-unexpected-index-mapping-result-of-kmalloc_sizeindex_node-1
+++ a/mm/slab.c
@@ -2190,7 +2190,7 @@ __kmem_cache_create (struct kmem_cache *
 			size += BYTES_PER_WORD;
 	}
 #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
-	if (size >= kmalloc_size(INDEX_NODE + 1)
+	if (size >= kmalloc_size(INDEX_NODE) * 2
 	    && cachep->object_size > cache_line_size()
 	    && ALIGN(size, cachep->align) < PAGE_SIZE) {
 		cachep->obj_offset += PAGE_SIZE - ALIGN(size, cachep->align);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
