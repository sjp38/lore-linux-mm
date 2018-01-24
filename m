Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86581800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 14:14:37 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id h8so3100710ote.8
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:14:37 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id d6si1829992oib.186.2018.01.24.11.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 11:14:36 -0800 (PST)
Subject: Re: [PATCH 5/6] Documentation for Pmalloc
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-6-igor.stoppa@huawei.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <8397e79f-c4b7-4cae-e5a0-2c3b32d9a327@nvidia.com>
Date: Wed, 24 Jan 2018 11:14:34 -0800
MIME-Version: 1.0
In-Reply-To: <20180124175631.22925-6-igor.stoppa@huawei.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

2 Minor typos inline below:

On 01/24/2018 09:56 AM, Igor Stoppa wrote:
> Detailed documentation about the protectable memory allocator.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>   Documentation/core-api/pmalloc.txt | 104 +++++++++++++++++++++++++++++++++++++
>   1 file changed, 104 insertions(+)
>   create mode 100644 Documentation/core-api/pmalloc.txt
> 
> diff --git a/Documentation/core-api/pmalloc.txt b/Documentation/core-api/pmalloc.txt
> new file mode 100644
> index 0000000..9c39672
> --- /dev/null
> +++ b/Documentation/core-api/pmalloc.txt
> @@ -0,0 +1,104 @@
> +============================
> +Protectable memory allocator
> +============================
> +
> +Introduction
> +------------
> +
> +When trying to perform an attack toward a system, the attacker typically
> +wants to alter the execution flow, in a way that allows actions which
> +would otherwise be forbidden.
> +
> +In recent years there has been lots of effort in preventing the execution
> +of arbitrary code, so the attacker is progressively pushed to look for
> +alternatives.
> +
> +If code changes are either detected or even prevented, what is left is to
> +alter kernel data.
> +
> +As countermeasure, constant data is collected in a section which is then
> +marked as readonly.
> +To expand on this, also statically allocated variables which are tagged
> +as __ro_after_init will receive a similar treatment.
> +The difference from constant data is that such variables can be still
> +altered freely during the kernel init phase.
> +
> +However, such solution does not address those variables which could be
> +treated essentially as read-only, but whose size is not known at compile
> +time or cannot be fully initialized during the init phase.
> +
> +
> +Design
> +------
> +
> +pmalloc builds on top of genalloc, using the same concept of memory pools
> +A pool is a handle to a group of chunks of memory of various sizes.
> +When created, a pool is empty. It will be populated by allocating chunks
> +of memory, either when the first memory allocation request is received, or
> +when a pre-allocation is performed.
> +
> +Either way, one or more memory pages will be obtaiend from vmalloc and

                                                 obtained

> +registered in the pool as chunk. Subsequent requests will be satisfied by
> +either using any available free space from the current chunks, or by
> +allocating more vmalloc pages, should the current free space not suffice.
> +
> +This is the key point of pmalloc: it groups data that must be protected
> +into a set of pages. The protection is performed through the mmu, which
> +is a prerequisite and has a minimum granularity of one page.
> +
> +If the relevant variables were not grouped, there would be a problem of
> +allowing writes to other variables that might happen to share the same
> +page, but require further alterations over time.
> +
> +A pool is a group of pages that are write protected at the same time.
> +Ideally, they have some high level correlation (ex: they belong to the
> +same module), which justifies write protecting them all together.
> +
> +To keep it to a minimum, locking is left to the user of the API, in
> +those cases where it's not strictly needed.
> +Ideally, no further locking is required, since each module can have own
> +pool (or pools), which should, for example, avoid the need for cross
> +module or cross thread synchronization about write protecting a pool.
> +
> +The overhead of creating an additional pool is minimal: a handful of bytes
> +from kmalloc space for the metadata and then what is left unused from the
> +page(s) registered as chunks.
> +
> +Compared to plain use of vmalloc, genalloc has the advantage of tightly
> +packing the allocations, reducing the number of pages used and therefore
> +the pressure on the TLB. The slight overhead in execution time of the
> +allocation should be mostly irrelevant, because pmalloc memory is not
> +meant to be allocated/freed in tight loops. Rather it ought to be taken
> +in use, initialized and write protected. Possibly destroyed.
> +
> +Considering that not much data is supposed to be dynamically allocated
> +and then marked as read-only, it shouldn't be an issue that the address
> +range for pmalloc is limited, on 32-bit systemd.
> +
> +Regarding SMP systems, the allocations are expected to happen mostly
> +during an initial transient, after which there should be no more need to
> +perform cross-processor synchronizations of page tables.
> +
> +
> +Use
> +---
> +
> +The typical sequence, when using pmalloc, is:
> +
> +1. create a pool
> +2. [optional] pre-allocate some memory in the pool
> +3. issue one or more allocation requests to the pool
> +4. initialize the memory obtained
> +   - iterate over points 3 & 4 as needed -
> +5. write protect the pool
> +6. use in read-only mode the handlers obtained throguh the allocations

                                                   through

> +7. [optional] destroy the pool
> +
> +
> +In a scenario where, for example due to some error, part or all of the
> +allocations performed at point 3 must be reverted, it is possible to free
> +them, as long as point 5 has not been executed, and the pool is still
> +modifiable. Such freed memory can be re-used.
> +Performing a free operation on a write-protected pool will, instead,
> +simply release the corresponding memory from the accounting, but it will
> +be still impossible to alter its content.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
