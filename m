Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5F7C6B000A
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 15:11:45 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t123so2077958wmt.2
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 12:11:45 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id h89si912206edd.471.2018.02.28.12.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 12:11:44 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 7/7] Documentation for Pmalloc
Date: Wed, 28 Feb 2018 22:06:20 +0200
Message-ID: <20180228200620.30026-8-igor.stoppa@huawei.com>
In-Reply-To: <20180228200620.30026-1-igor.stoppa@huawei.com>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Detailed documentation about the protectable memory allocator.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 111 +++++++++++++++++++++++++++++++++++++
 2 files changed, 112 insertions(+)
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
index 000000000000..8fb9c9d3171b
--- /dev/null
+++ b/Documentation/core-api/pmalloc.rst
@@ -0,0 +1,111 @@
+.. SPDX-License-Identifier: GPL-2.0
+
+Protectable memory allocator
+============================
+
+Purpose
+-------
+
+The pmalloc library is meant to provide R/O status to data that, for some
+reason, could neither be declared as constant, nor could it take advantage
+of the qualifier __ro_after_init, but is write-once and read-only in spirit.
+It protects data from both accidental and malicious overwrites.
+
+Example: A policy that is loaded from userspace.
+
+
+Concept
+-------
+
+pmalloc builds on top of genalloc, using the same concept of memory pools.
+
+The value added by pmalloc is that now the memory contained in a pool can
+become R/O, for the rest of the life of the pool.
+
+Different kernel drivers and threads can use different pools, for finer
+control of what becomes R/O and when. And for improved lockless concurrency.
+
+
+Caveats
+-------
+
+- Memory freed while a pool is not yet protected will be reused.
+
+- Once a pool is protected, it's not possible to allocate any more memory
+  from it.
+
+- Memory "freed" from a protected pool indicates that such memory is not
+  in use anymore by the requester; however, it will not become available
+  for further use, until the pool is destroyed.
+
+- pmalloc does not provide locking support with respect to allocating vs
+  protecting an individual pool, for performance reasons.
+  It is recommended not to share the same pool between unrelated functions.
+  Should sharing be a necessity, the user of the shared pool is expected
+  to implement locking for that pool.
+
+- pmalloc uses genalloc to optimize the use of the space it allocates
+  through vmalloc. Some more TLB entries will be used, however less than
+  in the case of using vmalloc directly. The exact number depends on the
+  size of each allocation request and possible slack.
+
+- Considering that not much data is supposed to be dynamically allocated
+  and then marked as read-only, it shouldn't be an issue that the address
+  range for pmalloc is limited, on 32-bit systems.
+
+- Regarding SMP systems, the allocations are expected to happen mostly
+  during an initial transient, after which there should be no more need to
+  perform cross-processor synchronizations of page tables.
+
+- To facilitate the conversion of existing code to pmalloc pools, several
+  helper functions are provided, mirroring their kmalloc counterparts.
+
+
+Use
+---
+
+The typical sequence, when using pmalloc, is:
+
+1. create a pool
+
+.. kernel-doc:: include/linux/pmalloc.h
+   :functions: pmalloc_create_pool
+
+2. [optional] pre-allocate some memory in the pool
+
+.. kernel-doc:: include/linux/pmalloc.h
+   :functions: pmalloc_prealloc
+
+3. issue one or more allocation requests to the pool with locking as needed
+
+.. kernel-doc:: include/linux/pmalloc.h
+   :functions: pmalloc
+
+.. kernel-doc:: include/linux/pmalloc.h
+   :functions: pzalloc
+
+4. initialize the memory obtained with desired values
+
+5. [optional] iterate over points 3 & 4 as needed
+
+6. write-protect the pool
+
+.. kernel-doc:: include/linux/pmalloc.h
+   :functions: pmalloc_protect_pool
+
+7. use in read-only mode the handles obtained through the allocations
+
+8. [optional] release all the memory allocated
+
+.. kernel-doc:: include/linux/pmalloc.h
+   :functions: pfree
+
+9. [optional, but depends on point 8] destroy the pool
+
+.. kernel-doc:: include/linux/pmalloc.h
+   :functions: pmalloc_destroy_pool
+
+API
+---
+
+.. kernel-doc:: include/linux/pmalloc.h
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
