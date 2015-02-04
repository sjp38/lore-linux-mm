Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id E85096B0073
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 08:46:04 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id w55so1833385wes.5
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 05:46:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hz2si3064778wjb.173.2015.02.04.05.46.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Feb 2015 05:46:03 -0800 (PST)
Message-ID: <54D22298.3040504@suse.cz>
Date: Wed, 04 Feb 2015 14:46:00 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
References: <20150202165525.GM2395@suse.de> <54CFF8AC.6010102@intel.com> <54D08483.40209@suse.cz> <20150203105301.GC14259@node.dhcp.inet.fi> <54D0B43D.8000209@suse.cz> <54D0F56A.9050003@gmail.com>
In-Reply-To: <54D0F56A.9050003@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-man@vger.kernel.org, Hugh Dickins <hughd@google.com>

On 02/03/2015 05:20 PM, Michael Kerrisk (man-pages) wrote:
> Hello Vlastimil
>
> Thanks for CCing me into this thread.

NP

> On 02/03/2015 12:42 PM, Vlastimil Babka wrote:
>> On 02/03/2015 11:53 AM, Kirill A. Shutemov wrote:
>>> On Tue, Feb 03, 2015 at 09:19:15AM +0100, Vlastimil Babka wrote:
>>>
>>> It doesn't skip. It fails with -EINVAL. Or I miss something.
>>
>> No, I missed that. Thanks for pointing out. The manpage also explains EINVAL in
>> this case:
>>
>> *  The application is attempting to release locked or shared pages (with
>> MADV_DONTNEED).
>
> Yes, there is that. But the page could be more explicit when discussing
> MADV_DONTNEED in the main text. I've done that.
>
>> - that covers mlocking ok, not sure if the rest fits the "shared pages" case
>> though. I dont see any check for other kinds of shared pages in the code.
>
> Agreed. "shared" here seems confused. I've removed it. And I've
> added mention of "Huge TLB pages" for this error.
>

Thanks.

>>>> - The word "will result" did sound as a guarantee at least to me. So here it
>>>> could be changed to "may result (unless the advice is ignored)"?
>>>
>>> It's too late to fix documentation. Applications already depends on the
>>> beheviour.
>>
>> Right, so as long as they check for EINVAL, it should be safe. It appears that
>> jemalloc does.
>
> So, first a brief question: in the cases where the call does not error out,
> are we agreed that in the current implementation, MADV_DONTNEED will
> always result in zero-filled pages when the region is faulted back in
> (when we consider pages that are not backed by a file)?

I'd agree at this point.
Also we should probably mention anonymously shared pages (shmem). I 
think they behave the same as file here.

>> I still wouldnt be sure just by reading the man page that the clearing is
>> guaranteed whenever I dont get an error return value, though,
>
> I'm not quite sure what you want here. I mean: if there's an error,

I was just reiterating that the guarantee is not clear from if you 
consider all the statements in the man page.

> then the DONTNEED action didn't occur, right? Therefore, there won't
> be zero-filled pages. But, for what it's worth, I added "If the
> operation succeeds" at the start of that sentence beginning "Subsequent
> accesses...".

Yes, that should clarify it. Thanks!

> Now, some history, explaining why the page is a bit of a mess,
> and for that matter why I could really use more help on it from MM
> folk (especially in the form of actual patches [1], rather than notes
> about deficiencies in the documentation), because:
>
>      ***I simply cannot keep up with all of the details***.

I see, and expected it would be like this. I would just send patch if 
the situation was clear, but here we should agree first, and I thought 
you should be involved from the beginning.

> Once upon a time (Linux 2.4), there was madvise() with just 5 flags:
>
>         MADV_NORMAL
>         MADV_RANDOM
>         MADV_SEQUENTIAL
>         MADV_WILLNEED
>         MADV_DONTNEED
>
> And already a dozen years ago, *I* added the text about MADV_DONTNEED.
> Back then, I believe it was true. I'm not sure if it's still true now,
> but I assume for the moment that it is, and await feedback. And the
> text saying that the call does not affect the semantics of memory
> access dates back even further (and was then true, MADV_DONTNEED aside).
>
> Those 5 flags have analogs in POSIX's posix_madvise() (albeit, there
> is a semantic mismatch between the destructive MADV_DONTNEED and
> POSIX's nondestructive POSIX_MADV_DONTNEED). They also appear
> on most other implementations.
>
> Since the original implementation, numerous pieces of cruft^W^W^W
> excellent new flags have been overloaded into this one system call.
> Some of those certainly violated the "does not change the semantics
> of the application" statement, but, sadly, the kernel developers who
> implemented MADV_REMOVE or MADV_DONTFORK did not think to send a
> patch to the man page for those new flags, one that might have noted
> that the semantics of the application are changed by such flags. Equally
> sadly, I did overlook to scan the bigger page when *I* added
> documentation of these flags to those pages, otherwise I might have
> caught that detail.
>
> So, just to repeat, I  could really use more help on it from MM
> folk in the form of actual patches to the man page.

Thanks for the background. I'll try to remember to check for man-pages 
part when I review some api changing patch.

> Thanks,
>
> Michael
>
> [1] https://www.kernel.org/doc/man-pages/patches.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
