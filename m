Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1B16B0290
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:41:01 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id n68so24280483qkn.8
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:41:01 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id 3si3005205qtp.70.2018.11.12.07.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:41:00 -0800 (PST)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v4 0/9] mpt3sas and dmapool scalability
Message-ID: <88395080-efc1-4e7b-f813-bb90c86d0745@cybernetics.com>
Date: Mon, 12 Nov 2018 10:40:57 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, linux-mm@kvack.org
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

I posted v3 on August 7.  Nobody acked or merged the patches, and then
I got too busy with other stuff to repost until now.

The only change since v3:
*) Dropped patch #10 (the mpt3sas patch) since the mpt3sas maintainers
didn't show any interest.

I believe these patches are ready for merging.

---

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
seconds.

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

The patches in this series improve the scalability of the DMA pool
implementation, which significantly reduces the running time of the
DMA alloc/free loops.  With the patches applied, "modprobe mpt3sas",
"rmmod mpt3sas", and system shutdown/reboot with mpt3sas loaded are
significantly faster.  Here are some benchmarks (of DMA alloc/free
only, not the entire modprobe/rmmod):

dma_pool_create() + dma_pool_alloc() loop, size = 128, count = 373959
  original:        350 ms ( 1x)
  dmapool patches:  17 ms (21x)

dma_pool_free() loop + dma_pool_destroy(), size = 128, count = 373959
  original:        8901 ms (   1x)
  dmapool patches:   15 ms ( 618x)
