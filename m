Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 959826B0007
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 02:37:00 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u74-v6so234326oie.16
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 23:37:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s128-v6si15049138ois.140.2018.08.14.23.36.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 23:36:59 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7F6Y32r063594
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 02:36:58 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kvbg9yq2u-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 02:36:57 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 15 Aug 2018 07:36:55 +0100
Date: Wed, 15 Aug 2018 09:36:49 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] docs/core-api: add memory allocation guide
References: <1534314887-9202-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1534314887-9202-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20180815063649.GB24091@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

(this time with the subject, sorry for the noise)

On Wed, Aug 15, 2018 at 09:34:47AM +0300, Mike Rapoport wrote:
> As Vlastimil mentioned at [1], it would be nice to have some guide about
> memory allocation. I've drafted an initial version that tries to summarize
> "best practices" for allocation functions and GFP usage.
> 
> [1] https://www.spinics.net/lists/netfilter-devel/msg55542.html
> 
> From 8027c0d4b750b8dbd687234feda63305d0d5a057 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Date: Wed, 15 Aug 2018 09:10:06 +0300
> Subject: [RFC PATCH] docs/core-api: add memory allocation guide
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  Documentation/core-api/gfp_mask-from-fs-io.rst |   2 +
>  Documentation/core-api/index.rst               |   1 +
>  Documentation/core-api/memory-allocation.rst   | 117 +++++++++++++++++++++++++
>  Documentation/core-api/mm-api.rst              |   2 +
>  4 files changed, 122 insertions(+)
>  create mode 100644 Documentation/core-api/memory-allocation.rst
> 
> diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
> index e0df8f4..e7c32a8 100644
> --- a/Documentation/core-api/gfp_mask-from-fs-io.rst
> +++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
> @@ -1,3 +1,5 @@
> +.. _gfp_mask_from_fs_io:
> +
>  =================================
>  GFP masks used from FS/IO context
>  =================================
> diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
> index cdc2020..8afc0da 100644
> --- a/Documentation/core-api/index.rst
> +++ b/Documentation/core-api/index.rst
> @@ -27,6 +27,7 @@ Core utilities
>     errseq
>     printk-formats
>     circular-buffers
> +   memory-allocation
>     mm-api
>     gfp_mask-from-fs-io
>     timekeeping
> diff --git a/Documentation/core-api/memory-allocation.rst b/Documentation/core-api/memory-allocation.rst
> new file mode 100644
> index 0000000..b1f2ad5
> --- /dev/null
> +++ b/Documentation/core-api/memory-allocation.rst
> @@ -0,0 +1,117 @@
> +=======================
> +Memory Allocation Guide
> +=======================
> +
> +Linux supplies variety of APIs for memory allocation. You can allocate
> +small chunks using `kmalloc` or `kmem_cache_alloc` families, large
> +virtually contiguous areas using `vmalloc` and it's derivatives, or
> +you can directly request pages from the page allocator with
> +`__get_free_pages`. It is also possible to use more specialized
> +allocators, for instance `cma_alloc` or `zs_malloc`.
> +
> +Most of the memory allocations APIs use GFP flags to express how that
> +memory should be allocated. The GFP acronym stands for "get free
> +pages", the underlying memory allocation function.
> +
> +Diversity of the allocation APIs combined with the numerous GFP flags
> +makes the question "How should I allocate memory?" not that easy to
> +answer, although very likely you should use
> +
> +::
> +
> +  kzalloc(<size>, GFP_KERNEL);
> +
> +Of course there are cases when other allocation APIs and different GFP
> +flags must be used.
> +
> +Get Free Page flags
> +===================
> +
> +The GFP flags control the allocators behavior. They tell what memory
> +zones can be used, how hard the allocator should try to find a free
> +memory, whether the memory can be accessed by the userspace etc. The
> +:ref:`Documentation/core-api/mm-api.rst <mm-api-gfp-flags>` provides
> +reference documentation for the GFP flags and their combinations and
> +here we briefly outline their recommended usage:
> +
> +  * Most of the times ``GFP_KERNEL`` is what you need. Memory for the
> +    kernel data structures, DMAable memory, inode cache, all these and
> +    many other allocations types can use ``GFP_KERNEL``. Note, that
> +    using ``GFP_KERNEL`` implies ``GFP_RECLAIM``, which means that
> +    direct reclaim may be triggered under memory pressure; the calling
> +    context must be allowed to sleep.
> +  * If the allocation is performed from an atomic context, e.g
> +    interrupt handler, use ``GFP_ATOMIC``.
> +  * Untrusted allocations triggered from userspace should be a subject
> +    of kmem accounting and must have ``__GFP_ACCOUNT`` bit set. There
> +    is handy ``GFP_KERNEL_ACCOUNT`` shortcut for ``GFP_KERNEL``
> +    allocations that should be accounted.
> +  * Userspace allocations should use either of the ``GFP_USER``,
> +    ``GFP_HIGHUSER`` and ``GFP_HIGHUSER_MOVABLE`` flags. The longer
> +    the flag name the less restrictive it is.
> +
> +    The ``GFP_HIGHUSER_MOVABLE`` does not require that allocated
> +    memory will be directly accessible by the kernel or the hardware
> +    and implies that the data may move.
> +
> +    The ``GFP_HIGHUSER`` means that the allocated memory is not
> +    movable, but it is not required to be directly accessible by the
> +    kernel or the hardware. An example may be a hardware allocation
> +    that maps data directly into userspace but has no addressing
> +    limitations.
> +
> +    The ``GFP_USER`` means that the allocated memory is not movable
> +    and it must be directly accessible by the kernel or the
> +    hardware. It is typically used by hardware for buffers that are
> +    mapped to userspace (e.g. graphics) that hardware still must DMA
> +    to.
> +
> +You may notice that quite a few allocations in the existing code
> +specify ``GFP_NOIO`` and ``GFP_NOFS``. Historically, they were used to
> +prevent recursion deadlocks caused by direct memory reclaim calling
> +back into the FS or IO paths and blocking on already held
> +resources. Since 4.12 the preferred way to address this issue is to
> +use new scope APIs described in
> +:ref:`Documentation/core-api/gfp_mask-from-fs-io.rst <gfp_mask_from_fs_io>`.
> +
> +Another legacy GFP flags are ``GFP_DMA`` and ``GFP_DMA32``. They are
> +used to ensure that the allocated memory is accessible by hardware
> +with limited addressing capabilities. So unless you are writing a
> +driver for a device with such restrictions, avoid using these flags.
> +
> +Selecting memory allocator
> +==========================
> +
> +The most straightforward way to allocate memory is to use a function
> +from the `kmalloc` family. And, to be on the safe size it's best to
> +use routines that set memory to zero, like `kzalloc`. If you need to
> +allocate memory for an array, there are `kmalloc_array` and `kcalloc`
> +helpers.
> +
> +The maximal size of a chunk that can be allocated with `kmalloc` is
> +limited. The actual limit depends on the hardware and the kernel
> +configuration, but it is a good practice to use `kmalloc` for objects
> +smaller than page size.
> +
> +For large allocations you can use `vmalloc` and `vzalloc`, or directly
> +request pages from the page allocator. The memory allocated by
> +`vmalloc` and related functions is not physically contiguous.
> +
> +If you are not sure whether the allocation size is too large for
> +`kmalloc` it is possible to use `kvmalloc` and its derivatives. It
> +will try to allocate memory with `kmalloc` and if the allocation fails
> +it will be retried with `vmalloc`. There are restrictions on which GFP
> +flags can be used with `kvmalloc`, please see :c:func:`kvmalloc_node`
> +reference documentation. Note, that `kvmalloc` may return memory that
> +is not physically contiguous.
> +
> +If you need to allocate many identical objects you can use slab cache
> +allocator. The cache should be set up with `kmem_cache_create` before
> +it can be used. Afterwards `kmem_cache_alloc` and its convenience
> +wrappers can allocate memory from that cache.
> +
> +When the allocated memory is no longer needed it must be freed. You
> +can use `kvfree` for the memory allocated with `kmalloc`, `vmalloc`
> +and `kvmalloc`. The slab caches should be freed with
> +`kmem_cache_free`. And don't forget to destroy the cache with
> +`kmem_cache_destroy`.
> diff --git a/Documentation/core-api/mm-api.rst b/Documentation/core-api/mm-api.rst
> index 46ae353..5ce1ec1 100644
> --- a/Documentation/core-api/mm-api.rst
> +++ b/Documentation/core-api/mm-api.rst
> @@ -14,6 +14,8 @@ User Space Memory Access
>  .. kernel-doc:: mm/util.c
>     :functions: get_user_pages_fast
> 
> +.. _mm-api-gfp-flags:
> +
>  Memory Allocation Controls
>  ==========================
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.
