Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECB196B000E
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 19:26:55 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x6so4569344plr.7
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 16:26:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i4sor876587pgo.431.2018.02.23.16.26.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 16:26:54 -0800 (PST)
Subject: Re: [PATCH 7/7] Documentation for Pmalloc
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-8-igor.stoppa@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <98b2fecf-c1b3-aa5e-ba70-2770940bb965@gmail.com>
Date: Fri, 23 Feb 2018 16:26:49 -0800
MIME-Version: 1.0
In-Reply-To: <20180223144807.1180-8-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 2/23/18 6:48 AM, Igor Stoppa wrote:
> Detailed documentation about the protectable memory allocator.
>
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>   Documentation/core-api/index.rst   |   1 +
>   Documentation/core-api/pmalloc.rst | 114 +++++++++++++++++++++++++++++++++++++
>   2 files changed, 115 insertions(+)
>   create mode 100644 Documentation/core-api/pmalloc.rst
>
> diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
> index c670a8031786..8f5de42d6571 100644
> --- a/Documentation/core-api/index.rst
> +++ b/Documentation/core-api/index.rst
> @@ -25,6 +25,7 @@ Core utilities
>      genalloc
>      errseq
>      printk-formats
> +   pmalloc
>   
>   Interfaces for kernel debugging
>   ===============================
> diff --git a/Documentation/core-api/pmalloc.rst b/Documentation/core-api/pmalloc.rst
> new file mode 100644
> index 000000000000..d9725870444e
> --- /dev/null
> +++ b/Documentation/core-api/pmalloc.rst
> @@ -0,0 +1,114 @@
> +.. SPDX-License-Identifier: GPL-2.0
> +
> +Protectable memory allocator
> +============================
> +
> +Purpose
> +-------
> +
> +The pmalloc library is meant to provide R/O status to data that, for some
> +reason, could neither be declared as constant, nor could it take advantage
> +of the qualifier __ro_after_init, but is write-once and read-only in spirit.
> +It protects data from both accidental and malicious overwrites.
> +
> +Example: A policy that is loaded from userspace.
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
> +Different kernel drivers and threads can use different pools, for finer
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
> +  in use anymore by the requester; however, it will not become available
> +  for further use, until the pool is destroyed.
> +
> +- Before destroying a pool, all the memory allocated from it must be
> +  released.

Is that true?A  pmalloc_destroy_pool() has:

.
.
+A A A  pmalloc_pool_set_protection(pool, false);
+A A A  gen_pool_for_each_chunk(pool, pmalloc_chunk_free, NULL);
+A A A  gen_pool_destroy(pool);
+A A A  kfree(data);

which to me looks like is the opposite, the data (ie, "memory") is being 
released first, then the pool is destroyed.



> +
> +- pmalloc does not provide locking support with respect to allocating vs
> +  protecting an individual pool, for performance reasons.

What is the recommendation to using locks then, as the computing 
real-world mainly operates in multi-threaded/process world?A  Maybe show 
an example of an issue that occur if locks aren't used and give a coding 
example.

> +  It is recommended not to share the same pool between unrelated functions.
> +  Should sharing be a necessity, the user of the shared pool is expected
> +  to implement locking for that pool.
> +
> +- pmalloc uses genalloc to optimize the use of the space it allocates
> +  through vmalloc. Some more TLB entries will be used, however less than
> +  in the case of using vmalloc directly. The exact number depends on the
> +  size of each allocation request and possible slack.
> +
> +- Considering that not much data is supposed to be dynamically allocated
> +  and then marked as read-only, it shouldn't be an issue that the address
> +  range for pmalloc is limited, on 32-bit systems.

Why is 32-bit systems mentioned and not 64-bit?A  Is there a problem with 
64-bit here?

Thanks,
Jay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
