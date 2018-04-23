Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B99086B000C
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:55:43 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f6-v6so13382480ioc.1
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:55:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 10-v6sor4138428ite.69.2018.04.23.05.55.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 05:55:42 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 4/9] Documentation for Pmalloc
Date: Mon, 23 Apr 2018 16:54:53 +0400
Message-Id: <20180423125458.5338-5-igor.stoppa@huawei.com>
In-Reply-To: <20180423125458.5338-1-igor.stoppa@huawei.com>
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net
Cc: labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>

Detailed documentation about the protectable memory allocator.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 161 +++++++++++++++++++++++++++++++++++++
 2 files changed, 162 insertions(+)
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
index 000000000000..27eb7b3eafc4
--- /dev/null
+++ b/Documentation/core-api/pmalloc.rst
@@ -0,0 +1,161 @@
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
+advantage of the qualifier __ro_after_init, but it is in spirit
+write-once/read-only.
+At some point it might get teared down, however that doesn't affect how it
+is treated, while it's still relevant.
+Pmalloc protects data from both accidental and malicious overwrites.
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
+memory. When memory is requested from a pool, the requests are satisfied
+by reserving adequate amounts of memory from the active area of memory in
+that pool. A request can cross page boundaries, therefore an area is the
+minimum granularity that pmalloc allows to protect.
+
+There might be special cases where an area contains only one page, but
+they are still addressed as areas.
+
+Areas are allocated on-the-fly, when the space available is insufficient
+for satisfying the latest request received.
+
+To facilitate the conversion of existing code to pmalloc pools, several
+helper functions are provided, mirroring their k/vmalloc counterparts.
+
+However, there is no pfree(), because the memory protected by a pool is
+released exclusively when the pool is destroyed.
+
+
+When to use pmalloc
+-------------------
+
+- Pmalloc memory is intended to complement __ro_after_init.
+  __ro_after_init requires that the initialization value is applied before
+  init is completed. If this is not possible, then pmalloc can be used.
+
+- Pmalloc can be useful also when the amount of data to protect is not
+  known at compile time and the memory can only be allocated dynamically.
+
+- Finally, it can be useful also when it is desirable to control
+  dynamically (for example throguh the kernel command line) if some
+  specific data ought to be protected or not, without having to rebuild
+  the kernel, for toggling a "const" qualifier.
+  This can be used, for example, by a linux distro, to create a more
+  versatile binary kernel and allow its users to toggle between developer
+  (unprotected) or production (protected) modes by reconfiguring the
+  bootloader.
+
+
+When *not* to use pmalloc
+-------------------------
+
+Using pmalloc is not a good idea when optimizing TLB utilization is
+paramount: pmalloc relies on virtual memory areas and will therefore use
+more TLB entries. It still does a better job of it, compared to invoking
+vmalloc for each allocation, but it is undeniably less optimized wrt to
+TLB use than using the physmap directly, through kmalloc or similar.
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
+  belong to. For this reason, no pfree() function is provided
+
+- The address range available for vmalloc (and thus for pmalloc too) is
+  limited, on 32-bit systems. However it shouldn't be an issue, since not
+  much data is expected to be dynamically allocated and turned into
+  read-only.
+
+- Regarding SMP systems, the allocations are expected to happen mostly
+  during an initial transient, after which there should be no more need
+  to perform cross-processor synchronizations of page tables.
+  Loading of kernel modules is an exception to this, but it's not expected
+  to happen with such high frequency to become a problem.
+
+- While pmalloc memory can be protected, since it is allocated dynamically,
+  it is still subject to indirect attacks, where the memory itself is not
+  touched, but anything used as reference to the allocation can be altered.
+  In some cases the allocation from a pmalloc pool is referred to by another
+  allocation, from either the same or another pool, however at some point,
+  there will be a base reference which can be attacked, if it cannot be
+  protected.
+  This base reference, or "anchor" is suitable for protection using
+  __ro_after_init, since it only needs to store the *address* of the
+  pmalloc allocation that will be initialized and protected later on.
+  But the allocation can take place during init, and its address is known
+  and constant.
+
+
+Utilization
+-----------
+
+Typical sequence, when using pmalloc
+
+Steps to perforn during init:
+
+#. create an "anchor", with the modifier __ro_after_init
+
+#. create a pool
+
+   :c:func:`pmalloc_create_pool`
+
+#. issue an allocation requests to the pool with either
+
+   :c:func:`pmalloc`
+
+   or one of its variants, like
+
+   :c:func:`pzalloc`
+
+   assigning its address to the anchor
+
+#. iterate the previous points as needed
+
+The Following steps can be performed at any time, both during and after
+init, as long as they strictly come after the previous sequence.
+
+#. initialize with the desired value the memory obtained from the pool(s)
+
+#. write-protect the memory so far allocated
+
+   :c::func:`pmalloc_protect_pool`
+
+#. iterate over the last 2 points as needed
+
+#. [optional] destroy the pool
+
+   :c:func:`pmalloc_destroy_pool`
+
+
+API
+---
+
+.. kernel-doc:: include/linux/pmalloc.h
+.. kernel-doc:: mm/pmalloc.c
-- 
2.14.1
