Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E26D66B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 06:42:56 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so21160150wib.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 03:42:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si24773197wjf.122.2015.02.03.03.42.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 03:42:55 -0800 (PST)
Message-ID: <54D0B43D.8000209@suse.cz>
Date: Tue, 03 Feb 2015 12:42:53 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
References: <20150202165525.GM2395@suse.de> <54CFF8AC.6010102@intel.com> <54D08483.40209@suse.cz> <20150203105301.GC14259@node.dhcp.inet.fi>
In-Reply-To: <20150203105301.GC14259@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, mtk.manpages@gmail.com, linux-man@vger.kernel.org

On 02/03/2015 11:53 AM, Kirill A. Shutemov wrote:
> On Tue, Feb 03, 2015 at 09:19:15AM +0100, Vlastimil Babka wrote:
>> [CC linux-api, man pages]
>> 
>> On 02/02/2015 11:22 PM, Dave Hansen wrote:
>> > On 02/02/2015 08:55 AM, Mel Gorman wrote:
>> >> This patch identifies when a thread is frequently calling MADV_DONTNEED
>> >> on the same region of memory and starts ignoring the hint. On an 8-core
>> >> single-socket machine this was the impact on ebizzy using glibc 2.19.
>> > 
>> > The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
>> > called:
>> > 
>> >>      MADV_DONTNEED
>> >>               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
>> >>               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
>> >>               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.
>> > 
>> > So if we have anything depending on the behavior that it's _always_
>> > zero-filled after an MADV_DONTNEED, this will break it.
>> 
>> OK, so that's a third person (including me) who understood it as a zero-fill
>> guarantee. I think the man page should be clarified (if it's indeed not
>> guaranteed), or we have a bug.
>> 
>> The implementation actually skips MADV_DONTNEED for
>> VM_LOCKED|VM_HUGETLB|VM_PFNMAP vma's.
> 
> It doesn't skip. It fails with -EINVAL. Or I miss something.

No, I missed that. Thanks for pointing out. The manpage also explains EINVAL in
this case:

*  The application is attempting to release locked or shared pages (with
MADV_DONTNEED).

- that covers mlocking ok, not sure if the rest fits the "shared pages" case
though. I dont see any check for other kinds of shared pages in the code.

>> - The word "will result" did sound as a guarantee at least to me. So here it
>> could be changed to "may result (unless the advice is ignored)"?
> 
> It's too late to fix documentation. Applications already depends on the
> beheviour.

Right, so as long as they check for EINVAL, it should be safe. It appears that
jemalloc does.

I still wouldnt be sure just by reading the man page that the clearing is
guaranteed whenever I dont get an error return value, though,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
