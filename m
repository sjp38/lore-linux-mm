Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFAA6B0261
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:43:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h22-v6so1986642lfj.21
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:43:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q9-v6sor1561863lfe.44.2018.04.13.06.43.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 06:43:12 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 4/6] Documentation for Pmalloc
Date: Fri, 13 Apr 2018 17:41:29 +0400
Message-Id: <20180413134131.4651-5-igor.stoppa@huawei.com>
In-Reply-To: <20180413134131.4651-1-igor.stoppa@huawei.com>
References: <20180413134131.4651-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, corbet@lwn.net
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Detailed documentation about the protectable memory allocator.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 107 +++++++++++++++++++++++++++++++++++++
 2 files changed, 108 insertions(+)
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
index 000000000000..c14907485137
--- /dev/null
+++ b/Documentation/core-api/pmalloc.rst
@@ -0,0 +1,107 @@
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
+read-only in spirit. At least as long as it doesn't get teared down.
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
+data, because this potentially read-only data is typically interleaved
+with other data, which must stay writeable.
+
+pmalloc introduces the concept of protectable memory pools.
+A pool contains a list of areas of virtually contiguous pages of
+memory. An area is the minimum amount of memory that pmalloc allows to
+protect, because the user might have allocated a memory range that
+crosses the boundary between pages.
+
+When an allocation is performed, if there is not enough memory already
+available in the pool, a new area of suitable size is grabbed.
+The size chosen is the largest between the roundup (to PAGE_SIZE) of
+the request from pmalloc and friends and the refill parameter specified
+when creating the pool.
+
+When a pool is created, it is possible to specify two parameters:
+- refill size: the minimum size of the memory area to allocate when needed
+- align_order: the default alignment to use when reserving memory
+
+To facilitate the conversion of existing code to pmalloc pools, several
+helper functions are provided, mirroring their k/vmalloc counterparts.
+However one is missing. There is no pfree() because the memory protected
+by a pool will be released exclusively when the pool is destroyed.
+
+
+
+Caveats
+-------
+
+- When a pool is protected, whatever memory would be still available in
+  the current vmap_area (from which allocations are performed) is
+  relinquished.
+
+- As already explained, freeing of memory is not supported. Pages will be
+  returned to the system upon destruction of the memory pool that they
+  belong to.
+
+- The address range available for vmalloc (and thus for pmalloc too) is
+  limited, on 32-bit systems. However it shouldn't be an issue, since not
+  much data is expected tobe dynamically allocated and turned into
+  read-only.
+
+- Regarding SMP systems, the allocations are expected to happen mostly
+  during an initial transient, after which there should be no more need
+  to perform cross-processor synchronizations of page tables.
+  Loading of kernel modules is an exception to this, but it's not expected
+  to happen with such high frequency to become a problem.
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
+#. issue one or more allocation requests to the pool
+
+   :c:func:`pmalloc`
+
+   or
+
+   :c:func:`pzalloc`
+
+#. initialize the memory obtained, with the desired values
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
