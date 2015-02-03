Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 278F86B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 06:16:07 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id h11so21699331wiw.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 03:16:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si30683397wiw.11.2015.02.03.03.16.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 03:16:05 -0800 (PST)
Date: Tue, 3 Feb 2015 11:16:00 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
Message-ID: <20150203111600.GR2395@suse.de>
References: <20150202165525.GM2395@suse.de>
 <54CFF8AC.6010102@intel.com>
 <54D08483.40209@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <54D08483.40209@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, mtk.manpages@gmail.com, linux-man@vger.kernel.org

On Tue, Feb 03, 2015 at 09:19:15AM +0100, Vlastimil Babka wrote:
> [CC linux-api, man pages]
> 
> On 02/02/2015 11:22 PM, Dave Hansen wrote:
> > On 02/02/2015 08:55 AM, Mel Gorman wrote:
> >> This patch identifies when a thread is frequently calling MADV_DONTNEED
> >> on the same region of memory and starts ignoring the hint. On an 8-core
> >> single-socket machine this was the impact on ebizzy using glibc 2.19.
> > 
> > The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
> > called:
> > 
> >>      MADV_DONTNEED
> >>               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
> >>               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
> >>               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.
> > 
> > So if we have anything depending on the behavior that it's _always_
> > zero-filled after an MADV_DONTNEED, this will break it.
> 
> OK, so that's a third person (including me) who understood it as a zero-fill
> guarantee. I think the man page should be clarified (if it's indeed not
> guaranteed), or we have a bug.
> 
> The implementation actually skips MADV_DONTNEED for
> VM_LOCKED|VM_HUGETLB|VM_PFNMAP vma's.
> 

This was the first reason why I did not consider the zero-filling to be a
guarantee. That said, at this point I'm also not considering pushing this
patch towards the kernel. I agree that this is a glibc bug so I've dropped
a line to some glibc people to see what they think the approach should be.

> I'm not sure about VM_PFNMAP, these are probably special enough. For mlock, one
> could expect that mlocking and MADV_DONTNEED would be in some opposition, but
> it's not documented in the manpage AFAIK. Neither is the hugetlb case, which
> could be really unexpected by the user.
> 

The equivalent posix page also lacks details on how exactly this flag
should behave. hugetlb is sortof special in that it's always backed by
a ram-based file where the contents can be refaulted. It gets hairy when
the mapping has been created to look anonymous but is not anonymous
really. The semantics of hugetlb have always been fuzzy.

> Next, what the man page says about guarantees:
> 
> "The kernel is free to ignore the advice."
> 
> - that would suggest that nothing is guaranteed
> 

Yep, another reason why I did not clear the page when ignoring the hint.

> "This call does not influence the semantics of the application (except in the
> case of MADV_DONTNEED)"
> 
> - that depends if the reader understands it as "does influence by MADV_DONTNEED"
> or "may influence by MADV_DONTNEED"
> 
> - btw, isn't MADV_DONTFORK another exception that does influence the semantics?
> And since it's mentioned as a workaround for some hardware, is it OK to ignore
> this advice?
> 

MADV_DONTFORK is also a Linux-specific extention. It happens to be one
that if it gets ignored then the application will be very surprised.

> And the part you already cited:
> 
> "Subsequent accesses of pages in this range will succeed, but will result either
> in reloading of the memory contents from the underlying mapped file (see
> mmap(2)) or zero-fill on-demand pages for mappings without an underlying file."
> 
> - The word "will result" did sound as a guarantee at least to me. So here it
> could be changed to "may result (unless the advice is ignored)"?
> 

The wording should be "may result" as there are circumstances where it
gets ignored even without this prototype patch.

> And if we agree that there is indeed no guarantee, what's the actual semantic
> difference from MADV_FREE? I guess none? So there's only a possible perfomance
> difference?
> 

Timing. MADV_DONTNEED if it has an effect is immediate, is a heavier
operations and RSS is reduced. MADV_FREE only has an impact in the future
if there is memory pressure.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
