Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A67C26B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 16:04:23 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s68-v6so17693912oih.23
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 13:04:23 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i11-v6si8628047oia.112.2018.08.01.13.04.22
        for <linux-mm@kvack.org>;
        Wed, 01 Aug 2018 13:04:22 -0700 (PDT)
From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [RFC 1/2] slub: Avoid trying to allocate memory on offline nodes
Date: Wed,  1 Aug 2018 15:04:17 -0500
Message-Id: <20180801200418.1325826-2-jeremy.linton@arm.com>
In-Reply-To: <20180801200418.1325826-1-jeremy.linton@arm.com>
References: <20180801200418.1325826-1-jeremy.linton@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org, Jeremy Linton <jeremy.linton@arm.com>

If a user calls the *alloc_node() functions with an invalid node
its possible to crash in alloc_pages_nodemask because NODE_DATA()
returns a bad node, which propogates into the node zonelist in
prepare_alloc_pages. This avoids that by not trying to allocate
new slabs against offline nodes.

(example backtrace)

  __alloc_pages_nodemask+0x128/0xf48
  allocate_slab+0x94/0x528
  new_slab+0x68/0xc8
  ___slab_alloc+0x44c/0x520
  __slab_alloc+0x50/0x68
  kmem_cache_alloc_node_trace+0xe0/0x230

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 mm/slub.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 51258eff4178..e03719bac1e2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2519,6 +2519,8 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 		if (unlikely(!node_match(page, searchnode))) {
 			stat(s, ALLOC_NODE_MISMATCH);
 			deactivate_slab(s, page, c->freelist, c);
+			if (!node_online(searchnode))
+				node = NUMA_NO_NODE;
 			goto new_slab;
 		}
 	}
-- 
2.14.3
