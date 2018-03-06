Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12BEB6B0008
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 09:10:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x7so11603818pfd.19
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 06:10:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id m63-v6si11266910pld.602.2018.03.06.06.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 06:10:52 -0800 (PST)
Date: Tue, 6 Mar 2018 06:10:47 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
Message-ID: <20180306141047.GB13722@bombadil.infradead.org>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-2-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180228200620.30026-2-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 28, 2018 at 10:06:14PM +0200, Igor Stoppa wrote:
> + * Encoding of the bitmap tracking the allocations
> + * -----------------------------------------------
> + *
> + * The bitmap is composed of units of allocations.
> + *
> + * Each unit of allocation is represented using 2 consecutive bits.
> + *
> + * This makes it possible to encode, for each unit of allocation,
> + * information about:
> + *  - allocation status (busy/free)
> + *  - beginning of a sequennce of allocation units (first / successive)
> + *
> + *
> + * Dictionary of allocation units (msb to the left, lsb to the right):
> + *
> + * 11: first allocation unit in the allocation
> + * 10: any subsequent allocation unit (if any) in the allocation
> + * 00: available allocation unit
> + * 01: invalid
> + *
> + * Example, using the same notation as above - MSb.......LSb:
> + *
> + *  ...000010111100000010101011   <-- Read in this direction.
> + *     \__|\__|\|\____|\______|
> + *        |   | |     |       \___ 4 used allocation units
> + *        |   | |     \___________ 3 empty allocation units
> + *        |   | \_________________ 1 used allocation unit
> + *        |   \___________________ 2 used allocation units
> + *        \_______________________ 2 empty allocation units
> + *
> + * The encoding allows for lockless operations, such as:
> + * - search for a sufficiently large range of allocation units
> + * - reservation of a selected range of allocation units
> + * - release of a specific allocation
> + *
> + * The alignment at which to perform the research for sequence of empty
> + * allocation units (marked as zeros in the bitmap) is 2^1.
> + *
> + * This means that an allocation can start only at even places
> + * (bit 0, bit 2, etc.) in the bitmap.
> + *
> + * Therefore, the number of zeroes to look for must be twice the number
> + * of desired allocation units.
> + *
> + * When it's time to free the memory associated to an allocation request,
> + * it's a matter of checking if the corresponding allocation unit is
> + * really the beginning of an allocation (both bits are set to 1).
> + *
> + * Looking for the ending can also be performed locklessly.
> + * It's sufficient to identify the first mapped allocation unit
> + * that is represented either as free (00) or busy (11).
> + * Even if the allocation status should change in the meanwhile, it
> + * doesn't matter, since it can only transition between free (00) and
> + * first-allocated (11).

This seems unnecessarily complicated.  Why not handle it like this:

 - Double the bitmap in size (as you have done) but
 - The first half of the bits are unchanged from the existing implementation
 - The second half of the bits are used for determining the length

On allocation, you look for a sufficiently-large string of 0 bits in
the first-half.  When you find it, you set all of them to 1, and set one
bit in the second-half to indicate where the tail of the allocation is
(you might actually want to use an rbtree or something to handle this ...
using all these bits seems pretty inefficient).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
