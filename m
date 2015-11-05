Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id A9A0C82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 19:42:57 -0500 (EST)
Received: by oifu63 with SMTP id u63so38701918oif.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 16:42:57 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id j194si1879075oig.140.2015.11.04.16.42.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 16:42:56 -0800 (PST)
Received: by obbww6 with SMTP id ww6so27721482obb.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 16:42:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151105001348.GC7357@bbox>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org> <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
 <20151105001348.GC7357@bbox>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 4 Nov 2015 16:42:37 -0800
Message-ID: <CALCETrV0yd26+G_kvmRbJwjCNguUh6iLwhyO1yKQ2bgiiWegEw@mail.gmail.com>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, Shaohua Li <shli@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin wang <yalin.wang2010@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Mel Gorman <mgorman@suse.de>

On Wed, Nov 4, 2015 at 4:13 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Tue, Nov 03, 2015 at 07:41:35PM -0800, Andy Lutomirski wrote:
>> On Nov 3, 2015 5:30 PM, "Minchan Kim" <minchan@kernel.org> wrote:
>> >
>> > Linux doesn't have an ability to free pages lazy while other OS already
>> > have been supported that named by madvise(MADV_FREE).
>> >
>> > The gain is clear that kernel can discard freed pages rather than swapping
>> > out or OOM if memory pressure happens.
>> >
>> > Without memory pressure, freed pages would be reused by userspace without
>> > another additional overhead(ex, page fault + allocation + zeroing).
>> >
>>
>> [...]
>>
>> >
>> > How it works:
>> >
>> > When madvise syscall is called, VM clears dirty bit of ptes of the range.
>> > If memory pressure happens, VM checks dirty bit of page table and if it
>> > found still "clean", it means it's a "lazyfree pages" so VM could discard
>> > the page instead of swapping out.  Once there was store operation for the
>> > page before VM peek a page to reclaim, dirty bit is set so VM can swap out
>> > the page instead of discarding.
>>
>> What happens if you MADV_FREE something that's MAP_SHARED or isn't
>> ordinary anonymous memory?  There's a long history of MADV_DONTNEED on
>> such mappings causing exploitable problems, and I think it would be
>> nice if MADV_FREE were obviously safe.
>
> It filter out VM_LOCKED|VM_HUGETLB|VM_PFNMAP and file-backed vma and MAP_SHARED
> with vma_is_anonymous.
>
>>
>> Does this set the write protect bit?
>
> No.
>
>>
>> What happens on architectures without hardware dirty tracking?  For
>> that matter, even on architecture with hardware dirty tracking, what
>> happens in multithreaded processes that have the dirty TLB state
>> cached in a different CPU's TLB?
>>
>> Using the dirty bit for these semantics scares me.  This API creates a
>> page that can have visible nonzero contents and then can
>> asynchronously and magically zero itself thereafter.  That makes me
>> nervous.  Could we use the accessed bit instead?  Then the observable
>
> Access bit is used by aging algorithm for reclaim. In addition,
> we have supported clear_refs feacture.
> IOW, it could be reset anytime so it's hard to use marker for
> lazy freeing at the moment.
>

That's unfortunate.  I think that the ABI would be much nicer if it
used the accessed bit.

In any case, shouldn't the aging algorithm be irrelevant here?  A
MADV_FREE page that isn't accessed can be discarded, whereas we could
hopefully just say that a MADV_FREE page that is accessed gets moved
to whatever list holds recently accessed pages and also stops being a
candidate for discarding due to MADV_FREE?

>>
>> > +               if (!PageDirty(page) && (flags & TTU_FREE)) {
>> > +                       /* It's a freeable page by MADV_FREE */
>> > +                       dec_mm_counter(mm, MM_ANONPAGES);
>> > +                       goto discard;
>> > +               }
>>
>> Does something clear TTU_FREE the next time the page gets marked clean?
>
> Sorry, I don't understand. Could you elaborate it more?

I don't fully understand how TTU_FREE ends up being set here, but, if
the page is dirtied by user code and then cleaned later by the kernel,
what prevents TTU_FREE from being incorrectly set here?


--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
