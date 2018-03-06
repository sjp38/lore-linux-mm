Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B43396B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 08:31:09 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z17so16854365qti.1
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 05:31:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z15si15059043qth.434.2018.03.06.05.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 05:31:08 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w26DTgLY044154
	for <linux-mm@kvack.org>; Tue, 6 Mar 2018 08:31:07 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ghsuppbfq-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Mar 2018 08:31:06 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 6 Mar 2018 13:31:04 -0000
Date: Tue, 6 Mar 2018 14:30:52 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/7] Documentation for Pmalloc
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-8-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180228200620.30026-8-igor.stoppa@huawei.com>
Message-Id: <20180306133051.GE19349@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 28, 2018 at 10:06:20PM +0200, Igor Stoppa wrote:
> Detailed documentation about the protectable memory allocator.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  Documentation/core-api/index.rst   |   1 +
>  Documentation/core-api/pmalloc.rst | 111 +++++++++++++++++++++++++++++++++++++
>  2 files changed, 112 insertions(+)
>  create mode 100644 Documentation/core-api/pmalloc.rst
> 
> diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
> index c670a8031786..8f5de42d6571 100644
> --- a/Documentation/core-api/index.rst
> +++ b/Documentation/core-api/index.rst
> @@ -25,6 +25,7 @@ Core utilities
>     genalloc
>     errseq
>     printk-formats
> +   pmalloc
> 
>  Interfaces for kernel debugging
>  ===============================
> diff --git a/Documentation/core-api/pmalloc.rst b/Documentation/core-api/pmalloc.rst
> new file mode 100644
> index 000000000000..8fb9c9d3171b
> --- /dev/null
> +++ b/Documentation/core-api/pmalloc.rst
> @@ -0,0 +1,111 @@
> +.. SPDX-License-Identifier: GPL-2.0

Please add a label to allow cross-referencing

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

It would be nice to add a label to genalloc.rst and reference it here:

diff --git a/Documentation/core-api/genalloc.rst b/Documentation/core-api/genalloc.rst
index 6b38a39fab24..983fa94f999c 100644
--- a/Documentation/core-api/genalloc.rst
+++ b/Documentation/core-api/genalloc.rst
@@ -1,3 +1,5 @@
+.. _genalloc:
+
 The genalloc/genpool subsystem
 ==============================
 
> +
> +The value added by pmalloc is that now the memory contained in a pool can
> +become R/O, for the rest of the life of the pool.
> +

IMHO, "read only" looks better than R/O

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
> +- pmalloc does not provide locking support with respect to allocating vs
> +  protecting an individual pool, for performance reasons.
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

Can we use #. instead of numbers for the numbered list items?

> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pmalloc_create_pool
> +
> +2. [optional] pre-allocate some memory in the pool
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pmalloc_prealloc

Maybe it's better to have a short reference to the function and keep all
the elaborate descriptions in the API section?
For instance, something like

diff --git a/Documentation/core-api/pmalloc.rst b/Documentation/core-api/pmalloc.rst
@@ -68,8 +70,7 @@ The typical sequence, when using pmalloc, is:
 
 1. create a pool
 
-.. kernel-doc:: include/linux/pmalloc.h
-   :functions: pmalloc_create_pool
+     :c:func:`pmalloc_create_pool`
 
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
> +6. write-protect the pool
> +
> +.. kernel-doc:: include/linux/pmalloc.h
> +   :functions: pmalloc_protect_pool
> +
> +7. use in read-only mode the handles obtained through the allocations
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
> -- 
> 2.14.1
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
