Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADE28E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:28:20 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j5-v6so8951571oiw.13
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 02:28:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o125-v6si3519835oib.242.2018.09.14.02.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 02:28:18 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8E9O41I125547
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:28:17 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mg8y9uy34-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:28:17 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 10:28:14 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v4 3/3] docs: core-api: add memory allocation guide
Date: Fri, 14 Sep 2018 12:27:58 +0300
In-Reply-To: <1536917278-31191-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536917278-31191-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536917278-31191-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Randy Dunlap <rdunlap@infradead.org>
---
 Documentation/core-api/index.rst             |   1 +
 Documentation/core-api/memory-allocation.rst | 122 +++++++++++++++++++++++++++
 2 files changed, 123 insertions(+)
 create mode 100644 Documentation/core-api/memory-allocation.rst

diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index 26b735c..165d7688 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -27,6 +27,7 @@ Core utilities
    errseq
    printk-formats
    circular-buffers
+   memory-allocation
    mm-api
    gfp_mask-from-fs-io
    timekeeping
diff --git a/Documentation/core-api/memory-allocation.rst b/Documentation/core-api/memory-allocation.rst
new file mode 100644
index 0000000..f8bb9aa
--- /dev/null
+++ b/Documentation/core-api/memory-allocation.rst
@@ -0,0 +1,122 @@
+=======================
+Memory Allocation Guide
+=======================
+
+Linux provides a variety of APIs for memory allocation. You can
+allocate small chunks using `kmalloc` or `kmem_cache_alloc` families,
+large virtually contiguous areas using `vmalloc` and its derivatives,
+or you can directly request pages from the page allocator with
+`alloc_pages`. It is also possible to use more specialized allocators,
+for instance `cma_alloc` or `zs_malloc`.
+
+Most of the memory allocation APIs use GFP flags to express how that
+memory should be allocated. The GFP acronym stands for "get free
+pages", the underlying memory allocation function.
+
+Diversity of the allocation APIs combined with the numerous GFP flags
+makes the question "How should I allocate memory?" not that easy to
+answer, although very likely you should use
+
+::
+
+  kzalloc(<size>, GFP_KERNEL);
+
+Of course there are cases when other allocation APIs and different GFP
+flags must be used.
+
+Get Free Page flags
+===================
+
+The GFP flags control the allocators behavior. They tell what memory
+zones can be used, how hard the allocator should try to find free
+memory, whether the memory can be accessed by the userspace etc. The
+:ref:`Documentation/core-api/mm-api.rst <mm-api-gfp-flags>` provides
+reference documentation for the GFP flags and their combinations and
+here we briefly outline their recommended usage:
+
+  * Most of the time ``GFP_KERNEL`` is what you need. Memory for the
+    kernel data structures, DMAable memory, inode cache, all these and
+    many other allocations types can use ``GFP_KERNEL``. Note, that
+    using ``GFP_KERNEL`` implies ``GFP_RECLAIM``, which means that
+    direct reclaim may be triggered under memory pressure; the calling
+    context must be allowed to sleep.
+  * If the allocation is performed from an atomic context, e.g interrupt
+    handler, use ``GFP_NOWAIT``. This flag prevents direct reclaim and
+    IO or filesystem operations. Consequently, under memory pressure
+    ``GFP_NOWAIT`` allocation is likely to fail. Allocations which
+    have a reasonable fallback should be using ``GFP_NOWARN``.
+  * If you think that accessing memory reserves is justified and the kernel
+    will be stressed unless allocation succeeds, you may use ``GFP_ATOMIC``.
+  * Untrusted allocations triggered from userspace should be a subject
+    of kmem accounting and must have ``__GFP_ACCOUNT`` bit set. There
+    is the handy ``GFP_KERNEL_ACCOUNT`` shortcut for ``GFP_KERNEL``
+    allocations that should be accounted.
+  * Userspace allocations should use either of the ``GFP_USER``,
+    ``GFP_HIGHUSER`` or ``GFP_HIGHUSER_MOVABLE`` flags. The longer
+    the flag name the less restrictive it is.
+
+    ``GFP_HIGHUSER_MOVABLE`` does not require that allocated memory
+    will be directly accessible by the kernel and implies that the
+    data is movable.
+
+    ``GFP_HIGHUSER`` means that the allocated memory is not movable,
+    but it is not required to be directly accessible by the kernel. An
+    example may be a hardware allocation that maps data directly into
+    userspace but has no addressing limitations.
+
+    ``GFP_USER`` means that the allocated memory is not movable and it
+    must be directly accessible by the kernel.
+
+You may notice that quite a few allocations in the existing code
+specify ``GFP_NOIO`` or ``GFP_NOFS``. Historically, they were used to
+prevent recursion deadlocks caused by direct memory reclaim calling
+back into the FS or IO paths and blocking on already held
+resources. Since 4.12 the preferred way to address this issue is to
+use new scope APIs described in
+:ref:`Documentation/core-api/gfp_mask-from-fs-io.rst <gfp_mask_from_fs_io>`.
+
+Other legacy GFP flags are ``GFP_DMA`` and ``GFP_DMA32``. They are
+used to ensure that the allocated memory is accessible by hardware
+with limited addressing capabilities. So unless you are writing a
+driver for a device with such restrictions, avoid using these flags.
+And even with hardware with restrictions it is preferable to use
+`dma_alloc*` APIs.
+
+Selecting memory allocator
+==========================
+
+The most straightforward way to allocate memory is to use a function
+from the :c:func:`kmalloc` family. And, to be on the safe size it's
+best to use routines that set memory to zero, like
+:c:func:`kzalloc`. If you need to allocate memory for an array, there
+are :c:func:`kmalloc_array` and :c:func:`kcalloc` helpers.
+
+The maximal size of a chunk that can be allocated with `kmalloc` is
+limited. The actual limit depends on the hardware and the kernel
+configuration, but it is a good practice to use `kmalloc` for objects
+smaller than page size.
+
+For large allocations you can use :c:func:`vmalloc` and
+:c:func:`vzalloc`, or directly request pages from the page
+allocator. The memory allocated by `vmalloc` and related functions is
+not physically contiguous.
+
+If you are not sure whether the allocation size is too large for
+`kmalloc`, it is possible to use :c:func:`kvmalloc` and its
+derivatives. It will try to allocate memory with `kmalloc` and if the
+allocation fails it will be retried with `vmalloc`. There are
+restrictions on which GFP flags can be used with `kvmalloc`; please
+see :c:func:`kvmalloc_node` reference documentation. Note that
+`kvmalloc` may return memory that is not physically contiguous.
+
+If you need to allocate many identical objects you can use the slab
+cache allocator. The cache should be set up with
+:c:func:`kmem_cache_create` before it can be used. Afterwards
+:c:func:`kmem_cache_alloc` and its convenience wrappers can allocate
+memory from that cache.
+
+When the allocated memory is no longer needed it must be freed. You
+can use :c:func:`kvfree` for the memory allocated with `kmalloc`,
+`vmalloc` and `kvmalloc`. The slab caches should be freed with
+:c:func:`kmem_cache_free`. And don't forget to destroy the cache with
+:c:func:`kmem_cache_destroy`.
-- 
2.7.4
