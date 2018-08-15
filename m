Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C19E86B000A
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 13:14:47 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x5-v6so1600902ioa.6
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:14:47 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 127-v6si16475165jaf.25.2018.08.15.10.14.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 Aug 2018 10:14:46 -0700 (PDT)
Subject: Re: docs/core-api: add memory allocation guide
References: <1534314887-9202-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <2f1c03e4-1c80-709d-f571-c7b17859fa59@infradead.org>
Date: Wed, 15 Aug 2018 10:14:30 -0700
MIME-Version: 1.0
In-Reply-To: <1534314887-9202-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Hi@d06av22.portsmouth.uk.ibm.com

On 08/14/2018 11:34 PM, Mike Rapoport wrote:
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

Hi Mike,

I have some suggestions below.


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

         supplies a variety
or even
         provides a variety

> +small chunks using `kmalloc` or `kmem_cache_alloc` families, large
> +virtually contiguous areas using `vmalloc` and it's derivatives, or

                                                  its

> +you can directly request pages from the page allocator with
> +`__get_free_pages`. It is also possible to use more specialized
> +allocators, for instance `cma_alloc` or `zs_malloc`.
> +
> +Most of the memory allocations APIs use GFP flags to express how that

                      allocation APIs

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

                                                        to find free

> +memory, whether the memory can be accessed by the userspace etc. The
> +:ref:`Documentation/core-api/mm-api.rst <mm-api-gfp-flags>` provides
> +reference documentation for the GFP flags and their combinations and
> +here we briefly outline their recommended usage:
> +
> +  * Most of the times ``GFP_KERNEL`` is what you need. Memory for the

I would write:
       Most of the time

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

       is the handy

> +    allocations that should be accounted.
> +  * Userspace allocations should use either of the ``GFP_USER``,
> +    ``GFP_HIGHUSER`` and ``GFP_HIGHUSER_MOVABLE`` flags. The longer

                        or

> +    the flag name the less restrictive it is.
> +
> +    The ``GFP_HIGHUSER_MOVABLE`` does not require that allocated

s/The//

> +    memory will be directly accessible by the kernel or the hardware
> +    and implies that the data may move.
> +
> +    The ``GFP_HIGHUSER`` means that the allocated memory is not

s/The//

> +    movable, but it is not required to be directly accessible by the
> +    kernel or the hardware. An example may be a hardware allocation
> +    that maps data directly into userspace but has no addressing
> +    limitations.
> +
> +    The ``GFP_USER`` means that the allocated memory is not movable

s/The//

> +    and it must be directly accessible by the kernel or the
> +    hardware. It is typically used by hardware for buffers that are
> +    mapped to userspace (e.g. graphics) that hardware still must DMA
> +    to.
> +
> +You may notice that quite a few allocations in the existing code
> +specify ``GFP_NOIO`` and ``GFP_NOFS``. Historically, they were used to

                        or

> +prevent recursion deadlocks caused by direct memory reclaim calling
> +back into the FS or IO paths and blocking on already held
> +resources. Since 4.12 the preferred way to address this issue is to
> +use new scope APIs described in
> +:ref:`Documentation/core-api/gfp_mask-from-fs-io.rst <gfp_mask_from_fs_io>`.
> +
> +Another legacy GFP flags are ``GFP_DMA`` and ``GFP_DMA32``. They are

   Other

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

   `kmalloc`,

> +will try to allocate memory with `kmalloc` and if the allocation fails
> +it will be retried with `vmalloc`. There are restrictions on which GFP
> +flags can be used with `kvmalloc`, please see :c:func:`kvmalloc_node`

                                    ^ s/,/;/

> +reference documentation. Note, that `kvmalloc` may return memory that

                            Note that

> +is not physically contiguous.
> +
> +If you need to allocate many identical objects you can use slab cache

                                                      can use the slab cache

> +allocator. The cache should be set up with `kmem_cache_create` before
> +it can be used. Afterwards `kmem_cache_alloc` and its convenience
> +wrappers can allocate memory from that cache.
> +
> +When the allocated memory is no longer needed it must be freed. You
> +can use `kvfree` for the memory allocated with `kmalloc`, `vmalloc`
> +and `kvmalloc`. The slab caches should be freed with
> +`kmem_cache_free`. And don't forget to destroy the cache with
> +`kmem_cache_destroy`.

Thanks for the new documentation.

-- 
~Randy
