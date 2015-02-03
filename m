Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B59736B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 06:21:30 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id a1so43992543wgh.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 03:21:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy6si6808867wib.19.2015.02.03.03.21.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 03:21:29 -0800 (PST)
Date: Tue, 3 Feb 2015 11:21:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
Message-ID: <20150203112124.GS2395@suse.de>
References: <20150202165525.GM2395@suse.de>
 <54CFF8AC.6010102@intel.com>
 <20150203094718.GO2395@suse.de>
 <20150203104756.GB14259@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150203104756.GB14259@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, Feb 03, 2015 at 12:47:56PM +0200, Kirill A. Shutemov wrote:
> On Tue, Feb 03, 2015 at 09:47:18AM +0000, Mel Gorman wrote:
> > On Mon, Feb 02, 2015 at 02:22:36PM -0800, Dave Hansen wrote:
> > > On 02/02/2015 08:55 AM, Mel Gorman wrote:
> > > > This patch identifies when a thread is frequently calling MADV_DONTNEED
> > > > on the same region of memory and starts ignoring the hint. On an 8-core
> > > > single-socket machine this was the impact on ebizzy using glibc 2.19.
> > > 
> > > The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
> > > called:
> > > 
> > 
> > It also claims that the kernel is free to ignore the advice.
> > 
> > > >      MADV_DONTNEED
> > > >               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
> > > >               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
> > > >               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.
> > > 
> > > So if we have anything depending on the behavior that it's _always_
> > > zero-filled after an MADV_DONTNEED, this will break it.
> > 
> > True. I'd be surprised if any application depended on that 
> 
> IIUC, jemalloc depends on this[1].
> 
> [1] https://github.com/jemalloc/jemalloc/blob/dev/src/chunk_mmap.c#L117
> 

Hope they never back regions with hugetlb then or fall apart if the process
called mlockall

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
