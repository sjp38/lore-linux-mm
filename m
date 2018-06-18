Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB3206B026D
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:37 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b12-v6so12185844wrs.10
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f206-v6si28154wme.27.2018.06.18.10.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:36 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwtGD104746
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:34 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jpe8575u4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:33 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:30 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 11/11] docs/mm: add description of boot time memory management
Date: Mon, 18 Jun 2018 19:59:59 +0300
In-Reply-To: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1529341199-17682-12-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Both bootmem and memblock are have pretty good internal documentation
coverage. With addition of some overview we get a nice description of the
early memory management.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/boot-time-mm.rst | 92 +++++++++++++++++++++++++++++++++
 Documentation/core-api/index.rst        |  1 +
 2 files changed, 93 insertions(+)
 create mode 100644 Documentation/core-api/boot-time-mm.rst

diff --git a/Documentation/core-api/boot-time-mm.rst b/Documentation/core-api/boot-time-mm.rst
new file mode 100644
index 0000000..379e5a3
--- /dev/null
+++ b/Documentation/core-api/boot-time-mm.rst
@@ -0,0 +1,92 @@
+===========================
+Boot time memory management
+===========================
+
+Early system initialization cannot use "normal" memory management
+simply because it is not set up yet. But there is still need to
+allocate memory for various data structures, for instance for the
+physical page allocator. To address this, a specialized allocator
+called the :ref:`Boot Memory Allocator <bootmem>`, or bootmem, was
+introduced. Several years later PowerPC developers added a "Logical
+Memory Blocks" which was later adopted by other architectures and
+renamed to :ref:`memblock <memblock>`. There is also a compatibility
+layer called `nobootmem` that translates bootmem allocation interfaces
+to memblock calls.
+
+The selection of the early alocator is done using
+``CONFIG_NO_BOOTMEM`` and ``CONFIG_HAVE_MEMBLOCK`` kernel
+configuration options. These options are enabled or disabled
+statically by the architectures' Kconfig files.
+
+* Architectures that rely only on bootmem select ``CONFIG_NO_BOOTMEM=n
+  && CONFIG_HAVE_MEMBLOCK=n``.
+* The users of memblock with the nobootmem compatibility layer set
+  ``CONFIG_NO_BOOTMEM=y && CONFIG_HAVE_MEMBLOCK=y``.
+* And for those that use both memblock and bootmem the configuration
+  includes ``CONFIG_NO_BOOTMEM=n && CONFIG_HAVE_MEMBLOCK=y``
+
+Whichever allocator is used, it is the responsibility of the
+architecture specific initialization to set it up in
+:c:func:`setup_arch` and tear it down in :c:func:`mem_init` functions.
+
+Once the early memory manegement is available it offers variety of
+functions and macros for memory allocations. The allocation request
+may be directed to the first (and probably the only) node or to a
+particular node in a NUMA system. There are API variants that panic
+when an allocation fails and those that don't. And more recent and
+advanced memblock even allows controlling its own behaviour.
+
+.. _bootmem:
+
+Bootmem
+=======
+
+(mostly stolen from Mel Gorman's "Understanding the Linux Virtual
+Memory Manager" `book`_)
+
+.. _book: https://www.kernel.org/doc/gorman/
+
+.. kernel-doc:: mm/bootmem.c
+   :doc: bootmem overview
+
+.. _memblock:
+
+Memblock
+========
+
+.. kernel-doc:: mm/memblock.c
+   :doc: memblock overview
+
+
+Functions and structures
+========================
+
+Common API
+----------
+
+The functions that are described in this section are available
+regardless of what early memory manager is enabled.
+
+.. kernel-doc:: mm/nobootmem.c
+
+Bootmem specific API
+--------------------
+
+The interfaces available only with bootmem, i.e when ``CONFIG_NO_BOOTMEM=n``
+
+.. kernel-doc:: include/linux/bootmem.h
+.. kernel-doc:: mm/bootmem.c
+   :nodocs:
+
+Memblock specific API
+---------------------
+
+Here is the description of memblock data structures, functions and
+macros. Some of them are actually internal, but since they are
+documented it would be silly to omit them. Besides, reading the
+descriptions for the internal functions can help to understand what
+really happens under the hood.
+
+.. kernel-doc:: include/linux/memblock.h
+.. kernel-doc:: mm/memblock.c
+   :nodocs:
diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index f5a66b7..93d5a46 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -28,6 +28,7 @@ Core utilities
    printk-formats
    circular-buffers
    gfp_mask-from-fs-io
+   boot-time-mm
 
 Interfaces for kernel debugging
 ===============================
-- 
2.7.4
