Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91ECF6B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 23:02:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n189so196005315qke.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:02:43 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id e23si12166297qte.88.2016.10.24.20.02.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 20:02:43 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH 0/2] to support memblock near alloc and memoryless on arm64
Date: Tue, 25 Oct 2016 10:59:16 +0800
Message-ID: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

If HAVE_MEMORYLESS_NODES is selected, and some memoryless numa nodes are
actually exist. The percpu variable areas and numa control blocks of that
memoryless numa nodes need to be allocated from the nearest available
node to improve performance.

In the beginning, I added a new function:
phys_addr_t __init memblock_alloc_near_nid(phys_addr_t size, phys_addr_t align, int nid);

But it can not replace memblock_virt_alloc_try_nid, because the latter can specify a min_addr,
it usually be assigned as __pa(MAX_DMA_ADDRESS), to prevent memory be allocated from DMA area.
It's bad to add another function, because the code will be duplicated in these two functions.

So I make memblock_alloc_near_nid to be called in the subfunctions of memblock_alloc_try_nid
and memblock_virt_alloc_try_nid. Add a macro node_distance_ready to distinguish different
situations:
1) By default, the value of node_distance_ready is zero, memblock_*_try_nid work as normal as before.
2) ARCH platforms set the value of node_distance_ready to be true when numa node distances are ready, (please refer patch 2)
   memblock_*_try_nid allocate memory from the nearest node relative to the specified node.

Zhen Lei (2):
  mm/memblock: prepare a capability to support memblock near alloc
  arm64/numa: support HAVE_MEMORYLESS_NODES

 arch/arm64/Kconfig            |  4 +++
 arch/arm64/include/asm/numa.h |  3 ++
 arch/arm64/mm/numa.c          |  6 +++-
 mm/memblock.c                 | 76 ++++++++++++++++++++++++++++++++++++-------
 4 files changed, 77 insertions(+), 12 deletions(-)

-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
