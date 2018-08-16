Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2FB56B02F1
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 14:22:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r2-v6so2406852pgp.3
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 11:22:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k4-v6si28606100pfc.328.2018.08.16.11.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 Aug 2018 11:22:00 -0700 (PDT)
Subject: Re: [PATCH v2 3/3] docs: core-api: add memory allocation guide
References: <1534424618-24713-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1534424618-24713-4-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <c671cfd1-1057-7cd6-200b-f49874a9771b@infradead.org>
Date: Thu, 16 Aug 2018 11:21:58 -0700
MIME-Version: 1.0
In-Reply-To: <1534424618-24713-4-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On 08/16/2018 06:03 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  Documentation/core-api/index.rst             |   1 +
>  Documentation/core-api/memory-allocation.rst | 124 +++++++++++++++++++++++++++
>  2 files changed, 125 insertions(+)
>  create mode 100644 Documentation/core-api/memory-allocation.rst


> diff --git a/Documentation/core-api/memory-allocation.rst b/Documentation/core-api/memory-allocation.rst
> new file mode 100644
> index 0000000..b9b0823
> --- /dev/null
> +++ b/Documentation/core-api/memory-allocation.rst
> @@ -0,0 +1,124 @@
> +=======================
> +Memory Allocation Guide
> +=======================
> +

[snip]

> +
> +Get Free Page flags
> +===================
> +
> +The GFP flags control the allocators behavior. They tell what memory
> +zones can be used, how hard the allocator should try to find free
> +memory, whether the memory can be accessed by the userspace etc. The
> +:ref:`Documentation/core-api/mm-api.rst <mm-api-gfp-flags>` provides
> +reference documentation for the GFP flags and their combinations and
> +here we briefly outline their recommended usage:
> +
> +  * Most of the time ``GFP_KERNEL`` is what you need. Memory for the
> +    kernel data structures, DMAable memory, inode cache, all these and
> +    many other allocations types can use ``GFP_KERNEL``. Note, that
> +    using ``GFP_KERNEL`` implies ``GFP_RECLAIM``, which means that
> +    direct reclaim may be triggered under memory pressure; the calling
> +    context must be allowed to sleep.
> +  * If the allocation is performed from an atomic context, e.g interrupt
> +    handler, use ``GFP_NOWAIT``. This flag prevents direct reclaim and
> +    IO or filesystem operations. Consequently, under memory pressure
> +    ``GFP_NOWAIT`` allocation is likely to fail. Allocations which
> +    have a reasonable fallback should be using ``GFP_NOWARN``.
> +  * If you think that accessing memory reserves is justified and the kernel
> +    will be stressed unless allocation succeeds, you may use ``GFP_ATOMIC``.
> +  * Untrusted allocations triggered from userspace should be a subject
> +    of kmem accounting and must have ``__GFP_ACCOUNT`` bit set. There
> +    is the handy ``GFP_KERNEL_ACCOUNT`` shortcut for ``GFP_KERNEL``
> +    allocations that should be accounted.
> +  * Userspace allocations should use either of the ``GFP_USER``,
> +    ``GFP_HIGHUSER`` or ``GFP_HIGHUSER_MOVABLE`` flags. The longer
> +    the flag name the less restrictive it is.
> +
> +    ``GFP_HIGHUSER_MOVABLE`` does not require that allocated memory
> +    will be directly accessible by the kernel or the hardware and
> +    implies that the data is movable.
> +
> +    ``GFP_HIGHUSER`` means that the allocated memory is not movable,
> +    but it is not required to be directly accessible by the kernel or
> +    the hardware. An example may be a hardware allocation that maps
> +    data directly into userspace but has no addressing limitations.
> +
> +    ``GFP_USER`` means that the allocated memory is not movable and it
> +    must be directly accessible by the kernel or the hardware. It is
> +    typically used by hardware for buffers that are mapped to
> +    userspace (e.g. graphics) that hardware still must DMA to.
> +
> +You may notice that quite a few allocations in the existing code
> +specify ``GFP_NOIO`` or ``GFP_NOFS``. Historically, they were used to
> +prevent recursion deadlocks caused by direct memory reclaim calling
> +back into the FS or IO paths and blocking on already held
> +resources. Since 4.12 the preferred way to address this issue is to
> +use new scope APIs described in
> +:ref:`Documentation/core-api/gfp_mask-from-fs-io.rst <gfp_mask_from_fs_io>`.
> +
> +Other legacy GFP flags are ``GFP_DMA`` and ``GFP_DMA32``. They are
> +used to ensure that the allocated memory is accessible by hardware
> +with limited addressing capabilities. So unless you are writing a
> +driver for a device with such restrictions, avoid using these
> +flags. And even with HW with restrictions it is preferable to use

please s/HW/hardware/

> +`dma_alloc*` APIs.
> +
> +Selecting memory allocator
> +==========================

and then you can add
Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

-- 
~Randy
