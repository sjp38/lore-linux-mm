Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0ACA26B0257
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 11:32:56 -0500 (EST)
Received: by mail-oi0-f53.google.com with SMTP id r187so10772591oih.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 08:32:56 -0800 (PST)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id c3si643470oeq.60.2016.03.01.08.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 08:32:54 -0800 (PST)
Date: Tue, 1 Mar 2016 10:32:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC] Support for 1GB THP
In-Reply-To: <20160301122036.GB19559@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1603011025490.31696@east.gentwo.org>
References: <20160301070911.GD3730@linux.intel.com> <20160301122036.GB19559@node.shutemov.name>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, 1 Mar 2016, Kirill A. Shutemov wrote:

> On Tue, Mar 01, 2016 at 02:09:11AM -0500, Matthew Wilcox wrote:
> >
> > There are a few issues around 1GB THP support that I've come up against
> > while working on DAX support that I think may be interesting to discuss
> > in person.
> >
> >  - Do we want to add support for 1GB THP for anonymous pages?  DAX support
> >    is driving the initial 1GB THP support, but would anonymous VMAs also
> >    benefit from 1GB support?  I'm not volunteering to do this work, but
> >    it might make an interesting conversation if we can identify some users
> >    who think performance would be better if they had 1GB THP support.
>
> At this point I don't think it would have much users. Too much hussle with
> non-obvious benefits.

In our business we preallocate everything and then the processing proceeds
without faults. 1G support has obvious benefits for us since we would be
ableto access larger areas of memory for lookups and various bits of
computation that we cannot do today without incurring TLB misses that
cause variances in our processing time. Having more mainstream support for
1G pages would make it easier to operate using these pages.

The long processing times for 1GB pages will make it even more important
to ensure all faults are done before hitting critical sections. But this
is already being done for most of our apps.

For the large NVDIMMs on the horizon using gazillions of terabytes we
really would want 1GB support. Otherwise TLB thrashing becomes quite easy
if one walks pointer chains through memory.

> >  - Latency of a major page fault.  According to various public reviews,
> >    main memory bandwidth is about 30GB/s on a Core i7-5960X with 4
> >    DDR4 channels.  I think people are probably fairly unhappy about
> >    doing only 30 page faults per second.  So maybe we need a more complex
> >    scheme to handle major faults where we insert a temporary 2MB mapping,
> >    prepare the other 2MB pages in the background, then merge them into
> >    a 1GB mapping when they're completed.
> >
> >  - Cache pressure from 1GB page support.  If we're using NT stores, they
> >    bypass the cache, and all should be good.  But if there are
> >    architectures that support THP and not NT stores, zeroing a page is
> >    just going to obliterate their caches.
>
> At some point I've tested NT stores for clearing 2M THP and it didn't show
> much benefit. I guess that could depend on microarhitecture and we
> probably should re-test this we new CPU generations.

Zeroing a page should not occur during usual processing but just during
the time that a process starts up.

> >  - Can we get rid of PAGE_CACHE_SIZE now?  Finally?  Pretty please?
>
> +1 :)

We have had grandiouse visions of being free of that particular set of
chains for more than 10 years now. Sadly nothing really was that appealing
and the current state of THP support is not that encouraging as well. We
rather go with static huge page support to have more control over how
memory is laid out for a process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
