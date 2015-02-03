Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id CECE96B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 05:48:07 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gq15so50211354lab.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 02:48:07 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id w8si6934201lbb.25.2015.02.03.02.48.05
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 02:48:05 -0800 (PST)
Date: Tue, 3 Feb 2015 12:47:56 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
Message-ID: <20150203104756.GB14259@node.dhcp.inet.fi>
References: <20150202165525.GM2395@suse.de>
 <54CFF8AC.6010102@intel.com>
 <20150203094718.GO2395@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203094718.GO2395@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, Feb 03, 2015 at 09:47:18AM +0000, Mel Gorman wrote:
> On Mon, Feb 02, 2015 at 02:22:36PM -0800, Dave Hansen wrote:
> > On 02/02/2015 08:55 AM, Mel Gorman wrote:
> > > This patch identifies when a thread is frequently calling MADV_DONTNEED
> > > on the same region of memory and starts ignoring the hint. On an 8-core
> > > single-socket machine this was the impact on ebizzy using glibc 2.19.
> > 
> > The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
> > called:
> > 
> 
> It also claims that the kernel is free to ignore the advice.
> 
> > >      MADV_DONTNEED
> > >               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
> > >               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
> > >               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.
> > 
> > So if we have anything depending on the behavior that it's _always_
> > zero-filled after an MADV_DONTNEED, this will break it.
> 
> True. I'd be surprised if any application depended on that 

IIUC, jemalloc depends on this[1].

[1] https://github.com/jemalloc/jemalloc/blob/dev/src/chunk_mmap.c#L117

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
