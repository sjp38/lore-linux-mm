Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8AD6B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 14:54:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i8-v6so2123460qke.7
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:54:03 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id o39-v6si290697qtf.75.2018.07.26.11.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 11:54:02 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH 0/3] mpt3sas and dmapool scalability
Message-ID: <73ec1f52-d758-05df-fb6a-41d269e910d0@cybernetics.com>
Date: Thu, 26 Jul 2018 14:53:46 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Matthew Wilcox <willy@infradead.org>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

drivers/scsi/mpt3sas is running into a scalability problem with the
kernel's DMA pool implementation.  With a LSI/Broadcom SAS 9300-8i
12Gb/s HBA and max_sgl_entries=256, during modprobe, mpt3sas does the
equivalent of:

chain_dma_pool = dma_pool_create(size = 128);
for (i = 0; i < 373959; i++)
    {
    dma_addr[i] = dma_pool_alloc(chain_dma_pool);
    }

And at rmmod, system shutdown, or system reboot, mpt3sas does the
equivalent of:

for (i = 0; i < 373959; i++)
    {
    dma_pool_free(chain_dma_pool, dma_addr[i]);
    }
dma_pool_destroy(chain_dma_pool);

With this usage, both dma_pool_alloc() and dma_pool_free() exhibit
O(n^2) complexity, although dma_pool_free() is much worse due to
implementation details.  On my system, the dma_pool_free() loop above
takes about 9 seconds to run.  Note that the problem was even worse
before commit 74522a92bbf0 ("scsi: mpt3sas: Optimize I/O memory
consumption in driver."), where the dma_pool_free() loop could take ~30
seconds because the iteration count was bigger.

mpt3sas also has some other DMA pools, but chain_dma_pool is the only
one with so many allocations:

cat /sys/devices/pci0000:80/0000:80:07.0/0000:85:00.0/pools
(manually cleaned up column alignment)
poolinfo - 0.1
reply_post_free_array pool  1      21     192     1
reply_free pool             1      1      41728   1
reply pool                  1      1      1335296 1
sense pool                  1      1      970272  1
chain pool                  373959 386048 128     12064
reply_post_free pool        12     12     166528  12

The first two patches in this series improve the scalability of the DMA
pool implementation, which significantly reduces the running time of the
DMA alloc/free loops.

The third patch modifies mpt3sas to replace chain_dma_pool with direct
calls to dma_alloc_coherent() and dma_free_coherent().  This eliminates
the allocation of up to 12,064 "struct dma_page" per ioc (the exact
number depends on the HBA's can_queue and sg_tablesize) and reduces
overhead even further.

The mpt3sas patch is independent of the dmapool patches; it can be used
with or without them.  If either the dmapool patches or the mpt3sas
patch is applied, then "modprobe mpt3sas", "rmmod mpt3sas", and system
shutdown/reboot with mpt3sas loaded are significantly faster.  Here are
some benchmarks (of DMA alloc/free only, not the entire modprobe/rmmod):

dma_pool_create() + dma_pool_alloc() loop, size = 128, count = 373959
  original:        350 ms ( 1x)
  dmapool patches:  18 ms (19x)
  mpt3sas patch:     7 ms (51x)

dma_pool_free() loop + dma_pool_destroy(), size = 128, count = 373959
  original:        8901 ms (   1x)
  dmapool patches:   19 ms ( 477x)
  mpt3sas patch:      2 ms (4245x)

Considering that LSI/Broadcom offer an out-of-tree vendor driver that
works across multiple kernel versions that won't get the dmapool
patches, it may be worth it for them to patch mpt3sas to avoid the
problem on older kernels.  The downside is that the code is a bit more
complicated.  So I leave it to their judgement whether they think it is
worth it to apply the mpt3sas patch.
