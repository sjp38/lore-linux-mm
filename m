Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 861736B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 04:47:25 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id k48so43923628wev.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 01:47:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u1si28017436wiy.37.2015.02.03.01.47.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 01:47:23 -0800 (PST)
Date: Tue, 3 Feb 2015 09:47:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
Message-ID: <20150203094718.GO2395@suse.de>
References: <20150202165525.GM2395@suse.de>
 <54CFF8AC.6010102@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <54CFF8AC.6010102@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, Feb 02, 2015 at 02:22:36PM -0800, Dave Hansen wrote:
> On 02/02/2015 08:55 AM, Mel Gorman wrote:
> > This patch identifies when a thread is frequently calling MADV_DONTNEED
> > on the same region of memory and starts ignoring the hint. On an 8-core
> > single-socket machine this was the impact on ebizzy using glibc 2.19.
> 
> The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
> called:
> 

It also claims that the kernel is free to ignore the advice.

> >      MADV_DONTNEED
> >               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
> >               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
> >               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.
> 
> So if we have anything depending on the behavior that it's _always_
> zero-filled after an MADV_DONTNEED, this will break it.

True. I'd be surprised if any application depended on that but to be safe,
an ignored hint could clear the pages. It would still be cheaper than a
full teardown and refault.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
