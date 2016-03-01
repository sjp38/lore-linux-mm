Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 797AB6B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 05:25:21 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p65so26684703wmp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 02:25:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id la5si36592457wjb.232.2016.03.01.02.25.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 02:25:20 -0800 (PST)
Date: Tue, 1 Mar 2016 11:25:41 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301102541.GD27666@quack.suse.cz>
References: <20160301070911.GD3730@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301070911.GD3730@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Tue 01-03-16 02:09:11, Matthew Wilcox wrote:
> There are a few issues around 1GB THP support that I've come up against
> while working on DAX support that I think may be interesting to discuss
> in person.
> 
>  - Do we want to add support for 1GB THP for anonymous pages?  DAX support
>    is driving the initial 1GB THP support, but would anonymous VMAs also
>    benefit from 1GB support?  I'm not volunteering to do this work, but
>    it might make an interesting conversation if we can identify some users
>    who think performance would be better if they had 1GB THP support.

Some time ago I was thinking about 1GB THP and I was wondering: What is the
motivation for 1GB pages for persistent memory? Is it the savings in memory
used for page tables? Or is it about the cost of fault?

If it is mainly about the fault cost, won't some fault-around logic (i.e.
filling more PMD entries in one PMD fault) go a long way towards reducing
fault cost without some complications?

>  - Latency of a major page fault.  According to various public reviews,
>    main memory bandwidth is about 30GB/s on a Core i7-5960X with 4
>    DDR4 channels.  I think people are probably fairly unhappy about
>    doing only 30 page faults per second.  So maybe we need a more complex
>    scheme to handle major faults where we insert a temporary 2MB mapping,
>    prepare the other 2MB pages in the background, then merge them into
>    a 1GB mapping when they're completed.

Yeah, here is one of the complications I have mentioned above ;)
 
>  - Cache pressure from 1GB page support.  If we're using NT stores, they
>    bypass the cache, and all should be good.  But if there are
>    architectures that support THP and not NT stores, zeroing a page is
>    just going to obliterate their caches.

Even doing fsync() - and thus flush all cache lines associated with 1GB
page - is likely going to take noticeable chunk of time. The granularity of
cache flushing in kernel is another thing that makes me somewhat cautious
about 1GB pages.

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

I was also thinking whether we wouldn't be better off with some other data
structure than radix tree for DAX. And I didn't really find anything that
I'd be satisfied with. The main advantages of radix tree I see are - it is
of constant depth, it supports lockless lookups, it is relatively simple
(although with the additions we'd need this advantage slowly vanishes), it
is pretty space efficient for common cases.

For your multi-order entries I was wondering whether we shouldn't relax the
requirement that all nodes have the same number of slots - e.g. we could
have number of slots variable with node depth so that PMD and eventually PUD
multi-order slots end up being a single entry at appropriate radix tree
level.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
