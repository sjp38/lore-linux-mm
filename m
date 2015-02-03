Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5731A6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 03:19:20 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id w55so38113940wes.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 00:19:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fl6si29996836wib.71.2015.02.03.00.19.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 00:19:18 -0800 (PST)
Message-ID: <54D08483.40209@suse.cz>
Date: Tue, 03 Feb 2015 09:19:15 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore repeated
 MADV_DONTNEED hints
References: <20150202165525.GM2395@suse.de> <54CFF8AC.6010102@intel.com>
In-Reply-To: <54CFF8AC.6010102@intel.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, mtk.manpages@gmail.com, linux-man@vger.kernel.org

[CC linux-api, man pages]

On 02/02/2015 11:22 PM, Dave Hansen wrote:
> On 02/02/2015 08:55 AM, Mel Gorman wrote:
>> This patch identifies when a thread is frequently calling MADV_DONTNEED
>> on the same region of memory and starts ignoring the hint. On an 8-core
>> single-socket machine this was the impact on ebizzy using glibc 2.19.
> 
> The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
> called:
> 
>>      MADV_DONTNEED
>>               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
>>               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
>>               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.
> 
> So if we have anything depending on the behavior that it's _always_
> zero-filled after an MADV_DONTNEED, this will break it.

OK, so that's a third person (including me) who understood it as a zero-fill
guarantee. I think the man page should be clarified (if it's indeed not
guaranteed), or we have a bug.

The implementation actually skips MADV_DONTNEED for
VM_LOCKED|VM_HUGETLB|VM_PFNMAP vma's.

I'm not sure about VM_PFNMAP, these are probably special enough. For mlock, one
could expect that mlocking and MADV_DONTNEED would be in some opposition, but
it's not documented in the manpage AFAIK. Neither is the hugetlb case, which
could be really unexpected by the user.

Next, what the man page says about guarantees:

"The kernel is free to ignore the advice."

- that would suggest that nothing is guaranteed

"This call does not influence the semantics of the application (except in the
case of MADV_DONTNEED)"

- that depends if the reader understands it as "does influence by MADV_DONTNEED"
or "may influence by MADV_DONTNEED"

- btw, isn't MADV_DONTFORK another exception that does influence the semantics?
And since it's mentioned as a workaround for some hardware, is it OK to ignore
this advice?

And the part you already cited:

"Subsequent accesses of pages in this range will succeed, but will result either
in reloading of the memory contents from the underlying mapped file (see
mmap(2)) or zero-fill on-demand pages for mappings without an underlying file."

- The word "will result" did sound as a guarantee at least to me. So here it
could be changed to "may result (unless the advice is ignored)"?

And if we agree that there is indeed no guarantee, what's the actual semantic
difference from MADV_FREE? I guess none? So there's only a possible perfomance
difference?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
