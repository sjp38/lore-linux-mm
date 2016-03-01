Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC026B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 07:20:39 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so33962345wmn.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 04:20:39 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id qo6si37108513wjc.79.2016.03.01.04.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 04:20:38 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id l68so30797131wml.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 04:20:38 -0800 (PST)
Date: Tue, 1 Mar 2016 15:20:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301122036.GB19559@node.shutemov.name>
References: <20160301070911.GD3730@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301070911.GD3730@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 01, 2016 at 02:09:11AM -0500, Matthew Wilcox wrote:
> 
> There are a few issues around 1GB THP support that I've come up against
> while working on DAX support that I think may be interesting to discuss
> in person.
> 
>  - Do we want to add support for 1GB THP for anonymous pages?  DAX support
>    is driving the initial 1GB THP support, but would anonymous VMAs also
>    benefit from 1GB support?  I'm not volunteering to do this work, but
>    it might make an interesting conversation if we can identify some users
>    who think performance would be better if they had 1GB THP support.

At this point I don't think it would have much users. Too much hussle with
non-obvious benefits.

>  - Latency of a major page fault.  According to various public reviews,
>    main memory bandwidth is about 30GB/s on a Core i7-5960X with 4
>    DDR4 channels.  I think people are probably fairly unhappy about
>    doing only 30 page faults per second.  So maybe we need a more complex
>    scheme to handle major faults where we insert a temporary 2MB mapping,
>    prepare the other 2MB pages in the background, then merge them into
>    a 1GB mapping when they're completed.
> 
>  - Cache pressure from 1GB page support.  If we're using NT stores, they
>    bypass the cache, and all should be good.  But if there are
>    architectures that support THP and not NT stores, zeroing a page is
>    just going to obliterate their caches.

At some point I've tested NT stores for clearing 2M THP and it didn't show
much benefit. I guess that could depend on microarhitecture and we
probably should re-test this we new CPU generations.

> Other topics that might interest people from a VM/FS point of view:
> 
>  - Uses for (or replacement of) the radix tree.  We're currently
>    looking at using the radix tree with DAX in order to reduce the number
>    of calls into the filesystem.  That's leading to various enhancements
>    to the radix tree, such as support for a lock bit for exceptional
>    entries (Neil Brown), and support for multi-order entries (me).
>    Is the (enhanced) radix tree the right data structure to be using
>    for this brave new world of huge pages in the page cache, or should
>    we be looking at some other data structure like an RB-tree?

I'm interested in multi-order entires for THP page cache. It's not
required for hugetmpfs, but would be nice to have.
> 
>  - Can we get rid of PAGE_CACHE_SIZE now?  Finally?  Pretty please?

+1 :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
