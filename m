Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4405182F66
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 13:23:34 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so46260480obd.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 10:23:34 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id o8si1282890oig.109.2015.11.04.10.23.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 10:23:33 -0800 (PST)
Received: by obctp1 with SMTP id tp1so46332143obc.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 10:23:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56399CA5.8090101@gmail.com>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org> <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
 <56399CA5.8090101@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 4 Nov 2015 10:23:13 -0800
Message-ID: <CALCETrU5P-mmjf+8QuS3-pm__R02j2nnRc5B1gQkeC013XWNvA@mail.gmail.com>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, Shaohua Li <shli@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin wang <yalin.wang2010@gmail.com>, Mel Gorman <mgorman@suse.de>

On Tue, Nov 3, 2015 at 9:50 PM, Daniel Micay <danielmicay@gmail.com> wrote:
>> Does this set the write protect bit?
>>
>> What happens on architectures without hardware dirty tracking?
>
> It's supposed to avoid needing page faults when the data is accessed
> again, but it can just be implemented via page faults on architectures
> without a way to check for access or writes. MADV_DONTNEED is also a
> valid implementation of MADV_FREE if it comes to that (which is what it
> does on swapless systems for now).

I wonder whether arches without the requisite tracking should just
turn it off.  While it might be faster than MADV_DONTNEED or munmap on
those arches, it doesn't really deserve to be faster.

>
>> Using the dirty bit for these semantics scares me.  This API creates a
>> page that can have visible nonzero contents and then can
>> asynchronously and magically zero itself thereafter.  That makes me
>> nervous.  Could we use the accessed bit instead?  Then the observable
>> semantics would be equivalent to having MADV_FREE either zero the page
>> or do nothing, except that it doesn't make up its mind until the next
>> read.
>
> FWIW, those are already basically the semantics provided by GCC and LLVM
> for data the compiler considers uninitialized (they could be more
> aggressive since C just says it's undefined, but in practice they allow
> it but can produce inconsistent results even if it isn't touched).
>
> http://llvm.org/docs/LangRef.html#undefined-values

But C isn't the only thing in the world.  Also, I think that a C
optimizer should be free to turn:

if ([complicated condition])
  *ptr = 1;

into:

if (*ptr != 1 && [complicated condition])
  *ptr = 1;

as long as [complicated condition] has no side effects.  The MADV_FREE
semantics in this patch set break that.

>
> It doesn't seem like there would be an advantage to checking if the data
> was written to vs. whether it was accessed if checking for both of those
> is comparable in performance. I don't know enough about that.

I'd imagine that there would be no performance difference whatsoever
on hardware that has a real accessed bit.  The only thing that changes
is the choice of which bit to use.

>
>>> +                       ptent = pte_mkold(ptent);
>>> +                       ptent = pte_mkclean(ptent);
>>> +                       set_pte_at(mm, addr, pte, ptent);
>>> +                       tlb_remove_tlb_entry(tlb, pte, addr);
>>
>> It looks like you are flushing the TLB.  In a multithreaded program,
>> that's rather expensive.  Potentially silly question: would it be
>> better to just zero the page immediately in a multithreaded program
>> and then, when swapping out, check the page is zeroed and, if so, skip
>> swapping it out?  That could be done without forcing an IPI.
>
> In the common case it will be passed many pages by the allocator. There
> will still be a layer of purging logic on top of MADV_FREE but it can be
> much thinner than the current workarounds for MADV_DONTNEED. So the
> allocator would still be coalescing dirty ranges and only purging when
> the ratio of dirty:clean pages rises above some threshold. It would be
> able to weight the largest ranges for purging first rather than logic
> based on stuff like aging as is used for MADV_DONTNEED.
>

With enough pages at once, though, munmap would be fine, too.

Maybe what's really needed is a MADV_FREE variant that takes an iovec.
On an all-cores multithreaded mm, the TLB shootdown broadcast takes
thousands of cycles on each core more or less regardless of how much
of the TLB gets zapped.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
