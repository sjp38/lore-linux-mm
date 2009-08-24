Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1D4C66B00ED
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:32:02 -0400 (EDT)
Received: by pxi15 with SMTP id 15so6342226pxi.23
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:31:54 -0700 (PDT)
Message-ID: <4A92EBB4.1070101@vflare.org>
Date: Tue, 25 Aug 2009 01:06:20 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
References: <200908241007.47910.ngupta@vflare.org> <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
In-Reply-To: <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi Pekka,

On 08/24/2009 11:03 PM, Pekka Enberg wrote:

<snip>

> On Mon, Aug 24, 2009 at 7:37 AM, Nitin Gupta<ngupta@vflare.org>  wrote:
>> +/**
>> + * xv_malloc - Allocate block of given size from pool.
>> + * @pool: pool to allocate from
>> + * @size: size of block to allocate
>> + * @pagenum: page no. that holds the object
>> + * @offset: location of object within pagenum
>> + *
>> + * On success,<pagenum, offset>  identifies block allocated
>> + * and 0 is returned. On failure,<pagenum, offset>  is set to
>> + * 0 and -ENOMEM is returned.
>> + *
>> + * Allocation requests with size>  XV_MAX_ALLOC_SIZE will fail.
>> + */
>> +int xv_malloc(struct xv_pool *pool, u32 size, u32 *pagenum, u32 *offset,
>> +                                                       gfp_t flags)

<snip>

>
> What's the purpose of passing PFNs around? There's quite a lot of PFN
> to struct page conversion going on because of it. Wouldn't it make
> more sense to return (and pass) a pointer to struct page instead?


PFNs are 32-bit on all archs while for 'struct page *', we require 32-bit or
64-bit depending on arch. ramzswap allocates a table entry <pagenum, offset>
corresponding to every swap slot. So, the size of table will unnecessarily
increase on 64-bit archs. Same is the argument for xvmalloc free list sizes.

Also, xvmalloc and ramzswap itself does PFN -> 'struct page *' conversion
only when freeing the page or to get a deferencable pointer.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
