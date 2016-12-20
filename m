Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAF6F6B030B
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:28:15 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id t184so24477340qkd.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:28:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v127si2491451qkh.28.2016.12.20.05.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:28:15 -0800 (PST)
Subject: [RFC PATCH 1/4] doc: page_pool introduction documentation
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 20 Dec 2016 14:28:12 +0100
Message-ID: <20161220132812.18788.20431.stgit@firesoul>
In-Reply-To: <20161220132444.18788.50875.stgit@firesoul>
References: <20161220132444.18788.50875.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>

Copied from:
 https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/introduction.html
 ~/git/prototype-kernel/kernel/Documentation/vm/page_pool/introduction.rst

This will be updated from above links before upstream submit.
Also this need to be "linked" into new kernel doc system.
---
 Documentation/vm/page_pool/introduction.rst |   71 +++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)
 create mode 100644 Documentation/vm/page_pool/introduction.rst

diff --git a/Documentation/vm/page_pool/introduction.rst b/Documentation/vm/page_pool/introduction.rst
new file mode 100644
index 000000000000..db03b02f218c
--- /dev/null
+++ b/Documentation/vm/page_pool/introduction.rst
@@ -0,0 +1,71 @@
+============
+Introduction
+============
+
+The page_pool is a generic API for drivers that have a need for a pool
+of recycling pages used for streaming DMA.
+
+
+Motivation
+==========
+
+The page_pool is primarily motivated by two things (1) performance
+and (2) changing the memory model for drivers.
+
+Drivers have developed performance workarounds when the speed of the
+page allocator and the DMA APIs became too slow for their HW
+needs. The page pool solves them on a general level providing
+performance gains and benefits that local driver recycling hacks
+cannot realize.
+
+A fundamental property is that pages are returned to the page_pool.
+This property allow a certain class of optimizations, which is to move
+setup and tear-down operations out of the fast-path, sometimes known as
+constructor/destruction operations.  DMA map/unmap is one example of
+operations this applies to.  Certain page alloc/free validations can
+also be avoided in the fast-path.  Another example could be
+pre-mapping pages into userspace, and clearing them (memset-zero)
+outside the fast-path.
+
+Memory model
+============
+
+Once drivers are converted to using page_pool API, then it will become
+easier change the underlying memory model backing the driver with
+pages (without changing the driver).
+
+One prime use-case is NIC zero-copy RX into userspace.  As DaveM
+describes in his `Google-plus post`_, the mapping and unmapping
+operations in the address space of the process has a cost that cancels
+out most of the gains of such zero-copy schemes.
+
+This mapping cost can solved the same way as the keeping DMA mapped
+trick.  By keeping the pages VM-mapped to userspace.  This is a layer
+that can be added later to the page_pool.  It will likely be
+beneficial to also consider using huge-pages (as backing) to reduce
+the TLB-stress.
+
+.. _Google-plus post:
+   https://plus.google.com/+DavidMiller/posts/EUDiGoXD6Xv
+
+Advantages
+==========
+
+Advantages of a recycling page pool as bullet points:
+
+1) Faster than going through page-allocator.  Given a specialized
+   allocator require less checks, and can piggyback on drivers
+   resource protection (for alloc-side).
+
+2) DMA IOMMU mapping cost is removed by keeping pages mapped.
+
+3) Makes DMA pages writable by predictable DMA unmap point.
+
+4) OOM protection at device level, as having a feedback-loop knows
+   number of outstanding pages.
+
+5) Flexible memory model allowing zero-copy RX, solving memory early
+   demux (does depend on HW filters into RX queues)
+
+6) Less fragmentation of the page buddy algorithm, when driver
+   maintains a steady-state working-set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
