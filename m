Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id F1A846B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 06:01:02 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p65so29779716wmp.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 03:01:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si24965631wmg.38.2016.03.01.03.01.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 03:01:01 -0800 (PST)
Date: Tue, 1 Mar 2016 11:00:55 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301110055.GK2747@suse.de>
References: <20160301070911.GD3730@linux.intel.com>
 <20160301102541.GD27666@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160301102541.GD27666@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue, Mar 01, 2016 at 11:25:41AM +0100, Jan Kara wrote:
> Hi,
> 
> On Tue 01-03-16 02:09:11, Matthew Wilcox wrote:
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
> Some time ago I was thinking about 1GB THP and I was wondering: What is the
> motivation for 1GB pages for persistent memory? Is it the savings in memory
> used for page tables? Or is it about the cost of fault?
> 

If anything, the cost of the fault is going to suck as a 1G allocation
and zeroing is required even if the application only needs 4K. It's by
no means a universal win. The savings are in page table usage and TLB
miss cost reduction and TLB footprint. For anonymous memory, it's not
considered to be worth it because the cost of allocating the page is so
high even if it works. There is no guarantee it'll work as fragementation
avoidance only works on the 2M boundary.

It's worse when files are involved because there is a
write-multiplication effect when huge pages are used. Specifically, a
fault incurs 1G of IO even if only 4K is required and then dirty
information is only tracked on a huge page granularity. This increased
IO can offset any TLB-related benefit.

I'm highly skeptical that THP for persistent memory is even worthwhile
once the write multiplication factors and allocation costs are taken into
consideration. I was surprised overall that it was even attempted before
basic features of persistent memory were even completed. I felt that it
should have been avoided until the 4K case was as fast as possible and
hitting problems where TLB was the limiting facto

Given that I recently threw in the towel over the cost of 2M allocations
let alone 1G translations, I'm highly skeptical that 1G anonymous pages
are worth the cost.

> If it is mainly about the fault cost, won't some fault-around logic (i.e.
> filling more PMD entries in one PMD fault) go a long way towards reducing
> fault cost without some complications?
> 

I think this would be a pre-requisite. Basically, the idea is that a 2M
page is reserved, but not allocated in response to a 4K page fault. The
pages are then inserted properly aligned such. If there are faults around
it then use other properly aligned pages and when the 2M chunk is allocated
then promote it at that point. Early research considered where there was
a fill-factor other than 1 that should trigger a hugepage promotion but
it would have to be re-evaluated on modern hardware.

I'm not aware of anyone actually working on such an implementation though
because it'd be a lot of legwork. I wrote a TODO item about this at some
far point in the past that never got to the top of the list

Title: In-place huge page collapsing
Description:
        When collapsing a huge page, the kernel allocates a huge page and
        then copies from the base page. This is expensive. Investigate
        in-place reservation whereby a base page is faulted in but the
        properly placed pages are reserved for that process unless the
        alternative is to fail the allocation. Care would be needed to
        ensure that the kernel does not reclaim because pages are reserved
        or increase contention on zone->lock. If it works correctly we
        would be able to collapse huge pages without copying and it would
        also performance extremely well when the workload uses sparse
        address spaces.

> >  - Cache pressure from 1GB page support.  If we're using NT stores, they
> >    bypass the cache, and all should be good.  But if there are
> >    architectures that support THP and not NT stores, zeroing a page is
> >    just going to obliterate their caches.
> 
> Even doing fsync() - and thus flush all cache lines associated with 1GB
> page - is likely going to take noticeable chunk of time. The granularity of
> cache flushing in kernel is another thing that makes me somewhat cautious
> about 1GB pages.
> 

Problems like this were highlighted in early hugepage-related papers in
the 90's. Even if persistent memory is extremely fast, there is going to
be large costs. In-place promotion would avoid some of the worst of the
costs.

If it was me, I would focus on getting all the basic features of persistent
memory working first, finding if there are workloads that are limited by
TLB pressure and then and only then start worrying about 1G pages. If that
is not done then persistent memory could fall down the same trap that the
VM did whereby huge pages were being used to workaround bottlenecks within
the VM or crappy hardware.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
