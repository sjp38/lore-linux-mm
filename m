Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2F486B0006
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 16:37:29 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id b34so9554266plc.2
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 13:37:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j11si2971400pgq.634.2018.02.04.13.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 04 Feb 2018 13:37:28 -0800 (PST)
Subject: Re: [PATCH 6/6] Documentation for Pmalloc
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204170056.28772-1-igor.stoppa@huawei.com>
 <20180204170056.28772-2-igor.stoppa@huawei.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <29176ee0-f253-ccd7-8201-3f061b5890b0@infradead.org>
Date: Sun, 4 Feb 2018 13:37:24 -0800
MIME-Version: 1.0
In-Reply-To: <20180204170056.28772-2-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Hi,

On 02/04/2018 09:00 AM, Igor Stoppa wrote:
> Detailed documentation about the protectable memory allocator.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  Documentation/core-api/index.rst   |   1 +
>  Documentation/core-api/pmalloc.rst | 114 +++++++++++++++++++++++++++++++++++++
>  2 files changed, 115 insertions(+)
>  create mode 100644 Documentation/core-api/pmalloc.rst
> 
> diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
> index d5bbe035316d..7244ddeb540f 100644
> --- a/Documentation/core-api/index.rst
> +++ b/Documentation/core-api/index.rst
> @@ -21,6 +21,7 @@ Core utilities
>     flexible-arrays
>     librs
>     genalloc
> +   pmalloc
>  
>  Interfaces for kernel debugging
>  ===============================
> diff --git a/Documentation/core-api/pmalloc.rst b/Documentation/core-api/pmalloc.rst
> new file mode 100644
> index 000000000000..8dabb5e18d8f
> --- /dev/null
> +++ b/Documentation/core-api/pmalloc.rst
> @@ -0,0 +1,114 @@
> +SPDX-License-Identifier: GPL-2.0
> +
> +Protectable memory allocator
> +============================
> +
> +Purpose
> +-------
> +
> +The pmalloc library is meant to provide R/O status to data that, for some
> +reason, could neither be declared as constant, nor it could take advantage

                                                  nor could it

> +of the qualifier __ro_after_init, but is write-once and read-only in spirit.
> +It protects data from both accidental and malicious overwrites.
> +
> +Ex: A policy that is loaded from userspace.

Either
   Example:
or
   E.g.:
(meaning For example)

> +
> +
> +Concept
> +-------
> +
> +pmalloc builds on top of genalloc, using the same concept of memory pools.
> +
> +The value added by pmalloc is that now the memory contained in a pool can
> +become R/O, for the rest of the life of the pool.
> +
> +Different kernel idrivers and threads can use different pools, for finer

                    drivers

> +control of what becomes R/O and when. And for improved lockless concurrency.
> +
> +
> +Caveats
> +-------
> +
> +- Memory freed while a pool is not yet protected will be reused.
> +
> +- Once a pool is protected, it's not possible to allocate any more memory
> +  from it.
> +
> +- Memory "freed" from a protected pool indicates that such memory is not
> +  in use anymore by the requestor, however it will not become avaiable for

                           requester; however,                   available


> +  further use, until the pool is destroyed.
> +
> +- Before destroying a pool, all the memory allocated from it must be
> +  released.
> +
> +- pmalloc does not provide locking support wrt allocating vs protecting

Write out "wrt" -> with respect to.

> +  an individual pool, for performance reason. It is recommended to not

                                         reasons.                  not to

> +  share the same pool between unrelated functions. Should sharing be a
> +  necessity, the user of the shared pool is expected to implement locking
> +  for that pool.
> +
> +- pmalloc uses genalloc to optimize the use of the space it allocates
> +  through vmalloc. Some more TLB entries will be used, however less than
> +  in the case of using directly vmalloc. The exact number depends on size

                 of using vmalloc directly.                          on the size

> +  of each allocation request and possible slack.
> +
> +- Considering that not much data is supposed to be dynamically allocated
> +  and then marked as read-only, it shouldn't be an issue that the address
> +  range for pmalloc is limited, on 32-bit systems.
> +
> +- Regarding SMP systems, the allocations are expected to happen mostly
> +  during an initial transient, after which there should be no more need to
> +  perform cross-processor synchronizations of page tables.
> +
> +- To facilitate the conversion of existing code to pmalloc pools, several
> +  helper functions are provided, mirroring their kmalloc counterparts.
> +
> +
> +Use
> +---
> +
> +The typical sequence, when using pmalloc, is:
> +
> +1. create a pool
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pmalloc_create_pool
> +
> +2. [optional] pre-allocate some memory in the pool
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pmalloc_prealloc
> +
> +3. issue one or more allocation requests to the pool with locking as needed
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pmalloc
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pzalloc
> +
> +4. initialize the memory obtained with desired values
> +
> +5. [optional] iterate over points 3 & 4 as needed
> +
> +6. write protect the pool

      write-protect

> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pmalloc_protect_pool
> +
> +7. use in read-only mode the handlers obtained through the allocations

                                handles ??

> +
> +8. [optional] release all the memory allocated
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pfree
> +
> +9. [optional, but depends on point 8] destroy the pool
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pmalloc_destroy_pool
> +
> +API
> +---
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
