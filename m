Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F52EC004C9
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEBC720675
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEBC720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5144E6B000C; Tue,  7 May 2019 20:10:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C3C16B000D; Tue,  7 May 2019 20:10:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DBFB6B000E; Tue,  7 May 2019 20:10:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03E056B000C
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:10:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i8so8932254pfo.21
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:10:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=BRMli1SPmPT1M1ZzEoZnww9z5elObfh02aZx1Lu8wmY=;
        b=K5ciTR2LzwRLmV68MI23MdWfw7G3/3uk6ESjVwwyRJ75bqcwVpY4lK83SwpHfLxAAl
         cvUKxKH8TYkVRGhAWWMOdE3xHvpXOiqK1N5Fq6DqGvzqF+sRDM+q/A5mYyExy5Vg5Dmm
         8AxaZaN4OvmvwfQV0DmBPAJU8SuWqkAAN73KUDqqQhzzlL28qUTq2vU6S2wgj/0/Z0Iz
         SIQBy3XI6ijiw+25Bo+6fqXVWHae0n3xTJfxzWWeiCe4SZcxiZhHb9h9VSIxSFTiRefF
         RfBcq/1kS0pcbd9ymzYAwR2SD8tAbeY0NrsoRgyboNCaskGg7VSYZxE/MRieaMHBZG9o
         EPlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUtqzCF1lXDjcml6CTo6jG7syRI78UvR3DUY5bcfKrZbUPamtCe
	HDEephfLFr6VnwxkvJVPh0FjemCAc12bkXGGXvMQRWpIIhGvYG68u0U6r1QAWA7hLMyEwQEKhCg
	Ex1LKSTHJVPjC9ER23DQj4QtER+YduUYSYA2mwBiZ4cy3UlgwX7m71wO5Asmmx2CdvQ==
X-Received: by 2002:a62:4e86:: with SMTP id c128mr44202596pfb.39.1557274209626;
        Tue, 07 May 2019 17:10:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzj1o8FXLpUH1mn3fsRKZ81700kiNxZ+tIB2b340IRI9rxbz2HGybnXg6j9h6RGvMkFl/w
X-Received: by 2002:a62:4e86:: with SMTP id c128mr44202508pfb.39.1557274208447;
        Tue, 07 May 2019 17:10:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557274208; cv=none;
        d=google.com; s=arc-20160816;
        b=E4Ush/5NoK0b9j4VArUt9sRwFymM4JtzpFOVpOsM0DLCmjC4m8OGHsh3lwlL54Yh/q
         SO1mZ2mSH1bQCjr7b+/sHftTsm25Fq3OghcZ2dQXsxoGRvzGbmS2JYW/ifRPl74wD3ND
         223W4WBbw9OeD83WjArvR330BguTBpAY8AQMGVxyCRkz2b1/72c7TZe7Dzq3KOBcb09P
         KAZQ+eW3RR0GdCReS1hTkm1OAALmbbDoSEVbaff5L+YUPRm1ct6JOmno/mHob7+fMAjU
         LoDQMtYKflS0P8he/cM/YzJ2nETf1r8I5rVktom4J33JW55A2ylQ2ZPgB5VpIhF3l/8R
         R5xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=BRMli1SPmPT1M1ZzEoZnww9z5elObfh02aZx1Lu8wmY=;
        b=PytntgVwb8jpqQQ8EgqMiI6/v/fmGNAcj4Np9T8Lbhjx/TM92Y3ahJvNDGmt9I54tT
         1hB1IF2NzHwnA5Sf2GU2D1+dFlzllNa8fNUQeFdsKuXoVln+3YRTZ+wRCnoCuFt9PF6e
         pb1uYivWPdvDl4i1kIvaU6qR/es6lkEWBMqcfPl2afAi3g/PTwIHUqXhsFTpZn/Kixnc
         7q8W9vFvaNliCP/4uR5HwhRiCJ3MPt70pxeS5/hlCBylx7KCOlt4aDVypcY2E+stbth0
         C0QF6tJTQEDaZXa3vzvWfN0rGN97QB+HdHENHpDhElMn3N32j4VERDaBSSK74YYbZavh
         utXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b6si4973500pgk.279.2019.05.07.17.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 17:10:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 May 2019 17:10:07 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 07 May 2019 17:10:07 -0700
Subject: [PATCH v2 4/6] lib/genalloc: Introduce chunk owners
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Christoph Hellwig <hch@lst.de>, Ira Weiny <ira.weiny@intel.com>,
 linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org
Date: Tue, 07 May 2019 16:56:21 -0700
Message-ID: <155727338118.292046.13407378933221579644.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The p2pdma facility enables a provider to publish a pool of dma
addresses for a consumer to allocate. A genpool is used internally by
p2pdma to collect dma resources, 'chunks', to be handed out to
consumers. Whenever a consumer allocates a resource it needs to pin the
'struct dev_pagemap' instance that backs the chunk selected by
pci_alloc_p2pmem().

Currently that reference is taken globally on the entire provider
device. That sets up a lifetime mismatch whereby the p2pdma core needs
to maintain hacks to make sure the percpu_ref is not released twice.

