Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 867766B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 11:05:37 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id x85so16174oix.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 08:05:37 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id t21si4404113oij.87.2018.03.06.08.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 08:05:36 -0800 (PST)
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-2-igor.stoppa@huawei.com>
 <20180306141047.GB13722@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <6d27845d-a8f3-607b-1b6b-8464de65162c@huawei.com>
Date: Tue, 6 Mar 2018 18:05:20 +0200
MIME-Version: 1.0
In-Reply-To: <20180306141047.GB13722@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 06/03/2018 16:10, Matthew Wilcox wrote:
> On Wed, Feb 28, 2018 at 10:06:14PM +0200, Igor Stoppa wrote:
>> + * Encoding of the bitmap tracking the allocations
>> + * -----------------------------------------------
>> + *
>> + * The bitmap is composed of units of allocations.
>> + *
>> + * Each unit of allocation is represented using 2 consecutive bits.
>> + *
>> + * This makes it possible to encode, for each unit of allocation,
>> + * information about:
>> + *  - allocation status (busy/free)
>> + *  - beginning of a sequennce of allocation units (first / successive)
>> + *
>> + *
>> + * Dictionary of allocation units (msb to the left, lsb to the right):
>> + *
>> + * 11: first allocation unit in the allocation
>> + * 10: any subsequent allocation unit (if any) in the allocation
>> + * 00: available allocation unit
>> + * 01: invalid
>> + *
>> + * Example, using the same notation as above - MSb.......LSb:
>> + *
>> + *  ...000010111100000010101011   <-- Read in this direction.
>> + *     \__|\__|\|\____|\______|
>> + *        |   | |     |       \___ 4 used allocation units
>> + *        |   | |     \___________ 3 empty allocation units
>> + *        |   | \_________________ 1 used allocation unit
>> + *        |   \___________________ 2 used allocation units
>> + *        \_______________________ 2 empty allocation units
>> + *
>> + * The encoding allows for lockless operations, such as:
>> + * - search for a sufficiently large range of allocation units
>> + * - reservation of a selected range of allocation units
>> + * - release of a specific allocation
>> + *
>> + * The alignment at which to perform the research for sequence of empty
>> + * allocation units (marked as zeros in the bitmap) is 2^1.
>> + *
>> + * This means that an allocation can start only at even places
>> + * (bit 0, bit 2, etc.) in the bitmap.
>> + *
>> + * Therefore, the number of zeroes to look for must be twice the number
>> + * of desired allocation units.
>> + *
>> + * When it's time to free the memory associated to an allocation request,
>> + * it's a matter of checking if the corresponding allocation unit is
>> + * really the beginning of an allocation (both bits are set to 1).
>> + *
>> + * Looking for the ending can also be performed locklessly.
>> + * It's sufficient to identify the first mapped allocation unit
>> + * that is represented either as free (00) or busy (11).
>> + * Even if the allocation status should change in the meanwhile, it
>> + * doesn't matter, since it can only transition between free (00) and
>> + * first-allocated (11).
> 
> This seems unnecessarily complicated.

TBH it seemed to me a natural extension of the existing encoding :-)

>  Why not handle it like this:
> 
>  - Double the bitmap in size (as you have done) but
>  - The first half of the bits are unchanged from the existing implementation
>  - The second half of the bits are used for determining the length

Wouldn't that mean a less tight loop and less localized data?
The implementation from this patch does not have to jump elsewhere, when
(un)marking the allocation units and the start.

> On allocation, you look for a sufficiently-large string of 0 bits in
> the first-half.  When you find it, you set all of them to 1, and set one
> bit in the second-half to indicate where the tail of the allocation is
> (you might actually want to use an rbtree or something to handle this ...
> using all these bits seems pretty inefficient).

1 bit maps to 1 unit of allocation, which is very seldom 1 byte.
For pmalloc use, I expect that the average allocation is likely to be
2-4 units, where 1 unit equals either a 32 or 64 bits word.
So it's probably likely that for every couple of allocation units, one
is marked as start-of-allocation.

In other cases where genalloc is used, like the tracking of uncached
pages, 1 unit of allocation equals to 1 page.

I would expect the rbtree to end up generating a far larger footprint.

For the same reasons, since the bitmap is implemented using unsigned
longs, chances are high that one allocation will fit in one bitmap
"word", which means that if the "beginning" bit and the "occupied" bit
are adjacent, one write is sufficient.

In the case you describe, it would be almost always at least 2.

I do not have factual evidence to back my reasoning, but it seems more
likely to be the case, from my analysis of data types that could belong
to pools (both existing users of genalloc and my experiments with
SELinux data structures and pmalloc).

Even in the XFS case, if I understood correctly, it was about protecting
1 or 2 pages at a time, which seems to fit what I have empirically observed.

What makes you think otherwise?

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
