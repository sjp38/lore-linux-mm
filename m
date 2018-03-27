Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89A636B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 21:57:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id e15so2908844wrj.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:57:45 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 62si258387wml.81.2018.03.26.18.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 18:57:44 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 6/6] Documentation for Pmalloc
Date: Tue, 27 Mar 2018 04:55:24 +0300
Message-ID: <20180327015524.14318-7-igor.stoppa@huawei.com>
In-Reply-To: <20180327015524.14318-1-igor.stoppa@huawei.com>
References: <20180327015524.14318-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>

Detailed documentation about the protectable memory allocator.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 101 +++++++++++++++++++++++++++++++++++++
 2 files changed, 102 insertions(+)
 create mode 100644 Documentation/core-api/pmalloc.rst

diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index c670a8031786..8f5de42d6571 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -25,6 +25,7 @@ Core utilities
    genalloc
    errseq
    printk-formats
+   pmalloc
 
 Interfaces for kernel debugging
 ===============================
diff --git a/Documentation/core-api/pmalloc.rst b/Documentation/core-api/pmalloc.rst
new file mode 100644
index 000000000000..3d2c19e5deaf
--- /dev/null
+++ b/Documentation/core-api/pmalloc.rst
@@ -0,0 +1,101 @@
+.. SPDX-License-Identifier: GPL-2.0
+
+.. _pmalloc:
+
+Protectable memory allocator
+============================
+
+Purpose
+-------
+
+The pmalloc library is meant to provide read-only status to data that,
+for some reason, could neither be declared as constant, nor could it take
+advantage of the qualifier __ro_after_init, but is write-once and
+read-only in spirit.
+It protects data from both accidental and malicious overwrites.
+
+Example: A policy that is loaded from userspace.
+
+
+Concept
+-------
+
+The MMU available in the system can be used to write protect memory pages.
+Unfortunately this feature cannot be used as-it-is, to protect sensitive
+data, because it is typically interleaved with data that must stay
+writeable.
+
+pmalloc introduces the concept of protectable memory pools.
+Each pool contains a list of areas of virtually contiguous pages of
+memory. An area is the minimum amount of memory that pmalloc allows to
+protect, because the data it contains can be larger than a single page.
+
+When an allocation is performed, if there is not enough memory already
+available in the pool, a new area of suitable size is allocated.
+The size chosen is the largest between the roundup (to PAGE_SIZE) of
+the request from pmalloc and friends and the refill parameter specified
+when creating the pool.
+
+When a pool is created, it is possible to specify two parameters:
+- refill size: the minimum size of the memory area to allocate when needed
+- align_order: the default alignment to use when returning to pmalloc
+
+Caveats
+-------
+
+- To facilitate the conversion of existing code to pmalloc pools, several
+  helper functions are provided, mirroring their k/vmalloc counterparts.
+  In particular, pfree(), which is mostly meant for error paths, when one
+  or more previous allocations must be rolled back.
+
+- Whatever memory was still available in the previous area (where
+  applicable) is relinquished.
+
+- Freeing of memory is not supported. Pages will be returned to the
+  system upon destruction of the memory pool.
+
+- Considering that not much data is supposed to be dynamically allocated
+  and then marked as read-only, it shouldn't be an issue that the address
+  range for pmalloc is limited, on 32-bit systems.
+
+- Regarding SMP systems, the allocations are expected to happen mostly
+  during an initial transient, after which there should be no more need to
+  perform cross-processor synchronizations of page tables.
+
+
+Use
+---
+
+The typical sequence, when using pmalloc, is:
+
+#. create a pool
+
+   :c:func:`pmalloc_create_pool`
+
+#. [optional] pre-allocate some memory in the pool
+
+   :c:func:`pmalloc_prealloc`
+
+#. issue one or more allocation requests to the pool with locking as needed
+
+   :c:func:`pmalloc`
+
+   :c:func:`pzalloc`
+
+#. initialize the memory obtained with desired values
+
+#. write-protect the memory so far allocated
+
+   :c::func:`pmalloc_protect_pool`
+
+#. iterate over the last 3 points as needed
+
+#. [optional] destroy the pool
+
+   :c:func:`pmalloc_destroy_pool`
+
+API
+---
+
+.. kernel-doc:: include/linux/pmalloc.h
+.. kernel-doc:: mm/pmalloc.c
-- 
2.14.1