This lifetime mismatch also stands in the way of a fix to
devm_memremap_pages() whereby devm_memremap_pages_release() must wait
for the percpu_ref ->release() callback to complete before it can
proceed to teardown pages.

So, towards fixing this situation, introduce the ability to store a
'chunk owner' at gen_pool_add() time, and a facility to retrieve the
owner at gen_pool_{alloc,free}() time. For p2pdma this will be used to
store and recall individual dev_pagemap reference counter instances
per-chunk.

Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/genalloc.h |   55 +++++++++++++++++++++++++++++++++++++++++-----
 lib/genalloc.c           |   51 +++++++++++++++++++++----------------------
 2 files changed, 74 insertions(+), 32 deletions(-)

diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
index dd0a452373e7..a337313e064f 100644
--- a/include/linux/genalloc.h
+++ b/include/linux/genalloc.h
@@ -75,6 +75,7 @@ struct gen_pool_chunk {
 	struct list_head next_chunk;	/* next chunk in pool */
 	atomic_long_t avail;
 	phys_addr_t phys_addr;		/* physical starting address of memory chunk */
+	void *owner;			/* private data to retrieve at alloc time */
 	unsigned long start_addr;	/* start address of memory chunk */
 	unsigned long end_addr;		/* end address of memory chunk (inclusive) */
 	unsigned long bits[0];		/* bitmap for allocating memory chunk */
@@ -96,8 +97,15 @@ struct genpool_data_fixed {
 
 extern struct gen_pool *gen_pool_create(int, int);
 extern phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long);
-extern int gen_pool_add_virt(struct gen_pool *, unsigned long, phys_addr_t,
-			     size_t, int);
+extern int gen_pool_add_owner(struct gen_pool *, unsigned long, phys_addr_t,
+			     size_t, int, void *);
+
+static inline int gen_pool_add_virt(struct gen_pool *pool, unsigned long addr,
+		phys_addr_t phys, size_t size, int nid)
+{
+	return gen_pool_add_owner(pool, addr, phys, size, nid, NULL);
+}
+
 /**
  * gen_pool_add - add a new chunk of special memory to the pool
  * @pool: pool to add new memory chunk to
@@ -116,12 +124,47 @@ static inline int gen_pool_add(struct gen_pool *pool, unsigned long addr,
 	return gen_pool_add_virt(pool, addr, -1, size, nid);
 }
 extern void gen_pool_destroy(struct gen_pool *);
-extern unsigned long gen_pool_alloc(struct gen_pool *, size_t);
-extern unsigned long gen_pool_alloc_algo(struct gen_pool *, size_t,
-		genpool_algo_t algo, void *data);
+unsigned long gen_pool_alloc_algo_owner(struct gen_pool *pool, size_t size,
+		genpool_algo_t algo, void *data, void **owner);
+
+static inline unsigned long gen_pool_alloc_owner(struct gen_pool *pool,
+		size_t size, void **owner)
+{
+	return gen_pool_alloc_algo_owner(pool, size, pool->algo, pool->data,
+			owner);
+}
+
+static inline unsigned long gen_pool_alloc_algo(struct gen_pool *pool,
+		size_t size, genpool_algo_t algo, void *data)
+{
+	return gen_pool_alloc_algo_owner(pool, size, algo, data, NULL);
+}
+
+/**
+ * gen_pool_alloc - allocate special memory from the pool
+ * @pool: pool to allocate from
+ * @size: number of bytes to allocate from the pool
+ *
+ * Allocate the requested number of bytes from the specified pool.
+ * Uses the pool allocation function (with first-fit algorithm by default).
+ * Can not be used in NMI handler on architectures without
+ * NMI-safe cmpxchg implementation.
+ */
+static inline unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
+{
+	return gen_pool_alloc_algo(pool, size, pool->algo, pool->data);
+}
+
 extern void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size,
 		dma_addr_t *dma);
-extern void gen_pool_free(struct gen_pool *, unsigned long, size_t);
+extern void gen_pool_free_owner(struct gen_pool *pool, unsigned long addr,
+		size_t size, void **owner);
+static inline void gen_pool_free(struct gen_pool *pool, unsigned long addr,
+                size_t size)
+{
+	gen_pool_free_owner(pool, addr, size, NULL);
+}
+
 extern void gen_pool_for_each_chunk(struct gen_pool *,
 	void (*)(struct gen_pool *, struct gen_pool_chunk *, void *), void *);
 extern size_t gen_pool_avail(struct gen_pool *);
diff --git a/lib/genalloc.c b/lib/genalloc.c
index 7e85d1e37a6e..770c769d7cb7 100644
--- a/lib/genalloc.c
+++ b/lib/genalloc.c
@@ -168,20 +168,21 @@ struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
 EXPORT_SYMBOL(gen_pool_create);
 
 /**
- * gen_pool_add_virt - add a new chunk of special memory to the pool
+ * gen_pool_add_owner- add a new chunk of special memory to the pool
  * @pool: pool to add new memory chunk to
  * @virt: virtual starting address of memory chunk to add to pool
  * @phys: physical starting address of memory chunk to add to pool
  * @size: size in bytes of the memory chunk to add to pool
  * @nid: node id of the node the chunk structure and bitmap should be
  *       allocated on, or -1
+ * @owner: private data the publisher would like to recall at alloc time
  *
  * Add a new chunk of special memory to the specified pool.
  *
  * Returns 0 on success or a -ve errno on failure.
  */
