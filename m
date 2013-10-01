Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE706B0036
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 04:38:41 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so6791087pbb.19
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 01:38:41 -0700 (PDT)
Date: Tue, 1 Oct 2013 09:38:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Message-ID: <20131001083828.GA8093@suse.de>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
 <20130930100249.GB2425@suse.de>
 <20130930101029.GC2425@suse.de>
 <20130930185106.GD2125@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130930185106.GD2125@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 30, 2013 at 11:51:06AM -0700, Andi Kleen wrote:
> > AFAIK, this is not a problem in the vast majority of modern CPUs
> 
> Let's do some simple math: e.g. a Sandy Bridge system has 512 4K iTLB L2 entries.
> That's around 2MB. There's more and more code whose footprint exceeds
> that.
> 

With an expectation that it is read-mostly data, replicated between the
caches accessing it and TLB refills taking very little time. This is not
universally true and there are exceptions but even recent papers on TLB
behaviour have tended to dismiss the iTLB refill overhead as a negligible
portion of the overall workload of interest.

> Besides iTLB is not the only target. It is also useful for 
> data of course.
> 

True, but how useful? I have not seen an example of a workload showing that
dTLB pressure on file-backed data was a major component of the workload. I
would expect that sysV shared memory is an exception but does that require
generic support for all filesystems or can tmpfs be special cased when
it's used for shared memory?

For normal data, if it's read-only data then there would be some benefit to
using huge pages once the data is in page cache. How common are workloads
that mmap() large amounts of read-only data? Possibly some databases
depending on the workload although there I would expect that the data is
placed in shared memory.

If the mmap()s data is being written then the cost of IO is likely to
dominate, not TLB pressure. For write-mostly workloads there are greater
concerns because dirty tracking can only be done at the huge page boundary
potentially leading to greater amounts of IO and degraded performance
overall.

I could be completely wrong here but these were the concerns I had when
I first glanced through the patches. The changelogs had no information
to convince me otherwise so I never dedicated the time to reviewing the
patches in detail. I raised my concerns and then dropped it.

> > > and I found it very hard to be motivated to review the series as a result.
> > > I suspected that in many cases that the cost of IO would continue to dominate
> > > performance instead of TLB pressure
> 
> The trend is to larger and larger memories, keeping things in memory.
> 

Yes, but using huge pages is not *necessarily* the answer. For fault
scalability it probably would be a lot easier to batch handle faults if
readahead indicates accesses are sequential. Background zeroing of pages
could be revisited for fault intensive workloads. A potential alternative
is that a contiguous page is allocated, zerod as one lump, split the pages
and put onto a local per-task list although the details get messy. Reclaim
scanning could be heavily modified to use collections of pages instead of
single pages (although I'm not aware of the proper design of such a thing).

Again, this could be completely off the mark but if it was me that was
working on this problem, I would have some profile data from some workloads
to make sure the part I'm optimising was a noticable percentage of the
workload and included that in the patch leader. I would hope that the data
was compelling enough to convince reviewers to pay close attention to the
series as the complexity would then be justified. Based on how complex THP
was for anonymous pages, I would be tempted to treat THP for file-backed
data as a last resort.

> In fact there's a good argument that memory sizes are growing faster
> than TLB capacities. And without large TLBs we're even further off
> the curve.
> 

I'll admit this is also true. It was considered to be true in the 90's
when huge pages were first being thrown around as a possible solution to
the problem. One paper recently suggested using segmentation for large
memory segments but the workloads they examined looked like they would
be dominated by anonymous access, not file-backed data with one exception
where the workload frequently accessed compile-time constants.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
