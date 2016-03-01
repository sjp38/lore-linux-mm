Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CFD446B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 06:51:40 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l68so32676429wml.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 03:51:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id it2si34203627wjb.129.2016.03.01.03.51.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 03:51:39 -0800 (PST)
Date: Tue, 1 Mar 2016 11:51:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301115136.GL2747@suse.de>
References: <20160301070911.GD3730@linux.intel.com>
 <20160301102541.GD27666@quack.suse.cz>
 <20160301110055.GK2747@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160301110055.GK2747@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Mar 01, 2016 at 11:00:55AM +0000, Mel Gorman wrote:
> On Tue, Mar 01, 2016 at 11:25:41AM +0100, Jan Kara wrote:
> > Hi,
> > 
> > On Tue 01-03-16 02:09:11, Matthew Wilcox wrote:
> > > There are a few issues around 1GB THP support that I've come up against
> > > while working on DAX support that I think may be interesting to discuss
> > > in person.
> > > 
> > >  - Do we want to add support for 1GB THP for anonymous pages?  DAX support
> > >    is driving the initial 1GB THP support, but would anonymous VMAs also
> > >    benefit from 1GB support?  I'm not volunteering to do this work, but
> > >    it might make an interesting conversation if we can identify some users
> > >    who think performance would be better if they had 1GB THP support.
> > 
> > Some time ago I was thinking about 1GB THP and I was wondering: What is the
> > motivation for 1GB pages for persistent memory? Is it the savings in memory
> > used for page tables? Or is it about the cost of fault?
> > 
> 
> If anything, the cost of the fault is going to suck as a 1G allocation
> and zeroing is required even if the application only needs 4K. It's by
> no means a universal win. The savings are in page table usage and TLB
> miss cost reduction and TLB footprint. For anonymous memory, it's not
> considered to be worth it because the cost of allocating the page is so
> high even if it works. There is no guarantee it'll work as fragementation
> avoidance only works on the 2M boundary.
> 
> It's worse when files are involved because there is a
> write-multiplication effect when huge pages are used. Specifically, a
> fault incurs 1G of IO even if only 4K is required and then dirty
> information is only tracked on a huge page granularity. This increased
> IO can offset any TLB-related benefit.
> 

It was pointed out to me privately that the IO amplication cost is not the
same for persistent memory as it is for traditional storage and this is
true. For example, the 1G of data does not have to be read on fault every
time. The write problems are mitigated but remain if the 1G block has to
be zero'd for example. Even for normal writeback the cache lines have to
be flushed as the kernel does not know what lines were updated. I know
there is a proposal to defer that tracking to userspace but that breaks
if an unaware process accesses the page and is overall very risky.

There are other issues such as having to reserve 1G of block in case a file
is truncated in the future or else there is an extremely large amount of
wastage. Maybe it can be worked around but a workload that uses persistent
memory with many small files may have a bad day.

While I know some of these points can be countered and discussed further,
at the end of the day, the benefits to huge page usage are reduced memory
usage on page tables, a reduction of TLB pressure and reduced TLB fill
costs. Until such time as it's known that there are realistic workloads
that cannot fit in memory due to the page table usage and workloads that
are limited by TLB pressure, the complexity of huge pages is unjustified
and the focus should be on the basic features working correctly.

If fault overhead of a 4K page is a major concern then fault-around should
be used on the 2M boundary at least. I expect there are relatively few real
workloads that are limited by the cost of major faults. Applications may
have a higher startup cost than desirable but in itself that does not justify
using huge pages to workload problems with fault speeds in the kernel.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
