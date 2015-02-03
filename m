Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id D60EB6B006E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 11:21:04 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id l2so45550839wgh.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 08:21:04 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id n6si29815101wiw.69.2015.02.03.08.21.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 08:21:03 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id y19so45478352wgg.11
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 08:21:03 -0800 (PST)
Message-ID: <54D0F56A.9050003@gmail.com>
Date: Tue, 03 Feb 2015 17:20:58 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
References: <20150202165525.GM2395@suse.de> <54CFF8AC.6010102@intel.com> <54D08483.40209@suse.cz> <20150203105301.GC14259@node.dhcp.inet.fi> <54D0B43D.8000209@suse.cz>
In-Reply-To: <54D0B43D.8000209@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: mtk.manpages@gmail.com, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-man@vger.kernel.org, Hugh Dickins <hughd@google.com>

Hello Vlastimil

Thanks for CCing me into this thread.

On 02/03/2015 12:42 PM, Vlastimil Babka wrote:
> On 02/03/2015 11:53 AM, Kirill A. Shutemov wrote:
>> On Tue, Feb 03, 2015 at 09:19:15AM +0100, Vlastimil Babka wrote:
>>> [CC linux-api, man pages]
>>>
>>> On 02/02/2015 11:22 PM, Dave Hansen wrote:
>>>> On 02/02/2015 08:55 AM, Mel Gorman wrote:
>>>>> This patch identifies when a thread is frequently calling MADV_DONTNEED
>>>>> on the same region of memory and starts ignoring the hint. On an 8-core
>>>>> single-socket machine this was the impact on ebizzy using glibc 2.19.
>>>>
>>>> The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
>>>> called:
>>>>
>>>>>      MADV_DONTNEED
>>>>>               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
>>>>>               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
>>>>>               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.
>>>>
>>>> So if we have anything depending on the behavior that it's _always_
>>>> zero-filled after an MADV_DONTNEED, this will break it.
>>>
>>> OK, so that's a third person (including me) who understood it as a zero-fill
>>> guarantee. I think the man page should be clarified (if it's indeed not
>>> guaranteed), or we have a bug.
>>>
>>> The implementation actually skips MADV_DONTNEED for
>>> VM_LOCKED|VM_HUGETLB|VM_PFNMAP vma's.
>>
>> It doesn't skip. It fails with -EINVAL. Or I miss something.
> 
> No, I missed that. Thanks for pointing out. The manpage also explains EINVAL in
> this case:
> 
> *  The application is attempting to release locked or shared pages (with
> MADV_DONTNEED).

Yes, there is that. But the page could be more explicit when discussing
MADV_DONTNEED in the main text. I've done that.

> - that covers mlocking ok, not sure if the rest fits the "shared pages" case
> though. I dont see any check for other kinds of shared pages in the code.

Agreed. "shared" here seems confused. I've removed it. And I've
added mention of "Huge TLB pages" for this error.

>>> - The word "will result" did sound as a guarantee at least to me. So here it
>>> could be changed to "may result (unless the advice is ignored)"?
>>
>> It's too late to fix documentation. Applications already depends on the
>> beheviour.
> 
> Right, so as long as they check for EINVAL, it should be safe. It appears that
> jemalloc does.

So, first a brief question: in the cases where the call does not error out,
are we agreed that in the current implementation, MADV_DONTNEED will
always result in zero-filled pages when the region is faulted back in
(when we consider pages that are not backed by a file)?

> I still wouldnt be sure just by reading the man page that the clearing is
> guaranteed whenever I dont get an error return value, though,

I'm not quite sure what you want here. I mean: if there's an error,
then the DONTNEED action didn't occur, right? Therefore, there won't
be zero-filled pages. But, for what it's worth, I added "If the
operation succeeds" at the start of that sentence beginning "Subsequent
accesses...".

Now, some history, explaining why the page is a bit of a mess,
and for that matter why I could really use more help on it from MM
folk (especially in the form of actual patches [1], rather than notes
about deficiencies in the documentation), because:

    ***I simply cannot keep up with all of the details***.

Once upon a time (Linux 2.4), there was madvise() with just 5 flags:

       MADV_NORMAL
       MADV_RANDOM
       MADV_SEQUENTIAL
       MADV_WILLNEED
       MADV_DONTNEED

And already a dozen years ago, *I* added the text about MADV_DONTNEED.
Back then, I believe it was true. I'm not sure if it's still true now,
but I assume for the moment that it is, and await feedback. And the 
text saying that the call does not affect the semantics of memory 
access dates back even further (and was then true, MADV_DONTNEED aside).

Those 5 flags have analogs in POSIX's posix_madvise() (albeit, there
is a semantic mismatch between the destructive MADV_DONTNEED and
POSIX's nondestructive POSIX_MADV_DONTNEED). They also appear
on most other implementations.

Since the original implementation, numerous pieces of cruft^W^W^W
excellent new flags have been overloaded into this one system call.
Some of those certainly violated the "does not change the semantics
of the application" statement, but, sadly, the kernel developers who
implemented MADV_REMOVE or MADV_DONTFORK did not think to send a
patch to the man page for those new flags, one that might have noted
that the semantics of the application are changed by such flags. Equally
sadly, I did overlook to scan the bigger page when *I* added 
documentation of these flags to those pages, otherwise I might have 
caught that detail.

So, just to repeat, I  could really use more help on it from MM
folk in the form of actual patches to the man page.

Thanks,

Michael

[1] https://www.kernel.org/doc/man-pages/patches.html

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
