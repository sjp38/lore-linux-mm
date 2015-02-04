Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8066B009E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 19:09:30 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so102682418pad.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 16:09:30 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id pk3si4382416pdb.166.2015.02.03.16.09.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 16:09:29 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so102523205pab.3
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 16:09:29 -0800 (PST)
Date: Wed, 4 Feb 2015 09:09:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
Message-ID: <20150204000921.GC3583@blaptop>
References: <20150202165525.GM2395@suse.de>
 <54CFF8AC.6010102@intel.com>
 <54D08483.40209@suse.cz>
 <20150203105301.GC14259@node.dhcp.inet.fi>
 <54D0B43D.8000209@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54D0B43D.8000209@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, mtk.manpages@gmail.com, linux-man@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Tue, Feb 03, 2015 at 12:42:53PM +0100, Vlastimil Babka wrote:
> On 02/03/2015 11:53 AM, Kirill A. Shutemov wrote:
> > On Tue, Feb 03, 2015 at 09:19:15AM +0100, Vlastimil Babka wrote:
> >> [CC linux-api, man pages]
> >> 
> >> On 02/02/2015 11:22 PM, Dave Hansen wrote:
> >> > On 02/02/2015 08:55 AM, Mel Gorman wrote:
> >> >> This patch identifies when a thread is frequently calling MADV_DONTNEED
> >> >> on the same region of memory and starts ignoring the hint. On an 8-core
> >> >> single-socket machine this was the impact on ebizzy using glibc 2.19.
> >> > 
> >> > The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
> >> > called:
> >> > 
> >> >>      MADV_DONTNEED
> >> >>               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
> >> >>               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
> >> >>               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.
> >> > 
> >> > So if we have anything depending on the behavior that it's _always_
> >> > zero-filled after an MADV_DONTNEED, this will break it.
> >> 
> >> OK, so that's a third person (including me) who understood it as a zero-fill
> >> guarantee. I think the man page should be clarified (if it's indeed not
> >> guaranteed), or we have a bug.
> >> 
> >> The implementation actually skips MADV_DONTNEED for
> >> VM_LOCKED|VM_HUGETLB|VM_PFNMAP vma's.
> > 
> > It doesn't skip. It fails with -EINVAL. Or I miss something.
> 
> No, I missed that. Thanks for pointing out. The manpage also explains EINVAL in
> this case:
> 
> *  The application is attempting to release locked or shared pages (with
> MADV_DONTNEED).
> 
> - that covers mlocking ok, not sure if the rest fits the "shared pages" case
> though. I dont see any check for other kinds of shared pages in the code.
> 
> >> - The word "will result" did sound as a guarantee at least to me. So here it
> >> could be changed to "may result (unless the advice is ignored)"?
> > 
> > It's too late to fix documentation. Applications already depends on the
> > beheviour.
> 
> Right, so as long as they check for EINVAL, it should be safe. It appears that
> jemalloc does.
> 
> I still wouldnt be sure just by reading the man page that the clearing is
> guaranteed whenever I dont get an error return value, though,
> 

IMHO,

Man page said
"MADV_DONTNEED: Subsequent accesses of pages in this range will succeed,
 but will result either in reloading of  the memory contents from the
 underlying mapped file (see mmap(2)) or  zero-fill-on-demand pages
 for mappings without an underlying file."

Heap by allocated by malloc(3) is anonymous page so it's a mapping
withtout an underlying file so userspace can expect zero-fill.

Man page said
"EINVAL: The application is attempting to release locked or
shared pages (with MADV_DONTNEED)"

So, user can expect the call on area by allocated by malloc(3)
if he doesn't call mlock will always be successful.

Man page said
"madivse: This call does not influence the semantics of the application
(except in the case of MADV_DONTNEED)"

So, we shouldn't break MADV_DONTNEED's semantic which free pages
instantly. It's a long time semantic and it was one of arguable issues
on MADV_FREE Rik had tried long time ago to replace MADV_DONTNEED
with MADV_FREE.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