-int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phys,
-		 size_t size, int nid)
+int gen_pool_add_owner(struct gen_pool *pool, unsigned long virt, phys_addr_t phys,
+		 size_t size, int nid, void *owner)
 {
 	struct gen_pool_chunk *chunk;
 	int nbits = size >> pool->min_alloc_order;
@@ -195,6 +196,7 @@ int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phy
 	chunk->phys_addr = phys;
 	chunk->start_addr = virt;
 	chunk->end_addr = virt + size - 1;
+	chunk->owner = owner;
 	atomic_long_set(&chunk->avail, size);
 
 	spin_lock(&pool->lock);
@@ -203,7 +205,7 @@ int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phy
 
 	return 0;
 }
-EXPORT_SYMBOL(gen_pool_add_virt);
+EXPORT_SYMBOL(gen_pool_add_owner);
 
 /**
  * gen_pool_virt_to_phys - return the physical address of memory
@@ -260,35 +262,20 @@ void gen_pool_destroy(struct gen_pool *pool)
 EXPORT_SYMBOL(gen_pool_destroy);
 
 /**
- * gen_pool_alloc - allocate special memory from the pool
- * @pool: pool to allocate from
- * @size: number of bytes to allocate from the pool
- *
- * Allocate the requested number of bytes from the specified pool.
- * Uses the pool allocation function (with first-fit algorithm by default).
- * Can not be used in NMI handler on architectures without
- * NMI-safe cmpxchg implementation.
- */
-unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
-{
-	return gen_pool_alloc_algo(pool, size, pool->algo, pool->data);
-}
-EXPORT_SYMBOL(gen_pool_alloc);
-
-/**
- * gen_pool_alloc_algo - allocate special memory from the pool
+ * gen_pool_alloc_algo_owner - allocate special memory from the pool
  * @pool: pool to allocate from
  * @size: number of bytes to allocate from the pool
  * @algo: algorithm passed from caller
  * @data: data passed to algorithm
+ * @owner: optionally retrieve the chunk owner
  *
  * Allocate the requested number of bytes from the specified pool.
  * Uses the pool allocation function (with first-fit algorithm by default).
  * Can not be used in NMI handler on architectures without
  * NMI-safe cmpxchg implementation.
  */
-unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
-		genpool_algo_t algo, void *data)
+unsigned long gen_pool_alloc_algo_owner(struct gen_pool *pool, size_t size,
+		genpool_algo_t algo, void *data, void **owner)
 {
 	struct gen_pool_chunk *chunk;
 	unsigned long addr = 0;
@@ -299,6 +286,9 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
 	BUG_ON(in_nmi());
 #endif
 
+	if (owner)
+		*owner = NULL;
+
 	if (size == 0)
 		return 0;
 
@@ -326,12 +316,14 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
 		addr = chunk->start_addr + ((unsigned long)start_bit << order);
 		size = nbits << order;
 		atomic_long_sub(size, &chunk->avail);
+		if (owner)
+			*owner = chunk->owner;
 		break;
 	}
 	rcu_read_unlock();
 	return addr;
 }
-EXPORT_SYMBOL(gen_pool_alloc_algo);
+EXPORT_SYMBOL(gen_pool_alloc_algo_owner);
 
 /**
  * gen_pool_dma_alloc - allocate special memory from the pool for DMA usage
@@ -367,12 +359,14 @@ EXPORT_SYMBOL(gen_pool_dma_alloc);
  * @pool: pool to free to
  * @addr: starting address of memory to free back to pool
  * @size: size in bytes of memory to free
+ * @owner: private data stashed at gen_pool_add() time
  *
  * Free previously allocated special memory back to the specified
  * pool.  Can not be used in NMI handler on architectures without
  * NMI-safe cmpxchg implementation.
  */
-void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
+void gen_pool_free_owner(struct gen_pool *pool, unsigned long addr, size_t size,
+		void **owner)
 {
 	struct gen_pool_chunk *chunk;
 	int order = pool->min_alloc_order;
@@ -382,6 +376,9 @@ void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
 	BUG_ON(in_nmi());
 #endif
 
+	if (owner)
+		*owner = NULL;
+
 	nbits = (size + (1UL << order) - 1) >> order;
 	rcu_read_lock();
 	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
@@ -392,6 +389,8 @@ void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
 			BUG_ON(remain);
 			size = nbits << order;
 			atomic_long_add(size, &chunk->avail);
+			if (owner)
+				*owner = chunk->owner;
 			rcu_read_unlock();
 			return;
 		}
@@ -399,7 +398,7 @@ void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
 	rcu_read_unlock();
 	BUG();
 }
-EXPORT_SYMBOL(gen_pool_free);
+EXPORT_SYMBOL(gen_pool_free_owner);
 
 /**
  * gen_pool_for_each_chunk - call func for every chunk of generic memory pool

