Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 996546B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 05:53:08 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id hz20so50183508lab.6
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 02:53:08 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id o15si18895867laa.27.2015.02.03.02.53.06
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 02:53:06 -0800 (PST)
Date: Tue, 3 Feb 2015 12:53:01 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
Message-ID: <20150203105301.GC14259@node.dhcp.inet.fi>
References: <20150202165525.GM2395@suse.de>
 <54CFF8AC.6010102@intel.com>
 <54D08483.40209@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54D08483.40209@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, mtk.manpages@gmail.com, linux-man@vger.kernel.org

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

It doesn't skip. It fails with -EINVAL. Or I miss something.

> - The word "will result" did sound as a guarantee at least to me. So here it
> could be changed to "may result (unless the advice is ignored)"?

It's too late to fix documentation. Applications already depends on the
beheviour.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
